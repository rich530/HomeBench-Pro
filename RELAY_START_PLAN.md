# HomeBench Pro: The Relay Start Plan

Start the build on any computer today, then hand the baton to the MacBook, which builds all night by itself. This replaces SETUP_TODAY.md from Build Kit v3.

---

## How this works (the relay race)

Think of it as a relay race with three pieces:

- **Computer 1 (any computer with a web browser)** runs the first leg. You only use websites here: GitHub, Supabase, Claude Code on the web, and the HomeBench Project. Claude writes the M0 plan in the cloud, and you review it and approve it.
- **GitHub is the baton.** Everything gets saved there. When the plan is approved and "merged," the baton has been handed off.
- **The MacBook runs the rest of the race.** It picks up the approved plan from GitHub and builds M0 one task at a time, all night, while you sleep. Your phone buzzes only when it needs you.

**Time:** about 75 minutes for Stage 1 and 75 minutes for Stage 2. After that, about 10 minutes a day.

## What you need before you start

- [ ] The file `homebench-pro-build-kit-v3.1.zip` from the HomeBench Project chat, downloaded to Computer 1.
- [ ] Your iPhone.
- [ ] A safe place to save passwords (Apple Passwords or your password manager). Never email passwords to yourself.
- [ ] Your MacBook, its charger, and your MacBook login password.
- [ ] One or two real Committed estimating workbooks (Excel files), plus the price book file `TradeBench_10_Price_Book_v1.xlsx`. These go on the MacBook in Stage 2.

## Words you will see (cheat sheet)

| Word | What it means |
|---|---|
| GitHub | A website that stores the code, like an online locker. |
| Repo | One locker on GitHub. Ours is named `homebench`. |
| main | The official copy of everything in the repo. |
| Branch | A practice copy where changes are made without touching main. |
| Pull request (PR) | A request that says "please put these changes into main." |
| Merge | Saying yes to a PR. The changes go into main. |
| Check (green or red) | GitHub automatically tests every PR. Green means it passed. |
| Supabase | The database, where HomeBench Pro's data will live. |
| Claude Code | A version of Claude that can write code and work on a computer. |
| Claude Code on the web | The same thing, running in Anthropic's cloud from your browser. |
| Terminal | A Mac app where you type commands. |
| Command | One line you type (or paste) into Terminal, then press Enter. |
| autorun | Our robot script that runs Claude Code task after task. |
| tmux | Keeps autorun running even if you close the Terminal window. |
| ntfy | A free phone app that shows alerts from the MacBook. |

**How to paste into Terminal:** copy the gray text, click inside the Terminal window, press Cmd+V, then press Enter.

**Copying prompts:** always copy prompts from `setup/STARTER_PROMPTS.md` or the Starter Prompts file, not from a PDF. PDFs sometimes break lines when you copy.

---

# STAGE 1: Computer 1 (browser only)

## Step 1. Update the HomeBench Project (skip anything already done)

1. Open claude.ai, then the **HomeBench - Build HQ** Project.
2. Replace the Project instructions with the contents of `HomeBench_Master_Instructions_v4_0.md`, then save.
3. In Project knowledge, remove Blueprint v2.9 and upload `HomeBench_Master_Blueprint_v3_0.md`.
4. Unzip the kit:
   - **Mac:** double-click the zip.
   - **Windows:** right-click it, choose Extract All, then Extract.

   You now have a folder named `homebench-pro-build-kit`.
5. Upload these files from that folder into Project knowledge:
   - `CLAUDE.md`
   - `docs/DECISIONS_LOG.md`
   - `docs/phases/M0_FOUNDATION.md`
   - `docs/phases/M1_ENGINE_PRICEBOOK_ESTIMATE.md`
   - `docs/phases/M2_BUDGET_WORKORDERS_GATE.md`
   - `docs/phases/M3_TIME_FIELD_JOBCOST_LOOP.md`
   - `docs/phases/ROADMAP_AFTER_PRO.md`
   - `claude-project/HANDOFF_TEMPLATE.md`

**You should see:** those files listed in Project knowledge.

## Step 2. Make the GitHub repo (skip if `rich530/homebench` already exists)

1. Go to github.com and sign in as **rich530**.
2. Click the **+** at the top right, then **New repository**.
3. Fill it in:
   - Repository name: `homebench`
   - Choose **Private**.
   - Do NOT tick "Add a README file."
