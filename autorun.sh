#!/usr/bin/env bash
# HomeBench Pro unattended build runner (build kit v3).
# Runs Claude Code headless, one task per fresh session, one branch per task,
# PR + auto-merge on green CI, phone notification when it needs Rich.
#
# Usage (run from the repo root):
#   ./scripts/autorun.sh plan M0            # agent writes docs/plans/M0_PLAN.md + docs/TASKS.md, opens PR, stops
#   ./scripts/autorun.sh revise M0 "notes"  # agent revises the plan with your notes
#   ./scripts/autorun.sh approve M0         # you approve the plan; the build starts immediately
#   ./scripts/autorun.sh build              # resume building the current milestone
#   ./scripts/autorun.sh unblock T-014      # after you supplied what a blocked task needed
#   ./scripts/autorun.sh status             # where things stand
#   ./scripts/autorun.sh stop               # finish the current task, then stop
#
# Optional environment variables (put them in ~/.homebench-autorun.env):
#   NTFY_TOPIC=your-secret-topic   phone alerts through the free ntfy app
#   MAX_TASKS=40                   max tasks per run
#   FIX_ATTEMPTS=2                 CI fix attempts per task before stopping
#   TASK_TIMEOUT_MIN=180           hard cap per session (needs gtimeout from brew coreutils)
#   LIMIT_SLEEP_MIN=30             wait when usage limits are hit
#   MERGE_WAIT_MIN=60              how long to wait for CI + auto-merge

set -uo pipefail

[ -f "$HOME/.homebench-autorun.env" ] && . "$HOME/.homebench-autorun.env"
MAX_TASKS="${MAX_TASKS:-40}"
FIX_ATTEMPTS="${FIX_ATTEMPTS:-2}"
TASK_TIMEOUT_MIN="${TASK_TIMEOUT_MIN:-180}"
LIMIT_SLEEP_MIN="${LIMIT_SLEEP_MIN:-30}"
MERGE_WAIT_MIN="${MERGE_WAIT_MIN:-60}"
NTFY_TOPIC="${NTFY_TOPIC:-}"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "Run this inside the homebench repo."; exit 1; }
cd "$ROOT" || exit 1
STATE_DIR="$ROOT/.autorun"
LOG_DIR="$STATE_DIR/logs"
mkdir -p "$LOG_DIR"

CMD="${1:-status}"
ARG2="${2:-}"
ARG3="${3:-}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_DIR/runner.log"; }

notify() {
  local msg="HomeBench Pro: $*"
  log "NOTIFY: $msg"
  command -v osascript >/dev/null 2>&1 && osascript -e "display notification \"${msg//\"/}\" with title \"HomeBench autorun\"" >/dev/null 2>&1
  if [ -n "$NTFY_TOPIC" ]; then curl -s -m 10 -d "$msg" "https://ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1; fi
}

milestone() {
  if [ -n "$ARG2" ] && [[ "$ARG2" =~ ^M[0-9]+$ ]]; then echo "$ARG2"
  elif [ -f "$STATE_DIR/current" ]; then cat "$STATE_DIR/current"
  else cat docs/CURRENT_MILESTONE 2>/dev/null || echo "M0"; fi
}

phase_file() { ls docs/phases/"$1"_*.md 2>/dev/null | head -n1; }

preflight() {
  local ok=1
  for bin in git gh jq claude; do command -v "$bin" >/dev/null 2>&1 || { echo "Missing: $bin (see setup/RELAY_START_PLAN.md)"; ok=0; }; done
  gh auth status >/dev/null 2>&1 || { echo "GitHub CLI not logged in: run 'gh auth login'"; ok=0; }
  if [ -f supabase/config.toml ]; then
    command -v supabase >/dev/null 2>&1 || { echo "Missing: supabase CLI"; ok=0; }
    docker info >/dev/null 2>&1 || { echo "Docker is not running. Open Docker Desktop."; ok=0; }
    [ "$ok" = 1 ] && { supabase status >/dev/null 2>&1 || supabase start >/dev/null 2>&1 || { echo "supabase start failed"; ok=0; }; }
  fi
  if [ -n "$(git status --porcelain --untracked-files=no)" ]; then echo "Working tree has uncommitted changes. Commit or stash them first."; ok=0; fi
  [ "$ok" = 1 ] || exit 1
}

