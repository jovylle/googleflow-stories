#!/usr/bin/env bash
#
# validate-plugin.sh — structural validation of the ChatGPT plugin package
# against the published package and submission rules:
#   https://developers.openai.com/plugins/build/plugins
#   https://developers.openai.com/plugins/deploy/submission
#   https://developers.openai.com/plugins/plugin-guidelines
#
# Checks the package the ZIP is made from (not the ZIP alone): manifest schema
# and field limits, skills layout, icon requirements, the skills-only boundary,
# reference-pack freshness, and secret hygiene.
#
# Exit code 0 = pass. Run before every ./build-plugin.sh upload.
#
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG="$ROOT/plugin/flow-story-maker"
NAME="flow-story-maker"
REF="$PKG/skills/flow-story-maker/references/gfs-instructions.md"
ZIP="$ROOT/plugin/dist/$NAME-$(tr -d '[:space:]' < "$ROOT/version.txt").zip"
REPORT="$(mktemp)"
trap 'rm -f "$REPORT"' EXIT

ok()   { printf '  ok    %s\n' "$1" >> "$REPORT"; }
fail() { printf '  FAIL  %s\n' "$1" >> "$REPORT"; }

echo "package: ${PKG#"$ROOT"/}"
echo "----------------------------------------"

# ---------------------------------------------------------------- package shape
[ -f "$PKG/plugin.json" ] && ok "plugin.json present" || fail "plugin.json missing"
[ -f "$PKG/skills/flow-story-maker/SKILL.md" ] && ok "primary skill present" || fail "primary skill SKILL.md missing"
[ -f "$PKG/skills/get-started/SKILL.md" ] && ok "onboarding skill present" || fail "onboarding skill SKILL.md missing"

# Skills-only boundary: MCP servers, app references and lifecycle hooks cannot be
# submitted in the same package, and the skills/MCP decision is irreversible.
for f in "$PKG/mcp.json" "$PKG/.mcp.json" "$PKG/.app.json"; do
  if [ -e "$f" ]; then fail "unexpected $(basename "$f") — this package must stay skills-only"; fi
done
if [ -d "$PKG/hooks" ]; then fail "hooks/ present — remove before directory submission"; fi
if [ -d "$PKG/.codex-plugin" ]; then fail ".codex-plugin/ present — portable root plugin.json expected"; fi
if [ -d "$PKG/skills" ]; then ok "skills/ discovered automatically (portable layout)"; else fail "skills/ directory missing"; fi

# --------------------------------------------------------------------- manifest
python3 - "$PKG/plugin.json" "$ROOT/version.txt" "$PKG" <<'PY' >> "$REPORT"
import json, re, sys, math

manifest_path, version_path, pkg = sys.argv[1], sys.argv[2], sys.argv[3]
ok = lambda m: print(f"  ok    {m}")
bad = lambda m: print(f"  FAIL  {m}")

try:
    with open(manifest_path, encoding="utf-8") as fh:
        m = json.load(fh)
except Exception as exc:                                  # noqa: BLE001
    bad(f"plugin.json does not parse: {exc}")
    raise SystemExit(0)

ok("plugin.json parses")

ALLOWED = {"$schema", "name", "version", "description", "author", "homepage",
           "repository", "license", "keywords", "extensions"}
extra = set(m) - ALLOWED
if extra:
    bad(f"manifest schema is additionalProperties:false — remove {sorted(extra)}")
else:
    ok("no unknown top-level keys")

if m.get("$schema") == "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json":
    ok("Agent Plugins schema declared")
else:
    bad(f"$schema must be the 1.0.0 Agent Plugins schema, got {m.get('$schema')!r}")

name = m.get("name", "")
if re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) and len(name) <= 64:
    ok(f"name is a stable lowercase-hyphen identifier ({name})")
else:
    bad(f"name must be lowercase letters/numbers/single hyphens, <=64 chars, got {name!r}")

version = (open(version_path, encoding="utf-8").read().strip())
if m.get("version") == version:
    ok(f"version matches version.txt ({version})")
else:
    bad(f"version {m.get('version')!r} != version.txt {version!r} — run ./plugin/build-plugin.sh")
if re.fullmatch(r"\d+\.\d+\.\d+", m.get("version", "")):
    ok("version is an explicit semantic version")
else:
    bad(f"version must be semver for submission, got {m.get('version')!r}")

desc = m.get("description", "")
ok(f"root description present ({len(desc)} chars)") if desc and len(desc) <= 4000 else bad("root description missing or over 4000 chars")

