# Decisions Log (source of truth #1)

Format: ID | date | who (RICH or AGENT) | decision | one-line reason. Newest at the bottom. AGENT entries are reviewed by Rich at each milestone handoff; Rich can reverse any of them.

## Seeded decisions (from HomeBench Master Blueprint v3.0, Sept 22, 2026)
PD-001 | 2026-09-22 | RICH | HomeBench Pro is built first, before any other HomeBench surface (Blueprint D19). | A usable product comes before marketing, public naming, or the consumer marketplace.
PD-002 | 2026-09-22 | RICH | The contractor OS is named HomeBench Pro. No "Trade-" prefixed names anywhere (D15). | "Trade" collides with stock trading in software and trademarks.
PD-003 | 2026-09-22 | RICH | One repo (rich530/homebench), one Supabase schema, environments local > homebench-staging > homebench-prod (D7, D17). | One source of truth; the marketplace sits on the same data.
PD-004 | 2026-09-22 | RICH | Build order M0 > M1 > M2 > M3 > Usable Product Gate > M4 > M5 > M6. Consumer track, O14 module, and open signup wait for the gate. | Margin control and price verification first; CRM replacement last.
PD-005 | 2026-09-22 | RICH | Tenancy is platform-aware from the first migration: organizations.kind (platform | contractor) and job_access grants. | The marketplace needs cross-org job visibility without a rewrite.
PD-006 | 2026-09-22 | RICH | "verified" price = 2+ completed jobs in price_evidence within tolerance (default 5%). | Blueprint §3 verification rule, enforced by data, not labels.
PD-007 | 2026-09-22 | RICH | JobNimbus stays Committed's CRM until M6 cutover; one-time import in M4, delta sync and parallel run in M6. | Avoid maintaining a sync for months before it is needed.
PD-008 | 2026-09-22 | RICH | QuickBooks Online stays the general ledger (M6). | Tax book, bank rec, and CPA workflow stay intact.
PD-009 | 2026-09-22 | RICH | Payments are Stripe Connect only; live keys after the D7 security audit is logged here. | Holdback and payouts need Connect; real money needs the audit.
PD-010 | 2026-09-22 | RICH | Agents apply migrations only locally; CI applies to staging on merge to main; production only on merge to production through a GitHub Environment Rich approves. | No tool writes production without a human merge (D17).
PD-011 | 2026-09-22 | RICH | No geofence or background-location features until a native wrapper exists. | iOS web apps do not get background location.
PD-012 | 2026-09-22 | RICH | Wisconsin only at launch; insurance fields now, insurance module later. | Scope discipline with no future migration pain.
PD-013 | 2026-09-22 | RICH | Legal and compliance text ships as LEGAL GATE library records (Doc 26); the system tracks ATCP 110 elements, ATCP 127 windows, and 779.02 lien notice delivery as dated data. | Self-built legal with verification, enforced by workflow.
PD-014 | 2026-09-22 | RICH | Working UI tokens live in src/config/brand.ts and are swapped when O18 (brand system) is decided. | Public brand waits for the product; swap cost stays near zero.

