#!/bin/bash
# Validate and publish the campus calendars to GitHub Pages.
#
# Called by the Sunday Cowork task after it regenerates the .ics files, and
# safe to run by hand any time. Exits immediately when nothing changed, so
# running it more often than needed costs nothing.
#
# It REFUSES to push if any .ics looks truncated or malformed. A corrupt feed
# reaching subscribers is worse than a stale one.
#
# Notes in PUBLISHING.md.

set -euo pipefail

REPO="/Users/xunkaichen/Desktop/Claude CoWork OS/Campus Outreach/Fall 2026 Calendars/github-repo"
LOG="$HOME/Library/Logs/campus-calendars-push.log"
EXPECTED_FILES=8

mkdir -p "$(dirname "$LOG")"
# Log to file AND stdout, so both the scheduled task and a human running this
# in Terminal can see what happened.
exec > >(tee -a "$LOG") 2>&1
echo "--- $(date '+%Y-%m-%d %H:%M:%S') ---"

cd "$REPO" || { echo "ERROR: repo folder not found at $REPO"; exit 1; }

if [ ! -d .git ]; then
  echo "ERROR: not a git repository. See SETUP-AUTO-PUSH.md."
  exit 1
fi

# Nothing changed? Exit quietly. This is the normal case most of the time.
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "No changes. Nothing to push."
  exit 0
fi

# A missing file is as dangerous as a corrupt one - a regeneration that wrote
# only some of the calendars would silently drop a school from the site.
n_files=$(ls -1 ./*.ics 2>/dev/null | wc -l | tr -d ' ')
if [ "$n_files" != "$EXPECTED_FILES" ]; then
  echo "ERROR: found $n_files .ics files, expected $EXPECTED_FILES - refusing to push."
  exit 1
fi

TOTAL=0
for f in *.ics; do
  if ! head -1 "$f" | grep -q '^BEGIN:VCALENDAR'; then
    echo "ERROR: $f does not start with BEGIN:VCALENDAR - refusing to push."
    exit 1
  fi
  if ! tail -2 "$f" | grep -q '^END:VCALENDAR'; then
    echo "ERROR: $f does not end with END:VCALENDAR - refusing to push."
    exit 1
  fi
  # grep -c exits 1 on zero matches, which would trip `set -e`, hence `|| true`.
  n_begin=$(grep -c '^BEGIN:VEVENT' "$f" || true)
  n_end=$(grep -c '^END:VEVENT' "$f" || true)
  if [ "$n_begin" != "$n_end" ]; then
    echo "ERROR: $f has unbalanced VEVENT blocks ($n_begin/$n_end) - refusing to push."
    exit 1
  fi
  if [ "$n_begin" -eq 0 ]; then
    echo "ERROR: $f contains no events - refusing to push."
    exit 1
  fi
  # Every event needs a UID, or subscribers get duplicates instead of updates.
  n_uid=$(grep -c '^UID:' "$f" || true)
  if [ "$n_uid" != "$n_begin" ]; then
    echo "ERROR: $f has $n_begin events but $n_uid UIDs - refusing to push."
    exit 1
  fi
  TOTAL=$(( TOTAL + n_begin ))
done

echo "Validation passed. $TOTAL events across $n_files calendars."

git add -A
git commit -m "Calendar refresh - $(date '+%Y-%m-%d') ($TOTAL events)"

if git push; then
  echo "Pushed successfully. Live at https://xkxk9991.github.io/Fall-2026-NJ-University-Calendars/"
else
  echo "ERROR: push failed. Check credentials (gh auth status) or network."
  exit 1
fi
