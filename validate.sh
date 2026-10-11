#!/usr/bin/env bash
#
# validate.sh — structural validation of the COMPILED instruction file.
#
# The product is build/google-flow-story-maker.md (what gets pasted into ChatGPT).
# The modules are only its source. This script checks the artifact itself:
# build sync, version stamping, module order/completeness, section numbering,
# cross-reference resolution, primary/advanced field shape, and stale-phrase
# absence — so a change that only got applied in one module is caught here.
#
# Usage:
#   ./validate.sh
#
# Exit code 0 = all checks pass. Non-zero = number of failed checks.
#
set -uo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
BUILD="build/google-flow-story-maker.md"
MODULES="modules"
FAILED=0
CHECKED=0

pass() { printf '  ok    %s\n' "$1"; CHECKED=$((CHECKED + 1)); }
fail() { printf '  FAIL  %s\n' "$1"; FAILED=$((FAILED + 1)); CHECKED=$((CHECKED + 1)); }

need() { # need <file> <literal> <label>
  if grep -qF -- "$2" "$1"; then pass "$3"; else fail "$3 — missing: $2"; fi
}

need_not() { # need_not <file> <literal> <label>
  if grep -qF -- "$2" "$1"; then
    fail "$3 — found stale text: $2 (line $(grep -nF -- "$2" "$1" | head -1 | cut -d: -f1))"
  else pass "$3"; fi
}

echo "validate: $BUILD"
echo

# ---------------------------------------------------------------- 1. build sync
echo "1. Build integrity"
TMP="$(mktemp)"
./build.sh >/dev/null 2>&1 || { fail "build.sh runs"; rm -f "$TMP"; exit "$FAILED"; }
pass "build.sh runs"
check_build_sync() {
  cp "$BUILD" "$TMP"
  ./build.sh >/dev/null 2>&1
  if diff -q "$TMP" "$BUILD" >/dev/null; then
    pass "committed build matches modules (in sync)"
  else
    fail "committed build is STALE vs modules — run ./build.sh and commit"
  fi
}
check_build_sync
rm -f "$TMP"

if grep -qE '\{\{[A-Z_]+\}\}' "$BUILD"; then
  fail "no unresolved {{PLACEHOLDER}} remains in the build"
else
  pass "no unresolved {{PLACEHOLDER}} remains in the build"
fi

VERSION="$(tr -d '[:space:]' < version.txt)"
if grep -qF "**Version:** $VERSION" "$BUILD"; then
  pass "header version matches version.txt ($VERSION)"
else
  fail "header version does not match version.txt ($VERSION)"
fi
echo

