# Access Applications (start these now; they have lead times the agent cannot clear)

None of these block M0 to M3. They block M4 to M6 if not started early. The agent builds every integration against a fake and marks it STUBBED until the real access exists. Confirm current requirements on each provider's site; processes change.

| Service | Needed by | What to do | Expect |
|---|---|---|---|
| Resend (email) | M0 invites (optional), M4 | Create account, add and verify a sending domain (DNS records) | Same day once DNS is updated |
| Twilio (texting) | M4 | Create account, buy a local number, complete A2P 10DLC brand and campaign registration for business texting | Days to weeks for approval |
| Stripe Connect | M4 | Create platform account, enable Connect, onboard Committed as a connected account in test mode | Test mode same day; live keys after the D7 security audit |
| Intuit Developer (QuickBooks Online) | M6 | Create developer account and app, use the sandbox company; production keys require completing Intuit's app review | Sandbox same day; production review takes longer |
| Hover | M4 | Request API/developer access for Committed's account | Partner or plan approval; confirm with Hover |
| MagicPlan | M4 | Confirm the plan level that includes API access; get API key and customer ID | Depends on plan |
| ABC Supply | M4 / M5 | Apply for API access tied to Committed's account for account-specific pricing | Approval required |
| JobNimbus | M4 / M6 | Generate an API key in JobNimbus settings; export CSVs of contacts, jobs, tasks, notes | Same day |
| HUD USPS ZIP crosswalk | M0 | Download the latest ZIP-to-CBSA file from HUD USER, save to data/seeds/ | Same day (free account) |
