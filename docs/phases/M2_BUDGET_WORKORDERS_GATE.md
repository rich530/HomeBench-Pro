# M2: Signed Job to Locked Budget, Pre-Job Cost Report, Commitments, Work Orders, POs, Readiness Gate

Plan approval: one.

## Goal
The moment a job is marked signed, Pro produces a locked budget, a Pre-Job Cost Report, crew work orders, purchase orders, and sub commitments, and no job reaches production until it passes the readiness gate. Committed uses this on every signed job from the week M2 ships.

## 2A. Budget and commitments
- On "Mark signed": create `job_budgets` (v1, locked) and `job_budget_lines` from the accepted option, by cost code and cost type, with labor hours by role. Immutable at DB (trigger) and API level. Revisions only via change orders (M3).
- `subcontracts` (sub, scope text from assemblies, amount, retainage %, payment terms, insurance requirements) from sub lines, and `purchase_orders` + `po_lines` from material lines (vendor/branch, delivery window, drop location, site contact; statuses draft, sent, confirmed, partial, backordered, delivered, returned). POs sent as PDF/email (email STUBBED until M4; PDF download works now).
- Committed cost = open commitments. Variance vs budget shown immediately.
- `job_materials` rows move estimate > ordered > received as POs progress.

## 2B. Sub compliance (moved forward from the old Phase 1D because commitments depend on it)
- `compliance_documents` (COI GL, COI WC or exemption, COI auto, W-9, signed master sub agreement, trade license) with expiry, upload, verification status, verified_by.
- Sub compliance status computed daily; expired or missing blocks commitment and scope issue (owner override logged). In-app flags at 30/14/0 days; renewal emails STUBBED until M4.

## 2C. Pre-Job Cost Report (screen + PDF, internal only)
- Money line: contract, budget cost, committed, projected GM$/GM%, projected net after overhead.
- Budget by cost code: in-house labor (hours and $), subcontract, material, equipment, fees.
- Labor plan: hours by role, crew, crew-days, loaded rate used.
- Sub plan: each sub, scope, amount, compliance status.
- Break-even: "Margin drops below the floor at N in-house hours. Budget is M hours."
- Material summary with lead times and special orders. Allowance exposure best/worst.
- Cash flow by week: deposit/progress billing vs payroll, material, sub payments; negative weeks flagged.
- Risk flags: margin below target, sample or pending_verification prices, uncommitted sub scopes at allowance, first-time assembly, long-lead items, winter exterior work, pre-1978, occupied commercial/after-hours, compliance expiring during the job, ATCP 127 cancellation window not yet passed.
- "Approve budget" by owner or PM (logged).

## 2D. Crew work orders (published versions immutable)
- Header: site, access, lockbox, hours, site contact, parking, dumpster, pets, occupied-space and dust rules.
- Task list with hour budget per task (crew sees hours, never dollars). Scope in field language from install templates.
- Materials pick list (delivered vs shop-pulled, selections, returns). Tools and equipment.
- Safety blocks by trigger (heights, ladders/lifts, electrical, silica, lead-safe for pre-1978, occupied commercial) from a library marked verified/unverified.
- Code callouts and manufacturer install references from library records only (no invented values).
- QC checkpoints with required photos (waterproofing before tile, framing before insulation, flashing, deck ledger attachment, garage door spring/track, water heater venting and T&P discharge).
- Discovery Protocol block: the job's discovery items, their fixed prices, and the rule "photo it, stop, call the PM, nothing proceeds without customer approval."
- Cleanup standard and do-not list. Sign-offs: crew lead start and complete, PM verification.

## 2E. Selections (light)
Selection categories per job with chosen item, allowance vs actual, lead time, customer approval (recorded). Required before related POs.

## 2F. Readiness gate
A job cannot move to Scheduled or In production until required items are green (configurable by job type):
- Signed (and deposit recorded as a manual entry, or client PO/NTE for commercial)
- Cancellation window passed where ATCP 127 applies; lien notice delivered for residential (recorded date and method)
- Budget approved; selections approved
- Permits applied/approved when required; HOA or landlord approval when required
- Utility locate for excavation (decks, additions, footings)
- Special-order items confirmed with delivery before the task that needs them
- All subs on the job compliant
- Crew assigned; work orders published
- Customer/client notified of start (recorded)
Owner override requires a reason (audit). Readiness board: all signed jobs, status, blocker, blocker owner, days since signing.

## Out of scope for M2
Gantt and resource scheduling (M5; M2 uses start date + crew assignment only), sub bid leveling and sub portal (M5), ABC ordering API (M4/M5), billing (M6).

## Acceptance checklist
- [ ] Signing the fixture bathroom job creates a locked budget, subcontracts (plumbing, electrical, glass), POs, Pre-Job Cost Report, and work orders in under 10 seconds.
- [ ] Budget ties to the accepted option to the cent; edits to a locked budget fail at DB and API.
- [ ] Committed cost reflects subcontracts; an over-allowance sub amount shows as a variance.
- [ ] Break-even hours fixture matches hand calc.
- [ ] Crew roles see work orders with zero dollars anywhere (UI and API tests). Discovery items print with prices on the PM copy and without prices on the crew copy.
- [ ] Non-compliant sub cannot be committed without logged override.
- [ ] Readiness gate blocks moving to Scheduled; override writes an audit record; ATCP 127 window blocks POs and start until it passes.
- [ ] PDFs render for Pre-Job Cost Report, work order, PO (letter and phone width).
- [ ] (Rich) Real data: 3 real signed Committed jobs run through M2. Listed as pending Rich in the handoff; no sign-off until checked.
- [ ] CI green. Docs, decisions, progress, handoff with spot-check SQL.
