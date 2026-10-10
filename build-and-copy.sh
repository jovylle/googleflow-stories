#!/usr/bin/env bash
#
# build-and-copy.sh — Rebuild the story-maker .md and copy it to the clipboard
# over SSH via OSC 52 in one step.
#
# Usage:
#   ./build-and-copy.sh
#
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
"$ROOT/build.sh"
"$ROOT/copy.sh"
