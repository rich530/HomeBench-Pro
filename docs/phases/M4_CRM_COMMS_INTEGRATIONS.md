# M4: CRM Replacement, Communications, Measurement Integrations, E-sign, Deposits, Lead Attribution, JobNimbus Import

Starts only after the USABLE PRODUCT GATE (end of M3) is signed. Plan approval: one.

## Goal
HomeBench Pro becomes Committed's daily CRM front end: leads in, texting and email on the record, measurements imported, proposals e-signed with deposits collected, and every lead source measured to CAC, while JobNimbus data is imported once for history.

## Deltas (override the carried sections)
- M0 already built accounts, sites, contacts, jobs, pipelines, activities, attachments. M4 adds only what is missing: appointments calendar with drag to reschedule and optional two-way Google Calendar sync, duplicate-merge tools, saved views, and the full commercial hierarchy screens.
- JobNimbus: build the one-time import (CSV wizard, API adapter, status mapping, idempotent on external_source/external_id, migration report). Delta sync and the parallel run move to M6.
- Communications: Twilio business texting requires A2P 10DLC registration before real sends; build and test against Twilio test credentials and keep real sends STUBBED until registration is approved (see setup/ACCESS_APPLICATIONS.md). Resend email goes live as soon as the domain is verified. Opt-out and consent language comes from library records under the Doc 26 LEGAL GATE.
- E-sign: built-in signature flow with completion certificate (signer identity, timestamps, IP, document hash) or a provider behind an interface. Template text is a LEGAL GATE library record.
- Deposits: Stripe Connect only (platform account + Committed as connected account), card and ACH, processing-fee handling as a setting. Live keys only after the D7 security audit is logged in DECISIONS_LOG; test mode until then.
- Lead attribution: `campaigns` (channel, spend by month, start/end), lead source on every job tied to a campaign, reports: leads, appointments, close rate, revenue, GM, cost per lead, CAC by source and campaign. Neighborhood intake (Doc 22) is a campaign type.
- ABC Supply: pricing API into `cost_item_prices` when access is approved (ordering in M5). Handle $0 prices as "Call branch for price".
- Measurements: Hover, MagicPlan, Roofr PDF parsing into the M1 measurement_sets model.

## Carried requirements (from TradeFlow v2)
> Legacy references inside the carried sections map as follows: Phase 1 = M0/M4, Phase 2 = M1/M4/M5, Phase 3 = M2/M5, Phase 4 = M3/M5, Phase 5 = M6. Where a carried section conflicts with CLAUDE.md v3 or the Deltas above, CLAUDE.md and the Deltas win.

### 1B. CRM core (residential + commercial)
- `accounts` (commercial clients: corporate, property management company, HOA/condo association, GC, institution) with parent/child hierarchy for regions.
- `sites` (client locations: site number, address, access instructions, hours, key/lockbox info, site contacts). Residential customers get one site automatically (their property).
- `contacts` (people) with roles per account/site (facility manager, property manager, AP contact, decision maker, homeowner, spouse, tenant). Consent flags for SMS/email with source and timestamp.
- `properties` attributes on sites: year built, building type, stories, approximate SF, HOA, gate code, pets, parking/dumpster notes. Computed `pre_1978`.
- `jobs` (one table for opportunity through completion). Fields: org-scoped number (e.g. CC-2026-0142), account (optional), site, primary contact, job type (commercial project, commercial service ticket, residential remodel, residential exterior, deck/outdoor, addition, warranty, insurance), work categories (multi: bathroom, kitchen, deck, addition, windows/doors, painting, repair, roofing, siding, gutters, garage, outdoor living, other), contract type (fixed, T&M, NTE, unit price, cost-plus, MSA), lead source, account manager/sales rep, estimator, PM, stage, estimated value, client PO number, external work order number, NTE amount, dates (created, sold, start, complete), lost reason.
- Pipelines configurable per job type. Seeds:
  - Residential: New lead, Contacted, Appointment set, Measured, Estimating, Proposal sent, Signed, Pre-production, Scheduled, In production, Punch/closeout, Invoiced, Paid, Lost, On hold.
  - Commercial project: Opportunity, Site walk, Bidding (subs), Bid submitted, Awarded, Contracted, Pre-construction, Scheduled, In progress, Substantially complete, Closeout docs, Billed, Paid, Lost.
  - Commercial service ticket: Received, Triage, NTE approved, Scheduled, Dispatched, In progress, Complete pending sign-off, Invoiced, Paid, Cancelled.
