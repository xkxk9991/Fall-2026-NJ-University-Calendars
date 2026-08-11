# How these calendars get published

## The short version

You don't do anything. A Cowork scheduled task runs every Sunday morning, re-checks the seven schools' sites, regenerates the `.ics` files, and pushes them here. GitHub Pages serves them; Google picks up the change within a day or so.

## The chain

1. **Sunday 08:01** — the scheduled task `nj-campus-calendars-weekly-refresh` fires.
2. It re-researches the standing gaps, extends the data tables in `Project Resources/semester_events.py`, and regenerates all seven files with `Project Resources/gen_ics.py`.
3. It runs `push-calendars.sh`, which validates every file and pushes only if something actually changed.
4. GitHub Pages redeploys within about a minute.
5. Google refreshes external calendar subscriptions **roughly once every 24 hours**, sometimes less often. A Sunday morning update typically surfaces Monday or Tuesday. That's a Google limitation with no workaround.

The task is silent. It speaks up only if the generator fails, validation fails, an event is cancelled, or a registration deadline falls within 14 days.

## Publishing by hand

If you've changed something and want it live now:

```bash
"/Users/xunkaichen/Desktop/Claude CoWork OS/Campus Outreach/Fall 2026 Calendars/github-repo/push-calendars.sh"
```

It prints what it did and appends the same to `~/Library/Logs/campus-calendars-push.log`.

## The safety guard

`push-calendars.sh` **refuses to push** if any calendar is missing, empty, truncated, missing its `BEGIN:`/`END:VCALENDAR` wrapper, has unbalanced event blocks, or has fewer `UID:` lines than events. A corrupt feed reaching subscribers is worse than a stale one — if validation fails, what's live stays the last known-good version and the error lands in the log.

## Why there's no launchd job any more

There used to be an hourly `com.nascent.calendars-push` LaunchAgent, on the assumption that Claude couldn't reach github.com and something local had to do the pushing.

It never worked. This repo lives under `~/Desktop`, which macOS protects with TCC, and background launchd agents don't get access to it. Every run failed with `Operation not permitted` (status 126). Fixing it would have meant granting Full Disk Access to `/bin/bash` — a broad permission for one small job.

It's also no longer needed: Claude's sandbox can reach github.com now and your `gh` credentials work, so the Sunday task pushes directly. The agent was unloaded and removed on 2026-08-11.

**The one trade-off:** Cowork scheduled tasks only run while the app is open. If Cowork is closed on Sunday morning, the refresh happens whenever you next launch it, not at 08:01. In practice that means the calendars update within a day or two of Sunday rather than exactly on it — which is well inside Google's own polling lag anyway.

## Turning on Pages (already done, for reference)

Repo → **Settings** → **Pages** → Source: **Deploy from a branch** → Branch `main`, folder `/ (root)`.

Live URLs:

```
https://xkxk9991.github.io/Fall-2026-NJ-University-Calendars/
https://xkxk9991.github.io/Fall-2026-NJ-University-Calendars/rutgers-new-brunswick.ics
https://xkxk9991.github.io/Fall-2026-NJ-University-Calendars/rutgers-newark.ics
https://xkxk9991.github.io/Fall-2026-NJ-University-Calendars/njit.ics
https://xkxk9991.github.io/Fall-2026-NJ-University-Calendars/princeton.ics
https://xkxk9991.github.io/Fall-2026-NJ-University-Calendars/tcnj.ics
https://xkxk9991.github.io/Fall-2026-NJ-University-Calendars/rider.ics
https://xkxk9991.github.io/Fall-2026-NJ-University-Calendars/essex-county-college.ics
```

## If a push fails

Check auth first:

```bash
gh auth status
```

Then the log:

```bash
tail -40 ~/Library/Logs/campus-calendars-push.log
```
