#!/bin/bash
# Auto-push updated campus calendars to GitHub Pages.
#
# Runs on YOUR Mac (not in Claude's sandbox, which has no network access to
# github.com). Checks whether the .ics files actually changed and pushes only
# if they did, so it is free to run often.
#
# Setup instructions are in SETUP-AUTO-PUSH.md.

set -euo pipefail

REPO="/Users/xunkaichen/Desktop/Claude CoWork OS/Campus Outreach/Fall 2026 Calendars/github-repo"
LOG="$HOME/Library/Logs/campus-calendars-push.log"

exec >>"$LOG" 2>&1
echo "--- $(date '+%Y-%m-%d %H:%M:%S') ---"

cd "$REPO" || { echo "ERROR: repo folder not found at $REPO"; exit 1; }

if [ ! -d .git ]; then
  echo "ERROR: not a git repository. Run the one-time setup in SETUP-AUTO-PUSH.md first."
  exit 1
fi

# Nothing changed? Exit quietly. This is the normal case most of the time.
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "No changes. Nothing to push."
  exit 0
fi

# Sanity check before publishing: every .ics must parse as a well-formed
# calendar. Prevents pushing a truncated or corrupted file to subscribers.
for f in *.ics; do
  if ! head -1 "$f" | grep -q '^BEGIN:VCALENDAR'; then
    echo "ERROR: $f does not start with BEGIN:VCALENDAR — refusing to push."
    exit 1
  fi
  if ! tail -2 "$f" | grep -q '^END:VCALENDAR'; then
    echo "ERROR: $f does not end with END:VCALENDAR — refusing to push."
    exit 1
  fi
  n_begin=$(grep -c '^BEGIN:VEVENT' "$f" || true)
  n_end=$(grep -c '^END:VEVENT' "$f" || true)
  if [ "$n_begin" != "$n_end" ]; then
    echo "ERROR: $f has unbalanced VEVENT blocks ($n_begin/$n_end) — refusing to push."
    exit 1
  fi
done

TOTAL=$(grep -c '^BEGIN:VEVENT' ./*.ics | awk -F: '{s+=$2} END {print s}')
echo "Validation passed. $TOTAL events across $(ls -1 ./*.ics | wc -l | tr -d ' ') calendars."

git add -A
git commit -m "Weekly calendar refresh — $(date '+%Y-%m-%d') ($TOTAL events)"

if git push; then
  echo "Pushed successfully."
else
  echo "ERROR: push failed. Check your credentials or network."
  exit 1
fi
