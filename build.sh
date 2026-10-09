#!/usr/bin/env bash
#
# build.sh — Compile the modular source files in modules/ into a single
# ChatGPT-ready instruction file: build/google-flow-story-maker.md
#
# Modules are concatenated in filename order (00-, 01-, 02-, ...), so the
# numeric prefixes define the document order. The {{VERSION}} placeholder in
# the header module is replaced with the contents of version.txt.
#
# Usage:
#   ./build.sh
#
set -eu

# Resolve the repo root (directory this script lives in).
ROOT="$(cd "$(dirname "$0")" && pwd)"
MODULES_DIR="$ROOT/modules"
BUILD_DIR="$ROOT/build"
OUT="$BUILD_DIR/google-flow-story-maker.md"
VERSION_FILE="$ROOT/version.txt"

# Read the version number (trimmed). Fall back to "dev" if missing.
if [ -f "$VERSION_FILE" ]; then
  VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
else
  VERSION="dev"
fi

# Ensure there is at least one module.
if ! ls "$MODULES_DIR"/*.md >/dev/null 2>&1; then
  echo "error: no modules found in $MODULES_DIR" >&2
  exit 1
fi

mkdir -p "$BUILD_DIR"

# Concatenate modules in sorted order, blank line between each, into a temp file.
TMP="$(mktemp)"
first=1
for module in $(ls "$MODULES_DIR"/*.md | sort); do
  if [ "$first" -eq 0 ]; then
    printf '\n' >> "$TMP"
  fi
  cat "$module" >> "$TMP"
  first=0
done

# Substitute the version placeholder and write the final output.
sed "s/{{VERSION}}/$VERSION/g" "$TMP" > "$OUT"
rm -f "$TMP"

MODULE_COUNT="$(ls "$MODULES_DIR"/*.md | wc -l | tr -d ' ')"
echo "Built $OUT"
echo "  version: $VERSION"
echo "  modules: $MODULE_COUNT"
echo "  lines:   $(wc -l < "$OUT" | tr -d ' ')"
