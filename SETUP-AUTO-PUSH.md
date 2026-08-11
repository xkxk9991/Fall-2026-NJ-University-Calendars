# Closing the automation gap — one-time setup, ~5 minutes

## The problem

Claude's sandbox has no network route to github.com — DNS doesn't even resolve there. So the Sunday task can regenerate the `.ics` files in this folder, but it physically cannot publish them. Without this setup you'd be re-uploading by hand every week.

Your Mac can reach GitHub, and your git credentials already live there. So the fix is a small job on your machine that watches this folder and pushes when the files change.

Two pieces, both already written for you:

- `push-calendars.sh` — validates the `.ics` files, then commits and pushes only if something actually changed
- `com.nascent.calendars-push.plist` — a launchd job that runs the script every hour

Running hourly rather than "Sunday at 9am" is deliberate. Cowork's scheduled tasks only run while the app is open — if it's closed Sunday morning, the refresh happens whenever you next launch it. An hourly check catches the update whenever it lands, and costs nothing when there's nothing to do.

---

## Step 1 — Make this folder a git repo

Create a new **public** repo on github.com (public is required for free GitHub Pages). Don't add a README — this folder already has one.

Then in Terminal:

```bash
cd "/Users/xunkaichen/Desktop/Claude CoWork OS/Campus Outreach/Fall 2026 Calendars/github-repo"
git init -b main
git add -A
git commit -m "NJ campus calendars — Fall 2026"
git remote add origin https://github.com/USERNAME/REPO.git
git push -u origin main
```

Replace `USERNAME/REPO` with yours. If prompted to authenticate, macOS will store the credential in Keychain and won't ask again.

## Step 2 — Turn on GitHub Pages

Repo → **Settings** → **Pages** → Source: **Deploy from a branch** → Branch `main`, folder `/ (root)` → **Save**.

A minute later your calendars are live at:

```
https://USERNAME.github.io/REPO/rutgers-new-brunswick.ics
https://USERNAME.github.io/REPO/rutgers-newark.ics
https://USERNAME.github.io/REPO/njit.ics
https://USERNAME.github.io/REPO/princeton.ics
https://USERNAME.github.io/REPO/tcnj.ics
https://USERNAME.github.io/REPO/rider.ics
https://USERNAME.github.io/REPO/essex-county-college.ics
```

## Step 3 — Point index.html at your URL

Open `index.html`, find this line near the bottom, and set it to your Pages URL with no trailing slash:

```js
const BASE = "https://USERNAME.github.io/REPO";
```

Commit and push that change. Now `https://USERNAME.github.io/REPO/` gives you one-click subscribe buttons for all seven.

## Step 4 — Install the auto-push job

```bash
cd "/Users/xunkaichen/Desktop/Claude CoWork OS/Campus Outreach/Fall 2026 Calendars/github-repo"
chmod +x push-calendars.sh
cp com.nascent.calendars-push.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.nascent.calendars-push.plist
```

Verify it's registered:

```bash
launchctl list | grep calendars-push
```

Test it end to end by touching a file and running the script directly:

```bash
./push-calendars.sh && tail -20 ~/Library/Logs/campus-calendars-push.log
```

You should see either "No changes. Nothing to push." or a successful push.

---

## After that

Nothing. The Sunday task researches and regenerates; the hourly job notices and publishes; Google picks it up on its own schedule.

**Google polls external calendars roughly once every 24 hours**, sometimes less often. So a Sunday morning refresh typically surfaces Monday or Tuesday. That's a Google limitation with no workaround — Apple Calendar lets you force a refresh interval, Google doesn't.

## If something goes wrong

Log lives at `~/Library/Logs/campus-calendars-push.log`.

The script **refuses to push** if any `.ics` file is truncated, missing its `BEGIN:`/`END:VCALENDAR` wrapper, or has unbalanced event blocks. That's deliberate — a corrupted file pushed to subscribers is worse than a stale one. If you see a validation error in the log, the calendars on GitHub are still the last good version.

To stop the job:

```bash
launchctl unload ~/Library/LaunchAgents/com.nascent.calendars-push.plist
```

## The alternative, if this is more setup than you want

The Google Calendar connector is working and needs none of this. You'd create seven empty calendars by hand, and the Sunday task would write events into them directly — instant, no hosting, no push, and the events stay editable.

What you'd give up: the calendars would live only in that Google account (currently `nickshariat@gmail.com`, not your Nascent address), and nobody else could subscribe. If sharing these with people at your church or company matters, stay with GitHub Pages.