author = m.get("author", {})
ok("author.name present") if author.get("name") else bad("author.name missing")
if "email" in author and author["email"]:
    bad("author.email is set — keep contact in the dashboard, not the package")
if author.get("url", "").startswith("https://") or not author.get("url"):
    ok("author.url is https or absent")
else:
    bad("author.url must be https")

for key in ("homepage", "repository"):
    val = m.get(key)
    if val and not val.startswith("https://"):
        bad(f"{key} must be https")
ok("homepage and repository are https URLs")

ext = m.get("extensions", {}).get("com.openai", {})
if not ext:
    bad("extensions.com.openai missing")
iface = ext.get("interface", {})
if iface:
    ok("interface present under extensions.com.openai")

LIMITS = {"displayName": 30, "shortDescription": 30, "longDescription": 4000, "developerName": 80}
for field, limit in LIMITS.items():
    val = iface.get(field, "")
    if not val:
        bad(f"interface.{field} is required")
    elif len(val) > limit:
        bad(f"interface.{field} is {len(val)} chars (limit {limit}): {val[:60]!r}")
    else:
        ok(f"interface.{field} within {limit} chars ({len(val)})")

cats = iface.get("category", "")
ok(f"category declared ({cats})") if cats else bad("interface.category is required (dashboard list)")

caps = iface.get("capabilities", [])
if len(caps) <= 20 and all(len(c) <= 120 for c in caps):
    ok(f"capabilities within limits ({len(caps)} items)")
else:
    bad("capabilities must be <=20 items of <=120 chars each")

prompts = iface.get("defaultPrompt", [])
prompts = [prompts] if isinstance(prompts, str) else prompts
if len(prompts) <= 3 and all(len(p) <= 128 for p in prompts):
    ok(f"defaultPrompt within limits ({len(prompts)} prompts)")
else:
    bad("defaultPrompt must be <=3 prompts of <=128 chars each")
if any("@" in p for p in prompts):
    bad("defaultPrompt must not contain app @mentions")

def luminance(hex_color):
    h = hex_color.lstrip("#")
    if len(h) != 6:
        return None
    parts = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    parts = [(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4) for c in parts]
    return 0.2126 * parts[0] + 0.7152 * parts[1] + 0.0722 * parts[2]

def ratio(a, b):
    la, lb = luminance(a), luminance(b)
    if la is None or lb is None:
        return None
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)

for field, bg, need in (("brandColor", "#FFFFFF", 2.0), ("brandColorDark", "#212121", 2.0)):
    val = iface.get(field)
    if not val:
        continue
    r = ratio(val, bg)
    if r is None:
        bad(f"interface.{field} is not #RRGGBB")
    elif r < need:
        bad(f"interface.{field} {val} contrast {r:.2f}:1 against {bg} (need {need}:1)")
    else:
        ok(f"interface.{field} contrast {r:.2f}:1 against {bg}")

for field in ("logo", "composerIcon"):
    rel = iface.get(field, "")
    if not rel:
        bad(f"interface.{field} is required for a submittable package")
    elif not rel.startswith("./"):
        bad(f"interface.{field} must be a ./-prefixed path, got {rel!r}")
    else:
        ok(f"interface.{field} declared ({rel})")

onboarding = ext.get("onboardingSkill", "")
if onboarding.startswith("./skills/") and onboarding.endswith("/SKILL.md"):
    ok(f"onboardingSkill is a packaged skill path ({onboarding})")
else:
    bad(f"onboardingSkill must point at a packaged SKILL.md, got {onboarding!r}")

pub = ext.get("publication", {})
ok("publication.release_notes present") if pub.get("release_notes") else bad("publication.release_notes missing")

print(f"  --    package_name={name} package_version={version}")
PY

# ----------------------------------------------------------------------- skills
for dir in "$PKG"/skills/*/; do
  skill="$(basename "$dir")"
  if [ ! -f "$dir/SKILL.md" ]; then
    fail "skills/$skill has no SKILL.md"
    continue
  fi
  fm_name="$(sed -n '1,20p' "$dir/SKILL.md" | awk '/^name:[[:space:]]*/{print $2; exit}')"
  fm_desc="$(sed -n '1,20p' "$dir/SKILL.md" | awk '/^description:[[:space:]]*/{print; exit}')"
  [ "$fm_name" = "$skill" ] && ok "skills/$skill frontmatter name matches its directory" \
                            || fail "skills/$skill frontmatter name is '$fm_name' (must equal '$skill')"
  [ -n "$fm_desc" ] && ok "skills/$skill has a description (activation trigger)" \
                    || fail "skills/$skill is missing a frontmatter description"
done

