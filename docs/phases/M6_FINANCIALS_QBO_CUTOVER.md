# M6: Financial Management, QuickBooks Online Sync, JobNimbus Cutover

Starts after M5 sign-off. Plan approval: one per sub-milestone (6A to 6E) because each includes ledger and billing formulas with fixtures.

## Deltas (override the carried sections)
- Payments run through Stripe Connect (M4). Holdback and payout release logic for HomeBench platform jobs is designed here with `payouts` (job, contractor org, gross, platform fee, holdback, released_at, transfer id) even though Committed-only jobs have no platform fee.
- Commission payouts: paid-on-collection commissions release when the job's invoice is paid; clawbacks on cancel.
- JobNimbus delta sync and the 30-day parallel run live here (moved from the old Phase 1E).
- Lien waiver and invoice templates are LEGAL GATE library records (Doc 26). 1099 threshold confirmed with the CPA.
- Intuit production keys require completing Intuit's app review; build and test against the QBO sandbox until approved (setup/ACCESS_APPLICATIONS.md).
- Sub-milestones: 6A receivables and billing, 6B payables/subs/compliance holds, 6C commitment ledger/WIP/cash/dashboards, 6D QuickBooks sync, 6E JobNimbus cutover.

## Carried requirements (from TradeFlow v2)
> Legacy references inside the carried sections map as follows: Phase 1 = M0/M4, Phase 2 = M1/M4/M5, Phase 3 = M2/M5, Phase 4 = M3/M5, Phase 5 = M6. Where a carried section conflicts with CLAUDE.md v3 or the Deltas above, CLAUDE.md and the Deltas win.

## Architecture decision (do not change without Rich)
- HomeBench Pro is the system of record for jobs, estimates, budgets, commitments, time, billing detail, payables detail, retainage, and lien waivers.
- QuickBooks Online is the system of record for the chart of accounts, general ledger, bank reconciliation, payroll journal entries, and tax reporting.
- Every financial event in HomeBench Pro also writes to an internal double-entry job ledger (`ledger_entries`), so a native general ledger is possible later for HomeBench without re-architecting.
- HomeBench Pro pushes transactions to QBO (writes are the free API call category for QBO apps) and pulls only what it needs (chart of accounts, classes, payment status).

## 6A. Receivables and billing
- Billing methods per job: deposit + milestones, progress billing by percent complete, schedule of values (SOV) pay applications, T&M/service ticket invoices, unit price invoices, cost-plus invoices (cost detail + fee), and MSA consolidated invoicing (many tickets per invoice per account/region/site, per client rules).
- SOV pay applications: original contract, approved change orders, work completed this period and to date by SOV line, stored materials, retainage held, previous billings, current amount due. Generate an AIA-style layout (not the copyrighted AIA form) and export data for licensed forms if the client requires them.
- Retainage receivable: % per contract, reduced/released per contract terms, release billing at completion.
- Client invoice requirements from the account/MSA: client PO, site number, external WO number, photos, signed ticket, lien waiver attachment, submission method (email, client portal, facility platform: manual upload tracked now).
- Customer credits, deposits applied, refunds.
- Payments: Stripe card and ACH links on invoices; checks recorded manually with deposit batch; partial payments; payment application across invoices.
- Statements, AR aging (current, 30, 60, 90+), automated reminders by sequence, collections notes, promise-to-pay tracking.
- Invoice approval workflow (PM prepares, AR reviews, owner approves over threshold).

## 6B. Payables, subs, compliance
- Vendor bills: upload PDF/CSV or email-in; AI-assisted extraction with per-field confidence and human confirmation; 3-way match to PO and receipt (quantity/price variance flagged); coded to job and cost code.
- Sub invoices and sub pay applications against subcontracts and their SOV; percent complete checked against field progress (M3); overbilling flagged.
- Retainage payable per subcontract; release at completion with final unconditional lien waiver.
- Lien waivers: conditional and unconditional, progress and final, from editable templates marked "LEGAL GATE: self-build + verify (Doc 26)". Configurable rule: no sub payment released without the required waiver on file.
- Compliance hold: expired COI or missing W-9 blocks payment (owner override logged).
- Approval workflow: PM approves job coding, owner approves over threshold, AP schedules.
- Payment batches: due-date view, cash-requirement preview, select bills to pay, record payment method (check, ACH, card), push bill payments to QBO. Positive-pay or bank-file export is a parking-lot item unless Rich's bank supports it.
- Vendor credits and material return credits applied to jobs.
- 1099 tracking: 1099-eligible vendors/subs, payments by year, threshold configurable (confirm the current IRS threshold with the CPA), year-end export.

