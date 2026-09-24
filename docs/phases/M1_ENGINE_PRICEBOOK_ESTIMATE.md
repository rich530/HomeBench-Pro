# M1: Engine, Cost Data, Price Book, Estimate Builder, Proposals

Plan approval: one. The plan must list every engine function signature with its formula and the hand-calculated fixtures (arithmetic shown in docs/fixtures/*.md).

## Goal
A deterministic engine that prices in-house labor, subs, materials, equipment, and fees for all six contract types, a price book that shows which lines are verified by real jobs, and an estimate builder Committed's estimators use on real jobs starting the week M1 ships, alongside JobNimbus.

## 1A. People and cost inputs (needed for loaded rates)
- `employees` (optional user link, trade/role, hourly wage effective-dated history, burden profile, WC class code, OT eligibility, default crew, certifications with expiry such as lead-safe renovator, OSHA, lift).
- `crews` (name, lead, members). `burden_profiles` and `wc_class_codes` (org-entered, effective-dated).
- `subcontractors` (trades, service area, contacts, approved status, 1099 flag, compliance status as a manual field until M2). `vendors` (branches, account reference, terms, contacts).
- `labor_roles` (carpenter, lead carpenter, painter, laborer, window installer, installer, PM, superintendent) with role-average and per-crew loaded rates computed by the engine.

## 1B. Cost data model
- `uoms`, `uom_conversions` (SQ, LF, SF, SY, EA, BF, opening, united inch, bundle, box, carton, sheet, stick, roll, gallon, hour, day, lump sum).
- `cost_codes` (org-editable tree seeded: 01 General conditions, 02 Demo, 03 Disposal, 04 Protection, 06 Rough carpentry, 07 Insulation, 08 Drywall, 09 Finish carpentry, 10 Doors/windows, 11 Cabinets, 12 Countertops, 13 Tile, 14 Flooring, 15 Painting, 16 Plumbing, 17 Electrical, 18 HVAC, 19 Concrete/footings, 20 Decks/outdoor, 21 Roofing, 22 Siding, 23 Gutters, 24 Garage doors, 25 Generators, 26 Water heaters, 30 Permits/fees, 31 Equipment rental, 40 Service/T&M, 90 Commission, 95 Overhead recovery, 98 Discovery items, 99 Contingency).
- Every cost line has `cost_type`: labor, subcontract, material, equipment, fee, disposal, other.
- `cost_sources`, `cost_items`, `cost_item_prices` (vendor/branch/metro, unit cost, effective, expiration, confidence, is_sample). Lookup returns price + provenance + staleness.
- `production_rates` (task, UOM, units per labor hour, crew size, source, sample count, last recalibrated), `complexity_factors` (occupied space, after-hours, access/height, stories, existing conditions, winter exterior, commercial site restrictions), `waste_factors`, `regional_indexes` (only when no local price exists).
- `sub_price_agreements` (per sub and trade unit prices, effective dates), `rate_cards` (MSA/T&M: labor billing rate by role, material markup %, sub markup %, equipment, trip charge, after-hours/weekend multipliers, minimum), `pricing_profiles` by work type (target GM, floor GM, overhead recovery %, commission plan reference, financing fee %, warranty reserve %, contingency %).
- `commission_plans` (rep, rate, basis revenue | gm, paid_on signing | collection, clawback_on_cancel).

## 1C. Price book (the HomeBench asset)
- `trades` (key, name, region, take_rate nullable, verification_mode human | auto, active).
- `price_book_items` (trade, name, tier good | better | best, unit, assembly_id, engine_cost_snapshot, retail_price, gm, status sample | pending_verification | verified, evidence_count, last_verified_at).
- `addons` (trade, name, price, description, white_glove flag).
- `discovery_items` (trade, condition, unit, fixed_price, photo_requirements, plain_language_description).
- `price_evidence` (price_book_item_id, job_id, actual_unit_cost, engine_unit_cost, variance_pct, within_tolerance, recorded_at). Written by M3 closeout; M1 builds the table, the status logic, and the UI badge.
- Admin screen: price book editor with evidence count and status per line; changing a price creates a new version (audit logged), never overwrites.

## 1D. Engine functions (`src/engine`, pure, 95%+ coverage, each returns a `trace`)
- `burdenedRate`, `loadedRate`, `overtimePremium`
- `laborHours(quantity, productionRate, factors)`
- `materialQuantity(baseQty, wastePct, packageRule)` returns exact, order quantity, leftover
- `lookupPrice(costItem, context)` with provenance
- `evaluateQuantity(expression, measurements)` safe evaluator (no eval): arithmetic, ceil, floor, round, min, max, named variables (floor_sf, wall_sf, ceiling_sf, perimeter_lf, room_count, tile_floor_sf, tile_wall_sf, openings, window_ui, door_count, deck_sf, stair_risers, railing_lf, roof_sq, eave_lf, rake_lf, ridge_lf, valley_lf, wall_siding_sf, gutter_lf, fixture_count, outlet_count, garage_door_count, door_width_in, door_height_in), extensible per org
- `explodeAssembly(assembly, measurements, context)` returns lines by cost code and cost type (feeds `job_materials` phase=estimate)
- `priceFromMargin`, `markupFromMargin`
- `rollupEstimate(lines, pricingProfile, contractType)` returns cost by type, overhead, commission, fees, reserve, contingency, sell, GM$, GM%, labor hours, crew-days, sub share
- `tmBillingRate`, `nteCheck`, `costPlusPrice`, `unitPriceExtension`, `breakEvenLaborHours`
- `verificationStatus(evidence[], tolerance)` returns sample | pending_verification | verified
- All persisted results computed server-side (CLAUDE.md 5.3).

## 1E. Assemblies and templates (all prices is_sample = true)
Bathroom (tub-to-shower, full gut), kitchen, decks and outdoor living, additions/garages (per-SF budget template), commercial windows and doors (per opening by type and size bracket, removal, trim, sealants, lift, after-hours, quantity pricing), painting (interior/exterior, occupied factor), repair and service T&M template, exteriors (roofing per SQ with tear-off, underlayment, ice barrier, flashing, ventilation; siding; gutters; residential window per opening), and the HomeBench launch trades as Good/Better/Best price book items: roofing, garage doors, standby generators, water heaters, windows, each with discovery items (e.g. roof decking per sheet, rotted jamb per opening). Each assembly carries components with quantity expressions, cost types, cost codes, production-rate refs, waste/packaging rules.

## 1F. Imports
- Supplier price book importer (CSV/XLSX) with saved mapping templates.
- Assisted import of Committed's real Excel estimating workbooks: list sheets and rows, map to cost items and assemblies, preview against a test measurement, save. BLOCKED until Rich drops at least one workbook in `data/private/` (gitignored). Build the importer against an invented workbook meanwhile.
- Import of the existing price book workbook (Doc 10, `TradeBench_10_Price_Book_v1.xlsx`) into trades/price_book_items/addons/discovery_items when present in `data/private/`.

## 1G. Estimate builder and proposals
- One screen: measurements (manual measurement sets, versioned, source field ready for hover | magicplan | roofr | lidar), factors, contract type, rate card | sections and lines | live money panel (labor, sub, material, fees/equipment, sell, GM%, markup%, hours, crew-days, evidence status of any price book lines used).
- Add assemblies or price book items by search; lines stay editable, overrides flagged and logged.
- Good/Better/Best options; add-ons; discovery items section.
- Contract type changes output: fixed price, T&M/NTE authorization with rate card, unit price schedule, cost-plus, commercial bid with schedule of values.
- Always-forgotten-costs checklist must be answered before "Ready to send". Margin floor blocks send without logged owner approval.
- Estimate versions immutable; compare versions; duplicate from a past job.
- Proposal: web link + PDF, plain-language scope per option, price, allowances with reconciliation terms, discovery items with prices ("if we find this, it costs exactly this"), exclusions, payment schedule, warranty summary (template, LEGAL GATE), photos.
- Signing in M1 is recorded, not collected: "Mark signed" with uploaded signed document, date, signer, accepted option. Built-in e-sign and deposits arrive in M4.

## Out of scope for M1
Budgets (M2), time clock (M3), Hover/MagicPlan/Roofr/ABC integrations (M4), e-sign and Stripe (M4), sub bid leveling (M5), texting/email (M4).

## Acceptance checklist
- [ ] `priceFromMargin(10000, 0.40)` = 16666.67; UI shows GM 40.0% and markup 66.7%.
- [ ] Burdened rate fixture: wage $30.00, taxes+benefits+PTO 20%, WC $12.00 per $100, GL $1.50/hr = $41.10; productive ratio 0.80 gives $51.375 (displays $51.38).
- [ ] Overtime fixture: 46 hours at $30 = 6 OT hours, premium $90.00, both allocation settings.
- [ ] Packaging fixture: 212 SF wall tile, 12% waste, 10.76 SF per carton = 237.44 SF, orders 23 cartons.
- [ ] T&M fixture: 3.5 hrs lead carpenter at rate card, trip charge, materials $86.40 at 25% markup matches hand calc; NTE warning at 80%.
- [ ] Full bathroom remodel, 64-opening commercial window estimate, and a Good/Better/Best roof estimate explode and roll up to hand-calculated fixtures to the cent.
- [ ] `verificationStatus` fixtures: 0, 1, 2-in-tolerance, 2-with-one-outside cases return the right status; UI badge matches.
- [ ] Proposal cannot be sent below floor GM without logged approval; discovery items print on the proposal.
- [ ] Estimate lines write `job_materials` rows with phase=estimate.
- [ ] Evaluator rejects non-arithmetic input (security test). Engine coverage 95%+.
- [ ] (Rich) Real data: one real Committed estimating workbook imported and one real job re-estimated in Pro. The agent prepares it and lists it as pending Rich; the milestone cannot be signed off until Rich checks it.
- [ ] CI green. Docs, decisions, progress, handoff with spot-check SQL.
