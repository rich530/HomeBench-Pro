# M0: Foundation (platform-aware tenancy, auth, roles, audit, CRM core minimum, HomeBench-ready tables, CI, staging pipeline)

Plan approval: one. Run `./scripts/autorun.sh plan M0`, review, then `./scripts/autorun.sh approve M0`.

## Goal
A secure multi-tenant foundation that Committed can log into, where a job can be created against a site and contact in under 60 seconds, and where every later milestone (and the HomeBench marketplace) plugs in without re-architecting. Migrations reach homebench-staging automatically through CI.

## 0.1 Scaffold and pipeline
- Next.js App Router, TypeScript strict, Tailwind, shadcn/ui, Public Sans, tokens from `src/config/brand.ts` compiled to CSS variables.
- Route groups: `/pro` (all M0 to M6 screens), `/admin` (platform admin shell). Placeholder landing page with no public brand claims.
- Supabase CLI local dev, migrations in `supabase/migrations`, generated types committed, `supabase/seed.sql` plus a TypeScript seed script with invented Wisconsin data.
- `src/engine` created with README and a first pure function (`priceFromMargin`) with tests, so the pattern exists from day one.
- `src/integrations/` with the interface + fake pattern and a README.
- GitHub Actions (extend the starter `.github/workflows/ci.yml`; keep a final job with id `ci` that depends on every other job, because branch protection requires exactly that check):
  - `ci.yml` on every PR: install, typecheck, lint, unit, e2e (Playwright against local Supabase in the runner), `supabase db reset` to prove migrations apply cleanly from zero.
  - `staging-migrate.yml` on push to `main`: link to homebench-staging with repo secrets `SUPABASE_ACCESS_TOKEN`, `STAGING_PROJECT_REF`, `STAGING_DB_PASSWORD`, then `supabase db push`. Fails loudly; never runs seeds against staging except the org/demo seed flagged safe.
  - `prod-migrate.yml` on push to `production`: same against homebench-prod, using GitHub Environment `production` (required reviewer: Rich). Secrets `PROD_PROJECT_REF`, `PROD_DB_PASSWORD`.
  - If the secrets are missing, the workflow files are still written and the task is marked BLOCKED only for the verification step, with the exact secret names in BLOCKERS.md.
- docs: PARKING_LOT.md, CHANGELOG.md, PHASE_SIGNOFF.md, DECISIONS_LOG.md, PROGRESS.md, BLOCKERS.md, plans/, handoffs/ (templates exist; keep them).

## 0.2 Tenancy, auth, roles, permissions
- `organizations` (id, kind: `platform` | `contractor`, legal_name, dba, created_at). Seed one platform org (HomeBench) and one contractor org (Committed Contracting).
- `org_settings` (org_id, license numbers, service areas, fiscal year start, default payment terms, margin targets and floors by work type, minimum job charge, trip charge, productive ratio, verification tolerance default 0.05, overtime allocation mode).
- `profiles`, `memberships (org_id, user_id, role)`, `invitations` (email, role, token, expiry).
- Auth: email + password and magic link. Invite by email with role (email sending STUBBED until Resend key present; invitation links shown in admin UI meanwhile).
- Roles: owner, admin, account_manager, sales_rep, estimator, project_manager, field_superintendent, crew_lead, crew_member, office, ap_ar, viewer, subcontractor, platform_admin, platform_ops. Homeowner arrives with the consumer track; reserve the enum value `homeowner`.
- `job_access (job_id, org_id, access_level, granted_by, reason, created_at)`: how a platform org (or later a second contractor) sees a job it does not own. RLS helper functions: `is_member(org_id)`, `has_role(org_id, roles[])`, `can_see_job(job_id)`.
- Permission matrix in `src/lib/permissions.ts`, mirrored in RLS. Money columns segregated per CLAUDE.md section 5.4 (crew and subcontractor roles have no grants on `*_financials`).
- `audit_log` (org_id, actor, action, table, row_id, before, after, reason, at) and a helper used by every mutation; DB triggers on sensitive tables as a backstop.

## 0.3 Regions
- `metros` and `zip_codes` for Wisconsin from the HUD USPS ZIP-to-CBSA crosswalk. Record file name and quarter in `cost_sources`.
- If the crosswalk file is not in `data/seeds/`, seed a 40-ZIP subset covering Waukesha, Milwaukee, Madison, Kenosha, Racine, Sheboygan, mark the task BLOCKED for the full file, and tell Rich where to download it in BLOCKERS.md.

