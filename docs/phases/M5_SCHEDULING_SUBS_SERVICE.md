# M5: Scheduling (Gantt), Subcontractor Management, Service Tickets, Full Procurement

Starts after M4 sign-off. Plan approval: one.

## Goal
Crews and subs scheduled from the budget on a Gantt and a company resource view, subs bidding, confirming, and working through their own portal, commercial service tickets running from request to billing-ready package, and materials ordered through supplier APIs.

## Deltas (override the carried sections)
- Readiness gate, work orders, selections, sub compliance, and owner change orders already exist (M2, M3). M5 adds scheduling on top: task durations from the locked budget, dependencies, critical path, baseline, sub date confirmations, resource view, weather overlay.
- Sub scope documents and subcontract templates are LEGAL GATE library records (Doc 26), e-signed through the M4 e-sign interface.
- Renewal emails for expiring sub compliance go live now (Resend).
- Selections become full (customer approves in the portal link with signature).

## Carried requirements (from TradeFlow v2)
> Legacy references inside the carried sections map as follows: Phase 1 = M0/M4, Phase 2 = M1/M4/M5, Phase 3 = M2/M5, Phase 4 = M3/M5, Phase 5 = M6. Where a carried section conflicts with CLAUDE.md v3 or the Deltas above, CLAUDE.md and the Deltas win.

### 2C. Sub bids and leveling
- Bid packages per job and trade: scope text (from assemblies), drawings/photos, measurements, due date, site-visit notes.
- Invite multiple subs by email/SMS; subs respond through a tokenized link (no login required) with price, inclusions, exclusions, schedule availability, and attachments.
- Bid leveling screen: side-by-side with scope checklist, exclusions flagged, low/avg/high, compliance status, past performance.
- Award selects the bid into the estimate as subcontract cost lines by cost code. Unawarded trades use sub price agreements or a flagged allowance.

### 3B. Gantt scheduling
Two levels: the job schedule (Gantt) and the company resource schedule.

#### Job schedule
- Schedule templates per job type (bathroom gut, tub-to-shower, kitchen, deck, addition, commercial window rollout, painting, service ticket) with tasks, typical durations, dependencies, and milestones. Example bathroom sequence: protection > demo > framing repair > plumbing rough (sub) > electrical rough (sub) > rough inspection (milestone) > insulation > backer/waterproofing > tile > vanity/top > plumbing finish (sub) > electrical finish (sub) > glass (sub) > paint/trim > punch > final inspection (milestone).
- Generated from the budget: task durations = budget hours / assigned crew size / productive hours per day, rounded up to half days; sub task durations from the sub's quoted duration.
- Dependencies: finish-to-start, start-to-start, finish-to-finish, with lag (e.g. tile cure time). Milestones for inspections, material deliveries, client approvals.
- Assignments: each task assigned to an in-house crew/employees or to a subcontractor.
- Critical path calculated and highlighted. Baseline captured at approval; actual vs baseline shown after production starts.
- Drag to move or resize; dependent tasks cascade with a preview before commit. Working calendar per org (work days, holidays) and per site (commercial access hours).
- Two-week lookahead per job; auto-notify subs of their dates by email/SMS with a confirm/decline link. Sub declines raise a schedule alert.
- Commercial multi-site rollouts (e.g. windows across 12 sites): parent program with child jobs per site, rolled up in one Gantt.

#### Company resource schedule
- Crews and subs as rows, days as columns, showing tasks across all jobs. Capacity (crew-days available vs booked), over-allocation warnings, backlog in crew-weeks.
- Weather overlay from a free forecast API for exterior tasks.
- Reschedule reasons logged (weather, material, customer, crew, sub, inspection, permit).

Library choice per CLAUDE.md section 3. Must render smoothly with 60 tasks on a job and 40 jobs on the resource view, work on tablet, and print/export to PDF.

### Sub scopes of work
- Per subcontract: scope, inclusions/exclusions, schedule dates from the Gantt, site rules, safety requirements, QC photo requirements, their price and payment terms, required lien waivers, and change order process. No company margin.
- Subcontract document generated from an editable template (marked "LEGAL GATE: self-build + verify (Doc 26)"), e-signed by the sub.

### Procurement
- POs by vendor/branch from budget material lines and selections: delivery date/time window, drop location, site contact. Statuses: draft, sent, confirmed, partial, backordered, delivered, returned.
- ABC Supply orders submitted through the ABC API where available; other vendors by PDF/email.
- Special-order tracking with expected dates feeding the Gantt milestones.

### 4C. Subcontractors in the field
Sub portal (subcontractor role, mobile-friendly):
- Their assigned jobs, tasks, dates, scope of work, site rules, and required QC photos.
- Confirm or decline schedule dates; lookahead notifications.
- Check in/out on site (for site logs, not payroll), progress updates, photos.
- Submit change requests with photos; submit invoices or pay applications against their subcontract (processed in Phase 5B).
- Upload renewed compliance documents.
- Subs never see other subs, company pricing, or margin.

### Commercial service tickets (T&M / NTE / MSA)
- Intake from client email (parse into a draft ticket), web request form per account/site, phone entry, or facility platform (manual entry of external WO number now; integration Phase 6).
- Triage: priority/SLA, NTE from the MSA or request, assign tech/crew, schedule.
- Tech workflow: arrive (check-in), before photos, time by clock, materials used (from truck stock or purchase with receipt photo), after photos, notes, client on-site signature.
- NTE control: running T&M total vs NTE; warning at 80%; work above NTE requires client approval captured in the ticket.
- Ticket completion produces a billing-ready package: rate-card pricing, receipts, photos, signature, client PO, site number, external WO number.
- Recurring and preventive work templates for accounts with regular service.

### Sub change orders
- Linked to owner COs or standalone (cost only), approved by PM, increasing the subcontract commitment.

## Out of scope for M5
AR/AP, retainage billing, lien waivers, QBO, cutover (M6).

## Acceptance checklist
- [ ] Sub bid flow: 3 plumbers invited, 2 respond through tokenized links, leveled, 1 awarded into the estimate as subcontract cost.
- [ ] Gantt generated from the fixture bathroom budget: dependencies cascade, critical path correct against a fixture, baseline captured, sub notified and confirms via link; decline raises an alert.
- [ ] Resource view flags a double-booked crew and an over-allocated week; renders 60 tasks per job and 40 jobs smoothly on a tablet; prints to PDF.
- [ ] Sub portal: sub sees only their assignments, confirms a date, uploads a renewed COI, submits a change request and an invoice draft.
- [ ] Service ticket fixture: NTE warning at 80%, over-NTE approval captured, billing-ready package complete with client PO, site number, external WO number, photos, signature.
- [ ] ABC order submitted through the API sandbox or STUBBED with access status listed.
- [ ] CI green. Docs, decisions, progress, handoff with spot-check SQL.