# ------------------------------------------------------------------------ icons
python3 - "$PKG" <<'PY' >> "$REPORT"
import glob, os, re, sys
pkg = sys.argv[1]
ok = lambda m: print(f"  ok    {m}")
bad = lambda m: print(f"  FAIL  {m}")
found = False
for path in sorted(glob.glob(os.path.join(pkg, "assets", "*.svg"))):
    rel = os.path.relpath(path, pkg)
    found = True
    text = open(path, encoding="utf-8").read()
    m = re.search(r'viewBox="([\d.\s]+)"', text)
    if not m:
        bad(f"{rel} has no viewBox")
        continue
    nums = [float(x) for x in m.group(1).split()]
    if len(nums) == 4 and nums[2] == nums[3] and nums[2] >= 48:
        ok(f"{rel} is square at {int(nums[2])}x{int(nums[3])}")
    else:
        bad(f"{rel} viewBox must be square and >=48x48, got {m.group(1)!r}")
if not found:
    bad("no assets/*.svg icons found")
PY

for ref in "./assets/logo.svg" "./assets/composer-icon.svg"; do
  rel="${ref#./}"
  [ -f "$PKG/$rel" ] && ok "icon file present: $rel" || fail "icon file missing: $rel"
done

# ---------------------------------------------------- reference pack freshness
if [ -f "$REF" ]; then
  tmp="$(mktemp)"
  tail -n +5 "$REF" > "$tmp"
  if diff -q "$tmp" "$ROOT/build/google-flow-story-maker.md" >/dev/null 2>&1; then
    ok "embedded rulebook matches the built pack"
  else
    fail "embedded rulebook is stale — run ./plugin/build-plugin.sh"
  fi
  rm -f "$tmp"
  if grep -q "{{VERSION}}" "$REF"; then
    fail "embedded rulebook still contains the {{VERSION}} placeholder"
  else
    ok "embedded rulebook has no unsubstituted placeholders"
  fi
else
  fail "embedded rulebook missing — run ./plugin/build-plugin.sh"
fi

# ------------------------------------------------------------- secret hygiene
if grep -rIl -E "sk-[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY|client_secret|api[_-]?key[\"' ]*[:=][\"' ]*[A-Za-z0-9_-]{16,}" "$PKG" >/dev/null 2>&1; then
  fail "possible credential material inside the package"
else
  ok "no credential-shaped strings in the package"
fi
if find "$PKG" -name '.DS_Store' | grep -q .; then
  fail ".DS_Store present — it must not ship"
else
  ok "no .DS_Store files"
fi

# ------------------------------------------------------------------------- zip
if [ -f "$ZIP" ]; then
  ok "dist zip present: ${ZIP#"$ROOT"/}"
  paths="$(unzip -Z1 "$ZIP")"
  if printf '%s\n' "$paths" | grep -qv "^$NAME/"; then
    fail "zip must contain only the $NAME/ root folder"
  else
    ok "zip root folder is $NAME/"
  fi
  for expected in "plugin.json" "skills/flow-story-maker/SKILL.md" "skills/get-started/SKILL.md" \
                  "skills/flow-story-maker/references/gfs-instructions.md" "assets/logo.svg" "assets/composer-icon.svg"; do
    printf '%s\n' "$paths" | grep -qx "$NAME/$expected" && ok "zip contains $expected" \
                                                        || fail "zip is missing $expected"
  done
  if printf '%s\n' "$paths" | grep -qE "\.DS_Store|\.env|\.git/"; then
    fail "zip carries junk paths"
  else
    ok "zip carries no junk paths"
  fi
else
  echo "  --    no zip yet (run ./plugin/build-plugin.sh to produce one)"
fi
stale="$(find "$ROOT/plugin/dist" -maxdepth 1 -name '*.zip' ! -name "$NAME-$(tr -d '[:space:]' < "$ROOT/version.txt").zip" 2>/dev/null | wc -l | tr -d ' ')"
if [ "$stale" = "0" ]; then
  ok "no stale version ZIPs in dist/"
else
  fail "dist/ holds $stale stale ZIP(s) — re-run ./plugin/build-plugin.sh so only the current version ships"
fi

# ----------------------------------------------------------------------- tally
cat "$REPORT"
FAILED="$(grep -c '^  FAIL' "$REPORT" || true)"
CHECKED="$(grep -c '^  ok' "$REPORT" || true)"
echo "----------------------------------------"
echo "checks: $CHECKED   failed: $FAILED"
if [ "$FAILED" -eq 0 ]; then
  echo "validate-plugin: PASS"
else
  echo "validate-plugin: FAIL"
  exit 1
fi
