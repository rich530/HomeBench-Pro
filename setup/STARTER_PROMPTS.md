# HomeBench Pro: Starter Prompts (copy from here, not from a PDF)

| Prompt | Where it goes | When |
|---|---|---|
| PROMPT 1 | Claude Code on the web (claude.ai/code), repo rich530/homebench | Relay plan Step 11 |
| PROMPT 2 | A NEW chat in the HomeBench - Build HQ Project | Step 13 |
| PROMPT 3 | The SAME Claude Code web session as Prompt 1 | Step 14, only if the review has notes |
| PROMPT 4 | Terminal on the MacBook, logged in as hbbuild, inside tmux | Step 28 |

---

## PROMPT 1: Write the M0 plan (Claude Code on the web)

```
You are starting HomeBench Pro milestone M0 in a Claude Code cloud session. This session is PLANNING ONLY. The build itself will run later, unattended, on Rich's MacBook through scripts/autorun.sh, which will read what you write here.

First read these files completely: CLAUDE.md, docs/DECISIONS_LOG.md, docs/PROGRESS.md, docs/TASKS.md (the format rules at the top are strict because a script parses them), docs/phases/M0_FOUNDATION.md, and scripts/autorun.sh (so you understand how tasks will be run).

For this session only, ignore the CLAUDE.md rules about one-task sessions, gh commands, and the PR finish sequence. Every other rule in CLAUDE.md applies.

Do these three things:

1. Write docs/plans/M0_PLAN.md with:
   - the full schema: every table, column, type, key, index, and RLS policy, including organizations.kind, job_access, the *_financials money segregation, audit_log, and the empty HomeBench-ready tables (job_materials, installed_assets, callbacks, cost_references, incentive_programs, incentive_rules, building_income_profile, incentive_lines, application_packets);
   - routes and screens as ASCII wireframes;
   - the CI and GitHub Actions design (ci.yml with a final job named "ci", staging-migrate.yml, prod-migrate.yml) and exactly which secrets each uses;
   - a test plan that maps every line of the M0 acceptance checklist to a named automated test;
   - risks;
   - every input Rich must provide (files, credentials, accounts, settings), with the task number that needs it.

2. Write the M0 task ledger into docs/TASKS.md under a heading "## M0", in the exact line format:
   - [ ] T-001 Short name | accept: the test or evidence that proves it is done
   Rules for the ledger:
   - tasks are small enough for one session (about 1 to 3 hours of agent work) and ordered so each task only depends on earlier ones;
   - T-001 is the Next.js + Supabase local scaffold and extends the existing .github/workflows/ci.yml, keeping a final job with the id "ci";
   - early tasks must not need any hosted service or secret;
   - any task that needs something from Rich says so in its name;
   - number them T-001, T-002, and so on, and make the last task exactly: - [ ] T-900 M0 acceptance run and handoff | accept: PHASE_SIGNOFF.md, CHANGELOG.md, docs/handoffs/M0_HANDOFF.md with Supabase spot-check SQL

3. Write docs/plans/M0_REVIEW_SUMMARY.md: one page in plain English for a non-developer owner. Cover what gets built, what Rich will be able to do when M0 is done, what he must provide and when, and the top 5 risks.

Also append one line to docs/PROGRESS.md: today's date | M0 plan and task ledger written in a cloud session | no code.

Rules for this session:
- Do not write application code.
- Do not run npm install, supabase, or docker.
- Do not edit CLAUDE.md or any file in docs/phases/.
- If you make a decision the files do not cover, add it to docs/DECISIONS_LOG.md as a line tagged AGENT with a one-line reason.

When finished:
- commit with the message "M0 plan and task ledger" and push your branch;
- then reply with a 5-line summary and the total number of tasks;
- then print the full contents of docs/plans/M0_PLAN.md;
- then print the full "## M0" section of docs/TASKS.md, so Rich can copy them for review.
```

---

## PROMPT 2: Review the plan (new chat in the HomeBench - Build HQ Project)

```
Review M0 plan.

Context: Build Kit v3.1 is in rich530/homebench. Claude Code on the web wrote this plan and task ledger. After approval it is merged to main and built unattended on the MacBook by scripts/autorun.sh, one task per session, with PR + auto-merge on green CI.

Check it against CLAUDE.md, M0_FOUNDATION.md, and DECISIONS_LOG.md in Project knowledge. Specifically:
- scope creep;
- missing business rules;
- weak data model (RLS on every table, money segregation, platform org + job_access, audit, immutability);
- task sizing and order (each task one session, dependency-safe, early tasks need no hosted services);
- whether every acceptance line has a named test;
- whether the TASKS.md lines match the exact format autorun.sh parses: "- [ ] T-001 Name | accept: ...", ending with T-900.

Give me the verdict first: APPROVE, APPROVE WITH NOTES, or REJECT. If there are notes, give them as ONE copy-ready block I can paste into Prompt 3.

M0_PLAN.md:
[paste the plan here]

TASKS.md, ## M0 section:
[paste the task list here]
```

---

## PROMPT 3: Apply the review notes (same Claude Code web session)

```
Apply these review notes from the HomeBench Project exactly. Change only docs/plans/M0_PLAN.md, the "## M0" section of docs/TASKS.md, and docs/plans/M0_REVIEW_SUMMARY.md. Log each change as a line tagged RICH in docs/DECISIONS_LOG.md. Do not write application code. Keep the exact TASKS.md line format and keep T-900 as the last task.

When finished, commit with the message "M0 plan revised per review", push to the same branch, reply with a list of what changed, then print the full updated docs/plans/M0_PLAN.md and the full "## M0" section of docs/TASKS.md.

REVIEW NOTES:
[paste the notes block here]
```

---

## PROMPT 4: Take the baton and build (MacBook Terminal, as hbbuild)

First, open the build window (paste, press Enter):

```
cd ~/homebench && tmux new -s build
```

Then start the build (paste, press Enter):

```
caffeinate -i ./scripts/autorun.sh approve M0
```

Watch until you see "Session start: T-001". Then hold Control, press b, let go, and press d. The build keeps running after you leave.

---

## Later: the next milestone (MacBook Terminal)

```
cd ~/homebench && ./scripts/autorun.sh plan M1
```