4. Click **Create repository**.

**You should see:** a "Quick setup" page with a link that says **uploading an existing file**.

## Step 3. Put the kit into the repo

1. Click **uploading an existing file**.
2. Open the `homebench-pro-build-kit` folder on your computer.
   - **Mac:** press **Cmd+Shift+.** (Command, Shift, period) in the Finder window. Hidden items now show: `.github`, `.claude`, `.gitignore`.
   - **Windows:** they already show.
3. Select EVERYTHING inside the folder, not the folder itself (Mac: Cmd+A; Windows: Ctrl+A).
4. Drag it all onto the GitHub upload box. Wait until the file list stops growing.
5. In the message box at the bottom, type: `HomeBench Pro build kit v3.1`
6. Click **Commit changes**.

**You should see:** the repo page listing `.claude`, `.github`, `claude-project`, `docs`, `scripts`, `setup`, `.gitignore`, `CLAUDE.md`, and `README.md`.

**If `.github`, `.claude`, or `.gitignore` is missing:**
- Click **Add file**, then **Create new file**.
- Type the exact name from Appendix A (for example `.github/workflows/ci.yml`; typing the `/` makes the folders for you).
- Paste the contents from Appendix A and click **Commit changes**.
- Repeat for each missing file.

## Step 4. Wait for the first green check

1. Click the **Actions** tab at the top of the repo.
2. Wait 1 to 3 minutes.

**You should see:** a run named **ci** with a green check. That creates the check the guardrails in Step 6 need.

## Step 5. Turn on auto-merge

1. Click **Settings** (top of the repo), then **General** on the left.
2. Scroll to **Pull Requests**.
3. Tick **Allow auto-merge**.
4. Tick **Automatically delete head branches**.

It saves by itself.

## Step 6. Make the production branch and the guardrails

1. **Create the production branch:** click **Code** (top left), click the button that says **main**, type `production`, then click **Create branch production from main**.
2. **Protect main:** go to **Settings**, then **Branches**, then **Add classic branch protection rule**. (If you only see "Add branch ruleset," use that; the choices are the same idea.)
   - Branch name pattern: `main`
   - Tick **Require a pull request before merging**, and untick "Require approvals" if it is ticked.
   - Tick **Require status checks to pass before merging**, type `ci` in the search box, and click it.
   - Click **Create**.
3. **Protect production:** add another rule.
   - Branch name pattern: `production`
   - Tick **Require a pull request before merging**.
   - Click **Create**.

**You should see:** two rules, one for `main` and one for `production`.

## Step 7. Make the two Supabase databases

1. Go to supabase.com and sign in. "Continue with GitHub" is easiest.
2. Click **New project**:
   - Name: `homebench-staging`
   - Database password: click **Generate a password**, then save it in your password manager as "homebench-staging DB password."
   - Region: a US region.
   - Click **Create new project**.
3. Do it again with the name `homebench-prod`, and save "homebench-prod DB password."
4. For each project, open it, go to Project Settings, then General, and save the **Project ID** in your password manager.
5. Make an access token: click your picture (top right), then Account preferences, then **Access Tokens**, then **Generate new token**. Name it `github-actions`, then copy it and save it. You only see it once.

## Step 8. Give GitHub the database keys

1. **Staging secrets:** in the repo, go to **Settings**, then **Secrets and variables**, then **Actions**, then **New repository secret**. Add these three, one at a time:
   - Name `SUPABASE_ACCESS_TOKEN`, value: the access token.
   - Name `STAGING_PROJECT_REF`, value: the staging Project ID.
   - Name `STAGING_DB_PASSWORD`, value: the staging DB password.
2. **Production environment:** go to **Settings**, then **Environments**, then **New environment**.
   - Name it `production` and click **Configure environment**.
   - Tick **Required reviewers**, type `rich530`, select yourself, and click **Save protection rules**.
   - On the same page, click **Add environment secret** twice:
     - `PROD_PROJECT_REF`: the prod Project ID.
     - `PROD_DB_PASSWORD`: the prod DB password.

The production keys live only here, and in Vercel later. They never go on the MacBook.

## Step 9. Phone alerts