sync_main() { git fetch -q origin && git checkout -q main && git pull -q --ff-only origin main; }

# Run one headless Claude Code session. Returns 0 ok, 75 usage/rate limit, other = failure.
run_claude() {
  local label="$1" prompt="$2"
  local out="$LOG_DIR/$(date '+%Y%m%d-%H%M%S')-$label.json"
  local runner=(claude -p "$prompt" --permission-mode auto --permission-prompts none --output-format json)
  command -v caffeinate >/dev/null 2>&1 && runner=(caffeinate -i "${runner[@]}")
  command -v gtimeout >/dev/null 2>&1 && runner=(gtimeout "$((TASK_TIMEOUT_MIN*60))" "${runner[@]}")
  log "Session start: $label (log $out)"
  "${runner[@]}" > "$out" 2>>"$LOG_DIR/runner.log"
  local code=$?
  local is_err result cost
  is_err="$(jq -r '.is_error // false' "$out" 2>/dev/null || echo true)"
  result="$(jq -r '.result // ""' "$out" 2>/dev/null | head -c 400)"
  cost="$(jq -r '.total_cost_usd // 0' "$out" 2>/dev/null || echo 0)"
  log "Session end: $label exit=$code error=$is_err est_cost=\$$cost"
  if echo "$result" | grep -qiE 'usage limit|rate limit|limit reached|overloaded'; then return 75; fi
  if [ "$code" -ne 0 ] || [ "$is_err" = "true" ]; then log "Result: $result"; return 1; fi
  return 0
}

# 0 merged, 2 CI failed, 3 no PR, 4 timed out
wait_for_merge() {
  local br="$1" waited=0 state buckets
  gh pr view "$br" --json state >/dev/null 2>&1 || return 3
  while [ "$waited" -lt "$((MERGE_WAIT_MIN*60))" ]; do
    state="$(gh pr view "$br" --json state -q .state 2>/dev/null)"
    [ "$state" = "MERGED" ] && return 0
    buckets="$(gh pr checks "$br" --json bucket -q '[.[].bucket] | unique | join(",")' 2>/dev/null)"
    if echo "$buckets" | grep -q "fail"; then return 2; fi
    sleep 60; waited=$((waited+60))
  done
  return 4
}

task_line() { grep -m1 -E "^- \[.\] $1 " docs/TASKS.md; }
next_task() { grep -m1 -E '^- \[ \] T-[0-9]+' docs/TASKS.md | sed -E 's/^- \[ \] (T-[0-9]+).*/\1/'; }
count_state() { grep -cE "^- \[$1\] T-" docs/TASKS.md 2>/dev/null || true; }

base_rules() {
  local m="$1"
  cat <<EOF
You are running UNATTENDED through scripts/autorun.sh. No human is available to answer questions; do not ask any.
First read: CLAUDE.md, docs/DECISIONS_LOG.md, the last 60 lines of docs/PROGRESS.md, $(phase_file "$m"), and docs/plans/${m}_PLAN.md if it exists.
Follow CLAUDE.md section 4 exactly (one task only, stop conditions, BLOCKED format, STUBBED rule, tests before commit, never force push, never touch staging or production, never supabase link or db push).
EOF
}

finish_rules() {
  cat <<'EOF'
Finish by: committing, pushing this branch, running `gh pr create --fill --base main` (skip if a PR already exists), then `gh pr merge --auto --squash`. Then end the session with a 3-line summary.
EOF
}

