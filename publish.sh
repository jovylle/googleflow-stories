#!/usr/bin/env bash
#
# publish.sh — Build the instructions and publish them to GitHub so the
# compiled file is reachable at a stable raw URL from any device (browser
# and phone).
#
# What it does:
#   1. Rebuilds build/google-flow-story-maker.md from modules/ (./build.sh).
#   2. Stages the source modules, version.txt, and the generated build file.
#   3. Commits (only if there are changes) and pushes to the current branch.
#   4. Prints the raw URL you can open on any device to copy the instructions.
#
# Note on scope: there is no ChatGPT API to inject instructions into a
# Custom GPT or Project. This command makes the file *available* at one
# canonical URL; pasting it into ChatGPT once per update is still manual.
# Once pasted, ChatGPT syncs it across your browser and phone automatically.
#
# Usage:
#   ./publish.sh                 # commit with an auto-generated message
#   ./publish.sh "your message"  # commit with a custom message
#
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# 1. Rebuild so the committed output always matches the modules.
"$ROOT/build.sh"

# 2. Stage source + output (explicit paths, not `git add .`).
git add modules version.txt build/google-flow-story-maker.md

# 3. Commit only if something is staged.
if git diff --cached --quiet; then
  echo "publish: nothing changed since last publish."
else
  VERSION="$(tr -d '[:space:]' < "$ROOT/version.txt" 2>/dev/null || echo dev)"
  MSG="${1:-publish: build v$VERSION ($(date '+%Y-%m-%d %H:%M:%S'))}"
  git commit -m "$MSG"
fi

# 4. Push to the current branch's upstream (set it up if missing).
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  git push
else
  git push -u origin "$BRANCH"
fi

# 5. Print the raw URL, derived from the origin remote.
REMOTE_URL="$(git remote get-url origin)"
# Normalize git@github.com:owner/repo.git and https URLs -> owner/repo
SLUG="$(printf '%s' "$REMOTE_URL" \
  | sed -E 's#^git@github\.com:##; s#^https://github\.com/##; s#\.git$##')"
RAW_URL="https://raw.githubusercontent.com/$SLUG/$BRANCH/build/google-flow-story-maker.md"

echo
echo "Published to branch: $BRANCH"
echo "Raw URL (open on any device, then copy into ChatGPT instructions):"
echo "  $RAW_URL"