# ------------------------------------------------- 2. module order/completeness
echo "2. Module coverage and order"
if [ -f "$BUILD" ]; then
  mapfile -t ORDERED < <(ls "$MODULES"/*.md | sort)
  PREV=0
  ORDER_OK=1
  MISSING=()
  for m in "${ORDERED[@]}"; do
    # first heading line of the module (skips the leading WHY-comment block)
    head_line="$(grep -m1 '^#' "$m" || true)"
    if [ -z "$head_line" ]; then continue; fi
    ln="$(grep -nF -- "$head_line" "$BUILD" | head -1 | cut -d: -f1)"
    if [ -z "$ln" ]; then
      MISSING+=("$(basename "$m")")
      ORDER_OK=0
    elif [ "$ln" -lt "$PREV" ]; then
      ORDER_OK=0
      fail "module order broken at $(basename "$m") (line $ln appears before previous module)"
    else
      PREV="$ln"
    fi
  done
  if [ "$ORDER_OK" -eq 1 ]; then
    pass "all ${#ORDERED[@]} modules appear in the build, in filename order"
  elif [ "${#MISSING[@]}" -gt 0 ]; then
    fail "modules whose content is missing from the build: ${MISSING[*]}"
  fi
fi
echo

# ------------------------------------------------------ 3. section numbering
echo "3. Section numbering"
if [ -f "$BUILD" ]; then
  NUMS="$(grep -oE '^## [0-9]+[a-z]?\.' "$BUILD" | grep -oE '[0-9]+[a-z]?' )"
  DUPES="$(printf '%s\n' "$NUMS" | sort | uniq -d)"
  if [ -n "$DUPES" ]; then
    fail "duplicate section numbers in the build: $(echo "$DUPES" | tr '\n' ' ')"
  else
    pass "no duplicate numbered section headings"
  fi
  BASE="$(printf '%s\n' "$NUMS" | grep -oE '^[0-9]+' )"
  # "7a" is a sub-section of 7, so compare (number, suffix) pairs, not numbers alone.
  if printf '%s\n' "$NUMS" | awk '
      { n=$1; sub(/[a-z]$/,"",n); s=$1; sub(/^[0-9]+/,"",s) }
      NR>1 { if (n<pn || (n==pn && s<=ps)) bad=1 }
      { pn=n; ps=s }
      END { exit bad?1:0 }'; then
    pass "numbered sections increase monotonically ($(printf '%s\n' "$BASE" | tr '\n' ' '))"
  else
    fail "numbered sections are not monotonically increasing: $(printf '%s\n' "$NUMS" | tr '\n' ' ')"
  fi
  UNNUMBERED="$(grep -E '^## ' "$BUILD" | grep -vE '^## [0-9]+[a-z]?\.|^## Sources' | sed 's/^## //')"
  if [ -z "$UNNUMBERED" ]; then
    pass "every content section carries a number"
  elif [ "$UNNUMBERED" = "Commands" ] && [ "$(grep -nE '^## ' "$BUILD" | head -1 | cut -d: -f1)" = "$(grep -n '^## Commands' "$BUILD" | cut -d: -f1)" ]; then
    pass "only unnumbered section is the front 'Commands' section (intentional)"
  else
    fail "unnumbered content sections: $(echo "$UNNUMBERED" | tr '\n' '|')"
  fi
fi
echo

# -------------------------------------------- 4. interview field shape (A-D, 1-12)
echo "4. Interview field shape"
INT="$MODULES/04-interview.md"
LETTERS="$(grep -oE '^\*\*[A-D]\. [^*]+' "$INT" | sed 's/^\*\*//')"
if [ "$(printf '%s\n' "$LETTERS" | wc -l | tr -d ' ')" = "4" ]; then
  pass "primary decisions are exactly four lettered fields"
else
  fail "expected 4 primary fields (A-D), found: $(printf '%s' "$LETTERS" | tr '\n' '|')"
fi
echo "$LETTERS" | grep -q '^B\. Character$' && pass "B is Character" || fail "B is not Character: $(echo "$LETTERS" | sed -n 2p)"
echo "$LETTERS" | grep -q '^C\. Art style$' && pass "C is Art style" || fail "C is not Art style: $(echo "$LETTERS" | sed -n 3p)"
echo "$LETTERS" | grep -q '^D\. Image generation topic$' && pass "D is Image generation topic" || fail "D is not Image generation topic: $(echo "$LETTERS" | sed -n 4p)"

ADV_FILE="$(mktemp)"
awk '/^### Advanced \/ optional \(hidden by default\)/{f=1;next} /^<!--/{f=0} f' "$INT" \
  | grep -oE '^[0-9]+\.' | grep -oE '^[0-9]+' >"$ADV_FILE"
ADV_EXPECT="$(seq 1 "$(wc -l <"$ADV_FILE" | tr -d ' ')")"
if diff -q <(printf '%s\n' "$ADV_EXPECT") "$ADV_FILE" >/dev/null; then
  pass "advanced fields are contiguously numbered 1..$(tail -1 "$ADV_FILE")"
else
  fail "advanced field numbering is not contiguous 1..N: $(tr '\n' ' ' <"$ADV_FILE")"
fi
grep -qE '^11\. Image workflow' "$INT" && pass "advanced item 11 is Image workflow" || fail "advanced item 11 is not Image workflow"
rm -f "$ADV_FILE"
echo

# ------------------------------------------------------- 5. cross-references
echo "5. Cross-references resolve"
declare -A REFS=(
  ["clip-continuity module"]="09-clip-continuity.md"
  ["shot-composition module"]="08a-shot-composition.md"
  ["story-planning module"]="05-story-planning.md"
  ["interview module"]="04-interview.md"
  ["video-prompt module"]="08-video-prompt.md"
  ["research-policy module"]="13-research-policy.md"
  ["model module"]="06-model-rules.md"
  ["defaults module"]="15-defaults.md"
  ["riddle module"]="03-riddle-prephase.md"
  ["Commands module"]="01-commands.md"
)
for ref in "${!REFS[@]}"; do
  target="$MODULES/${REFS[$ref]}"
  if [ ! -f "$target" ]; then
    fail "reference \"$ref\" maps to a module that does not exist (${REFS[$ref]})"
  elif ! grep -qF "$ref" "$BUILD"; then
    pass "\"$ref\" → ${REFS[$ref]} (reference absent from build, mapping still valid)"
  else
    pass "\"$ref\" → ${REFS[$ref]} exists"
  fi
done
# "section B"/"section C" point at real primary fields
for s in B C; do
  if grep -qE "section $s" "$BUILD"; then
    grep -qE "^\*\*$s\. " "$INT" && pass "reference \"section $s\" resolves to a primary field" \
      || fail "reference \"section $s\" has no matching primary field"
  fi
done
# "item N below/above" must land inside the advanced list
while read -r ref; do
  [ -z "$ref" ] && continue
  n="$(printf '%s' "$ref" | grep -oE '[0-9]+')"
  if grep -qE "^$n\. " "$INT"; then pass "reference \"$ref\" resolves to advanced item $n"
  else fail "reference \"$ref\" has no advanced item $n"; fi
done < <(grep -oE 'item [0-9]+ (below|above)' "$BUILD" | sort -u)
echo

# ------------------------------------------- 6. v2.12.0 change coverage (artifact)
echo "6. Change coverage in the compiled artifact"
need "$BUILD" "**B. Character**" "primary field B. Character present in build"
need "$BUILD" "**C. Art style**" "primary field C. Art style present in build"
need "$BUILD" "**D. Image generation topic**" "primary field D. Image generation topic present in build"
need "$BUILD" "Use my uploaded photo(s) as the character sheet source" "photo-as-character-sheet option present"
need "$BUILD" "**Generate reference images with ChatGPT" "default image workflow named in build"
need "$MODULES/15-defaults.md" "**Generate reference images with ChatGPT**" "defaults module names the image workflow default"
need "$MODULES/16-checklist.md" "character sheet" "checklist covers the photo identity source"
need "$MODULES/10-clip1-final.md" "character sheet" "Clip 1 readiness covers the photo identity source"
need_not "$BUILD" "Characters + Art Style" "no stale combined 'Characters + Art Style' field"
need_not "$BUILD" "ChatGPT prepares the image" "no stale 'ChatGPT prepares the image' default wording"
need_not "$BUILD" "generate the image with ChatGPT" "no stale 'generate the image with ChatGPT' wording"
need "$BUILD" "Do not reintroduce a fixed riddle=3 template" "riddle clip-count guard still present"
if grep -qE '^- [0-9]+ clips? \(recommended for riddle' "$BUILD"; then
  fail "prescriptive clip-count template reintroduced: $(grep -nE '^- [0-9]+ clips? \(recommended for riddle' "$BUILD" | head -1)"
else
  pass "no prescriptive 'recommended for riddle' clip-count template"
fi
echo

# ----------------------------------------------------------- 7. default parity
echo "7. Interview/defaults parity"
for field in "Character" "Art style"; do
  grep -qE "^- $field:" "$MODULES/15-defaults.md" && pass "defaults module has a $field default" \
    || fail "defaults module is missing a $field default"
done
if grep -qE '^- Characters \+ Art Style:' "$MODULES/15-defaults.md"; then
  fail "defaults module still has a combined Characters + Art Style default"
else
  pass "defaults module has no combined character/art-style default"
fi
if awk '/^\*\*Primary \(always shown\)\*\*/{f=1} /^\*\*Advanced/{f=0} f' "$MODULES/15-defaults.md" | grep -qF "Image workflow"; then
  fail "image workflow default is still listed under Primary in the defaults module"
else
  pass "image workflow default is not listed under Primary in the defaults module"
fi
if awk '/^\*\*Advanced/{f=1} f' "$MODULES/15-defaults.md" | grep -qF "Image workflow"; then
  pass "image workflow default is listed under Advanced in the defaults module"
else
  fail "image workflow default is missing from Advanced in the defaults module"
fi
echo

# ------------------------------------- 8. named-rule references resolve (artifact)
# The build refers to rules by name ("the master audio rule", "the shot-composition
# hard rule"). Those references are claims that a defining rule exists somewhere in
# the artifact — check each named rule is actually defined, not just cited.
echo "8. Named-rule references resolve"
check_rule() { # check_rule <grep-pattern> <label>
  if grep -qE -- "$1" "$BUILD"; then pass "rule defined: $2"
  else fail "rule referenced but never defined: $2"; fi
}
check_rule "master audio rule" "master audio rule"
check_rule "No-answer-reveal rule" "no-answer-reveal rule"
check_rule "One shot = one image \(hard rule" "image-output-isolation / one-shot-one-image hard rule"
check_rule "### Clip continuation mode" "continuation-mode section"
check_rule "honesty rule" "honesty rule"
check_rule "no-premature-generation rule" "no-premature-generation rule"
check_rule "Do not start generating a complete story package before interviewing" "interview-before-generation contract"
echo

# ---------------------------------------- 9. identity-source vs workflow clarity
echo "9. Character-sheet identity vs image-workflow clarity"
need "$BUILD" "identity source** only (image method A for that character)" "photo option states it sets identity only, not the workflow"
need "$BUILD" "still governs how the shots are produced" "submit-time attachments restate the workflow field's authority"
need_not "$BUILD" 'the image workflow for that subject can default to "use supplied image"' "no stale submit-time rule that silently switches the workflow"
# the "Advanced / optional" enumeration must name every field that lives there
ADV_LINE="$(grep -m1 '\*\*Advanced / optional (hidden by default):\*\*' "$BUILD")"
for f in "image workflow" "clip continuation" "continuity" "delivery"; do
  case "$ADV_LINE" in
    *"$f"*) pass "advanced enumeration names: $f" ;;
    *) fail "advanced enumeration omits: $f" ;;
  esac
done
echo

# ------------------------------------------------- 10. advanced-field parity
echo "10. Advanced-field parity (interview vs defaults)"
for field in "Image workflow" "Clip continuation" "Continuity" "Dialogue" "Delivery" "Aspect ratio" "Number of clips" "Video model" "Genre" "Creative direction" "Platform"; do
  in_int=no; in_def=no
  grep -qF "$field" "$MODULES/04-interview.md" && in_int=yes
  awk '/^\*\*Advanced/{f=1} f' "$MODULES/15-defaults.md" | grep -qF "$field" && in_def=yes
  if [ "$in_int" = yes ] && [ "$in_def" = yes ]; then pass "advanced field in both modules: $field"
  else fail "advanced field mismatch ($field): interview=$in_int defaults=$in_def"; fi
done
echo

echo "----------------------------------------"
echo "checks: $CHECKED   failed: $FAILED"
[ "$FAILED" -eq 0 ] && echo "validate: PASS" || echo "validate: FAIL"
exit "$FAILED"
