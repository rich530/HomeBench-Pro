# HomeBench Pro: Project Constitution (CLAUDE.md) v3.0

Read this file at the start of every session. It overrides your defaults. If a phase file conflicts with this file, this file wins unless docs/DECISIONS_LOG.md says otherwise. Replaces TradeFlow CLAUDE.md v2 in full.

You are usually running UNATTENDED through scripts/autorun.sh. Nobody is watching. Section 4 tells you exactly how to behave when you are unsure, blocked, or failing.

---

## 1. What HomeBench Pro is

HomeBench Pro is the contractor operating system inside HomeBench. It is the first product HomeBench ships. It runs estimating, locked job budgets, work orders, field time by cost code, job costing, and the learning loop for Committed Contracting (tenant #1). Later it adds CRM, communications, scheduling, sub management, financials, and QuickBooks sync, replaces JobNimbus, and is given free to contractors as HomeBench's supply-side engine.

HomeBench (the parent) is a homeowner marketplace: verified fixed prices in Good/Better/Best tiers, homeowner picks the crew, no ambushes. HomeBench Pro's job-cost actuals are what verify HomeBench's price book. Build every table so the marketplace can sit on top of it without re-architecting.

One-sentence promise: every estimate becomes a locked budget and field-ready work orders before the job starts, every hour and dollar lands on a cost code, and every finished job makes the next price more accurate.

### The closed loop (this IS the product)

Lead > Measure > Estimate (assemblies, in-house labor, subs, materials, Good/Better/Best, discovery items) > Proposal > Signed > Locked budget + Pre-Job Cost Report > Work orders + POs + readiness gate > Production (time clock by job and cost code, daily logs, QC photos, change orders) > Budget vs actual > Closeout variance > price_evidence + recalibrated production rates > next estimate.

If a feature does not feed this loop or make it easier to use, log it in docs/PARKING_LOT.md and move on.

### Milestone map (build in this order)

- M0 Foundation: platform-aware tenancy, auth, roles, audit, CRM core minimum, HomeBench-ready tables, CI, staging pipeline.
- M1 Engine, cost data, price book, estimate builder, proposals.
- M2 Signed job to locked budget, Pre-Job Cost Report, commitments, work orders, POs, readiness gate.
- M3 Time clock, field app, change orders with discovery items, job costing, closeout, price evidence, callbacks.
- USABLE PRODUCT GATE (Committed runs real jobs through M0 to M3 daily). Nothing public, no marketing, no consumer track until this passes.
- M4 CRM replacement, communications, measurement integrations, e-sign, deposits, lead attribution, JobNimbus import.
- M5 Scheduling (Gantt), subs (bids, portal, scopes, compliance automation), service tickets, full procurement.
- M6 Financials (AR, AP, retainage, lien waivers, WIP, cash), QuickBooks Online sync, JobNimbus cutover.
- Roadmap (docs/phases/ROADMAP_AFTER_PRO.md): HomeBench consumer transaction, O14 incentive module, open signup. Do not build until DECISIONS_LOG says so.

Gate rule: a milestone is done only when its acceptance checklist passes with evidence, the Supabase spot-check SQL is written into the handoff, and Rich signs off in docs/PHASE_SIGNOFF.md.

## 2. The business this is built for (tenant #1)

Committed Contracting, Pewaukee/Waukesha, Wisconsin. $4M+ 2025, $6M pace 2026. Wisconsin only at launch.

Revenue mix, most to least:
1. Corporate commercial accounts: window/door replacement, kitchen and bathroom remodels, painting, repair and remodel work orders across many sites; commercial electrification (heat pumps, incentive programs).
2. Residential: decks, bathrooms, additions, garages, outdoor living, interior remodels.
3. Residential exteriors: roofing, siding, gutters, windows (also HomeBench launch trades with garage doors, standby generators, water heaters).
4. Insurance and storm work (smallest; fields now, module later).

Labor model: hourly W-2 tradespeople who clock in and out of multiple jobs per day, plus many subcontractors (plumbing, electrical, HVAC, tile, drywall, countertops, concrete). Both need their own place in estimating, work orders, job costing, and financials.

Measurement tools in use: Roofr, Hover, MagicPlan (integrations in M4). Manual measurement sets from M1.

## 3. Stack and environments (do not change without Rich)

- One repo: github.com/rich530/homebench. Next.js (App Router), TypeScript strict. Route groups: `/pro` (HomeBench Pro), `/admin` (platform), consumer routes later. Everything shares one Supabase schema.
- Supabase: Postgres, Auth, RLS, Storage, Edge Functions, Realtime.
- Environments: local (Supabase CLI in Docker) for all agent work; `homebench-staging` (receives migrations only from GitHub Actions on merge to `main`); `homebench-prod` (receives migrations only from GitHub Actions on merge to `production`, gated by a GitHub Environment that Rich approves).
- Vercel: Production Branch = `production`. `main` deploys as the staging preview wired to homebench-staging. Feature branches get previews.
- Tailwind + shadcn/ui, lucide-react. Zod, React Hook Form, TanStack Query and Table. decimal.js for all money and quantity math.
- Vitest (unit), Playwright (e2e). GitHub Actions: typecheck, lint, unit, e2e, migration dry-run.
- All brand strings, product names, and design tokens live in one file: `src/config/brand.ts` (and CSS variables generated from it). Never hardcode "HomeBench", "HomeBench Pro", colors, or logos anywhere else. The public brand system is undecided (O18); the tokens in section 8 are working UI tokens and will be swapped from brand.ts.
- Payments (M4+): Stripe Connect only (platform account, connected contractor accounts, holdback). Never plain Stripe charges.
- Integrations, each behind an interface in `src/integrations/<name>` with a fake implementation and recorded fixtures: Resend, Twilio, Stripe Connect, QuickBooks Online, Hover, MagicPlan, Roofr (PDF), ABC Supply, JobNimbus, n8n signed webhooks.
- Gantt (M5): open-source React library with a verified permissive license, or custom SVG. Paid libraries need Rich.

## 4. How you work unattended (autonomy rules)

1. Work comes from docs/TASKS.md. Each session does exactly ONE task, on the branch the runner created. Never start a second task.
2. Before coding, read: this file, docs/DECISIONS_LOG.md, docs/PROGRESS.md (last 60 lines), the current phase file, docs/plans/<milestone>_PLAN.md. docs/PROGRESS.md is your memory between sessions; context compaction will erase anything else.
3. When a decision is not covered here or in the phase file, pick the option that best protects margin accuracy, data integrity, and simplicity, log it in docs/DECISIONS_LOG.md (one line of reasoning, tagged AGENT), and keep going. Do not stop to ask.
4. Stop conditions (the only reasons to not finish a task): spending money, production data, legal/compliance language that is not already a library record, a data-model change to a milestone Rich already signed off, or an input only Rich can provide (file, credential, account, sample data). For those: mark the task `- [~] T-xxx BLOCKED: <exactly what is needed>` in docs/TASKS.md, add an entry to docs/BLOCKERS.md with the plain-language ask for Rich, build every piece that does not depend on the missing input (interfaces, fakes, fixtures, UI states), commit, PR, and end the session.
5. STUBBED rule: an integration running on its fake implementation is STUBBED. Say so in PROGRESS.md, the handoff, and PHASE_SIGNOFF. A STUBBED item never counts as a passing acceptance check.
6. Before every commit: typecheck, lint, unit tests, and e2e tests for anything touched. Fix failures before committing. Never skip, disable, or weaken a test to make it pass; if a test is wrong, fix it and log why in DECISIONS_LOG.
7. Git: one branch per task, small commits, forward-only migrations, generated Supabase types committed. Finish every task with: mark it `[x]` in TASKS.md, append 3 to 6 lines to PROGRESS.md, commit, push, `gh pr create --fill --base main`, then `gh pr merge --auto --squash` (the required check `ci` must pass before GitHub merges). Never force push. Never push to `production`. Never commit secrets.
8. Database: migrations run only against the local Supabase (`supabase start`, `supabase db reset`, `supabase migration new`). Never `supabase link`, never `supabase db push`, never touch staging or production directly. CI applies migrations.
9. End of milestone (the runner triggers this): run the acceptance checklist, update docs/CHANGELOG.md and docs/PHASE_SIGNOFF.md (pass/fail with evidence), write docs/handoffs/<milestone>_HANDOFF.md from claude-project/HANDOFF_TEMPLATE.md including the Supabase spot-check SQL Rich will paste into the staging SQL editor.
10. Keep the "Out of scope" line of each phase file. Ideas outside it go to docs/PARKING_LOT.md, not into code.

## 5. Engineering rules (non-negotiable)

1. Every business table has `org_id` and RLS. Automated tests prove org A cannot read or write org B rows on every table, and that a platform org sees only jobs granted through `job_access`.
2. Money and quantity columns are `numeric(14,4)`. Round to cents only at documented rounding points. Never JS floats for money.
3. All cost, price, payroll-cost, margin, retainage, and billing math lives in `src/engine` as pure, deterministic, unit-tested functions (95%+ coverage). Any number that is stored is computed server-side (server action, route handler, or Edge Function calling the engine). Totals submitted by a client are recomputed and client values discarded. AI never produces a number the engine did not compute.
4. Money fields are column-segregated: cost, price, and margin live in separate `*_financials` tables or security-invoker views that crew and subcontractor roles have no grants on. Crew roles see hours, never dollars. Subs see only their own scope and price.
5. Estimates, budgets, work orders, proposals, and snapshots delivered to a customer are versioned and immutable. After signing, the budget baseline changes only through change orders.
6. Every price and rate carries provenance: source, region, effective date, expiration, confidence (verified / supplier / org_history / licensed_index / public_index / sample). "verified" has one meaning: at least 2 completed jobs in `price_evidence` support it within tolerance (section 6).
7. Audit log for every change to prices, rates, budgets, time entries, approvals, payments, overrides, and permissions.
8. Seed data is realistic for a Wisconsin remodeling and commercial contractor. Placeholder costs are `is_sample = true` and show "Sample price" in the UI.
9. Never invent building code citations, manufacturer specs, tax rules, lien-law language, incentive program rules, or contract terms. Store them as editable library records with `source`, `verified`, and `verified_by` fields. Ship placeholders marked unverified and labeled "LEGAL GATE: self-build + verify (Doc 26)" where legal.
10. Do not scrape or copy licensed or proprietary data (RSMeans, Craftsman, Xactimate, competitor databases).
11. Secrets live in environment variables and Supabase Vault. Integration tokens encrypted at rest, never sent to the client. Production credentials never exist on the build machine.
12. Customer PII (names, phones, emails, addresses) never goes into logs, fixtures copied from real data, or anything outside the database. Fixtures use invented people.

## 6. Domain rules a 40-year remodeler enforces

### Pricing
- Margin, not markup: `price = cost / (1 - target_gm)`. $10,000 cost at 40% GM = $16,666.67. Show GM% and markup% side by side everywhere a price is set.
- Target and floor margins by work type (commercial service/T&M, commercial project, residential remodel, exteriors, decks, HomeBench trades). Below floor requires owner approval (logged).
- Minimum job charge and trip charge for service work.
- Good/Better/Best tiers with add-ons for residential and every HomeBench trade.

### Verified price (the HomeBench price-book rule)
- `price_evidence` links a price book line to completed jobs with actual unit cost from closeout. A line is `verified` only when at least 2 completed jobs support it and each is within the tolerance set in org settings (default plus or minus 5% of engine cost). Fewer than 2, or out of tolerance, the line is `pending_verification` and the UI says so.
- Closeout (M3) writes price_evidence automatically. Nobody types "verified".

### Discovery Protocol (brand law: no ambushes, ever)
- `discovery_items`: pre-priced hidden conditions per trade (e.g. rotted decking per sheet, subfloor repair per SF, rotted jamb per opening) with fixed price, unit, and photo requirements.
- Proposals list the relevant discovery items and prices in plain language before signing.
- In the field, a discovery item is documented with photos and becomes a fixed-price change order the customer approves before work proceeds. Nothing proceeds without approval.

### Make-It-Right
- Callbacks and warranty jobs link to the original job. Their cost is tracked and attributed to crew, sub, or product. Callback rate by crew and sub is a report. Platform holdback logic arrives with Stripe Connect (M4+); the data model supports it from M0.

### In-house labor (hourly W-2)
- Burdened rate = wage x (1 + employer taxes% + benefits% + PTO%) + wage x WC rate per $100 / 100 + GL allocation per hour. WC rates per class code, entered by the org, effective-dated. Never hardcoded.
- Loaded rate = burdened / productive ratio.
- Overtime: weekly hours over 40 at 1.5x wage. Engine computes the premium; an org setting decides allocation (job where OT occurred vs spread across the week's jobs).
- Hours = quantity / units_per_labor_hour x complexity factors.

### Subcontractors
- First-class cost type with its own cost codes, bids, agreements, commitments, and compliance. Never bury sub cost inside labor.
- A sub cannot be committed, scheduled, issued a scope, or paid while compliance is expired (COI GL, WC or exemption, auto if required, W-9, signed sub agreement). Owner override is logged.

### Materials (O13)
- `job_materials` from the first estimate: sku, description, quantity, unit cost, supplier, source, estimate vs actual.
- Waste factors by material and complexity; round up to purchasable units after waste.
- Special-order lead times drive the readiness gate. Allowances carry overage/underage reconciliation language.

### Home-OS
- `installed_assets` on every site: product, manufacturer, model, serial, install date, warranty end, expected service life, source job. Written at closeout. This is the homeowner's permanent record and a future HomeBench asset.

### Sales commission
- Commission plans per rep (rate, basis: revenue or GM, paid-on: signing / collection, clawback on cancel). Commission is a job cost in the estimate and a ledger entry per job.

### Contract types
Fixed price, T&M, NTE, unit price, cost-plus (percentage or fixed fee), and MSA rate cards. Engine, budget, and reports handle all six.

### Always-forgotten costs (the estimator must answer each: include / not needed)
Permits and plan review, inspection re-trips, dumpster/disposal, delivery, equipment rental (lifts, scaffold, floor protection, dust containment), protection and cleanup, supervision/PM time, drive time, after-hours premiums, lead-safe practices on pre-1978 buildings, commission, financing fees, warranty reserve, contingency, overhead recovery.

### Commercial
Account > region > site > contacts. MSA rate cards (labor by role, material markup, trip charge, after-hours multipliers, NTE defaults, payment terms, retainage, required documents, invoice requirements: client PO, site number, external WO number, photos). External facility platform WO numbers stored now; integrations later.

### Residential and Wisconsin (library records, LEGAL GATE: self-build + verify)
- Selections with customer sign-off before ordering. Occupied-home rules. Pre-1978 triggers lead-safe blocks on work orders.
- Track per residential job, as data with dates: ATCP 110 contract elements present, cancellation window where ATCP 127 applies (blocks material orders and start dates until it passes), Wis. Stat. 779.02 lien notice delivered (date and method). Text lives in editable templates; the system tracks that it happened.
- Sales tax configurable per job type; confirmed with Committed's CPA before go-live.
- Jurisdiction library for permits/inspections (seed Waukesha and Milwaukee counties, unverified).

### Insurance and storm (fields now, module later)
Jobs carry optional carrier, claim number, adjuster, deductible, ACV, RCV, supplement status.

### Incentives (O14, tables from M0, module later)
`incentive_programs`, `incentive_rules`, `building_income_profile`, `incentive_lines`, `application_packets`, `cost_references`. Program rules are config data. Engines produce numbers only from `incentive_rules` and `cost_references`, enforced server-side.

## 7. UX rules: easiest in the industry

- Role-based home screens: Owner, Sales/Account Manager, Estimator, Project Manager, Field Superintendent, Crew Lead, Crew Member, Office/Admin, AP/AR, Subcontractor (limited), Platform Admin.
- Any core action within 3 taps from home. Command palette (Cmd/Ctrl+K).
- Field screens mobile-first on iPhone: 48px touch targets, sunlight contrast, offline for time clock, photos, daily logs. Do not rely on background location (iOS web apps do not get it); no geofence features until a native wrapper exists.
- Time clock is one screen: current job, current task, big "Switch job" and "Clock out".
- Numbers first: every job header shows Contract, Budget cost, Committed, Actual, Projected GM% with one status color.
- Plain language. Buttons say exactly what happens.
- "Why this number?" on every calculated figure (inputs, formula, provenance, evidence count).

## 8. Working design tokens (provisional; swap via brand.ts when O18 is decided)

- Primary `#1F3B2D` (nav, brand surfaces). Action `#2E6FB7` (buttons, links, focus). Text `#23272B`. Secondary text/borders `#7D868D`. Panels `#E7EAEC` on `#FFFFFF`.
- Status: On budget `#2F7D4F`, Watch `#B7800A`, Over `#B3261E`. Safety `#F26B1D` for field safety items only.
- Public Sans, `font-variant-numeric: tabular-nums` on all figures. Sentence case. Money line is the hero. Dense, calm tables. Responsive to 360px, visible focus, reduced motion, WCAG AA.

## 9. Glossary

Organization (platform or contractor), Account, Site, Property, Job, Service ticket, Cost item, Assembly, Production rate, Burdened/loaded rate, Cost code, Price book line, Discovery item, Price evidence, Estimate version, Budget (locked baseline), Commitment (subcontract or PO), Change order, Work order, Readiness gate, Time entry, Installed asset, EAC, WIP.

## 10. Decisions in force (history in docs/DECISIONS_LOG.md)

- HomeBench Pro is built first, before any other HomeBench surface (D19).
- One repo, one Supabase schema, platform-aware tenancy from the first migration.
- Committed is tenant #1. JobNimbus stays Committed's CRM until M6 cutover; Pro runs alongside it from M1.
- QuickBooks Online stays the general ledger (M6 sync).
- Wisconsin only at launch. Insurance module deferred; insurance fields present.
- No "Trade-" prefixed names anywhere. The old TradeFlow codebase and kit are not reused; its ideas are.
