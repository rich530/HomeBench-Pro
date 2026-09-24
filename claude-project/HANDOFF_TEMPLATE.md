# Handoff: <Milestone> <name>

Date:
Status: Complete / Partial / Blocked
Branches merged: (count)   Sessions run: (count)   Estimated agent cost: (sum of total_cost_usd from .autorun/logs)

## What Rich can do now that he could not before
- (plain English, 3 to 6 lines, written for the owner, not a developer)

## Acceptance checklist results
- [pass / fail / STUBBED / pending Rich] item (evidence: test name, screenshot path, or preview URL)

## Supabase spot-check (Rich pastes this into the homebench-staging SQL editor)
Five or fewer queries, each with the expected result in plain words. Example:
```sql
-- 1. RLS is on for every table (expect: zero rows)
select tablename from pg_tables where schemaname = 'public' and rowsecurity = false;
```

## STUBBED integrations
- (integration, what fake it runs on, what access or credential makes it real)

## Blockers waiting on Rich
- (copied from docs/BLOCKERS.md, still open)

## Decisions made during the build (AGENT entries for Rich to confirm or reverse)
- (IDs and one line each from DECISIONS_LOG.md)

## Data model changes
- (new tables, columns, migrations by filename)

## Known gaps and bugs
- (severity: blocks next milestone / fix soon / parking lot)

## Parking lot additions
-

## What Rich needs to do
- (review the staging preview URL, run the spot-check, sign PHASE_SIGNOFF, provide a file or credential, approve a production merge)

## Next milestone
- Name, and the command: ./scripts/autorun.sh plan <next>
