# NJ Campus Calendars — Fall 2026

Seven subscribable calendars covering the full Fall 2026 semester at New Jersey colleges and universities. Compiled from official university sources only.

| School | File | Events |
|---|---|---|
| Rutgers–New Brunswick | `rutgers-new-brunswick.ics` | 58 |
| Rutgers–Newark | `rutgers-newark.ics` | 33 |
| NJIT | `njit.ics` | 54 |
| Princeton | `princeton.ics` | 44 |
| TCNJ | `tcnj.ics` | 39 |
| Rider | `rider.ics` | 24 |
| Essex County College | `essex-county-college.ics` | 19 |

**271 events total**, including 3 recurring series.

## What's in them

Three categories per school:

- **Campus life** — fairs, festivals, homecoming, family weekends, guest lectures, home football, departmental programming
- **Academic dates** — add/drop, withdrawal deadlines, breaks, reading days, finals
- **Outreach access** — career fairs with fees and deadlines, tabling policies, sponsorship routes

University-run events only. Events hosted by student religious organisations, chaplaincies, campus ministries or outside churches are deliberately excluded. Programming run by a university department stays in — including Offices of Religious Life, which is why Princeton's ORL concert series and open gatherings appear.

Every event title is prefixed `[MAJOR]` or `[minor]` by scale, then the school abbreviation. Each description holds the scale, a summary, an outreach note where relevant, and the source URL.

Times are stored in UTC and display correctly as US Eastern. The generator is DST-aware — events before Nov 1 use EDT, events after use EST.

## Setup

### 1. Enable GitHub Pages

Settings → Pages → Source: **Deploy from a branch** → Branch: `main`, folder `/ (root)` → Save.

Your files will be live at `https://USERNAME.github.io/REPO/rutgers-new-brunswick.ics` within a minute or two.

### 2. Subscribe in Google Calendar

Open `index.html` in a browser for one-click subscribe links, or do it manually:

Google Calendar → **Other calendars** → **+** → **From URL** → paste the `.ics` URL → **Add calendar**.

Repeat for each school you want. Each becomes its own calendar with its own colour, and you can toggle them independently.

### 3. Rename them

Google names subscribed calendars after the URL. Click the three dots next to each → Settings → rename to something readable.

## Things to know

**Google polls external feeds slowly** — typically once every 24 hours, sometimes less often. Updates pushed here on Sunday morning may not appear in your calendar until Monday or Tuesday. This is a Google limitation with no workaround. Apple Calendar lets you set a refresh interval; Google doesn't.

**Subscribed calendars are read-only.** You can't edit an event or add your own notes to one. If you need to annotate something, copy it to your own calendar first.

**Coverage is uneven, by necessity.** Rider and Essex County College publish very little in advance — Rider had no day-by-day welcome week schedule and ECC had no events posted past August. Where a schedule doesn't exist, there's no event here rather than a guess. Several entries are `[ACTION]` reminders to chase a school directly.

**These update themselves.** A scheduled task re-checks all seven schools every Sunday morning and republishes here if anything changed. See [PUBLISHING.md](PUBLISHING.md). Subscribe once and you're done.

## Regenerating

```
python3 gen_ics.py
```

Event data lives in two files: `gen_ics.py` holds welcome week, `semester_events.py` holds everything else. Extend the data tables; don't hand-edit the `.ics` files.

UIDs are content-hashed from school + title + start date, so they stay stable across regenerations. Reordering the event lists won't cause subscribers to see duplicates.

## Sources

Every event links to its source in the description field. Primary sources are the seven registrars' academic calendars, university event feeds (Localist at Rutgers–Newark, iCal feeds at Princeton), career services pages, and individual ministry sites.

Compiled 2026-08-10.
