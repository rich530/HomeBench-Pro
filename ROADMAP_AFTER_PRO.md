# Roadmap After HomeBench Pro (do not build until DECISIONS_LOG.md approves an item)

Entry rule: nothing here starts before the USABLE PRODUCT GATE (end of M3) is signed. Order after that is Rich's call (Blueprint O23). Everything shares the same repo, Supabase schema, engine, and price book.

## Track 1: HomeBench consumer transaction (Blueprint §4 P1 to P4)
- Homeowner accounts (`homeowner` role), per-trade intake definitions stored as data (question flows, photo prompts, validation), photo-guided mobile intake.
- Quote engine: intake > tiered quote from verified price book lines only; human verification queue (D6: "pending confirmation within 2 hours"); positioning never leads with "instant."
- Checkout: deposit through Stripe Connect, Discovery Protocol plain-language acknowledgment, Wisconsin notices (O6), homeowner terms (Doc 26).
- Contractor profiles and homeowner crew selection; assignment writes a `job_access` grant and a job in the contractor's HomeBench Pro job feed.
- Payouts with holdback (D10, O2), reviews engine, unit-economics dashboard from the events log.
- Trades go live one at a time only when their price book lines are verified (2-real-jobs rule).

## Track 2: O14 incentive-stack module (Track B)
Program rules as config data in the M0 incentive tables, forecast engine reading only `incentive_rules` and `cost_references`, delivered memos as immutable snapshots, field-app walk flow per O14-B1/B2. Phase 5 agents gated on three manual walks.

## Track 3: HomeBench Pro for outside contractors (D8: free)
Self-serve signup, onboarding wizard (trades, service area, price book import, burden profile, WC classes, starter assemblies, team invites, CSV/JobNimbus import), module gating, tenant data export, super-admin console, help center.

## Later candidates
- Licensed cost data for tenants (embedding license required; Committed's internal-use licenses do not cover it).
- Commercial client portal (requests, NTE and quote approvals, ticket status, invoices across sites).
- Facility platform integrations (ServiceChannel, Corrigo).
- AI layer: estimate assistant from photos and measurements (engine prices it), work order writer, job-cost anomaly explanations, read-only "Ask Pro" over org data with RLS, daily owner brief via n8n.
- Native general ledger (only if contractors need it; the internal double-entry ledger from M6 is the base).
- HomeBench Capture: native iOS LiDAR/photogrammetry into `measurement_sets` (also enables geofenced time reminders).
- Insurance/restoration module (claim records, carrier estimate import, supplements, depreciation tracking).
- Multi-state: jurisdiction libraries, tax, wage data beyond Wisconsin.
