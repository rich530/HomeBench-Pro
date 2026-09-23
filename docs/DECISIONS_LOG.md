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
