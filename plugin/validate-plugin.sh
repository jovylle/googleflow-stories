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
if len(author.get("name", "")) > 120:
    bad(f"author.name is {len(author['name'])} chars (limit 120)")
if len(author.get("email", "") or "") > 320:
    bad("author.email is over 320 chars")
if "email" in author and author["email"]:
    bad("author.email is set — keep contact in the dashboard, not the package")
if author.get("url", "").startswith("https://") or not author.get("url"):
    ok("author.url is https or absent")
else:
    bad("author.url must be https")
if len(author.get("url", "") or "") > 2048:
    bad("author.url is over 2048 chars")

for key in ("homepage", "repository"):
    val = m.get(key)
    if val and not val.startswith("https://"):
        bad(f"{key} must be https")
    if len(val or "") > 2048:
        bad(f"{key} is over 2048 chars")
ok("homepage and repository are https URLs within 2048 chars")

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
if len(set(prompts)) == len(prompts):
    ok("defaultPrompt entries are unique")
else:
    bad("defaultPrompt entries must be unique")

# Listing URLs. Required for an MCP app's public review; a skills-only package
# still declares them here, because the portal imports them from the manifest and
# does not fill them from the root homepage or author.url.
LISTING_URLS = ("websiteURL", "supportURL", "privacyPolicyURL", "termsOfServiceURL")
missing = [f for f in LISTING_URLS if not iface.get(f)]
if missing:
    bad(f"interface.{', interface.'.join(missing)} missing — the listing needs all four URLs")
for field in LISTING_URLS:
    val = iface.get(field, "")
    if not val:
        continue
    if not val.startswith("https://"):
        bad(f"interface.{field} must be https, got {val!r}")
    elif len(val) > 1024:
        bad(f"interface.{field} is {len(val)} chars (limit 1024)")
    elif "@" in val.split("//", 1)[-1]:
        bad(f"interface.{field} carries embedded credentials")
    else:
        ok(f"interface.{field} is https within 1024 chars ({val})")
if iface.get("websiteURL") and iface.get("websiteURL") != m.get("homepage"):
    ok("interface.websiteURL is declared in its own right, not left to homepage")

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

# Every declared asset must exist, be a supported image format, stay within the
# 5 MiB cap, and be square and >=48x48 when it is a raster the portal will show.
python3 - "$PKG" "$ROOT/plugin/dist/icon" <<'PY' >> "$REPORT"
import json, os, struct, sys

pkg, dashboard_icon_dir = sys.argv[1], sys.argv[2]
ok = lambda m: print(f"  ok    {m}")
bad = lambda m: print(f"  FAIL  {m}")

SUPPORTED = {".png", ".jpg", ".jpeg", ".webp", ".svg"}
CAP = 5 * 1024 * 1024


def png_size(path):
    with open(path, "rb") as fh:
        head = fh.read(24)
    if head[:8] != b"\x89PNG\r\n\x1a\n" or head[12:16] != b"IHDR":
        return None
    return struct.unpack(">II", head[16:24])


def webp_size(path):
    with open(path, "rb") as fh:
        head = fh.read(30)
    if head[:4] != b"RIFF" or head[8:12] != b"WEBP":
        return None
    if head[12:16] == b"VP8X":
        w = int.from_bytes(head[24:27], "little") + 1
        h = int.from_bytes(head[27:30], "little") + 1
        return w, h
    return None


with open(os.path.join(pkg, "plugin.json"), encoding="utf-8") as fh:
    iface = json.load(fh)["extensions"]["com.openai"]["interface"]

declared = [f for f in ("logo", "logoDark", "composerIcon", "composerIconDark")
            if iface.get(f)]
for field in declared:
    rel = iface[field]
    path = os.path.join(pkg, rel[2:] if rel.startswith("./") else rel)
    if not os.path.isfile(path):
        bad(f"interface.{field} points at a missing file ({rel})")
        continue
    ext = os.path.splitext(path)[1].lower()
    size = os.path.getsize(path)
    if ext not in SUPPORTED:
        bad(f"interface.{field} is {ext} — the portal accepts PNG, JPEG, WebP or SVG")
        continue
    if size > CAP:
        bad(f"interface.{field} is {size / 1048576:.1f} MiB (cap 5 MiB)")
        continue
    dims = png_size(path) if ext == ".png" else (webp_size(path) if ext == ".webp" else None)
    if dims:
        w, h = dims
        if w != h:
            bad(f"interface.{field} is {w}x{h} — icons must be square")
        elif w < 48:
            bad(f"interface.{field} is {w}x{h} — icons must be at least 48x48")
        elif max(w, h) > 4096:
            bad(f"interface.{field} is {w}x{h} — rasters cap at 4096 px per side")
        else:
            ok(f"interface.{field} is a square {w}x{h} {ext[1:]} within 5 MiB")
    else:
        ok(f"interface.{field} is a supported {ext[1:]} within 5 MiB ({size} bytes)")

shots = iface.get("screenshots", [])
if shots:
    for rel in shots:
        path = os.path.join(pkg, rel[2:] if rel.startswith("./") else rel)
        if os.path.isfile(path):
            ok(f"screenshot present: {rel}")
        else:
            bad(f"screenshot declared but missing: {rel}")

# The dashboard asks for a primary listing icon at upload time; it is not part of
# the package, so keep the rendered one honest here instead of discovering it late.
icons = sorted(f for f in os.listdir(dashboard_icon_dir)
               if os.path.splitext(f)[1].lower() in SUPPORTED) if os.path.isdir(dashboard_icon_dir) else []
