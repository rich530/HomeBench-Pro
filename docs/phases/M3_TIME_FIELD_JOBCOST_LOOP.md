# M3: Time Clock, Field App, Change Orders with Discovery Items, Job Costing, Closeout, Price Evidence, Callbacks

Plan approval: one. The plan must include the offline sync design and every time and cost formula with fixtures.

## Goal
Every in-house hour lands on the right job and cost code at the right loaded cost, every hidden condition becomes a customer-approved fixed-price change, the owner sees budget vs committed vs actual on every job in real time, and every closed job writes price evidence that verifies (or challenges) the price book. When M3 passes and Committed runs it daily, HomeBench Pro is a usable product.

## 3A. Time clock and timesheets (hourly W-2 crews)
- Installable PWA, offline-first (IndexedDB queue; append-only for punches, logs, photos; audited edits for everything else). Sync aggressively on reconnect; show unsynced count on screen (iOS can evict web storage, so never hold data longer than needed).
- Clock-in: pick job (today's assigned jobs first, then search), pick task (work order tasks mapped to cost codes). GPS and timestamp at each punch (foreground only). Optional photo.
- One-tap "Switch job" with no gap. Non-job codes: shop, travel between jobs, material pickup, training, warranty/callback, each mapped to a cost code so overhead vs job cost is right.
- No geofence features (iOS web apps do not get background location). Parking lot: native wrapper.
- Crew lead can clock the whole crew in/out and switch together. Breaks per org settings.
- Missed punch requests to PM; all edits audited with reason.
- Weekly approval: worker review > PM approval > payroll lock. OT computed weekly by the engine; allocation per org setting.
- Job cost from time: hours x loaded rate (effective-dated wage, burden, WC class). Payroll true-up import adjusts burden to actual payroll later.
- Payroll export CSV by employee, period, job, cost code, regular/OT hours (mapping configurable). No payroll processing.

## 3B. Field app (minimum that makes the loop work)
- Today: my jobs and tasks, site access, work order, do-not list, one-tap navigation link.
- Task progress: percent complete or quantity installed.
- QC checkpoints: camera opens directly; photo required to complete.
- Daily log under 2 minutes: weather, crew and subs on site, progress, issues, delays, safety notes, visitors/inspectors, photos.
- Discovery: pick a discovery item from the job's list (or "other condition"), count it, photograph it; creates a pending change order at the pre-set fixed price and alerts the PM. Work on that item shows "STOP: awaiting customer approval."
- Extra material requests with reason and photo; PM approval; lands on `job_materials`.
- Punch list with before/after photos; customer walkthrough sign-off (recorded).
- Crew sees hours budget vs used per task, never dollars.

## 3C. Change orders
- Owner change orders from discovery items (fixed price, no re-pricing), field change requests, or the office (priced through the engine).
- Customer approval recorded (typed name + timestamp + IP + document hash, or uploaded signed CO; built-in e-sign provider arrives in M4).
- Approval creates a budget revision (v1 baseline unchanged), updates contract value, work orders, and job_materials.
- Unapproved extra work is tracked as "unbilled extras at risk" with aging alerts.

## 3D. Job costing
- Actuals: time entries at loaded cost, PO receipts, vendor bills entered manually or by CSV (full AP in M6), sub invoices entered manually, equipment, fees, returns and credits. Unmapped actuals go to a review queue that blocks closeout.
- Dashboard per job: budget vs committed vs actual by cost code and cost type; labor budgeted, used, earned hours (percent complete x budget hours per task); efficiency (earned/used); EAC per cost code; projected GM vs sold GM; sub cost vs subcontract.
- Company view: all active jobs sorted by projected GM erosion, with status colors.
- Alerts: labor at 80% and 100% of budget, efficiency below threshold, material over budget by X%, allowance exceeded, unapproved extras, NTE nearing limit, discovery CO pending more than 24 hours.
- Commission accrual per job from commission plans (payout tracking in M6).

## 3E. Closeout, price evidence, Home-OS, callbacks
- Closeout checklist: punch complete, final photos, final inspection, unmapped actuals cleared, returns processed, installed assets recorded, customer closeout documents delivered.
- Variance report: estimate vs actual by cost code and type, labor efficiency by task, waste actual vs allowed, sub cost vs commitment, root cause per significant variance (estimating, field productivity, scope change, hidden condition, weather, sub, material).
- On closeout, write `price_evidence` for every price book line and assembly used (actual unit cost vs engine unit cost) and recompute `verificationStatus`. A line with 2+ in-tolerance jobs flips to verified automatically; a line out of tolerance flips back to pending and alerts the estimator.
- Recalibration: production rates and waste factors updated by rolling weighted average with outlier exclusion, proposed to the estimator, applied only on approval.
- `installed_assets` written for installed products (roof system, garage door, water heater, generator, windows) with warranty end and service life.
- Callbacks: a warranty/callback job links to the original; its cost rolls into a Make-It-Right report by crew, sub, product; callback rate per crew and sub.

## Out of scope for M3
Sub portal and sub field access (M5), commercial service ticket workflow (M5), AR/AP/billing (M6), texting (M4).

## Acceptance checklist
- [ ] Airplane-mode test: clock in, switch job twice, photos, daily log, discovery item all sync without duplicates.
- [ ] Switching jobs creates contiguous entries with correct cost codes; travel lands on the travel code.
- [ ] Weekly OT fixture (46 hours across 3 jobs) matches hand calc under both allocation settings.
- [ ] Timesheet approval locks entries; edits after lock need admin with audit.
- [ ] Payroll CSV matches the fixture format.
- [ ] Discovery item in the field creates a fixed-price CO; work shows STOP until approval; approval creates budget revision v2 while v1 stays unchanged.
- [ ] Earned hours, efficiency, EAC match fixtures; 80%/100% labor alerts fire.
- [ ] Closeout of 2 fixture jobs within tolerance flips a price book line to verified; a third out-of-tolerance job flips it back to pending with an alert.
- [ ] Recalibration excludes outliers and waits for approval.
- [ ] Closeout writes installed_assets; a callback job appears in the Make-It-Right report attributed correctly.
- [ ] CI green. Docs, decisions, progress, handoff with spot-check SQL.

## USABLE PRODUCT GATE (Rich scores this; it unlocks marketing, public name use, and the consumer track)
- [ ] 10 real Committed jobs estimated in Pro.
- [ ] 5 real jobs run signed > locked budget > work orders > time clock > closeout.
- [ ] One crew clocking in Pro daily for 2 consecutive weeks.
- [ ] At least 5 price book lines with real price_evidence (any status).
- [ ] Owner dashboard used in the weekly production meeting 2 weeks running.
