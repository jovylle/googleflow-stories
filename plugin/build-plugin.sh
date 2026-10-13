#!/usr/bin/env bash
#
# build-plugin.sh — assemble the public ChatGPT plugin package from the
# canonical instruction modules.
#
#   modules/ ──(./build.sh)──> build/google-flow-story-maker.md
#                                   │
#                                   └──> plugin/flow-story-maker/skills/
#                                          flow-story-maker/references/
#                                          gfs-instructions.md
#
# The pack stays the single source of truth: the plugin never hand-edits the
# rulebook, it embeds a generated copy and ships it in the ZIP.
#
# Also stamps the plugin version from version.txt, so one bump releases both.
#
# Usage: ./plugin/build-plugin.sh
#
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG="$ROOT/plugin/flow-story-maker"
NAME="flow-story-maker"
REF="$PKG/skills/flow-story-maker/references/gfs-instructions.md"

# 1. Rebuild the canonical pack (build.sh is the repo's own build).
"$ROOT/build.sh" >/dev/null
VERSION="$(tr -d '[:space:]' < "$ROOT/version.txt")"

# 2. Stamp the plugin version from the pack version.
python3 - "$PKG/plugin.json" "$VERSION" <<'PY'
import json, sys
path, version = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as fh:
    manifest = json.load(fh)
manifest["version"] = version
with open(path, "w", encoding="utf-8") as fh:
    json.dump(manifest, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
PY

# 3. Emit the generated rulebook the skill loads at runtime.
mkdir -p "$(dirname "$REF")"
{
  printf '<!-- GENERATED FILE — do not edit.\n'
  printf '     Source: modules/ in github.com/jovylle/googleflow-stories.\n'
  printf '     Rebuild: ./plugin/build-plugin.sh   (pack v%s) -->\n\n' "$VERSION"
  cat "$ROOT/build/google-flow-story-maker.md"
} > "$REF"

# 4. Deterministic ZIP for the submission portal. dist/ is build output: only
#    the current version's archive is kept, so a stale ZIP can never be uploaded.
mkdir -p "$ROOT/plugin/dist"
rm -f "$ROOT/plugin/dist"/*.zip
ZIP="$ROOT/plugin/dist/$NAME-$VERSION.zip"
( cd "$ROOT/plugin" && zip -r -X -q "$ZIP" "$NAME" -x '*.DS_Store' -x '*/.*' )

echo "plugin:    $NAME v$VERSION"
echo "reference: ${REF#"$ROOT"/}  ($(wc -c < "$REF" | tr -d ' ') chars)"
echo "zip:       ${ZIP#"$ROOT"/}  ($(du -h "$ZIP" | cut -f1 | tr -d ' '))"