## 6C. Commitment ledger, WIP, cash, dashboards
- Commitment accounting: budget, committed (open POs + subcontracts + approved sub COs), actual (time + bills), remaining to commit, and cost-to-complete by cost code for every job.
- WIP report: contract (with approved COs), EAC, cost to date, percent complete (cost-to-cost), earned revenue, billed to date, over/under billing, projected GM. Export XLSX and PDF. Must tie out to fixtures and be lender and bonding friendly.
- 13-week cash forecast: scheduled billings and expected collections (by customer payment history), AP due, sub payments, payroll (from schedule and labor budget), known overhead from settings; weekly ending cash projection with a low-cash alert threshold.
- Overhead recovery check: actual overhead (from QBO P&L by account mapping) divided by direct job cost vs the overhead % used in pricing; alert when pricing under-recovers.
- Dashboards:
  - Owner: sales booked by work type, backlog ($ and crew-weeks), gross margin sold vs produced, labor efficiency, sub cost variance, AR aging, AP due, cash forecast, WIP over/under billing, jobs at risk.
  - PM: my jobs budget/committed/actual, alerts, schedule slips, unbilled work, pending COs.
  - Account manager: commercial accounts revenue, open tickets, SLA performance, NTE exposure, repeat work.
- Job profitability by job, work type, account, PM, crew, and sub.

## 6D. QuickBooks Online sync
- OAuth 2.0 connection with token refresh (access tokens are short-lived; refresh tokens must be persisted securely on every refresh), idempotency keys, retry queue, sync log UI with per-record status and resend.
- Push: customers (accounts/sites as customers or sub-customers per setting), invoices and credit memos, payments and deposits, vendors, bills and vendor credits, bill payments, journal entries for retainage and WIP adjustments if the CPA approves.
- Pull: chart of accounts, classes/locations, items (for mapping), payment status on invoices paid directly in QBO, bank account list for payment recording.
- Mapping screen: cost codes and cost types to QBO items/accounts and classes; work types to classes (or locations) so QBO P&L can be run by division.
- Design around QBO without relying on premium QBO project APIs: HomeBench Pro owns the job structure and sends job references in customer/sub-customer and memo fields.
- Reconciliation report: HomeBench Pro AR/AP totals vs QBO AR/AP totals by date, with drill-down to unmatched records.
- Webhooks for QBO changes using the current QBO webhook format.

## 6E. JobNimbus cutover
- Parity checklist (must all pass): contacts, accounts, sites, jobs, pipelines, tasks, calendar, two-way text/email, files and photos, estimates/proposals with e-sign, invoices and payments, mobile field use, reports Committed uses weekly, lead forms, ABC Supply, Hover, MagicPlan, Roofr intake.
- Parallel run: 30 days with delta sync from JobNimbus; all new jobs start in HomeBench Pro; weekly reconciliation report.
- Role-based training: 20-minute guided walkthroughs in-app per role, one-page quick guides (PDF) per role, and a "What moved where" JobNimbus-to-HomeBench Pro map.
- Cutover weekend runbook: data freeze, final delta import, file transfer verification, QBO reconciliation, user access check, go-live announcement template.
- JobNimbus kept read-only for 90 days, then export an archive and cancel.
- Post-cutover: 2 weeks of daily issue triage (bug list in docs/CUTOVER_LOG.md).

## Acceptance checklist
- [ ] SOV pay app fixture with 2 change orders and 10% retainage ties out to a hand calculation to the cent.
- [ ] MSA consolidated invoice for 8 service tickets across 3 sites includes client PO, site numbers, external WO numbers, and photos.
- [ ] Stripe test ACH and card payments apply to invoices and push to the QBO sandbox.
- [ ] Vendor bill 3-way match flags a price variance; sub pay app over field percent complete is flagged; payment blocked without lien waiver and with expired COI.
- [ ] WIP report for 6 fixture jobs ties out to the cent, including over/under billing.
- [ ] 13-week cash forecast matches a fixture scenario and fires the low-cash alert.
- [ ] QBO sandbox round-trip: customer, invoice, payment, vendor, bill, bill payment; re-sync creates zero duplicates; reconciliation report shows zero variance.
- [ ] Internal ledger balances (debits = credits) for every fixture transaction.
- [ ] Parity checklist complete; parallel run reconciliation clean for 2 consecutive weeks before cutover.
- [ ] CI green. Docs, decisions, and handoff updated.