## 0.4 CRM core minimum (just enough for M1 to M3)
- `accounts` (commercial clients: corporate, property manager, HOA/condo, GC, institution) with parent/child for regions.
- `sites` (address, site number, access instructions, hours, lockbox, parking/dumpster notes) and property attributes: year built, building type, stories, approx SF, HOA, gate code, pets; computed `pre_1978`. Residential customers get one site automatically.
- `contacts` with roles per account/site; SMS and email consent flags with source and timestamp (stored now, used in M4).
- `jobs`: org-scoped number (CC-2026-0001), account (optional), site, primary contact, job type (commercial project, commercial service ticket, residential remodel, residential exterior, deck/outdoor, addition, warranty/callback, insurance, homebench_platform), work categories (multi), contract type (fixed, T&M, NTE, unit, cost-plus, MSA), lead source, sales rep, estimator, PM, pipeline + stage, estimated value (in `job_financials`), client PO, external WO number, NTE amount (financials), dates (created, sold, start, complete), lost reason, `parent_job_id` (callbacks and warranty link to the original job), insurance fields (carrier, claim number, adjuster, deductible, ACV, RCV, supplement status), residential compliance fields (atcp110_elements_confirmed_at, cancellation_window_ends_at, lien_notice_delivered_at, lien_notice_method).
- `external_source`, `external_id` on accounts, sites, contacts, jobs (JobNimbus import in M4 is idempotent against these).
- Pipelines configurable per job type. Seed residential, commercial project, commercial service ticket (stages as in the TradeFlow v2 spec) and a `homebench_platform` pipeline placeholder (sold, assigned, scheduled, in_progress, discovery_hold, complete, paid).
- `activities` (notes, calls, tasks with due date and assignee; tasks show on the assignee's home screen).
- `attachments` in Supabase Storage by job, tags (before, during, after, damage, QC, discovery, other), EXIF time and GPS kept.
- Screens: pipeline board and table with saved filters; job detail with money-line header (placeholders until M1) and tabs Overview, Contacts, Site, Activity, Files, plus disabled Estimate, Budget, Work orders, Time, Job cost. Quick-add job (site + contact + job in one form) with duplicate detection by phone, email, normalized address.

## 0.5 HomeBench-ready tables (schema now, features later)
Created empty in M0 with RLS and types, so no later milestone needs a re-architecture:
- O13: `job_materials` (job_id, sku, description, quantity, uom, unit_cost, supplier, source, phase: estimate | ordered | received | installed | returned).
- Home-OS: `installed_assets` (site_id, job_id, product, manufacturer, model, serial, install_date, warranty_end, expected_service_life_years, notes).
- O14: `cost_references`, `incentive_programs`, `incentive_rules`, `building_income_profile`, `incentive_lines`, `application_packets` (columns per Blueprint §3; empty is fine).
- Make-It-Right: `callbacks` (original_job_id, callback_job_id, reason, attributed_to: crew | sub | product | design | unknown, cost via financials view).

## 0.6 App shell
Role-based home (Owner, Estimator, PM, Crew placeholder), left nav, command palette, global search across accounts, sites, contacts, jobs. Usable at 360px.

## Out of scope for M0
Estimating, pricing engine beyond `priceFromMargin`, budgets, time, texting, email sending (beyond STUBBED invites), integrations, financials, consumer screens, public marketing pages.

## Acceptance checklist
- [ ] RLS: automated test proves org A cannot read, insert, update, or delete any org B row on every table (test enumerates tables from the schema so new tables are covered automatically).
- [ ] Platform org sees a Committed job only after a `job_access` grant; revoking it removes access (automated).
- [ ] Crew and subcontractor roles get zero rows from every `*_financials` table/view (automated).
- [ ] Quick-add job with new site and contact in under 60 seconds (timed Playwright test).
- [ ] Commercial account with 3 regions and 12 sites; service ticket job against one site with client PO and external WO number.
- [ ] Callback job links to its original job via `parent_job_id` and appears in `callbacks`.
- [ ] Every Wisconsin ZIP in the seed resolves to a metro.
- [ ] Usable at 360px; Lighthouse accessibility 90+ on home, pipeline, job detail.
- [ ] `supabase db reset` from zero passes in CI; staging-migrate workflow applied the migrations to homebench-staging (or BLOCKED on secrets, listed).
- [ ] brand.ts is the only hand-written source file containing the product names and color hex values; generated CSS and docs excepted (automated grep test).
- [ ] CI green. CHANGELOG, PHASE_SIGNOFF, DECISIONS_LOG, PROGRESS, handoff with Supabase spot-check SQL.