1. On your iPhone, install the free app **ntfy** from the App Store.
2. Open it, tap **+**, and make up a topic name nobody could guess, like `hb-rich-7Q4x9`.
3. Tap **Subscribe**.
4. Write the topic name down. You need it in Stage 2.

## Step 10. Connect Claude Code on the web to the repo

1. Go to **claude.ai/code** and sign in with your Claude account.
2. When it asks, connect **GitHub** and install the **Claude GitHub App**. When GitHub asks which repositories, choose **Only select repositories**, then **homebench**, then **Install**.
3. Back on claude.ai/code, pick the repository **rich530/homebench** and leave the environment on its default.

**You should see:** a box where you can type a task for Claude.

## Step 11. Start the build (PROMPT 1)

1. Paste **PROMPT 1** into the box and send it.
2. Claude works for about 10 to 30 minutes. You can close the tab and come back; it keeps working.

**You should see at the end:** a short summary, the number of tasks, and the full plan and task list printed in the chat.

## Step 12. Make the pull request

1. In the Claude Code session, click **Create PR**. It opens, or links to, a GitHub pull request page.
2. Wait for the **ci** check to turn green.
3. Do NOT merge yet.

## Step 13. Get the plan reviewed (PROMPT 2)

1. In the web session, copy the printed plan and the printed `## M0` task list (use the copy button on each message).
2. Open a **new chat** in the HomeBench - Build HQ Project.
3. Paste **PROMPT 2**, then paste the plan and task list where it says to.
4. Check the verdict:
   - **"Approve":** go to Step 15.
   - **"Approve with notes" or "Reject":** go to Step 14.

## Step 14. Fix the plan (PROMPT 3), only if needed

1. Copy the notes block the Project gave you.
2. Go back to the SAME Claude Code web session, paste **PROMPT 3**, and put the notes where it says to.
3. Claude updates the plan on the same pull request.
4. Repeat Step 13 with the new printed plan until the verdict is **Approve**.

## Step 15. Hand off the baton (merge)

1. Open the pull request on GitHub and wait for the green **ci** check.
2. Click **Squash and merge**, then **Confirm squash and merge**.

**You should see:** "Pull request successfully merged and closed." On the repo's **Code** tab, `docs/plans/M0_PLAN.md` now exists.

**The baton is in GitHub.** Computer 1 is done.

---

# STAGE 2: The MacBook (builds all night)

## Step 16. Make the MacBook stay awake (in YOUR normal account)

1. Plug in the charger. It stays plugged in from now on.
2. Keep the lid OPEN. A MacBook falls asleep when the lid closes. The screen going dark is fine.
3. Go to System Settings, then **Battery**, then **Options...**:
   - Turn ON **Prevent automatic sleeping on power adapter when the display is off**.
   - Set **Wake for network access** to Always, or Only on power adapter.
4. In Battery, set **Low Power Mode** to **Never**.
5. Go to System Settings, then General, then Software Update, then the (i) next to Automatic updates, and turn OFF **Install macOS updates**. That way it never restarts itself overnight; you'll update by hand on a weekend.

(Menu names can be slightly different depending on your macOS version. Look for the closest match.)

## Step 17. Make the build user "hbbuild"