if not icons:
    bad("no dashboard icon in plugin/dist/icon/ — render one before uploading")
for name in icons:
    path = os.path.join(dashboard_icon_dir, name)
    ext = os.path.splitext(name)[1].lower()
    dims = png_size(path) if ext == ".png" else (webp_size(path) if ext == ".webp" else None)
    if os.path.getsize(path) > CAP:
        bad(f"dashboard icon {name} is over 5 MiB")
    elif dims and dims[0] == dims[1] and dims[0] >= 48:
        ok(f"dashboard icon {name} is a square {dims[0]}x{dims[1]}")
    elif dims:
        bad(f"dashboard icon {name} is {dims[0]}x{dims[1]} — square, at least 48x48")
    else:
        ok(f"dashboard icon {name} present (dimensions not checked)")
PY

# The portal requires public URLs that are reachable and identify the same
# publisher. Opt in with CHECK_URLS=1 — the default run stays offline.
if [ "${CHECK_URLS:-0}" = "1" ]; then
  for ref in $(python3 -c "
import json
i=json.load(open('$PKG/plugin.json'))['extensions']['com.openai']['interface']
print(' '.join(i[f] for f in ('websiteURL','supportURL','privacyPolicyURL','termsOfServiceURL') if i.get(f)))
"); do
    code="$(curl -sL -o /dev/null -w '%{http_code}' --max-time 20 "$ref" || echo 000)"
    [ "$code" = "200" ] && ok "listing URL reachable: $ref ($code)" || fail "listing URL $ref returned $code"
  done
else
  echo "  --    listing URL reachability not checked (set CHECK_URLS=1)"
fi

# ------------------------------------------------------- marketplace catalog
# The repo marketplace in .agents/plugins/marketplace.json is how the plugin is
# distributed without the public directory. Its source.path is resolved relative
# to the marketplace root (the repo root), not to .agents/, so a stale or
# escaping path silently skips the entry instead of failing the marketplace.
python3 - "$ROOT" <<'PY' >> "$REPORT"
import json, os, sys

root = sys.argv[1]
ok = lambda m: print(f"  ok    {m}")
bad = lambda m: print(f"  FAIL  {m}")

path = os.path.join(root, ".agents", "plugins", "marketplace.json")
if not os.path.isfile(path):
    bad("no repo marketplace at .agents/plugins/marketplace.json")
    raise SystemExit(0)

try:
    with open(path, encoding="utf-8") as fh:
        cat = json.load(fh)
except Exception as exc:                                      # noqa: BLE001
    bad(f"marketplace.json does not parse: {exc}")
    raise SystemExit(0)

ok("marketplace.json parses")

market = cat.get("name", "")
if market:
    ok(f"marketplace name declared ({market})")
else:
    bad("marketplace top-level name is required")

label = cat.get("interface", {}).get("displayName", "")
if label:
    ok(f"marketplace interface.displayName declared ({label})")
else:
    bad("marketplace interface.displayName is required — it is the picker title")

entries = cat.get("plugins", [])
if not entries:
    bad("marketplace has no plugins[] entries")
else:
    ok(f"marketplace lists {len(entries)} plugin entry/entries")

manifest = json.load(open(os.path.join(root, "plugin", "flow-story-maker", "plugin.json"),
                          encoding="utf-8"))
manifest_name = manifest.get("name")

for entry in entries:
    name = entry.get("name", "")
    if not name:
        bad("a marketplace entry has no name")
        continue
    for field in ("installation", "authentication"):
        if not entry.get("policy", {}).get(field):
            bad(f"marketplace entry {name} is missing policy.{field}")
    if not entry.get("category"):
        bad(f"marketplace entry {name} is missing category")
    if not entry.get("interface", {}).get("displayName"):
        bad(f"marketplace entry {name} has no interface.displayName (picker label)")

    src = entry.get("source")
    src = {"source": "local", "path": src} if isinstance(src, str) else (src or {})
    kind = src.get("source", "")
    if kind in ("local", ""):
        rel = src.get("path", "")
        if not rel.startswith("./"):
            bad(f"marketplace entry {name} source.path must start with ./ (got {rel!r})")
            continue
        target = os.path.normpath(os.path.join(root, rel))
        if not target.startswith(os.path.normpath(root) + os.sep):
            bad(f"marketplace entry {name} source.path escapes the marketplace root ({rel})")
        elif not os.path.isfile(os.path.join(target, "plugin.json")):
            bad(f"marketplace entry {name} source.path holds no plugin.json ({rel})")
        else:
            ok(f"marketplace entry {name} resolves to a packaged plugin ({rel})")
            with open(os.path.join(target, "plugin.json"), encoding="utf-8") as fh:
                version = json.load(fh).get("version")
            ok(f"marketplace entry {name} serves package version {version}")
    elif kind in ("url", "git-subdir", "npm"):
        ok(f"marketplace entry {name} uses a {kind} source (resolved by the host)")
    else:
        bad(f"marketplace entry {name} has an unknown source kind {kind!r}")

    if kind in ("local", "") and name != manifest_name:
        bad(f"marketplace entry {name} does not match the package name {manifest_name!r}")
    elif kind in ("local", ""):
        ok(f"marketplace entry {name} matches the package name")
PY

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