- `activities`: notes, calls, meetings, tasks with due date and assignee. Tasks appear on the assignee's home screen.
- `appointments` calendar: per user and team views, drag to reschedule, appointment types (site walk, sales appointment, measure, meeting), reminders. Two-way Google Calendar sync for internal users (optional per user).
- `attachments`: Supabase Storage by job, photo tags (before, during, after, damage, QC, other), EXIF time and GPS captured.
- Pipeline board and table views with saved filters. Job detail with money-line header placeholders and tabs (Overview, Contacts, Site, Activity, Files, and disabled Estimate, Budget, Schedule, Work orders, Financials until later phases).
- Quick-add lead and quick-add service ticket forms. Duplicate detection by phone, email, and normalized address.

### 1C. Communications
- Two-way SMS (Twilio) and email (Resend) sent and received from the job and contact record, threaded, with attachments. Inbound replies match to contact/job.
- Templates with merge fields. Basic stage automations (e.g. "Appointment set" sends a confirmation text; "Proposal sent" creates a follow-up task at day 2).
- Opt-out handling: STOP/unsubscribe honored automatically and recorded. No legal compliance text generated; a settings field holds language finished under the Doc 26 LEGAL GATE.
- Web lead form (embeddable) and a signed lead API endpoint. n8n webhook receiver.
- Notifications: in-app and email; SMS for urgent items (configurable per user).

### 1E. JobNimbus migration
- Import wizard for JobNimbus CSV exports (contacts, jobs, tasks, notes): upload > map columns (saved mapping templates) > preview > dedupe review > import > report.
- JobNimbus API adapter (API key stored encrypted, server-side only) to pull contacts, jobs, activities, and files/attachments. If any endpoint is unclear, build CSV first, stub the adapter behind an interface, and log the gap.
- Map JobNimbus statuses to HomeBench Pro pipelines and stages with a mapping screen.
- Idempotent: `external_source` + `external_id` on every imported record. Re-runs create zero duplicates.
- Delta sync: a scheduled job that pulls records changed in JobNimbus since the last run, so both systems stay aligned during the parallel run (until Phase 5E cutover).
- Migration report: counts by type, skipped records with reasons, files transferred, and a reconciliation view (JobNimbus count vs HomeBench Pro count).

### 2D. Measurements
- `measurement_sets` per job (source: manual, Hover, MagicPlan, Roofr, future `lidar_capture`), versioned, with a raw payload stored for re-parsing.
- Hover API integration (OAuth, create job/capture request, webhooks on completion, pull JSON measurements, attach PDF). Use the Hover sandbox and test-job endpoints for tests.
- MagicPlan REST API integration (API key + customer ID, project list, project files/export, webhook on project update) for interior floor plans: rooms, floor/wall/ceiling areas, perimeters, openings.
- Roofr: PDF report import parser. If a documented Roofr API or webhook is available to Committed's account, add it behind the same interface; otherwise log it to the parking lot.
- AI-assisted extraction for PDFs is allowed behind an interface with per-field confidence; the user confirms every value before use.
- Future-proofing: the schema supports 3D model references (file, format, scale, capture device) so a HomeBench Pro LiDAR/photogrammetry capture can plug in later without migration.

## Out of scope for M4
Gantt, sub portal, service tickets (M5); AR/AP, QBO, delta sync and cutover (M6).

## Acceptance checklist
- [ ] Two-way SMS (Twilio test environment) and email (Resend) threaded on a job; STOP halts messaging and is recorded.
- [ ] Web lead form and signed lead API create a job with campaign attribution; n8n webhook receiver verifies signatures.
- [ ] CAC report by source matches a fixture with 3 campaigns and 20 leads.
- [ ] Proposal e-signed with certificate; Stripe Connect test deposit recorded against the connected account; job moves to Signed and triggers M2.
- [ ] JobNimbus import of 1,000 contacts and 600 jobs (fixture CSVs) with correct mapping; re-import creates zero duplicates; migration report reconciles counts.
- [ ] Hover sandbox job imports measurements; MagicPlan test project imports room areas; Roofr sample PDF parses with per-field confirmation (each STUBBED item listed if access is pending).
- [ ] Appointment calendar: create, drag to reschedule, reminder fires.
- [ ] CI green. Docs, decisions, progress, handoff with spot-check SQL.
