#!/usr/bin/env bash
#
# copy.sh — Copy the built story-maker .md to the system clipboard over SSH
# using the OSC 52 terminal escape sequence. Paste the result into the
# ChatGPT Project's Instructions.
#
# Note: OSC 52 support depends on your terminal (and multiplexer). Some
# terminals cap the clipboard payload size. If nothing copies, check that
# your terminal has OSC 52 / clipboard access enabled.
#
# Usage:
#   ./copy.sh
#
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
FILE="$ROOT/build/google-flow-story-maker.md"

if [ ! -f "$FILE" ]; then
  echo "error: $FILE not found. Run ./build.sh first." >&2
  exit 1
fi

# Base64-encode the file (no newlines) and emit the OSC 52 copy sequence.
printf '\033]52;c;%s\a' "$(base64 < "$FILE" | tr -d '\n')"

BYTES="$(wc -c < "$FILE" | tr -d ' ')"
echo "Copied $FILE to clipboard ($BYTES bytes)." >&2
echo "Paste it into the ChatGPT Project's Instructions." >&2
