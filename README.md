# HomeBench Pro Build Kit v3.1

Replaces the TradeFlow Build Kit v2 in full. HomeBench Pro is the contractor operating system inside HomeBench and the first thing HomeBench ships (Blueprint D19).

## What is in here
- `CLAUDE.md`: the constitution Claude Code reads every session.
- `docs/phases/`: M0 to M6 milestone specs plus ROADMAP_AFTER_PRO.md.
- `docs/DECISIONS_LOG.md`: source of truth #1, seeded with PD-001 to PD-014.
- `docs/TASKS.md`, `PROGRESS.md`, `BLOCKERS.md`, `PARKING_LOT.md`, `CHANGELOG.md`, `PHASE_SIGNOFF.md`: the agent's working ledgers.
- `scripts/autorun.sh`: the unattended runner (one headless Claude Code session per task, PR + auto-merge on green CI, phone alerts).
- `.claude/settings.json`: hard deny rules (no production, no hosted database, no force push).
- `setup/user-settings.autoMode.json`: auto mode trust config that goes in `~/.claude/settings.json` (auto mode ignores it in the repo).
- `setup/RELAY_START_PLAN.md`: step-by-step start (any computer) and hand-off to the MacBook, plain language.
- `setup/STARTER_PROMPTS.md`: the exact prompts, copy from here.
- `setup/ACCESS_APPLICATIONS.md`: integrations with approval lead times; start them now.
- `claude-project/HANDOFF_TEMPLATE.md`: end-of-milestone handoff with Supabase spot-check.
- `.github/workflows/ci.yml`: starter CI so the required `ci` check exists from the first push.

## The loop, per milestone
1. `./scripts/autorun.sh plan M0` writes the plan, the task ledger, and a one-page summary, then pings your phone.
2. You review, paste the plan into the HomeBench Project ("Review M0 plan"), and run `./scripts/autorun.sh approve M0`.
3. The runner builds every task unattended and pings you only for blockers, repeated CI failure, or completion.
4. You open the staging preview, run the handoff's Supabase spot-check SQL, and sign `docs/PHASE_SIGNOFF.md` (the agent can prepare that PR for you).
5. Next milestone: `./scripts/autorun.sh plan M1`.

After M3, the Usable Product Gate decides when marketing, the public name, and the consumer track begin.