do_plan() {
  local m; m="$(milestone)"; local br="plan/$m"
  preflight; sync_main
  git checkout -q -B "$br"
  local p
  p="$(base_rules "$m")
TASK: Write docs/plans/${m}_PLAN.md for milestone $m: schema (tables, columns, RLS policies), routes, screens as ASCII wireframes, engine functions with formulas and hand-calculated fixtures where money is involved, test plan mapped to every acceptance checklist line, risks, and every input Rich must provide (files, credentials, accounts) with the date it is needed.
Then write the task ledger for $m into docs/TASKS.md under a heading '## $m', in the exact format described at the top of that file: small tasks, dependency-ordered, each with its acceptance evidence, numbered from T-001 (or continuing the last number), and a final task 'T-9xx $m acceptance run and handoff'.
Also write docs/plans/${m}_REVIEW_SUMMARY.md: one page in plain English for a non-developer owner: what gets built, what he will be able to do when it is done, what he must provide and when, the top 5 risks.
Do not write application code in this session.
$(finish_rules)"
  run_claude "plan-$m" "$p"; local rc=$?
  [ "$rc" -eq 75 ] && { notify "Usage limit hit while planning $m. Re-run plan later."; exit 1; }
  [ "$rc" -ne 0 ] && { notify "Planning $m failed. See .autorun/logs."; exit 1; }
  wait_for_merge "$br"; rc=$?
  [ "$rc" -ne 0 ] && { notify "Plan PR for $m did not merge (code $rc). Check GitHub."; exit 1; }
  sync_main
  notify "Plan for $m is ready. Read docs/plans/${m}_REVIEW_SUMMARY.md, paste the plan into the HomeBench Project ('Review M-plan'), then run: ./scripts/autorun.sh approve $m"
}

do_revise() {
  local m; m="$(milestone)"; local notes="$ARG3"; local br="plan/$m-rev-$(date +%H%M%S)"
  [ -z "$notes" ] && { echo "Usage: autorun.sh revise $m \"your notes\""; exit 1; }
  preflight; sync_main; git checkout -q -B "$br"
  local p
  p="$(base_rules "$m")
TASK: Revise docs/plans/${m}_PLAN.md, docs/TASKS.md (only the '## $m' section, only tasks not yet done), and docs/plans/${m}_REVIEW_SUMMARY.md to apply these notes from Rich exactly: $notes
Log each change as a RICH decision in docs/DECISIONS_LOG.md. Do not write application code.
$(finish_rules)"
  run_claude "revise-$m" "$p" && wait_for_merge "$br" && sync_main && notify "Plan $m revised. Review, then approve." || notify "Plan revision for $m failed. See logs."
}

do_approve() {
  local m; m="$(milestone)"
  [ -f "docs/plans/${m}_PLAN.md" ] || { sync_main; }
  [ -f "docs/plans/${m}_PLAN.md" ] || { echo "No docs/plans/${m}_PLAN.md yet. Run plan first."; exit 1; }
  date '+%Y-%m-%d %H:%M' > "$STATE_DIR/approved_$m"
  echo "$m" > "$STATE_DIR/current"
  log "Plan $m approved by Rich."
  ARG2="$m"; do_build
}

do_unblock() {
  local id="$ARG2"; [[ "$id" =~ ^T-[0-9]+$ ]] || { echo "Usage: autorun.sh unblock T-014"; exit 1; }
  preflight; sync_main
  task_line "$id" | grep -q '^- \[~\]' || { echo "$id is not blocked."; exit 1; }
  local br="unblock/$id"; git checkout -q -B "$br"
  sed -i.bak -E "s/^- \[~\] ($id .*) BLOCKED:.*/- [ ] \1/" docs/TASKS.md && rm -f docs/TASKS.md.bak
  echo "$(date '+%Y-%m-%d') | $id unblocked by Rich" >> docs/PROGRESS.md
  git commit -qam "Unblock $id" && git push -q -u origin "$br" && gh pr create --fill --base main >/dev/null && gh pr merge --auto --squash "$br" >/dev/null
  wait_for_merge "$br" && sync_main && log "$id unblocked." || notify "Unblock PR for $id did not merge."
}