## Build decisions (appended by the agent and Rich from here on)
AD-001 | 2026-09-24 | AGENT | Package manager is npm with a committed package-lock.json; Node 22. | The starter CI already runs `npm ci`; one less tool on the MacBook and in CI.
AD-002 | 2026-09-24 | AGENT | Pin exact versions of Next.js (latest stable at T-001), Supabase CLI, and all npm packages. | Unattended builds must be reproducible night to night.
AD-003 | 2026-09-24 | AGENT | field_superintendent gets no *_financials access in M0 (financial read = owner, admin, account_manager, sales_rep, estimator, project_manager, office, ap_ar). | Protects margin data by default; Rich can add the role with one line in permissions.ts and one migration.
AD-004 | 2026-09-24 | AGENT | Every child table references its parent with a composite (id, org_id) foreign key. | Makes cross-org references impossible in the database, not only in RLS policy.
AD-005 | 2026-09-24 | AGENT | job_materials.unit_cost lives in job_materials_financials, not on job_materials. | CLAUDE.md 5.4 money segregation outranks the column list in the phase file.
AD-006 | 2026-09-24 | AGENT | O14 table columns (incentive_programs, incentive_rules, cost_references, building_income_profile, incentive_lines, application_packets) are provisional because Blueprint §3 is not in the repo. | Tables ship empty, so later column changes are cheap forward migrations; Rich to confirm or paste §3.
AD-007 | 2026-09-24 | AGENT | building_income_profile is readable only by owner, admin, account_manager, estimator. | Household income is sensitive personal data.
AD-008 | 2026-09-24 | AGENT | work_categories is an enum array on jobs; adding a category is a forward migration. | Simple and type-safe; org-editable categories can come later if needed.
AD-009 | 2026-09-24 | AGENT | sites.pre_1978 is generated from year_built and is null when the year is unknown; the UI shows "Year unknown: treat as pre-1978". | Lead-safe rules should fail safe.
AD-010 | 2026-09-24 | AGENT | Residential, commercial project, and service ticket pipeline stages are reconstructed (TradeFlow v2 stage spec is not in the repo); they are seed data Rich can edit. | Unblocks M0; stages are data, not code.
AD-011 | 2026-09-24 | AGENT | HUD CBSA code 99999 (non-metro ZIPs) maps to a synthetic metro WI-NONMETRO. | The acceptance rule requires every Wisconsin ZIP to resolve to a metro.
AD-012 | 2026-09-24 | AGENT | A ZIP spanning several CBSAs maps to the one with the highest residential ratio; the 40-ZIP subset CBSA codes are re-checked against the HUD file when it arrives. | Deterministic, matches where most homes are.
AD-013 | 2026-09-24 | AGENT | job_access grants are created only by owner/admin of the job's owning org (or the service role later for the marketplace); a platform org cannot grant itself access; revocation is an update, never a delete. | Contractor controls its data; grant history stays auditable.
AD-014 | 2026-09-24 | AGENT | callback_financials.cost_to_date exists in M0 at 0 and is maintained from job cost in M3. | Keeps callback cost in a financials table from day one.
AD-015 | 2026-09-24 | AGENT | Uploaded photos are stored as the unmodified original so EXIF time and GPS stay in the file; metadata is also copied into attachments columns. | Phase file requires EXIF kept; evidence value for discovery and QC photos.
AD-016 | 2026-09-24 | AGENT | Address normalization lives in one SQL function (normalize_address) backing a generated column; TypeScript does not reimplement it. | One source of truth for duplicate detection.
AD-017 | 2026-09-24 | AGENT | Field roles read jobs, sites, and contacts across their org in M0; M3 narrows crew visibility to assigned jobs. | Assignments do not exist until M2/M3.
AD-018 | 2026-09-24 | AGENT | Staging gets a manual staging-bootstrap workflow (platform org, Committed org, owner invite to Rich, optional separate Demo Contracting org with invented data). Needs STAGING_SUPABASE_URL and STAGING_SERVICE_ROLE_KEY. | Someone has to be able to log in to staging, and Committed's staging org stays free of demo data.
AD-019 | 2026-09-24 | AGENT | Committed's org seed uses its public business facts (N34W24041 Capitol Dr, Pewaukee, WI 53072; DC 051800146; DCQ 041800065); margin targets, minimum job charge, and trip charge are seeded as is_sample until Rich enters real values. | Real org identity, no invented financial policy.
AD-020 | 2026-09-24 | AGENT | Restored the kit folder layout (the upload flattened it), indented the example lines in docs/TASKS.md so autorun.sh cannot parse them as tasks, and noted that the repo is rich530/HomeBench-Pro (CLAUDE.md says rich530/homebench; CLAUDE.md left unchanged). | Otherwise the runner finds no phase file and loops on the example T-001 line.
AD-021 | 2026-09-24 | AGENT | The subcontractor role sees no org data in M0 (own profile and membership only) until the M5 sub portal defines scope. | Subs see only their own scope and price (CLAUDE.md 5.4); nothing is scoped yet.
AD-022 | 2026-09-24 | AGENT | supabase/seed.sql holds brand-neutral reference data only; orgs, users, and demo data come from the TypeScript seed that reads names from brand.ts. | Keeps brand.ts the only source of product names while db reset still works.