1. Go to System Settings, then **Users & Groups**, then **Add User...** (type your password if asked).
2. Fill it in:
   - New User: **Administrator** (it must be admin to install things; you'll switch it back later).
   - Full name: `HomeBench Build`
   - Account name: `hbbuild`
   - Password: make one and save it.
3. Click **Create User**.
4. **If hbbuild already exists on this MacBook:** click the (i) next to it and turn ON **Allow this user to administer this computer**.
5. Apple menu, then **Log Out**. Log in as **hbbuild**.

## Step 18. Open Terminal

Press **Cmd+Space**, type `Terminal`, and press Enter. A window with a blinking cursor opens. Every gray box from here on gets pasted into this window.

## Step 19. Install Homebrew (the app installer)

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

1. When it asks for a password, type **hbbuild's** password. You won't see any dots; that's normal. Press Enter.
2. Press Enter again when it says "Press RETURN to continue." Then wait about 5 minutes.
3. At the end it prints **Next steps** with lines to run. Copy and paste those lines. On most MacBooks they are:

```
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

4. Check it:

```
brew --version
```

**You should see:** "Homebrew" and a version number.

## Step 20. Install the tools

```
brew install git gh jq coreutils tmux node supabase/tap/supabase
```

This takes 5 to 10 minutes. **You should see:** it finish without the word "Error."

## Step 21. Install Docker Desktop

1. In Safari, go to docker.com, then Download Docker Desktop, then **Mac with Apple chip**. (Pick Intel only if the MacBook is older than 2020.)
2. Open the download and drag Docker into Applications.
3. Open Docker from Applications and accept the terms. If it asks for a password to install a helper, type hbbuild's password. You can skip signing in.
4. In Docker, click the gear (Settings), then General, and tick **Start Docker Desktop when you sign in to your computer**.

**You should see:** a small whale icon at the top of the screen.

## Step 22. Install Claude Code and log in

1. In Safari, go to **code.claude.com/docs** and open the Setup (or Quickstart) page.
2. Copy the macOS install command and paste it in Terminal. At the time of writing it looks like `curl -fsSL https://claude.ai/install.sh | bash`; use what the page shows.
3. Quit Terminal (Cmd+Q) and open it again (Step 18).
4. Check the version:

```
claude --version
```

It must be **2.1.259 or higher**.

5. Log in:

```
claude
```

   - Pick a color theme with the arrow keys and press Enter.
   - Choose to log in with your **Claude account** (subscription). A browser opens; click Authorize.
   - Back in Terminal, type `/exit` and press Enter.

## Step 23. Log in to GitHub from Terminal

```
gh auth login
```

Answer with the arrow keys and Enter:
- **GitHub.com**
- **HTTPS**
- Authenticate Git with your GitHub credentials? **Yes**
- **Login with a web browser**

It shows an 8-character code. Press Enter and a browser opens. Paste the code, click **Authorize**, and come back to Terminal.

**You should see:** "Logged in as rich530."

## Step 24. Download the repo to the MacBook

```
cd ~ && gh repo clone rich530/homebench && cd homebench && ls
```

**You should see:** `CLAUDE.md  README.md  claude-project  docs  scripts  setup`

## Step 25. Give it your real files (they never go to GitHub)

```
mkdir -p ~/homebench/data/private && open ~/homebench/data/private
```

A Finder window opens. Drag in these files:
- your Committed estimating workbook(s);
- `TradeBench_10_Price_Book_v1.xlsx`.

## Step 26. Teach auto mode about your setup (so it doesn't stop to ask you)

```
mkdir -p ~/.claude && [ -f ~/.claude/settings.json ] && cp ~/.claude/settings.json ~/.claude/settings.backup.json; cp ~/homebench/setup/user-settings.autoMode.json ~/.claude/settings.json && claude auto-mode config | grep -c -i homebench
```

**You should see:** a number bigger than 0.

## Step 27. Connect your phone alerts

Replace `hb-rich-7Q4x9` with YOUR topic from Step 9, in BOTH places:

```
echo 'NTFY_TOPIC=hb-rich-7Q4x9' > ~/.homebench-autorun.env && curl -d "MacBook test: HomeBench alerts work" ntfy.sh/hb-rich-7Q4x9
```

**You should see:** your iPhone buzz with "MacBook test."

## Step 28. Start the build (PROMPT 4)

```
cd ~/homebench && tmux new -s build
```

The window clears and a green bar appears at the bottom. That means you're inside tmux. Now paste:

```
caffeinate -i ./scripts/autorun.sh approve M0
```

1. Watch for 2 minutes. You should see lines like "Plan M0 approved by Rich," "Build started," and "Session start: T-001."
2. **Leave it running:** hold **Control**, press **b**, let go of both, then press **d**. You're back at a normal window, and the build keeps going inside tmux.
3. Your phone buzzes: "Build started for M0."

**Walk away.** Leave the MacBook plugged in, lid open, logged in as hbbuild.

## What the phone buzzes mean

| Buzz says | What it means | What you do |
|---|---|---|
| Build started for M0 | It's working. | Nothing. |
| New blocker on T-0xx | A task needs something only you can give (a file, a password). It moved on to the next task. | On GitHub, read `docs/BLOCKERS.md`, provide the item, then run the unblock command in Stage 3. |
| Task T-0xx did not merge / failed twice | Something is really stuck. It stopped. | Do the "Stuck" row in the trouble table. |
| Usage limit | Your Claude plan hit its limit. | Nothing. It waits and continues by itself. |
| M0 queue empty | M0 is built. | Do "When M0 is done" in Stage 3. |

---

# STAGE 3: Next morning and after

## Check on it (on the MacBook)

```
cd ~/homebench && ./scripts/autorun.sh status
```

This shows tasks done, open, and blocked, plus the last progress notes.

To watch it live:

```
tmux attach -t build
```

When you're done watching, press Control+b, then d.

**From your phone or any computer:** open the repo on GitHub. The **Pull requests** tab (Closed) shows every finished task.

## Clear a blocker

After you provide what `BLOCKERS.md` asked for, run this (change `T-014` to the real number):

```
cd ~/homebench && ./scripts/autorun.sh unblock T-014
```

## Connect Vercel (once the repo has a file named package.json, usually after the first night)

1. Go to vercel.com and sign up with GitHub.
2. Click **Add New**, then **Project**, then **Import** next to `homebench`, then **Deploy**. It's fine if the first deploy fails.
3. In the project, go to **Settings**, then **Git**, set Production Branch to `production`, and save.
4. Go to **Settings**, then **Environment Variables**. Add each of these three twice: once for **Preview** with staging values, once for **Production** with prod values. (Find them in Supabase under Project Settings, then API.)
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`

## After the first good night: lock hbbuild back down

1. Log into YOUR normal account.
2. Go to System Settings, then Users & Groups, click the (i) next to hbbuild, and turn OFF **Allow this user to administer this computer**.
3. Log back into hbbuild. If the build stopped, use the first row of the trouble table.

## Trouble table

| Problem | Fix |
|---|---|
| MacBook restarted or the power went out | Log in as hbbuild, open Terminal, paste `cd ~/homebench && tmux new -s build`, then `caffeinate -i ./scripts/autorun.sh build`, then press Control+b, d. |
| "Docker is not running" | Open Docker from Applications, wait for the whale, run the build command again. |
| "GitHub CLI not logged in" | Run `gh auth login` (Step 23). |
| "Plan M0 is not approved" | Run `./scripts/autorun.sh approve M0`. |
| Stuck: failed twice or did not merge | Paste `tail -n 40 ~/homebench/.autorun/logs/runner.log`, copy what appears, paste it in the HomeBench Project, and say **BUILD troubleshoot**. |
| Want it to stop for now | `./scripts/autorun.sh stop` (it finishes the current task first). |

## When M0 is done

1. Open `docs/handoffs/M0_HANDOFF.md` on GitHub and paste it into the HomeBench Project with **Review M0 handoff**.
2. Run the handoff's Supabase spot-check: in Supabase, open homebench-staging, go to SQL Editor, paste, and click Run.
3. When everything is green, start the next milestone:

```
./scripts/autorun.sh plan M1
```

---

# Appendix A: Hidden files (only if Step 3 did not upload them)

**File name:** `.gitignore`

```
node_modules/
.next/
.env
.env.*
!.env.example
.autorun/
data/private/
supabase/.temp/
*.log
.DS_Store
```

**File name:** `.github/workflows/ci.yml`

```
name: ci
on:
  pull_request:
  push:
    branches: [main]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - name: Checks
        run: |
          if [ -f package.json ]; then
            npm ci
            npm run typecheck --if-present
            npm run lint --if-present
            npm test --if-present
          else
            echo "Kit only, no app yet."
          fi
```

**File name:** `.claude/settings.json`

```
{
  "permissions": {
    "deny": [
      "Bash(supabase link)",
      "Bash(supabase link *)",
      "Bash(supabase db push)",
      "Bash(supabase db push *)",
      "Bash(supabase db reset --linked*)",
      "Bash(supabase db reset --db-url*)",
      "Bash(vercel --prod*)",
      "Bash(vercel deploy --prod*)",
      "Bash(vercel promote *)",
      "Bash(vercel env pull*)",
      "Bash(git push --force*)",
      "Bash(git push -f*)",
      "Bash(git push origin production*)",
      "Bash(git push origin HEAD:production*)",
      "Bash(git checkout production*)",
      "Bash(gh pr merge * --admin*)",
      "Bash(gh api -X DELETE *)",
      "Bash(gh repo delete *)",
      "Read(./.env.production)",
      "Read(./.env.production.*)"
    ]
  }
}
```
