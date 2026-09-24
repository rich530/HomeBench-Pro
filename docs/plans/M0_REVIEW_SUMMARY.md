# M0 Review Summary (for Rich)

**What M0 is:** the foundation. Nothing you'd use to price a job yet. M0 builds the locked, multi-company base that everything else sits on. It covers logins and roles, a data wall between companies, an audit trail, a minimum job/customer/site CRM, and the automatic path that carries database changes to staging. 28 tasks, each one unattended overnight session on the MacBook.

## What gets built
- **Logins and roles.** You sign in with a password or an emailed link, and you invite people by role (owner, estimator, PM, crew lead, crew member, office, and others). Until email sending is set up, the invite link appears on screen for you to copy and send.
- **Walls between companies.** Every row of data belongs to one company. Automated tests check every table and prove Company A can't see, add, change, or delete Company B's data. When a new table gets added later, the tests fail until that table is covered too.
- **Money kept separate.** Dollar amounts (estimated value, NTE, insurance ACV/RCV, costs) are stored in separate "financials" tables. Crew, subs, and viewers get zero rows from those tables, and a test proves it.
- **HomeBench access switch.** The HomeBench platform can see a Committed job only after you share that job with it. Revoking the share removes access. This is the future marketplace plumbing, built in from day one.
- **Audit trail.** Changes to jobs, money fields, memberships, settings, and sharing are recorded with who made the change, when, and the before and after values. The trail can't be edited or deleted.
- **CRM minimum:** commercial accounts with regions and sites; residential customers and sites with property details (year built, and a pre-1978 flag that treats an unknown year as pre-1978 to be safe); contacts with texting and email consent; jobs numbered CC-2026-0001 and up, with type, contract type, rep/estimator/PM, client PO and work-order numbers for commercial, insurance fields, and Wisconsin compliance dates; callbacks linked to the original job; notes, calls, and tasks; photos and files that keep their time and GPS.
- **Screens:** role-based home pages (owner, estimator, PM, crew placeholder), pipeline board and table with saved filters, a one-form "new job" screen that flags duplicates (target: under 60 seconds), job detail with tabs, Ctrl+K search across everything, and a platform admin area. Everything works on a phone at 360px width.
- **Pipeline:** every change is tested automatically, and on merge to main CI applies database changes to homebench-staging by itself. Production changes happen only when you approve a merge to `production`.

## What you can do when M0 is done
1. Log in on staging, invite your team, and assign their roles.
2. Add a customer, site, and job from one form in under a minute, and see duplicates before you create them.
3. Run the pipeline board and move jobs through stages. Every move is logged.
4. Set up a commercial account with regions and sites, and log a service ticket with its PO and work-order number.
5. Link a callback to the original job.
6. Crew accounts see job and site info with no dollars anywhere.

## What you need to provide, and when
| When | What |
|---|---|
| **Before `approve M0`** | GitHub settings from the relay plan Steps 4–6: branch protection on `main` requiring `ci`, auto-merge on, and a protected `production` branch. |
| **Before `approve M0`** | On the MacBook, clone with `cd ~ && gh repo clone rich530/HomeBench-Pro homebench`. Step 24 of the relay plan says `rich530/homebench`, but your repo is named HomeBench-Pro. |
| Around task T-010 (not urgent) | The free HUD ZIP-to-CBSA file from HUD USER, saved in `data/seeds/`. A 40-ZIP Southeast Wisconsin set runs in the meantime. |
| By task T-027 | GitHub secrets `SUPABASE_ACCESS_TOKEN`, `STAGING_PROJECT_REF`, and `STAGING_DB_PASSWORD` (relay Step 8), plus two new ones: `STAGING_SUPABASE_URL` and `STAGING_SERVICE_ROLE_KEY`. Those two let a one-click "staging-bootstrap" action create Committed on staging and email you an owner invite. |
| Before final M0 check | Vercel connected with the staging and prod keys (relay Stage 3). In Supabase staging, set the Auth "Site URL" to the staging preview address. |
| Before M1 starts | Your real numbers: margin target and floor by work type, minimum job charge, trip charge, productive ratio, payment terms, fiscal year start, and Committed's legal name/DBA. M0 fills these with sample values marked "sample". |
| At review | Confirm or edit the pipeline stages (rebuilt from scratch because the TradeFlow v2 stage list isn't in the repo). Also confirm the provisional incentive (O14) table columns, or add Blueprint §3 to the repo. |

## Top 5 risks
1. **Data leaking between companies.** This is the one that could kill the marketplace idea. It's covered by database-level locks plus tests that check every table automatically.
2. **Slow or flaky CI stalls the overnight build.** The runner stops after 2 failed CI fixes. CI runs only the database services it needs, versions are pinned, and failures get root-caused, never skipped.
3. **Setup gaps stop the runner on night one.** The kit upload had flattened every folder, and the task list format would have made the runner loop. Both are fixed in this session. The repo-name clone command above is the one remaining item.
4. **Staging can't be verified because keys or Vercel aren't set up yet.** The build still finishes, and the handoff lists exactly which keys are missing.
5. **Scope creep.** Texting, email automations, and estimating all wait for their milestones. New ideas go to the Parking Lot.