do_build() {
  local m; m="$(milestone)"
  [ -f "$STATE_DIR/approved_$m" ] || { echo "Plan $m is not approved. Run: ./scripts/autorun.sh approve $m"; exit 1; }
  preflight
  rm -f "$STATE_DIR/STOP"
  local done_count=0
  notify "Build started for $m."
  while :; do
    [ -f "$STATE_DIR/STOP" ] && { notify "Stopped on request after $done_count tasks."; exit 0; }
    [ "$done_count" -ge "$MAX_TASKS" ] && { notify "Reached MAX_TASKS=$MAX_TASKS. Run build again to continue."; exit 0; }
    sync_main
    local id; id="$(next_task)"
    if [ -z "$id" ]; then
      notify "$m queue empty: $(count_state x) done, $(count_state '~') blocked. Handoff: docs/handoffs/${m}_HANDOFF.md. Run the Supabase spot-check and sign off."
      exit 0
    fi
    local blocked_before; blocked_before="$(count_state '~')"
    local br="task/$m-$id"
    git checkout -q -B "$br"
    local p
    p="$(base_rules "$m")
TASK: Execute ONLY this task from docs/TASKS.md: $(task_line "$id")
You are on branch $br. When done, mark it [x] (or [~] BLOCKED per CLAUDE.md 4.4) in docs/TASKS.md and append to docs/PROGRESS.md.
$(finish_rules)"
    local rc tries=0
    while :; do
      run_claude "$id" "$p"; rc=$?
      if [ "$rc" -eq 75 ]; then log "Usage limit. Sleeping $LIMIT_SLEEP_MIN min."; sleep "$((LIMIT_SLEEP_MIN*60))"; continue; fi
      break
    done
    if [ "$rc" -ne 0 ]; then
      tries=$((tries+1))
      run_claude "$id-retry" "$p"; rc=$?
      [ "$rc" -ne 0 ] && { notify "Task $id failed twice in session. Stopped. See .autorun/logs."; exit 1; }
    fi
    local fix=0 mrc
    while :; do
      wait_for_merge "$br"; mrc=$?
      [ "$mrc" -eq 0 ] && break
      if [ "$mrc" -eq 2 ] && [ "$fix" -lt "$FIX_ATTEMPTS" ]; then
        fix=$((fix+1))
        git checkout -q "$br" && git pull -q origin "$br"
        run_claude "$id-cifix$fix" "$(base_rules "$m")
TASK: CI failed on the pull request for branch $br (task $id). Run 'gh pr checks $br' and 'gh run view --log-failed' to read the failures. Fix them on this branch without weakening or skipping tests, rerun the checks locally, commit, and push. Auto-merge is already enabled; if not, run 'gh pr merge --auto --squash'."
        continue
      fi
      notify "Task $id did not merge (code $mrc: 2=CI failing, 3=no PR, 4=timeout). Stopped."
      exit 1
    done
    sync_main
    if task_line "$id" | grep -q '^- \[ \]'; then notify "Task $id merged but was not marked done. Stopped to avoid a loop."; exit 1; fi
    local blocked_after; blocked_after="$(count_state '~')"
    [ "$blocked_after" -gt "$blocked_before" ] && notify "New blocker on $id. See docs/BLOCKERS.md. Build continues with the next task."
    done_count=$((done_count+1))
    log "Task $id complete ($done_count this run)."
  done
}

do_status() {
  local m; m="$(milestone)"
  echo "Milestone: $m   Plan approved: $([ -f "$STATE_DIR/approved_$m" ] && cat "$STATE_DIR/approved_$m" || echo no)"
  echo "Tasks: $(count_state x) done, $(count_state ' ') open, $(count_state '~') blocked"
  echo "Next: $(next_task)"
  echo "--- last progress lines ---"; tail -n 12 docs/PROGRESS.md 2>/dev/null
  echo "--- blockers ---"; grep -E '^- \[~\]' docs/TASKS.md 2>/dev/null || echo "none"
}

case "$CMD" in
  plan) do_plan ;;
  revise) do_revise ;;
  approve) do_approve ;;
  build) do_build ;;
  unblock) do_unblock ;;
  status) do_status ;;
  stop) touch "$STATE_DIR/STOP"; echo "Will stop after the current task." ;;
  *) echo "Unknown command: $CMD"; exit 1 ;;
esac
