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
check_rule "Do not start generating a complete story package before the user has submitted Form 1" "interview-before-generation contract"
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

# ----------------------------- 11. mirrored enumerations say the same thing
echo "11. Mirrored enumerations agree"
# Any place that enumerates the advanced fields must name the image workflow —
# the change moved it there, and three separate mirror lists have already drifted.
MIRRORS="$(grep -n 'clip count, aspect ratio' "$BUILD" || true)"
if [ -z "$MIRRORS" ]; then
  pass "no advanced-field enumeration to check"
else
  while IFS= read -r line; do
    n="${line%%:*}"
    if printf '%s' "$line" | grep -Eqi 'image[ -]?workflow'; then
      pass "line $n enumerates the image workflow among advanced fields"
    else
      fail "line $n enumerates advanced fields but omits image workflow"
    fi
  done <<< "$MIRRORS"
fi
# Script Overview is part of A. Story topic — never a standalone primary field.
if grep -qE '^- Script Overview:' "$MODULES/15-defaults.md"; then
  fail "defaults module lists Script Overview as a standalone primary field"
else
  pass "defaults module nests Script Overview inside A. Story topic"
fi
# The advanced list's last item must carry the same label in both mirror lists.
need "$BUILD" "Other requirements (Advanced item 12)" "defaults module uses the interview's label for advanced item 12"
if grep -qE '^- Additional requirements:' "$MODULES/15-defaults.md"; then
  fail "defaults module still uses the old 'Additional requirements' label"
else
  pass "no stale 'Additional requirements' label in the defaults module"
fi
echo

# ------------------------------------------------- 12. two-form flow contract
# The opening interaction must be exactly two forms: Form 1 (setup) produces
# Form 2 (production). Earlier wording ("manageable, interactive steps", a chained
# follow-up question, pick-then-confirm locking) is what made ChatGPT spread the
# opening across ~8 turns — one field per turn, with a confirmation card per riddle.
# These guards keep that from creeping back in.
echo "12. Two-form flow contract"
need "$BUILD" "**Form 1 of 2**" "Form 1 is labeled in the build"
need "$BUILD" "**Form 2 of 2**" "Form 2 is labeled in the build"
need "$BUILD" "The whole opening is exactly two forms" "two-form contract stated in the role module"
need_not "$BUILD" "manageable, interactive steps" "no stale 'manageable, interactive steps' wording"
need_not "$BUILD" "ask a follow-up" "no chained follow-up-question pattern"
need "$MODULES/03-riddle-prephase.md" "All three fields, in this one form" "Form 1 carries its three setup fields in one form"
need "$MODULES/03-riddle-prephase.md" "locks it in that same single action" "a riddle pick locks in one action, with no confirmation round"
need_not "$MODULES/03-riddle-prephase.md" "the user picks (or edits and confirms)" "no stale pick-then-confirm lock wording"
need "$INT" "Present all four primary fields together" "Form 2 presents its primary fields in one form"
need_not "$INT" "Step 1: Story topic" "no per-field sequencing in the interview module"
need_not "$INT" "Hakbang" "no step-by-step interview framing"
echo

echo "13. Riddle outcome contract (never answered + consequence)"
need "$MODULES/03-riddle-prephase.md" "The riddle is never answered correctly on screen" "the never-answered outcome is stated"
need "$MODULES/03-riddle-prephase.md" "A visible consequence is always included" "the consequence rule is stated"
need "$MODULES/03-riddle-prephase.md" "do not drop either silently" "clip-count conflict with the consequence has a defined resolution"
need "$MODULES/15-defaults.md" "The riddle is never answered correctly on screen" "defaults mirror the never-answered outcome"
need "$MODULES/15-defaults.md" "A visible consequence is always included" "defaults mirror the consequence rule"
need "$MODULES/16-checklist.md" "the riddle is never answered correctly on screen" "the final checklist verifies the outcome contract"
need "$MODULES/05-story-planning.md" "riddle outcome contract" "story planning carries the outcome contract"
need_not "$MODULES/03-riddle-prephase.md" "or another character who reacts but never answers correctly" "no optional either/or riddle structure"
need_not "$MODULES/03-riddle-prephase.md" "reacts without answering correctly" "no optional-answering wording in the reveal rule"
need_not "$MODULES/15-defaults.md" "or a character who reacts without answering correctly" "no optional answering in the defaults mirror"
echo

echo "14. Clip 1 turn never goes silent"
need "$MODULES/10-clip1-final.md" "**Never go silent.**" "the no-silent-turn rule is stated"
need "$MODULES/10-clip1-final.md" "as the last action of the turn" "image generation is ordered after all text"
need "$MODULES/10-clip1-final.md" "unavailable, fails, or the workflow is not ChatGPT-generated" "an explicit failure path replaces a silent wait"
need "$MODULES/14-style.md" "**Never leave a turn without visible text.**" "the no-empty-turn rule is mirrored in the style module"
echo

echo "15. .start always begins at Form 1 (no state inference)"
need "$MODULES/01-commands.md" "always present Form 1 first" ".start always presents Form 1"
need "$MODULES/01-commands.md" "earlier turns are never a substitute for Form 1" "prior conversation state cannot replace Form 1"
need "$MODULES/02-role.md" "Pre-filled is not the same as omitted" "a known value pre-fills its field instead of removing it"
need "$MODULES/02-role.md" "since the most recent" "the scope of 'already in hand' is defined as the current run"
need "$MODULES/02-role.md" "Form 2 keeps all four primary fields visible" "Form 2 never drops a field because its answer is known"
need_not "$MODULES/02-role.md" "unless the user has already supplied enough information" "the skip-on-enough-information loophole is gone"
need "$MODULES/04-interview.md" "the field stays visible" "interview fields are never dropped when known"
echo

echo "16. Clip 1 image ratio and one-image discipline"
need "$MODULES/10-clip1-final.md" "Match the video's aspect ratio" "the image must match the video's aspect ratio"
need "$MODULES/10-clip1-final.md" "A wrong-ratio image is a failed attempt" "a wrong-ratio result is retried, not handed to the user"
need "$MODULES/10-clip1-final.md" "zero on an" "only the Clip 1 image is generated in the post-form turn (zero on auto first message)"
need_not "$MODULES/10-clip1-final.md" "i-crop o gumawa" "no crop-in-Flow workaround wording"
echo

echo "17. Story Overview checkpoint (before generating anything)"
need "$MODULES/05-story-planning.md" "before any clip prompt, any expanded blueprint, or any image" "the checkpoint precedes all generation"
need "$MODULES/05-story-planning.md" "It is not a form" "the checkpoint is distinguished from a form"
need "$MODULES/05-story-planning.md" "never label it as Form 3" "the checkpoint is not a third form"
need "$MODULES/05-story-planning.md" "state it in plain words" "the consequence is surfaced for review"
need "$MODULES/05-story-planning.md" "never present a second uninvited checkpoint" "no round-trip creep"
need "$MODULES/05-story-planning.md" "This is where a clip-count or spoken-duration shortfall is raised" "the clip-count and duration shortfall are raised at the checkpoint"
need "$MODULES/05-story-planning.md" "skips the checkpoint and goes straight to the full package" "the checkpoint is skippable"
need "$MODULES/02-role.md" "plus one Story Overview checkpoint" "the two-form contract names the checkpoint"
need "$MODULES/11-output-format.md" "First, the Story Overview checkpoint" "the default delivery honours the checkpoint"
need "$MODULES/16-checklist.md" "Story Overview checkpoint was shown" "the checklist verifies the gate"
echo

echo "18. Riddle re-roll affordance stays visible"
need "$MODULES/03-riddle-prephase.md" "Always show the re-roll affordance in the same message as the pick list" "the pick list must show the re-roll path"
need "$MODULES/03-riddle-prephase.md" "Reroll riddles" "the optional re-roll button is specified"
need "$MODULES/03-riddle-prephase.md" "Re-present the affordance every time the list is shown" "the re-roll control survives a re-roll"
need "$MODULES/03-riddle-prephase.md" "mean removing the edit and re-roll affordances" "removing the confirmation card does not remove the controls"
need "$MODULES/03-riddle-prephase.md" "A re-roll means a genuinely fresh batch" "re-roll produces new riddles, not reshuffled ones"
echo

echo "19. Riddles do not close on a first-person self-question"
need "$MODULES/03-riddle-prephase.md" "Do not end the riddle with" "the Ano ako? ending is banned"
need "$MODULES/03-riddle-prephase.md" "any equivalent first-person self-question" "all first-person self-questions are banned, not just the exact phrase"
need "$MODULES/03-riddle-prephase.md" "recited by a character to an audience" "the ban is justified by the recital framing"
need "$MODULES/03-riddle-prephase.md" "never a first-person one" "the permitted impersonal close is stated"
need "$MODULES/03-riddle-prephase.md" "a riddle the user supplies is preserved exactly as written" "the user's own riddle is still preserved verbatim"
need "$MODULES/16-checklist.md" "not end in a first-person self-question" "the checklist verifies the riddle ending"
echo

echo "20. Default riddle story: horror, two entities, no clues, no re-used riddle nouns"
need "$MODULES/03-riddle-prephase.md" "The default riddle story is a horror scene with two sides" "the default two-entity horror structure is stated"
need "$MODULES/03-riddle-prephase.md" "Genre: horror by default" "riddle stories default to horror"
need "$MODULES/03-riddle-prephase.md" "holds the victims where they are" "the Teller is the one who traps them"
need "$MODULES/03-riddle-prephase.md" "The trap is shown, not implied" "the trap must be established visually"
need "$MODULES/03-riddle-prephase.md" "The consequence is the Teller's act, not an event in the world" "the consequence comes from the Teller"
need "$MODULES/03-riddle-prephase.md" "No tips and no clues" "no hints of any kind"
need "$MODULES/03-riddle-prephase.md" "A consequence that dramatizes what the riddle's wording describes" "the raining-bridge leak is named"
need "$MODULES/03-riddle-prephase.md" "because it depicts the answer's own description" "why that consequence is a leak"
need_not "$MODULES/03-riddle-prephase.md" "follow from the riddle's wording, mood, and situation" "the old rule that licensed the leak is gone"
need "$MODULES/03-riddle-prephase.md" "Write the riddle so the reciter is never the" "riddles must be impersonal when recited"
need "$MODULES/03-riddle-prephase.md" "repeated as an old rhyme" "the quoted-riddle escape hatch for the user's own riddle"
need "$MODULES/03-riddle-prephase.md" "The riddle's own words are off-limits as scene material" "the riddle's nouns are banned from the scene"
need "$MODULES/03-riddle-prephase.md" "a washed-out bridge would hand the answer straight to the audience" "the worked example from the failing run"
need "$MODULES/03-riddle-prephase.md" "Never add a tip or a clue" "the no-clue rule in the reveal section"
need "$MODULES/05-story-planning.md" "Scene elements are answer-blind too" "the blueprint bans riddle nouns from the scene"
need "$MODULES/05-story-planning.md" "state it in plain words as what the Teller does" "the checkpoint shows the consequence as the Teller's act"
need "$MODULES/07-image-workflow.md" "Build the frame from the situation, not from the riddle" "image prompts are built from the situation"
need "$MODULES/11-output-format.md" "No citations, links, or foreign text" "junk citations are banned from the package"
need "$MODULES/15-defaults.md" "Horror for a riddle story" "the defaults module carries the horror default"
need "$MODULES/15-defaults.md" "a horror two-entity scene" "the defaults module carries the structure"
need "$MODULES/15-defaults.md" "chosen fresh for every run** by the creative-diversity section (2a)" "victim and Teller forms are a per-run choice, not a fixed default"
need "$MODULES/15-defaults.md" "no tips and no clues of any kind" "the defaults module carries the no-clue rule"
need "$MODULES/16-checklist.md" "the consequence is the Teller's own act" "the checklist verifies the consequence source"
need "$MODULES/16-checklist.md" "no tip or clue of any kind is present" "the checklist verifies no clues"
need "$MODULES/16-checklist.md" "no citations, links, source titles, or unrelated text" "the checklist verifies no junk text"
echo

echo "21. Script Overview is a list, not a paragraph"
need "$MODULES/05-story-planning.md" "a short markdown list, not a paragraph" "the overview format is a list"
need "$MODULES/05-story-planning.md" "one action step per line" "the overview is one step per line"
need "$MODULES/05-story-planning.md" "never reword a Script Overview the user wrote" "the user's own overview wording is preserved"
need "$MODULES/04-interview.md" "Script Overview (a short action-sequence list, optional text)" "the Form 2 field asks for a list"
need "$MODULES/04-interview.md" "as a list, not a paragraph" "the Form 2 field states the list form"
need "$MODULES/11-output-format.md" "Script Overview (a short action-sequence list)" "the delivered package returns a list"
need "$MODULES/15-defaults.md" "a short action-sequence list" "the defaults module states the list form"
need "$MODULES/16-checklist.md" "in the action-sequence list format" "the checklist verifies the list format"
need "$MODULES/10-clip1-final.md" "in the action-sequence list form" "the Clip 1 gate verifies the list form"
echo

echo "22. One image per request: no batches, no sheets, no panels"
need "$MODULES/06-model-rules.md" "images are generated one at a time, on demand" "images are produced one at a time"
need "$MODULES/06-model-rules.md" "is a labeling rule, never a list of images to generate" "image roles are labels, not a production list"
need_not "$MODULES/06-model-rules.md" "Treat this as a practical planning target" "the batch-affording planning target is gone"
need "$MODULES/07-image-workflow.md" "A batch of images is never a delivery" "a batch is not a delivery"
need "$MODULES/07-image-workflow.md" "never one image per subject" "multi-subject fields mean one composed frame"
need "$MODULES/07-image-workflow.md" "an image library for style references" "reference lookups are banned"
need "$MODULES/07-image-workflow.md" "One request produces exactly one image" "one request = one image"
need "$MODULES/08a-shot-composition.md" "One frame per request, never a batch" "the shot rules forbid a batch"
need "$MODULES/11-output-format.md" "The header text is never an image" "accordion headers are text, never rendered as images"
need "$MODULES/10-clip1-final.md" "one image, of one composed scene" "the Clip 1 image is one composed scene"
need "$MODULES/16-checklist.md" "Exactly one image was generated in the turn" "the checklist verifies the image count"
echo

echo "23. The supernatural Teller voice (riddle horror) + its slower duration budget"
need "$MODULES/08-video-prompt.md" "### The supernatural Teller voice (riddle horror)" "the voice block has its own section"
need "$MODULES/08-video-prompt.md" "A terrifying supernatural entity speaks in" "the vendored deep-voice template is present"
need "$MODULES/08-video-prompt.md" "not a normal human lowering their voice" "the timbre-pinning negative line survives"
need "$MODULES/08-video-prompt.md" "The entity speaks exactly this line, in" "the spoken-line slot exists (the source prompt had none)"
need "$MODULES/08-video-prompt.md" "no added growls, whispers, or vocalizations that carry meaning" "no extra vocalizations"
need "$MODULES/08-video-prompt.md" "never any hint or statement of the answer" "the voice block cannot leak the answer"
need "$MODULES/08-video-prompt.md" "Do not use it for a story that is not horror" "the block is horror-scoped"
need "$MODULES/08-video-prompt.md" "It is slower than a normal speaking pace" "the heavy voice costs duration"
need "$MODULES/08-video-prompt.md" "12–16 words per 8-second clip" "the heavy-voice word budget is stated"
need "$MODULES/03-riddle-prephase.md" "12–16 words per 8-second clip" "the riddle budget carries the heavy-voice figure"
need "$MODULES/15-defaults.md" "supernatural Teller voice block" "the defaults point at the voice block"
need "$MODULES/16-checklist.md" "the supernatural Teller voice block was used verbatim" "the checklist verifies the voice block"
need "$MODULES/08-video-prompt.md" "[VOICE TIMBRE — filled from the Teller's locked voice identity" "the voice block's timbre is a slot, not a constant"
need "$MODULES/08-video-prompt.md" "an impossibly deep, inhuman male voice" "the proven deep-voice fill survives as the imposing-entity default"
need "$MODULES/08-video-prompt.md" "the voice must match who is on screen speaking" "the timbre must match the locked design"
need "$MODULES/08-video-prompt.md" "a child Teller speaks with an uncanny child's voice" "the child-Teller fill is named"
need "$MODULES/08-video-prompt.md" "**Forcing the deep male timbre onto a locked design that contradicts it" "the no-forcing rule is explicit"
need "$MODULES/08-video-prompt.md" "**One speaker, stated in the clip prompt.**" "the clip names who speaks and who stays silent"
need "$MODULES/16-checklist.md" "the \`[VOICE TIMBRE]\` slot filled from the locked Teller's design" "the final gate checks the timbre source"
need "$MODULES/16-checklist.md" "every victim stays silent (no speech, no lip-sync, no audible wrong answer)" "the final gate checks the one-speaker rule"
echo

echo "44. The image-prompt trailer (anti-storyboard, inside the prompt)"
# WHY: two live runs in a row rendered 6-panel storyboard sheets — numbered panels,
# 0:04 timestamp chips, captions, a "Video Model" metadata bar — from prompts that
# obeyed every prose ban. ChatGPT's image tool reads the prompt, not the rulebook, so
# the negatives must ride inside the prompt itself as a fixed trailer. Guards pin the
# trailer verbatim, the escalation path (trailer repeated as the opening sentence on
# the first repeat, then report + the Flow-side fallback), and the checklist mirror.
need "$MODULES/07-image-workflow.md" "### The image-prompt trailer (mandatory on every generated image)" "the trailer has its own subsection"
need "$MODULES/07-image-workflow.md" "One single frame of one composed scene — a single shot. No storyboard, no panels," "the trailer text is pinned verbatim"
need "$MODULES/07-image-workflow.md" "no numbered cards, no grids, no timestamp chips, no captions, titles, watermarks," "the trailer names the shapes the image tool reaches for"
need "$MODULES/07-image-workflow.md" "it goes into the generation call itself" "the trailer rides inside the prompt, not the prose"
need "$MODULES/07-image-workflow.md" "In-scene signage the scene actually plans" "planned props are never collateral damage of the trailer"
need "$MODULES/07-image-workflow.md" "regenerate with the trailer **repeated as the prompt's opening sentence**" "the first repeat escalates the trailer's position"
need "$MODULES/07-image-workflow.md" "offer the flow-side fallback" "a double failure hands over the prompt, not the bad frame"
need "$MODULES/07-image-workflow.md" "**Unusual-shape ingredients go Flow-first" "unusual shapes are offered Flow first, not last"
need "$MODULES/07-image-workflow.md" "**Auto riddle images generate in chat by default" "auto images default to chat"
need "$MODULES/11-output-format.md" "sends **only that shot's full scene-only image prompt text**" "button isolates the image prompt"
need "$MODULES/03b-auto-presets.md" "**The first message generates zero images**" "auto first message is text-only"
need "$MODULES/10-clip1-final.md" "generate zero images in the first message" "Clip 1 defers on auto"
need "$MODULES/10-clip1-final.md" "Always print the Clip 1 image prompt too" "Clip 1 prompt plus regen command ships"
need "$MODULES/16-checklist.md" "the first message generated zero images" "the final gate checks auto text-first"
need "$MODULES/07-image-workflow.md" "at most one in-chat attempt" "the retry lottery is capped at one"
need "$BUILD" "**Unusual-shape ingredients go Flow-first" "the Flow-first rule survives the build"
need "$MODULES/07-image-workflow.md" "A prompt that omits the trailer is a defect caught at the checklist" "omission is a named defect"
need "$MODULES/16-checklist.md" "Every image prompt carried the mandatory image-prompt trailer verbatim" "the final gate checks the trailer shipped"
need "$MODULES/16-checklist.md" "the trailer was repeated as the prompt's opening sentence for the regeneration" "the final gate checks the escalation"
need "$BUILD" "One single frame of one composed scene — a single shot. No storyboard" "the trailer survives the build"
need_not "$BUILD" "with an impossibly deep, inhuman male voice. The voice is extremely bass-heavy" "the voice template no longer hardcodes the timbre outside the fill rule"
echo

# ------------------------------------------------------- 24. handoff freshness
# The handoff is the resume point for a fresh session; it goes stale silently.
# Pinning it to the current version makes a release bump a failing check until
# the state table is updated (and it is the section a reader trusts most).
echo "24. Handoff freshness"
VER="$(tr -d '[:space:]' < version.txt)"
need "docs/HANDOFF.md" "$VER" "the handoff names the current version ($VER)"
need "docs/HANDOFF.md" "build/google-flow-story-maker.md" "the handoff names the canonical artifact"
need "docs/HANDOFF.md" "docs/SUMMARY.md" "the handoff points at the version history"
echo

# ------------------------------------------------------- 25. the .auto skip path
# .auto is the one command that skips both forms AND the checkpoint, on explicit
# invocation only. Guards pin: the typed count-sentence extension, the explicit
# checkpoint prohibition (v2.16.0 in a new guise otherwise), the .go distinction,
# the auto-lock quality gate, the checklist lock, and the anti-state-inference
# rule (bare attachments never trigger). The mukbang-ASMR default lives in §32;
# the old standing voiceover authorization is retired there, not here.
echo "25. The .auto skip path"
need "$BUILD" "the one skip command" "the count sentence names .auto as the one skip command"
need "$BUILD" "neither a form nor a checkpoint" ".auto is typed outside the form count"
need "$BUILD" "for that run only" "the .auto skip is scoped to one run"
need "$BUILD" "do not present the Story Overview checkpoint" "the checkpoint is explicitly barred on .auto runs"
need "$BUILD" "Bare attachments never trigger" "attachments alone never start an auto run"
need "$BUILD" "does not create a riddle or set a story type" ".go and .auto cannot be conflated"
need "$BUILD" "generate one candidate that passes the riddle rules" "auto-lock keeps the riddle quality gate"
need "$BUILD" "self-check before locking it" "auto-lock self-checks before locking"
need "$MODULES/16-checklist.md" "On an \`.auto\` run" "the checklist locks the .auto path"
need "$MODULES/16-checklist.md" "no partial form" "the checklist bars partial forms on .auto"
need_not "$BUILD" "auto counts as a form" ".auto is never folded into the form count"
need_not "$BUILD" "generate a shortlist" "no pick-list resurrection on the auto path"
echo

# ------------------------------------------------------- 26. neutral riddle generation
# Generated riddles are written as if no story exists yet; genre mood lives in
# delivery only. Guards pin the neutrality rule, the rewritten genre paragraph,
# the checklist mirror, and trap the two outvoting sentences that told the model
# to mood the wording (the license behind horror-theme answers).
echo "26. Neutral riddle generation"
need "$MODULES/03-riddle-prephase.md" "Generate every candidate neutrally, as if no story exists yet" "the neutrality rule is stated"
need "$MODULES/03-riddle-prephase.md" "no genre, no setting, no characters, and no Teller" "generation excludes story context"
need "$MODULES/03-riddle-prephase.md" "none of its mood reaches the riddle text" "mood is directed away from the riddle"
need "$MODULES/03-riddle-prephase.md" "spend the genre entirely on how the riddle is delivered" "mood has a permitted replacement"
need "$BUILD" "as if no story exists yet" "the neutrality rule survives the build"
need "$MODULES/16-checklist.md" "generated neutrally" "the checklist verifies neutral generation"
need_not "$MODULES/03-riddle-prephase.md" "apply the mood to the" "no mood-into-wording rule remains"
need_not "$MODULES/03-riddle-prephase.md" "dread lives in the phrasing" "no dread-in-the-wording claim remains"
echo

# ------------------------------------------------------- 27. allocated timestamps
# The thinking beat collapsed because the pause had no timestamps to hold it.
# Guards pin: the blueprint clip map, the nominal-span hedge, the position-based
# thinking beat, the final-clip consequence rule (+03 mirror), the prompt header
# (+08), the checklist mirror, and the trap against hard clip-number pinning.
echo "27. Allocated timestamps"
need "$MODULES/05-story-planning.md" "Clip N of M, timestamp range, one-line beat purpose" "the blueprint clip map has a per-clip line format"
need "$MODULES/05-story-planning.md" "Timestamps are nominal block spans, not exact durations" "timestamps are hedged as nominal spans"
need "$MODULES/05-story-planning.md" "A middle clip may be a thinking beat" "the thinking beat is defined by position, not number"
need "$MODULES/05-story-planning.md" "no consequence starts before the final clip" "the consequence is held to the final clip"
need "$MODULES/05-story-planning.md" "sharing the final clip never merges them" "wait and consequence stay separate even when they share the final clip"
need "$MODULES/05-story-planning.md" "offer one more clip in one line at the Story Overview checkpoint" "the shortfall offer names its site"
need "$MODULES/03-riddle-prephase.md" "no consequence starts before the final clip" "the riddle module mirrors the final-clip rule"
need "$MODULES/08-video-prompt.md" "begin each independently generated clip prompt with its clip-map line" "each prompt carries its timestamp header"
need "$MODULES/08-video-prompt.md" "do not put timestamps inside a shot description" "timestamps stay planning-level"
need "$MODULES/16-checklist.md" "clip map is present" "the checklist mirrors the clip-map rule"
need "$MODULES/16-checklist.md" "carries its own clip-map line as its timestamp header" "the checklist mirrors the prompt header rule"
need "$BUILD" "no consequence starts before the final clip" "the rule survives the build"
need_not "$MODULES/05-story-planning.md" "Clip 2 is the thinking beat" "no hard clip-number pinning"
echo

# ------------------------------------------------------- 28. story-type trigger
# A story type named WITHOUT the word `auto` is a guided-mode start (an implicit
# .start): it begins the run but never authorizes skipping the forms. Only the word
# `auto` before the type (± dot) authorizes auto mode — the v2.25.0 reading that made
# "horror riddle" an .auto authorization is retired. Guards pin the guided-start
# reading, the Tagalog form, the never-triggers list incl. the mid-run carve-out,
# and trap the retired auto-authorization readings.
echo "28. Story-type trigger"
need "$BUILD" "names the story type outright" "the trigger is stated in request form"
need "$BUILD" "starts the run as an implicit \`.start\`" "a type named without auto starts guided mode"
need "$BUILD" "only the word \`auto\` before the type authorizes auto mode" "the auto boundary is explicit"
need "$BUILD" "horror na bugtong" "the Tagalog type form is named"
need "$BUILD" "a bare attachment with no request" "bare attachments are excluded"
need "$BUILD" "a question or opinion ask" "questions are excluded"
need "$BUILD" "it is a Form 1 answer or an overview change" "mid-run mentions are carved out"
need "$MODULES/02-role.md" "typed literally" "the literal case is named"
need "$MODULES/02-role.md" "starts the run in guided mode" "type words start a guided run, never hijack one"
need "$MODULES/16-checklist.md" "ran **guided mode** instead" "the checklist names the guided fallback"
need "$MODULES/16-checklist.md" "a bare attachment or a question never started anything" "the checklist bars false triggers"
need "$BUILD" "is manual input, not an auto run" "bare input stays manual"
need_not "$BUILD" "story-type words always trigger" "no always-trigger reading"
need_not "$BUILD" "a bare attachment starts the auto path" "attachments never start a run"
need_not "$BUILD" "No \`.start\` and no typed \`.auto\` is required" "the retired auto-authorization is gone"
need_not "$BUILD" "naming the story type outright as a request is the authorization" "the old auto licence is retired"
need_not "$BUILD" "starts the \`.auto\` path with the same semantics" "the old auto-aliasing of type words is retired"
echo

# ------------------------------------------------------- 29. tagalog indirect description
# Riddle clues must turn on words of the chosen language used obliquely (Tagalog
# default: mukha/mata/kamay, double meanings) — wordplay as misdirection. Guards
# pin the technique, the worked example, the checklist mirror, the user-riddle
# carve-out, and trap spooky-word indirection and direct naming.
echo "29. Tagalog indirect-description rule"
need "$MODULES/03-riddle-prephase.md" "words used obliquely" "the rule is stated as a technique"
need "$MODULES/03-riddle-prephase.md" "may mukha ngunit walang mata" "the Tagalog example is present"
need "$MODULES/03-riddle-prephase.md" "never rewrites a user-supplied riddle" "the user-riddle carve-out is scoped"
need "$BUILD" "the wordplay itself is the misdirection, not decoration" "the rule survives the build"
need "$BUILD" "orasan" "the example survives the build"
need "$MODULES/16-checklist.md" "words used obliquely" "the rule is mirrored in the checklist"
need_not "$MODULES/03-riddle-prephase.md" "words chosen for spookiness" "indirection never comes from spooky words"
need_not "$BUILD" "clues may directly name the answer" "no direct-description reading survives"
echo

# ------------------------------------------------------- 30. overview text only
# The live run rendered the overview itself as a hero+grid+storyboard sheet with
# the locked riddle as readable text. The one-image rule never contemplated the
# overview being an image. Guards pin: overview is text, the three banned shapes
# named, the checkpoint turn imageless, Clip 1 the run's sole image, checklist
# mirror. Traps: "storyboard image" must vanish with the 05 rewrite it came from;
# "visual-style reference grid" is preventive (no literal licensed the sheet).
echo "30. Overview text-only"
need "$BUILD" "The Story Overview checkpoint is delivered as plain text" "overview is text-only in the build"
need "$BUILD" "hero illustration" "the hero shape is named"
need "$BUILD" "multi-panel storyboard sheets" "the storyboard shape is named"
need "$MODULES/05-story-planning.md" "storyboard sheets included" "storyboard sheets banned in planning"
need "$MODULES/05-story-planning.md" "No image of the overview" "planning bans an overview image"
need "$MODULES/10-clip1-final.md" "in a non-auto run the only image in the entire run is the Clip 1 reference image" "Clip 1 states the run's sole image (non-auto)"
need "$MODULES/16-checklist.md" "not a generated image" "checklist verifies text delivery"
need_not "$BUILD" "storyboard image" "no storyboard-image permission survives"
need_not "$BUILD" "visual-style reference grid" "no style-grid wording survives"
echo

# ------------------------------------------------------- 31. riddle spoken only
# The live run displayed the locked riddle as on-screen text. 08:53's "counts as
# explicitly supplied speech" licensed it. Guards pin the re-scope (speech, never
# text), the standalone rule, and the checklist mirror. The need_not trap fires
# pre-edit on the old sentence and flips green with its removal — that flip is
# the proof.
echo "31. Riddle spoken-only"
need "$BUILD" "counts as supplied speech for the clip that delivers it" "speech authorization is re-scoped"
need "$BUILD" "spoken-only" "the spoken-only label survives the build"
need "$BUILD" "never as on-screen text, subtitles, captions, or overlays" "the riddle-text ban survives the build"
need "$MODULES/08-video-prompt.md" "and nothing else — it is spoken-only" "re-scope sentence in module 08"
need "$MODULES/16-checklist.md" "delivered as Teller speech only" "checklist mirrors the rule"
need_not "$BUILD" "counts as explicitly supplied speech" "old licensing sentence retired"
echo

# ------------------------------------------------------- 32. mukbang ASMR default
# A mukbang run is silent of speech by default — ASMR eating sounds only. The old
# standing voiceover authorization ("carries its own speech authorization") is
# retired: the need_not below fires pre-edit and flips with its removal.
echo "32. Mukbang ASMR default"
need "$MODULES/01-commands.md" "silent of speech by default" "01 runs mukbang silent of speech"
need "$MODULES/01-commands.md" "If the user explicitly asks for narration or voiceover on the mukbang" "01 carries the follow-the-user clause"
need "$MODULES/08-video-prompt.md" "carries no standing speech authorization" "08 retires the standing authorization"
need "$MODULES/08-video-prompt.md" "chewing, sizzle, crunch, slurp" "08 names the ASMR inventory"
need "$MODULES/15-defaults.md" "the mukbang path runs ASMR food and eating sounds" "defaults mirror the ASMR audio"
need "$MODULES/16-checklist.md" "every clip is silent of speech by default" "checklist mirrors the no-speech rule"
need "$BUILD" "silent of speech by default" "the rule survives the build"
need_not "$BUILD" "carries its own speech authorization" "no standing voiceover license survives"
echo

# ------------------------------------------------------- 33. flat riddle endings
# Veo 3.1 renders Tagalog '?' intonation as inviting; the Teller issues a
# challenge, not an invitation. Generated riddles close on a flat statement with
# a period — the worked example included. User riddles stay verbatim.
echo "33. Flat riddle endings"
need "$MODULES/03-riddle-prephase.md" "A generated riddle never ends with a question mark" "the flat-ending rule is stated"
need "$MODULES/03-riddle-prephase.md" "End on the final clue as a flat" "clues close flat"
need "$MODULES/03-riddle-prephase.md" "never a question mark" "the impersonal closer takes a period"
need "$MODULES/03-riddle-prephase.md" "even if it ends with a question mark" "the verbatim carve-out survives"
need "$MODULES/03-riddle-prephase.md" "or with a trailing question mark" "the self-check covers the ending"
need "$MODULES/16-checklist.md" "does not end with a question mark" "the checklist mirrors the ban"
need "$BUILD" "A generated riddle never ends with a question mark" "the rule survives the build"
need_not "$MODULES/03-riddle-prephase.md" "at most close with an impersonal question" "the old permission is gone"
need_not "$MODULES/03-riddle-prephase.md" "vanishes in the dark. Ano ito?" "the worked example is flat"
echo

# ------------------------------------------------------- 34. riddle variety
# Live defect: every batch of generated riddle options came back the same. Cause
# was in the pack — the same eight-noun example list appeared twice, so the model
# read it as a menu. Guards pin the widened non-exhaustive pool, the batch-unique
# answers rule, the reroll answer rule, and the neutrality carve-out.
echo "34. Riddle variety"
need "$MODULES/03-riddle-prephase.md" "they are not a menu" "the example pool is not a menu"
need "$MODULES/03-riddle-prephase.md" "Answers follow the answer-source rule (section 2b)" "answers follow the source rule, not invention or the illustrations"
need "$MODULES/03-riddle-prephase.md" "no two candidates in the same list share an answer" "answers are unique within a batch"
need "$MODULES/03-riddle-prephase.md" "it constrains answers toward freshness, never toward mood" "the neutrality carve-out is stated"
need "$MODULES/03-riddle-prephase.md" "must not reuse the locked riddle's answer" "rerolls do not reuse the locked answer"
need "$MODULES/15-defaults.md" "vary the answers across the batch and across re-rolls" "defaults mirror the variety rule"
need "$MODULES/16-checklist.md" "the answers are varied and not repeated" "checklist mirrors the variety rule"
need "$BUILD" "they are not a menu" "the variety rule survives the build"
need_not "$BUILD" "described from the thing itself: shadow" "the menu-shaped sentence is retired"
echo

# ------------------------------------------------------- 35. single-item revision
# The user asked to change one item (e.g. the riddle text) after everything is
# ready and get only the affected clip prompts back — never a re-plan. Guards pin
# the scope sentence, the two revision classes, the silent-swap test with its
# re-seal, and the Extend coverage.
echo "35. Single-item revision"
need "$MODULES/01-commands.md" "apply the revision to that item only" "the one-item scope is stated"
need "$MODULES/01-commands.md" "regenerate only the deliverables that carry the changed item" "the re-emit scope is stated"
need "$MODULES/01-commands.md" "state in one line which clips were updated and reprint only those clip prompts" "the one-line update report is required"
need "$MODULES/01-commands.md" "regenerates the Clip 1 reference image" "identity changes regenerate the reference image"
need "$MODULES/03-riddle-prephase.md" "apply the swap silently if and only if the new riddle still fits the locked plan" "the silent-swap test is stated"
need "$MODULES/03-riddle-prephase.md" "re-seal the answer and re-run the end-of-plan leak check" "a swap re-seals and re-checks for leaks"
need "$MODULES/03-riddle-prephase.md" "A revision is not the reroll path" "revision and reroll are distinct"
need "$MODULES/05-story-planning.md" "is never a re-plan" "planning forbids a re-plan on a revision"
need "$MODULES/08-video-prompt.md" "re-emit the Extend clip's delta" "Extend deltas are re-emitted when visible"
need "$MODULES/16-checklist.md" "one item only, never a re-plan" "the checklist mirrors the revision rule"
need "$MODULES/11-output-format.md" "which clips were updated and reprint only those clip prompts" "the report shape is mirrored"
need "$BUILD" "apply the revision to that item only" "the revision rule survives the build"
need "$BUILD" "regenerates the Clip 1 reference image" "the image regeneration survives the build"
need_not "$BUILD" "re-plan from scratch" "no re-plan escape hatch survives"
echo

# ------------------------------------------------------- 36. reference-image binding
# The user asked that clip prompts follow the exact visual quality of the given
# image. The binding was missing: step 1/step 5 said nothing about where the look
# comes from. Guards pin the binding, the photo-stays-photographic carve-out, the
# Extend carve-out (a binding would be a restatement in disguise), and the traps
# against the vague wish-phrase and against spawning extra style assets.
echo "36. Reference-image binding"
need "$MODULES/08-video-prompt.md" "match its look in medium, render quality, palette, lighting, and grade" "the clip prompt binds to the reference image"
need "$MODULES/08-video-prompt.md" "user-supplied photo is matched at its own medium" "a supplied photo keeps its own medium"
need "$MODULES/08-video-prompt.md" "a photograph stays photographic" "photos are not silently stylized"
need "$MODULES/08-video-prompt.md" "unless the user's chosen art style explicitly asks for a different treatment" "the art-style override is carved out"
need "$MODULES/08-video-prompt.md" "read from the reference image named in step 1" "step 5 reads its look from the image"
need "$MODULES/08-video-prompt.md" "state the observed medium, palette, lighting direction, and color grade" "the look is stated concretely"
need "$MODULES/08-video-prompt.md" "continues the base clip's look directly" "the Extend carve-out is stated"
need "$MODULES/08-video-prompt.md" "the delta never describes an image's qualities" "the Extend delta describes no image"
need "$MODULES/09-clip-continuity.md" "carries no reference-image binding" "Extend carries no image binding"
need "$MODULES/09-clip-continuity.md" "inheritance from the base clip is the visual contract" "inheritance is named the contract"
need "$MODULES/09-clip-continuity.md" "binds to this keyframe the same way" "an Add clip binds to its own keyframe"
need "$MODULES/10-clip1-final.md" "Clip 1's prompt binds to it directly" "Clip 1 binds to its own reference image"
need "$MODULES/10-clip1-final.md" "it is matched as a photograph" "Clip 1 names the photo case"
need "$MODULES/16-checklist.md" "names its reference image and requires the video to match that image's medium" "the checklist mirrors the binding"
need "$MODULES/16-checklist.md" "carries no image binding — it continues the base clip's look" "the checklist mirrors the Extend carve-out"
need "$BUILD" "match its look in medium, render quality, palette, lighting, and grade" "the binding survives the build"
need "$BUILD" "a photograph stays photographic" "the photo rule survives the build"
need_not "$BUILD" "the exact visual quality of the image shown" "the vague wish-phrase never ships"
need_not "$MODULES/08-video-prompt.md" "stylize the supplied photo to match" "no photo-stylization permission"
need_not "$MODULES/09-clip-continuity.md" "the Extend clip names its reference image" "Extend never names an image"
need_not "$MODULES/10-clip1-final.md" "generate a style sample from the reference image" "the binding spawns no extra assets"
echo

# ------------------------------------------------------- 37. optional plugin package
# The plugin is a separate deliverable. The default validation covers only the
# story maker modules and compiled Markdown. Set VALIDATE_PLUGIN=1 to check the
# plugin's packaged copy during plugin work, or run its own validator directly.
if [ "${VALIDATE_PLUGIN:-0}" = "1" ]; then
echo "37. Plugin package"
if [ -f "$ROOT/plugin/flow-story-maker/plugin.json" ]; then
  pass "the plugin package exists"
else
  fail "plugin/flow-story-maker/plugin.json is missing"
fi
if [ -f "$ROOT/plugin/flow-story-maker/plugin.json" ]; then
  PLUGIN_VERSION="$(python3 -c "import json;print(json.load(open('$ROOT/plugin/flow-story-maker/plugin.json'))['version'])" 2>/dev/null || echo unknown)"
  PACK_VERSION="$(tr -d '[:space:]' < "$ROOT/version.txt")"
  if [ "$PLUGIN_VERSION" = "$PACK_VERSION" ]; then
    pass "the plugin version tracks version.txt ($PACK_VERSION)"
  else
    fail "plugin version $PLUGIN_VERSION does not match version.txt $PACK_VERSION — run ./plugin/build-plugin.sh"
  fi
fi
PLUGIN_REF="$ROOT/plugin/flow-story-maker/skills/flow-story-maker/references/gfs-instructions.md"
# The portal imports the listing URLs from the manifest and does not fill them
# from homepage/author.url, so an unlisted privacy or support page is a silent
# submission failure. Keep all four declared.
if [ -f "$ROOT/plugin/flow-story-maker/plugin.json" ]; then
  LISTING="$(python3 -c "
import json,sys
i=json.load(open('$ROOT/plugin/flow-story-maker/plugin.json'))['extensions']['com.openai']['interface']
print(','.join(f for f in ('websiteURL','supportURL','privacyPolicyURL','termsOfServiceURL') if not i.get(f)))
" 2>/dev/null || echo error)"
  if [ "$LISTING" = "error" ]; then
    fail "the plugin manifest could not be read for its listing URLs"
  elif [ -z "$LISTING" ]; then
    pass "the plugin manifest declares all four listing URLs"
  else
    fail "the plugin manifest is missing listing URL(s): $LISTING"
  fi
fi
if [ -f "$PLUGIN_REF" ]; then
  PLUGIN_TMP="$(mktemp)"
  tail -n +5 "$PLUGIN_REF" > "$PLUGIN_TMP"
  if diff -q "$PLUGIN_TMP" "$BUILD" >/dev/null 2>&1; then
    pass "the plugin's embedded rulebook matches this build"
  else
    fail "the plugin's embedded rulebook is stale — run ./plugin/build-plugin.sh"
  fi
  rm -f "$PLUGIN_TMP"
else
  fail "the plugin's embedded rulebook is missing — run ./plugin/build-plugin.sh"
fi
for skill_dir in "$ROOT"/plugin/flow-story-maker/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  declared="$(sed -n '1,20p' "$skill_dir/SKILL.md" 2>/dev/null | awk '/^name:[[:space:]]*/{print $2; exit}')"
  if [ "$declared" = "$skill_name" ]; then
    pass "skill $skill_name declares its own folder name"
  else
    fail "skill $skill_name declares '$declared' — must equal the folder name"
  fi
done
if [ -e "$ROOT/plugin/flow-story-maker/mcp.json" ] || [ -e "$ROOT/plugin/flow-story-maker/.app.json" ] || [ -d "$ROOT/plugin/flow-story-maker/hooks" ]; then
  fail "the plugin package picked up an MCP/app/hooks component — it must stay skills-only"
else
  pass "the plugin package is still skills-only"
fi
if [ -x "$ROOT/plugin/validate-plugin.sh" ]; then
  if "$ROOT/plugin/validate-plugin.sh" >/dev/null 2>&1; then
    pass "the plugin package validator passes"
  else
    fail "the plugin package validator fails — run ./plugin/validate-plugin.sh"
  fi
else
  fail "plugin/validate-plugin.sh is missing or not executable"
fi
echo
fi

# ------------------------------------------------------- 38. live-run reliability
echo "38. Riddle roles, pacing, and Form 2 submission"
need "$MODULES/03-riddle-prephase.md" "The victims pay the price; the Teller performs the act" "the consequence has an explicit actor and victim"
need "$MODULES/04-interview.md" "the chosen Character fills the victim slot only" "the Character choice cannot become the Teller"
need "$MODULES/05-story-planning.md" "separate locked designs for the victims and the Teller" "the blueprint keeps both roles distinct"
need "$MODULES/16-checklist.md" "victims pay the price and the Teller acts" "the final gate checks consequence direction"
need "$MODULES/03-riddle-prephase.md" "Do not use the 24-word ceiling as proof that an 8-second clip fits" "the normal-pace ceiling is not a guaranteed fit"
need "$MODULES/05-story-planning.md" "offer one more clip or a longer-duration model" "the checkpoint surfaces a duration shortfall"
need "$MODULES/04-interview.md" "visible Submit button" "Form 2 has an explicit submission control"
need "$MODULES/04-interview.md" "type .go or send one line with your choices" "Form 2 has a text fallback"
need "$MODULES/16-checklist.md" "visible Submit button and a .go/text fallback" "the final gate checks Form 2 submission"
need_not "$MODULES/03-riddle-prephase.md" "fold the consequence into the final moment of that beat" "the old beat-compression permission is gone"
need_not "$MODULES/03-riddle-prephase.md" "the whole story can often be **1–2 clips**" "the old word-count clip shortcut is gone"
echo

# ------------------------------------------------------- 39. creative diversity
# A twelve-run sample produced one film: a small animal cornered in a doorway by
# something much larger and robed, shot from behind the victim, ending in the way
# being sealed. Nothing mandated that formula — the retired victim wording
# ("small, cute, vulnerable") plus passage-shaped trap examples and
# sealing-shaped consequence examples read as the spec, and nothing selected a
# camera. Guards pin the invariants-vs-defaults split, the nine axes, the
# no-reuse rule, the planning-only fingerprint, `.reroll visual`, the camera
# viewpoint axis, the image acceptance gate, and trap every retired phrase so the
# narrow formula cannot drift back in.
echo "39. Creative diversity (riddle ensemble)"
need "$MODULES/03-riddle-prephase.md" "## 2a. Creative diversity engine (every riddle story)" "the creative-diversity section exists"
need "$MODULES/03-riddle-prephase.md" "**None of the fixed items implies any of the free ones.**" "invariants are separated from visual defaults"
need "$MODULES/03-riddle-prephase.md" "The victims do **not** have to be small, cute, young, soft, or animal" "the small-cute-victim requirement is explicitly retired"
need "$MODULES/03-riddle-prephase.md" "**Horror is not darkness, robes, giants, or stone corridors.**" "the horror-look assumption is refused"
need "$MODULES/03-riddle-prephase.md" "**Nothing fixes the Teller's shape.**" "the Teller's shape is a free axis"
need "$MODULES/03-riddle-prephase.md" "the supernatural Teller voice block governs that delivery" "a bodiless Teller still has to speak the riddle"
need "$MODULES/03-riddle-prephase.md" "### The axes (settle all nine, every run)" "the axes are enumerated"
need "$MODULES/03-riddle-prephase.md" "Inverted — a Teller visibly smaller than the victim — must be weighed every run" "the inverted size relation is a first-class option"
need "$MODULES/03-riddle-prephase.md" "and the trap does not have to be architectural" "the trap is not assumed to be a passage"
need "$MODULES/03-riddle-prephase.md" "they are not the set to choose from" "the consequence examples are labelled illustrations"
need "$MODULES/03-riddle-prephase.md" "### The combination has to be one situation, not a collage" "coherence is required of the combination"
need "$MODULES/03-riddle-prephase.md" "### Do not reuse the recent design" "recent-design avoidance is stated"
need "$MODULES/03-riddle-prephase.md" "prefer a **materially different composition** over a recoloured one" "recolouring is not variety"
need "$MODULES/03-riddle-prephase.md" "### The fingerprint (planning only — never story, never an image prompt)" "the fingerprint is scoped"
need "$MODULES/03-riddle-prephase.md" "It is **never** passed to the image model, in whole or in part." "the fingerprint never reaches the image prompt"
need "$MODULES/03-riddle-prephase.md" "### Explicit choices win" "user-locked axes are never randomized away"
need "$MODULES/03-riddle-prephase.md" "Never invent a history you cannot see" "no invented production history"
need "$MODULES/03-riddle-prephase.md" "draws one of the option-deck presets (section 2c)" ".auto riddle draws its look from the deck"
need "$MODULES/03-riddle-prephase.md" "and so is a distance that will not close" "non-architectural traps are named in the structure block"
need "$MODULES/04-interview.md" "must **not** all be small mammals or birds" "the victim pitches must vary in form"
need "$MODULES/04-interview.md" "differ in **archetype and form**" "the three pitches differ by archetype, not costume"
need "$MODULES/05-story-planning.md" "the run's one-line **creative fingerprint** belongs in these continuity notes" "the blueprint carries the fingerprint"
need "$MODULES/15-defaults.md" "chosen fresh for every run** by the creative-diversity section (2a)" "the defaults defer the ensemble to section 2a"
need "$MODULES/15-defaults.md" "and draws the run's look from the deck (section 2c)" "the .auto default draws from the deck"
need "$MODULES/01-commands.md" "\`.reroll visual\` — Change the **look** of a riddle production without touching the riddle" ".reroll visual exists"
need "$MODULES/01-commands.md" "\`.reroll\` changes **riddles only** — it never changes the look of the production — and a fresh batch re-runs the answer-source rule (section 2b)" ".reroll is scoped to riddles and re-draws answers"
need "$MODULES/01-commands.md" "Axes the user has locked (a chosen character, art style, setting, or camera) are **not** re-rolled" ".reroll visual respects locked axes"
need "$MODULES/08a-shot-composition.md" "### Camera viewpoint (choose one explicitly, before any image)" "the viewpoint axis is enumerated"
need "$MODULES/08a-shot-composition.md" "**Do not default to a rear-view figure facing a larger centred one.**" "the house composition is refused"
need "$MODULES/08a-shot-composition.md" "State the chosen viewpoint in the image prompt" "the viewpoint reaches the image prompt"
need "$MODULES/07-image-workflow.md" "### Image acceptance gate (check the frame against the plan before presenting it)" "the acceptance gate exists"
need "$MODULES/07-image-workflow.md" "A swapped species or swapped design is a **failed frame**." "species/design drift is a failed frame"
need "$MODULES/07-image-workflow.md" "**Report a repeated failure; never quietly replan.**" "repeated failure is reported, not silently replanned"
need "$MODULES/07-image-workflow.md" "never present a mismatched frame as if it were the planned scene" "a mismatched frame is never presented as the plan"
need "$MODULES/10-clip1-final.md" "Then check the frame against the plan before showing it" "Clip 1 runs the acceptance gate"
need "$MODULES/10-clip1-final.md" "**Never rewrite the plan to match the image.**" "Clip 1 never replans around the image"
need "$MODULES/16-checklist.md" "the **victims and the Teller were chosen for this run**" "the final gate checks the ensemble was chosen"
need "$MODULES/16-checklist.md" "planning-only creative fingerprint" "the final gate checks the fingerprint"
need "$MODULES/16-checklist.md" "passed the **image acceptance gate** before being shown" "the final gate checks the acceptance gate"
need "$MODULES/16-checklist.md" "the **viewpoint was chosen on purpose**" "the final gate checks the viewpoint choice"
need "$BUILD" "## 2a. Creative diversity engine (every riddle story)" "the diversity section survives the build"
need "$BUILD" "materially different composition" "the anti-recolouring rule survives the build"
need "$BUILD" "Image acceptance gate" "the acceptance gate survives the build"
# The dry run is the only place the variety claim is measured rather than asserted,
# so the scorer is wired in: a sample that stops clearing its bars fails the build
# instead of surviving in a reviewer's memory.
if [[ -f specs/evidence/score-diversity-dry-run.py && -f specs/evidence/diversity-dry-run.tsv ]]; then
  pass "the 12-production dry-run sample and its scorer are present"
  if command -v python3 >/dev/null 2>&1; then
    if python3 specs/evidence/score-diversity-dry-run.py >/dev/null 2>&1; then
      pass "the dry run still clears every diversity acceptance criterion"
    else
      fail "the diversity dry run FAILS an acceptance criterion — run: python3 specs/evidence/score-diversity-dry-run.py"
    fi
  else
    printf '  skip  python3 not found — diversity dry run NOT scored\n'
  fi
else
  fail "the diversity dry-run sample or its scorer is missing"
fi
need_not "$MODULES/03-riddle-prephase.md" "**small, cute, vulnerable**" "the retired victim wording is gone from the riddle module"
need_not "$MODULES/03-riddle-prephase.md" "Keep them small and soft rather than fearsome" "the keep-them-small instruction is gone"
need_not "$MODULES/04-interview.md" "small, cute, vulnerable characters" "the interview no longer pitches only small victims"
need_not "$MODULES/04-interview.md" "they must look soft, not fearsome" "the soft-looking victim instruction is gone"
need_not "$MODULES/15-defaults.md" "small, cute, vulnerable" "the defaults no longer state the narrow victims"
need_not "$BUILD" "small, cute, vulnerable" "the retired victim wording is gone from the build"
echo

echo "40. Answer bank: the generator's answer source (spread, families, no invention)"
# WHY: the generator used to invent its own answer, so unrelated sessions converged on
# the same handful of objects, and the illustrations in Step 0a (salamin, kandila,
# anino, orasan) read as the menu. An embedded 1,000-answer bank was tried as the fix and
# then withdrawn at the user's call — the pack must not ship a data table. These guards
# keep the surviving rule (draw wide across the ordinary world, repeat nothing, never
# invent) wired into every site that points at it, and the need_not traps at the end make
# the bank's return a validation failure rather than a silent re-introduction.
need "$MODULES/03-riddle-prephase.md" "## 2b. Where a generated riddle's answer comes from" "the answer-source rule is its own section"
need "$MODULES/03-riddle-prephase.md" "**No answer list is supplied with this pack.**" "the pack states that no answer list ships with it"
need "$MODULES/03-riddle-prephase.md" "### Draw across the whole ordinary world, not from the top of a habit" "the wide-draw rule is its own subsection"
need "$MODULES/03-riddle-prephase.md" "**The examples in Step 0a are illustrations, never the menu.**" "the illustrations are not the menu"
need "$MODULES/03-riddle-prephase.md" "**Never answer with a thing you already used in this conversation**" "no answer is reused across the conversation"
need "$MODULES/03-riddle-prephase.md" "### Spread a batch, and repeat nothing" "the batch rule is stated"
need "$MODULES/03-riddle-prephase.md" "never the previous answers reordered or dressed in new wording" ".reroll draws genuinely fresh"
need "$MODULES/03-riddle-prephase.md" "The **riddle itself is written fresh**" "the answer supplies the thing, never the wording"
need "$MODULES/03-riddle-prephase.md" "**Never invent a history you cannot see.**" "no claimed history that cannot be read"
need "$MODULES/03-riddle-prephase.md" "ANSWERS-USED" "the used-answer record is still honoured"
need "$MODULES/03-riddle-prephase.md" "the answer-source rule (section 2b)" "Form 1's generator path names the rule"
need "$MODULES/03-riddle-prephase.md" "**Answers follow the answer-source rule (section 2b) — drawn across the ordinary world" "the Step 0a answer line points at the rule"
need "$MODULES/15-defaults.md" "Every generated answer follows the answer-source rule (section 2b)" "the defaults name the answer source"
need "$MODULES/16-checklist.md" "its answer followed the **answer-source rule (section 2b)**" "the final gate checks the answer source"
need "$MODULES/01-commands.md" "a fresh batch re-runs the answer-source rule (section 2b)" ".reroll is scoped to riddles and re-draws answers"
need "$MODULES/04-interview.md" "Same defect the riddle answers' source rule exists to stop" "the picks rule cites the riddle rule, not a withdrawn bank"
need "$BUILD" "## 2b. Where a generated riddle's answer comes from" "the answer-source rule survives the build"
# The bank module and its generator are gone (v2.38.0): there is no generated
# answer table left to drift, so the freshness check and its dry run are retired.
need_not "$MODULES/03-riddle-prephase.md" "Draw answers from anywhere in the ordinary world" "the invent-an-answer instruction is retired"
need_not "$BUILD" "Draw answers from anywhere in the ordinary world" "the retired instruction is gone from the build"
need_not "$BUILD" "Riddle answer bank (1000 answers)" "the withdrawn 1,000-answer table is not shipped"
need_not "$BUILD" "answer bank" "the withdrawn answer bank is gone from the pack"
need_not "$MODULES/03-riddle-prephase.md" "answer bank" "the withdrawn answer bank is gone from the riddle module"
echo

echo "41. Deliver everything the user came for: all prompts, the ingredient, both routes, wide picks"
# WHY: two narrowed offers in one failure class. (1) The delivery style was named "prompts
# now" but printed collapsed summaries and required a `1`/`2` reply per clip, so the user
# left the delivery turn with no prompt to copy — reported live as "it seems not giving all
# the clips prompts it should make it available to copy already" — and the image ingredient
# and the two ways they actually generate clips in Flow (extend the previous clip, or
# generate each clip from the same image) were never both handed over. (2) Every option set
# the pack offers (story ideas, AI Character A/B/C, the art-style list, the generated Script
# Overview) came back as the same few picks run after run, because a fixed set with no
# rotation rule is read from its head — the same defect the riddle answers' source rule
# prevents (section 40). These guards keep the prompts, the ingredient, both routes, and a
# wide fresh range in the pack.
need "$MODULES/11-output-format.md" "### Delivery turn (all prompts in full and copyable; the image ingredient; one image per action)" "the delivery turn is defined by handing over the prompts"
need "$MODULES/11-output-format.md" "Print the complete copy-ready Google Flow video prompt of **every** clip" "every clip's prompt is printed, not withheld"
need "$MODULES/11-output-format.md" "a summary line is a header, not a substitute" "a summary may not replace a prompt"
need "$MODULES/11-output-format.md" "Do not make the user reply \`1\`, \`2\`, … to see a prompt" "prompts are not gated behind a number reply"
need "$MODULES/11-output-format.md" "**Both continuation routes for every Clip 2+, labelled and separate.**" "both routes are delivered side by side"
need "$MODULES/11-output-format.md" "**The image ingredient, in the same turn.**" "the image ingredient is handed over at delivery"
need "$MODULES/11-output-format.md" "**that clip's standalone route** — the **independent** prompt" "the standalone block is that clip's own route"
need "$MODULES/11-output-format.md" "there is no chat-side image and no image prompt to print" "the ingredient hand-over has a supplied/Flow carve-out"
need "$MODULES/09-clip-continuity.md" "**Capability check, like Extend.**" "the ingredient-input capability must be verified"
need "$MODULES/09-clip-continuity.md" "the **Add clip** prompt bound to its own keyframe when the beat needs a new location/angle/setup" "the standalone route follows the clip's own plan"
need "$MODULES/05-story-planning.md" "**Add-clip keyframes are the one exception**" "the asset plan reconciles Add-clip keyframes"
need "$MODULES/08-video-prompt.md" "(Clip 1, every Add clip, and every clip generated from the run's ingredient)" "the master-block enumeration includes ingredient clips"
need "$MODULES/09-clip-continuity.md" "(Clip 1, every Add clip, and every clip generated from the run's ingredient)" "the continuity enumeration includes ingredient clips"
need "$MODULES/03-riddle-prephase.md" "These are proposals under the **suggestion-variety rule (interview module, section 3a)**" "Form 1's option set points at 3a"
need "$MODULES/16-checklist.md" "**The ingredient-as-input capability was verified before the independent route was offered**" "the final gate checks the capability"
need "$BUILD" "**that clip's standalone route**" "the standalone-route rule survives the build"
need_not "$MODULES/11-output-format.md" "print a labelled **Extend** block and a labelled **independent** block" "the independent-only pair is retired"
need_not "$MODULES/11-output-format.md" "the Clip 1 image (already generated by the Clip 1 final phase) plus its **complete copy-ready image prompt" "the unconditional ingredient hand-over is retired"
need_not "$MODULES/15-defaults.md" "the Extend delta and the independent prompt bound to that ingredient" "the fixed ingredient-only pair is retired from the defaults"
need_not "$MODULES/05-story-planning.md" "the Extend delta and the independent prompt — for the user to choose between" "the fixed pair is retired from the clip list"
need "$MODULES/11-output-format.md" "A compact view is available on request, never the default." "the compact view is opt-in, not the default"
need "$MODULES/11-output-format.md" "never merge clips into one giant prompt" "the never-merge rule survives"
need "$MODULES/11-output-format.md" "uses the run's ingredient — no new image" "an independent clip needs no new image"
need "$MODULES/10-clip1-final.md" "every remaining clip's complete prompt in full" "Clip 1 continues into full prompts, not summaries"
need "$MODULES/10-clip1-final.md" "**This image is the run's image ingredient**" "Clip 1's image is named as the run's ingredient"
need "$MODULES/09-clip-continuity.md" "**Independent, from the run's existing image ingredient (default)**" "the same-ingredient route is its own contract"
need "$MODULES/09-clip-continuity.md" "**No new keyframe is made.**" "the same-ingredient route makes no new keyframe"
need "$MODULES/09-clip-continuity.md" "**Independent clip using the run's ingredient → no new image.**" "the image-needs summary covers the same-ingredient route"
need "$MODULES/09-clip-continuity.md" "the **Extend** delta, and that clip's **standalone** route" "the continuity module mirrors the two-block delivery"
need "$MODULES/04-interview.md" "deliver **the complete video prompt of every clip, up to the first 5, in full, in clip order, each in its own fenced code block**" "the interview's delivery default hands over the prompts"
need "$MODULES/04-interview.md" "independently from the run's existing image ingredient" "the interview offers the same-ingredient route"
need "$MODULES/15-defaults.md" "Deliver **every clip's complete video prompt in full**" "the defaults deliver the prompts in full"
need "$MODULES/15-defaults.md" "both** continuation routes labelled side by side" "the defaults name both routes"
need "$MODULES/05-story-planning.md" "Record which route is recommended for each Clip 2+" "the clip list records the route but withholds neither"
need "$MODULES/16-checklist.md" "**The delivery turn printed every clip's complete prompt**" "the final gate checks the prompts were handed over"
need "$MODULES/16-checklist.md" "**Every Clip 2+ was delivered in both routes, labelled**" "the final gate checks both routes shipped"
need "$MODULES/16-checklist.md" "**The run's image ingredient was handed over in the delivery turn**" "the final gate checks the ingredient shipped"
need "$BUILD" "### Delivery turn (all prompts in full and copyable" "the delivery turn survives the build"
need "$BUILD" "**Both continuation routes for every Clip 2+, labelled and separate.**" "the two-route rule survives the build"
# The picks the pack proposes: one rule, every site pointing at it (section 3a).
need "$MODULES/04-interview.md" "## 3a. The picks this pack proposes (suggestion variety)" "the suggestion-variety rule is its own section"
need "$MODULES/04-interview.md" "Draw from a wide range, not from the head of a set." "the head-of-set trap is refused"
need "$MODULES/04-interview.md" "**Never re-offer what this conversation has already shown.**" "a shown option is not offered twice"
need "$MODULES/04-interview.md" "Do not always start from the same place." "the set must move between runs"
need "$MODULES/04-interview.md" "**These are the auto-mode picks — and only an auto trigger makes them decisions.**" "the picks are named as what auto mode fills in, and only an auto trigger authorizes them"
need "$MODULES/04-interview.md" "the suggestion-variety rule (section 3a)" "the interview's option sets point at the rule"
need "$MODULES/15-defaults.md" "**suggestion-variety rule (section 3a)**" "the defaults point at the rule"
need "$MODULES/15-defaults.md" "**these defaults are the auto-mode picks**" "the defaults say auto mode consumes them"
need "$MODULES/15-defaults.md" "An auto run must never reuse the previous run's picks" "an auto run does not repeat the last run's picks"
need "$MODULES/16-checklist.md" "**Every suggestion set offered this run came from the suggestion-variety rule (3a)**" "the final gate checks the picks came from a wide range"
need "$BUILD" "## 3a. The picks this pack proposes (suggestion variety)" "the picks rule survives the build"
# Retired: the collapsed delivery that gave the user summaries instead of prompts.
need_not "$MODULES/11-output-format.md" "Collapsed by default = summaries only" "the collapsed-by-default delivery is retired"
need_not "$MODULES/11-output-format.md" "### Interactive presentation (hide long prompts" "the hide-the-prompts heading is retired"
need_not "$MODULES/11-output-format.md" "only when the user opens it" "a prompt gated behind opening a clip is retired"
need_not "$MODULES/04-interview.md" "deliver all clip video prompts at once as collapsed summaries" "the interview no longer defaults to collapsed summaries"
need "$MODULES/04-interview.md" "**Without that trigger, nothing here is autonomous.**" "an offer is not a decision outside an auto trigger"
need "$MODULES/04-interview.md" "This rule changes *which options are offered*, never *who chooses*." "the rule's scope is options, never the choice"
need "$MODULES/04-interview.md" "Form 1 is presented, the user submits it, then Form 2 is presented" "both forms are always presented in order"
need "$MODULES/15-defaults.md" "**Outside that trigger nothing here is autonomous:**" "the defaults do not license autonomous picking"
need "$MODULES/15-defaults.md" "never that the pack picked for the user" "a blank field is a shown default, not a silent pick"
need "$MODULES/02-role.md" "Do not start generating a complete story package before the user has submitted Form 1" "the pre-existing no-early-package invariant is pinned"
need "$MODULES/16-checklist.md" "**No autonomous picking happened without the user's own auto trigger**" "the final gate checks nothing was picked for the user"
need "$BUILD" "**Without that trigger, nothing here is autonomous.**" "the no-autonomous-picking rule survives the build"
need_not "$MODULES/04-interview.md" "or leaves a field blank, what fills it is this pack's own proposal" "the blank-field licence is retired"
need_not "$MODULES/15-defaults.md" "as collapsed summaries (expandable on request)" "the defaults no longer collapse the prompts"
need_not "$MODULES/10-clip1-final.md" "present the remaining clips as collapsed summaries" "Clip 1 no longer hands over summaries"
need_not "$BUILD" "collapsed summaries (expandable on request)" "the collapsed delivery is gone from the build"
echo

# ------------------------------------------------------- 42. two modes, story state, decks
# WHY: auto mode was ambiguous (a story type named without `auto` was read as an .auto
# authorization), auto chose free-form (so its output needed correcting), revisions could
# drift into settled details because the locks lived only in prose, and auto delivered
# Clip 1's image while leaving later images on demand. v2.39.0 fixes all four: the word
# `auto` is the only trigger; an auto run draws only from the user-vetted option decks;
# the Story State locks every field (identically in both modes) with a dependency map
# scoping what a revision may touch; and auto delivers prompts first, then every required
# reference image one per message as separate clean frames. Guards pin all of it, the
# pick-riddle-first form, and the Notion log's honesty rule.
echo "42. Two modes, the option decks, Story State locks, auto delivery"
need "$BUILD" "## 2c. Auto mode — the option decks and the locked auto run" "the auto section survives the build"
need "$BUILD" "## 4a. Story State — field locks, seals, and versions" "the Story State section survives the build"
need "$MODULES/03b-auto-presets.md" "Auto mode starts only when the user's message contains the word \`auto\` before the story type" "auto has one explicit trigger"
need "$MODULES/03b-auto-presets.md" "A story type named **without** the word \`auto\`" "a bare type name is routed to guided mode"
need "$MODULES/03b-auto-presets.md" "The presets are the only things an auto run may draw from" "auto cannot choose outside the decks"
need "$MODULES/03b-auto-presets.md" "**Every list in this section is user-vetted and editable in place**" "the decks are the user's, editable in place"
need "$MODULES/03b-auto-presets.md" "Take the starting point from something outside the conversation" "the draw is seeded externally"
need "$MODULES/03b-auto-presets.md" "Never draw the same preset, or the same deck entry, the previous run in this conversation used" "an auto run does not repeat its draws"
need "$MODULES/03b-auto-presets.md" "One conversation holds one story." "one story per conversation is stated"
need "$MODULES/03b-auto-presets.md" "ask for it in one short line and stop that path until it arrives" "a missing attachment stops the path"
need "$MODULES/03b-auto-presets.md" "Never invent the missing material" "a missing attachment is never invented"
need "$MODULES/03b-auto-presets.md" "The first message generates zero images" "auto delivery is its own subsection"
need "$MODULES/11-output-format.md" "the entire text package is printed before any image is generated" "prompts are never withheld for an image"
need "$MODULES/03b-auto-presets.md" "**The first message generates zero images**" "auto first message text-only"
need "$MODULES/03b-auto-presets.md" "never a collage" "auto images are never a collage"
need "$MODULES/03b-auto-presets.md" "### The pick-riddle-first modifier" "the pick-first modifier is its own subsection"
need "$MODULES/03b-auto-presets.md" "that does not lock a riddle by itself" "the modifier defers the lock"
need "$MODULES/03b-auto-presets.md" "drawn from **ten different answer families**" "the ten candidates come from ten families"
need "$MODULES/03b-auto-presets.md" "a free-text field for pasting a riddle of their own" "the custom riddle box exists"
need "$MODULES/03b-auto-presets.md" "locked **exactly as written**" "a pasted riddle locks verbatim"
need "$MODULES/03b-auto-presets.md" "### The Notion riddle log (when connected)" "the Notion protocol is its own subsection"
need "$MODULES/03b-auto-presets.md" "**Answer Family**" "the log carries answer families"
need "$MODULES/03b-auto-presets.md" "Never claim a check or a write that did not happen" "Notion honesty is pinned"
need "$MODULES/01-commands.md" "a story type named without it is a guided-mode request, never an auto run" "the commands module carries the boundary"
need "$MODULES/01-commands.md" "it draws at random from the user-vetted presets and allowed lists, never free-form" "the commands module scopes auto's choices to the decks"
need "$MODULES/01-commands.md" "renders the riddle-selection form instead" "the commands module names the pick-first path"
need "$MODULES/01-commands.md" "**One conversation holds one story.**" "the commands module carries the one-story rule"
need "$MODULES/01-commands.md" "never silently restarts the pack or resets the Story State" "a second story never resets state"
need "$MODULES/01-commands.md" "It never applies the auto option decks (section 2c)" ".go never silently applies auto presets"
need "$MODULES/01-commands.md" "The locks \`.revise\` works against are the Story State field locks (section 4a)" ".revise is tied to the Story State locks"
need "$MODULES/02-role.md" "always with the word \`auto\` before the type" "the role module carries the trigger boundary"
need "$MODULES/03-riddle-prephase.md" "### Auto runs draw from the option decks, not free selection" "the diversity engine hands auto runs to the deck"
need "$MODULES/03-riddle-prephase.md" "Guided runs — every run that did not start with the word \`auto\` — keep the full free selection" "guided keeps the free nine-axis selection"
need "$MODULES/03-riddle-prephase.md" "that run does **not** lock a riddle by itself and renders the riddle-selection form instead" "Step 0a honours the pick-first modifier"
need "$MODULES/05a-story-state.md" "Every field is **locked the moment it is chosen**" "locks apply at pick time"
need "$MODULES/05a-story-state.md" "locked **identically hard**" "auto and guided picks are equally protected"
need "$MODULES/05a-story-state.md" "**a lock prevents an unrelated edit from changing that field.**" "the lock's one job is stated"
need "$MODULES/05a-story-state.md" "an **explicit user revision** — \`.revise <field> <value>\`" "nothing but an explicit revision opens a field"
need "$MODULES/05a-story-state.md" "only along these edges" "the dependency map scopes a revision"
need "$MODULES/05a-story-state.md" "Anything not reachable through those edges stays exactly as it is." "isolation is absolute outside the map"
need "$MODULES/05a-story-state.md" "a **re-check of Clip N+1's opening state**" "a clip change checks the next clip's opening state"
need "$MODULES/05a-story-state.md" "**bumps the version by one**" "edits create a new version"
need "$MODULES/05a-story-state.md" "marks **only the dependent images and prompts** for regeneration" "regeneration is scoped to dependents"
need "$MODULES/05a-story-state.md" "changing Clip 2's camera** must preserve the locked riddle and character" "the worked example is pinned"
need "$MODULES/05a-story-state.md" "flag it in one line and ask which to apply" "a breaking revision is asked about, never resolved silently"
need "$MODULES/05a-story-state.md" "### Status block — 2 lines, every response" "the status block is defined"
need "$MODULES/05a-story-state.md" "Every response opens with a 2-line status block" "always-on is stated"
need "$MODULES/05a-story-state.md" "Never print the sealed answer, the riddle text, or the fingerprint here" "the status leaks nothing"
need "$MODULES/03-riddle-prephase.md" "the 2-line status block (§4a) still opens that message" "lock-to-Form2 keeps the status"
need "$MODULES/11-output-format.md" "Every response opens with the 2-line status block" "delivery carries the status"
need "$MODULES/16-checklist.md" "Every response opened with the 2-line status block" "the final gate checks the status"
need "$MODULES/11-output-format.md" "### Auto-run delivery (prompts first, then every reference image)" "the delivery module carries the auto order"
need "$MODULES/11-output-format.md" "the exception does not apply: zero images in the first message" "the on-demand default names its auto exception"
need "$MODULES/15-defaults.md" "its picks are drawn randomly from the option decks (section 2c)" "the defaults route auto's picks to the decks"
need "$MODULES/15-defaults.md" "the first message generates zero images" "the defaults carry the auto image sequencing"
need "$MODULES/16-checklist.md" "drawn at random from the option decks (section 2c)" "the final gate checks the deck source"
need "$MODULES/16-checklist.md" "the text package was delivered first" "the final gate checks the delivery order"
need "$MODULES/16-checklist.md" "one image per message, each a separate clean frame of one composed scene" "the final gate checks the image sequencing"
need "$MODULES/16-checklist.md" "asked for in one line, never invented" "the final gate checks the missing-attachment path"
need "$MODULES/16-checklist.md" "the riddle was **not** locked silently" "the final gate checks the pick-first deferral"
need "$MODULES/16-checklist.md" "not logged" "the final gate checks the Notion honesty rule"
need "$MODULES/16-checklist.md" "pointed to a fresh chat in one line" "the final gate checks the one-story rule"
need "$MODULES/16-checklist.md" "respected the Story State locks (section 4a)" "the final gate checks the locks"
echo

# ------------------------------------------------------- 43. code-backed randomness
# WHY: the wide-draw rules ask a language model for variety, and a language model
# cannot roll dice — left to itself it returns to the head of its habits, which is the
# convergence defect sections 2a/2b/3a exist to stop. When ChatGPT's Python tool is
# available, the draw for every generated riddle's ingredients (category, subcategory,
# characteristics, difficulty) — and for auto's deck entries — must actually run as
# code (secrets.SystemRandom), never be simulated with model-picked numbers; a drawn
# category may not be swapped for an easier one; the fallback must be stated plainly
# when code execution is unavailable; and the honest limit is pinned: the answers are
# randomness-guided, not uniformly random across all possible objects.
echo "43. Code-backed randomness (the riddle ingredient draw)"
need "$MODULES/03-riddle-prephase.md" "### Code-backed randomness (when Python is available)" "the code-backed draw is its own subsection"
need "$MODULES/03-riddle-prephase.md" "# Riddle ingredient draw — run this before writing any riddle." "the pack carries the exact ready-to-run snippet"
need "$MODULES/03-riddle-prephase.md" "Edit the lists here to change what the draw can pick; never edit the run" "the lists are the user's to edit, in the snippet itself"
need "$MODULES/03-riddle-prephase.md" "no two candidates share a category+subcategory combination" "the snippet enforces one draw per candidate"
# The snippet is executable content, not just wording: run it. A shipped snippet
# that no longer executes (or was edited into a non-running shape) fails the build.
if command -v python3 >/dev/null 2>&1; then
  if python3 specs/evidence/run-ingredient-draw.py >/dev/null 2>&1; then
    pass "the shipped draw snippet executes as written (10 unique draws)"
  else
    fail "the shipped draw snippet FAILS to run — python3 specs/evidence/run-ingredient-draw.py"
  fi
else
  printf '  skip  python3 not found — the draw snippet was NOT executed\n'
fi
need "$MODULES/03-riddle-prephase.md" "**Before writing any riddle, execute Python**" "Python must actually be executed"
need "$MODULES/03-riddle-prephase.md" "secrets.SystemRandom()" "the draw uses a CSPRNG, not model numbers"
need "$MODULES/03-riddle-prephase.md" "do not simulate randomness with model-picked numbers" "simulated randomness is banned outright"
need "$MODULES/03-riddle-prephase.md" "Do not change the drawn category because another category is easier to write about" "a drawn category may not be swapped for an easier one"
need "$MODULES/03-riddle-prephase.md" "One draw per candidate, and all answers in a batch stay unique" "one draw per candidate, unique answers"
need "$MODULES/03-riddle-prephase.md" "**randomness-guided, not uniformly random across all possible objects**" "the honest limit is stated in the pack"
need "$MODULES/03-riddle-prephase.md" "state in one line that the draw was not code-backed" "the fallback is stated, not hidden"
need "$MODULES/03-riddle-prephase.md" "**Never claim a Python draw that did not run.**" "no claimed draw that did not run"
need "$MODULES/03-riddle-prephase.md" "the answer draw is code-backed (section 2b): run the Python draw for every candidate" "Step 0a runs the draw before writing"
need "$MODULES/03b-auto-presets.md" "these draws are **code-backed too**" "auto's deck draws ride the same code-backed draw"
need "$MODULES/16-checklist.md" "the answer draw ran as Python" "the final gate checks the code-backed draw"
need "$MODULES/16-checklist.md" "never simulated with model-picked numbers" "the final gate bars simulated randomness"
need "$MODULES/16-checklist.md" "the draw was **not code-backed**" "the final gate checks the fallback honesty"
need "$BUILD" "### Code-backed randomness (when Python is available)" "the code-backed draw survives the build"
need "$BUILD" "secrets.SystemRandom()" "the CSPRNG survives the build"
echo

# ------------------------------------------------------- 45. riddle shapes and the shape draw
# WHY: the clean-project auto run planned four clips — a dedicated empty 8s wait
# block between the riddle and the failed attempt — and the user reported the drag
# ("4 clips is too long") and a consequence that was not visually clear. v2.42.0
# retires the dedicated empty wait clip: a short-riddle story runs on the 3-clip
# shape (riddle / silent beat + failed attempt / consequence) or the 2-clip shape
# (riddle / silent beat + failed attempt + consequence, each separately readable
# even when they share the final clip). An auto riddle run DRAWS the shape by
# executed code (CLIP_COUNTS = [2, 3], the same code-backed machinery as the
# ingredient draw) instead of assuming the longer one; and the consequence must
# read on screen — the Teller's one act, what it does to the victims, their
# visible reaction — with no explanation and no ambiguity. The module 06
# corrections (8s-only planning, Lite the only extender) and the live-run prompt
# practices (camera first, quotes, named ambience/effects, plain-list negatives)
# ride the same live-verified pass.
echo "45. Riddle shapes: the drawn 2-or-3 counts, no empty wait clip, a consequence that reads"
need "$MODULES/03-riddle-prephase.md" "**The consequence must read on screen.**" "the consequence clarity contract is stated"
need "$MODULES/03-riddle-prephase.md" "what it does to the victims, and **their visible reaction**" "the consequence names its three visible parts"
need "$MODULES/03-riddle-prephase.md" "no explanation, no ambiguity" "the consequence is shown, not explained"
need "$MODULES/03-riddle-prephase.md" "**The two shapes — 2 clips or 3.**" "the two shapes are defined"
need "$MODULES/03-riddle-prephase.md" "**3-clip shape:**" "the 3-clip shape is named"
need "$MODULES/03-riddle-prephase.md" "**2-clip shape:**" "the 2-clip shape is named"
need "$MODULES/03-riddle-prephase.md" "no dedicated empty wait clip" "the dedicated empty wait clip is retired by name"
need "$MODULES/03-riddle-prephase.md" "The consequence is the final beat" "the consequence holds the final beat"
need "$MODULES/03b-auto-presets.md" "**The deck draw (auto riddle).**" "the auto deck draw is its own rule"
need "$MODULES/03b-auto-presets.md" "CLIP_COUNTS = [2, 3]" "the count list is shipped in the snippet"
need "$MODULES/03b-auto-presets.md" "never assumes the longer one" "auto never assumes 3 clips"
need "$MODULES/03b-auto-presets.md" "turn the draw into a 2-3-2-3 metronome" "the no-repeat exemption is reasoned"
need "$MODULES/03b-auto-presets.md" "say in one line that the shape draw was" "the fallback honesty names the shape draw"
# The snippet is executable content, not just wording: run it. A shipped snippet
# that no longer executes, stopped drafting from {2, 3}, or became a constant
# fails the build.
if command -v python3 >/dev/null 2>&1; then
  if python3 specs/evidence/run-shape-draw.py >/dev/null 2>&1; then
    pass "the shipped shape-draw snippet executes and draws only 2 or 3 (both occur)"
  else
    fail "the shipped shape-draw snippet FAILS to run or draws outside {2, 3} — python3 specs/evidence/run-shape-draw.py"
  fi
else
  printf '  skip  python3 not found — the shape-draw snippet was NOT executed\n'
fi
need "$MODULES/05-story-planning.md" "sharing the final clip never merges them" "wait and consequence stay separate even sharing the final clip"
need "$MODULES/05-story-planning.md" "a dedicated empty wait block is never planned" "planning retires the empty wait block"
need "$MODULES/05-story-planning.md" "offer one more clip or a longer-duration model" "the shortfall offer counts from the shape"
need "$MODULES/06-model-rules.md" "Verified live against the user's own Flow UI" "the live UI verification is recorded"
need "$MODULES/06-model-rules.md" "8-second clips only on the user's plan" "Lite is 8s-only on this account"
need "$MODULES/06-model-rules.md" "the only model that performs the Extend" "Lite is named the only extender"
need "$MODULES/08-video-prompt.md" "Open a shot's description with the **camera**" "prompts open camera-first"
need "$MODULES/08-video-prompt.md" "Keep every spoken line **in quotation marks**" "spoken lines stay quoted"
need "$MODULES/08-video-prompt.md" "ambient sound and the specific effects" "ambience and effects are named explicitly"
need "$MODULES/08-video-prompt.md" "negative constraints as a **plain list**" "negatives are written as a plain list"
need "$MODULES/15-defaults.md" "their visible reaction" "the defaults mirror the visibility contract"
need "$MODULES/15-defaults.md" "**drawn** — 2 or 3" "the defaults say the count is drawn"
need "$MODULES/15-defaults.md" "including its **shape draw (2 clips or 3, never assumed)**" "the defaults carry the shape draw"
need "$MODULES/16-checklist.md" "no dedicated empty wait clip" "the final gate checks the shapes"
need "$MODULES/16-checklist.md" "reads on screen" "the final gate checks the consequence reads"
need "$MODULES/16-checklist.md" "drawn by the executed snippet" "the final gate checks the drawn shape"
need "$BUILD" "**The deck draw (auto riddle).**" "the deck draw survives the build"
need "$BUILD" "CLIP_COUNTS = [2, 3]" "the count list survives the build"
need "$BUILD" "**The consequence must read on screen.**" "the clarity contract survives the build"
need_not "$MODULES/03-riddle-prephase.md" "a following clip holds the silent think-beat" "the dedicated-wait example is retired"
need_not "$MODULES/05-story-planning.md" "a full block with no new dialogue, no attempt, and no fail" "the dedicated-wait license is retired"
need_not "$MODULES/05-story-planning.md" "do not compress them into one" "the compression ban is retired in favour of separate readability"
need_not "$MODULES/16-checklist.md" "was never compressed into the consequence" "the retired compression wording is gone from the gate"
echo

# ------------------------------------------------------- 46. effect capabilities (stress-tested)
# WHY: the user's five live stress tests plus an orientation sub-test say what Veo
# 3.1 Lite actually renders (the log lives in docs/veo-stress-tests.md): weather,
# lightning, wind, drifting debris, breakage, reveals, and simple reactions are
# reliable; earthquake ground motion, requested camera shake (entirely absent),
# multi-step choreography, and mid-clip orientation flips are not. v2.43.0 wires
# the map into the pack — the capability block (module 5), the auto deck guard
# (2c), the guided free-selection filter (2a), the camera limits (7a), and the
# final gate (15) — so both modes' options and every prompt stay inside what the
# model renders. The map is small-sample: keep the "proven so far" stance too.
echo "46. Effect capabilities: the stress-test map, the deck guard, and the camera limits"
need "$MODULES/06-model-rules.md" "### Proven effect capabilities on Veo 3.1 Lite" "the capability map is its own subsection"
need "$MODULES/06-model-rules.md" "docs/veo-stress-tests.md" "the capability map names its evidence log"
need "$MODULES/06-model-rules.md" "proven so far" "the small-sample stance is stated"
need "$MODULES/06-model-rules.md" "requested camera shake — entirely absent, not weak" "shake is recorded as absent, not weak"
need "$MODULES/06-model-rules.md" "**Spectacle is safe; motion is not.**" "the headline planning rule is stated"
need "$MODULES/06-model-rules.md" "**The appearance of drama is not its physical simulation.**" "appearance vs simulation is stated"
need "$MODULES/03b-auto-presets.md" "stays inside the **proven effect capabilities (module 5)**" "the deck guard is stated"
need "$MODULES/03b-auto-presets.md" "no camera-shake requests, no earthquake ground motion" "the deck guard names the bans"
need "$MODULES/03-riddle-prephase.md" "**Free selection is still capability-bounded:**" "guided free selection is capability-bounded"
need "$MODULES/03-riddle-prephase.md" "the same map the deck guard enforces on auto runs" "guided and auto share one map"
need "$MODULES/08a-shot-composition.md" "### Camera limits (from the live stress tests)" "the camera limits are their own subsection"
need "$MODULES/08a-shot-composition.md" "Never write that the camera shakes." "the shake ask is banned by name"
need "$MODULES/08a-shot-composition.md" "One camera movement per shot." "one camera movement per shot"
need "$MODULES/08a-shot-composition.md" "Hold the orientation within a clip." "the orientation-hold rule is stated"
need "$MODULES/16-checklist.md" "No prompt asks for a camera shake or a ground-motion effect" "the final gate bans the shake/ground-motion ask"
need "$MODULES/16-checklist.md" "Character orientation is held inside every clip" "the final gate checks orientation-hold"
need "$MODULES/16-checklist.md" "Every effect and consequence stays inside the proven effect capabilities" "the final gate checks the capability map"
need "$BUILD" "### Proven effect capabilities on Veo 3.1 Lite" "the capability map survives the build"
need "$BUILD" "**Spectacle is safe; motion is not.**" "the headline rule survives the build"
need "$BUILD" "### Camera limits (from the live stress tests)" "the camera limits survive the build"
need "$BUILD" "**Free selection is still capability-bounded:**" "the guided filter survives the build"
need_not "$BUILD" "the camera shakes slightly" "no positive shake-request phrasing survives in the build"
need_not "$BUILD" "the ground shakes" "no ground-motion staging survives in the build"
echo

# ------------------------------------------------------- 47. the deck draw: people in the deck, the PREVIOUS paste, the printed draw
# WHY: three consecutive live auto-riddle runs converged into one film — the same
# stairwell, the same elderly-woman Teller, the same young-man victim — because the
# decks had NO people lists: victim, Teller, and size relation were free-invented,
# which is model prior, not randomness. Worse, two of the three runs only SAID
# "Python randomized" with no code or output — an unprinted draw is unverifiable.
# v2.45.0 puts people in the deck and makes no-repeat mechanical: the previous
# run's printed values are pasted into PREVIOUS and the code EXCLUDES them from
# the pool; the output's "excluding:" line makes the paste visible; the clip count
# stays exempt (two values would metronome 2-3-2-3).
echo "47. The deck draw: people lists, the PREVIOUS paste, and the printed output"
need "$MODULES/03b-auto-presets.md" "**The deck draw (auto riddle).**" "the deck draw is its own rule"
need "$MODULES/03b-auto-presets.md" "VICTIMS = [" "the deck ships victim forms"
need "$MODULES/03b-auto-presets.md" "TELLERS = [" "the deck ships Teller forms"
need "$MODULES/03b-auto-presets.md" "SIZES = [" "the deck ships size relations"
need "$MODULES/03b-auto-presets.md" "PREVIOUS = []" "the no-repeat paste slot is shipped"
need "$MODULES/03b-auto-presets.md" "def fresh(options):" "the exclusion is code, not diligence"
need "$MODULES/03b-auto-presets.md" 'print("excluding:", ' "the paste is visible in the printed output"
need "$MODULES/03b-auto-presets.md" "nothing (first draw in this conversation)" "the unpasted second run is a visible defect"
need "$MODULES/03b-auto-presets.md" "**How the no-repeat rule actually works.**" "the mechanism is explained where the snippet ships"
need "$MODULES/03b-auto-presets.md" "**victim forms** (" "the look lists include victim forms"
need "$MODULES/03b-auto-presets.md" "**Teller forms** (" "the look lists include Teller forms"
need "$MODULES/03-riddle-prephase.md" "the cast is drawn, never free-invented" "auto draws people, it does not invent them"
need "$MODULES/15-defaults.md" "and the people lists (victim, Teller, size relation)" "the defaults carry the people draw"
need "$MODULES/16-checklist.md" "the deck draw was printed" "the final gate requires the printed draw"
need "$MODULES/16-checklist.md" "excluding:" "the final gate checks the paste line"
need "$BUILD" "**The deck draw (auto riddle).**" "the deck draw survives the build"
need "$BUILD" "VICTIMS = [" "the victim list survives the build"
need "$BUILD" "PREVIOUS = []" "the paste slot survives the build"
need_not "$MODULES/03b-auto-presets.md" "**The shape draw (auto riddle).**" "the count-only snippet section is retired"
need "$MODULES/03b-auto-presets.md" "**The deck carries no photoreal style and no Teller with a real human face**" "the no-photoreal/no-real-face rule is stated"
need_not "$BUILD" "cinematic live-action night" "the photoreal live-action style stays out of the deck"
if command -v python3 >/dev/null 2>&1; then
  if python3 specs/evidence/run-shape-draw.py >/dev/null 2>&1; then
    pass "the shipped deck-draw snippet runs; both counts occur; PREVIOUS exclusions hold"
  else
    fail "the shipped deck-draw snippet FAILS — python3 specs/evidence/run-shape-draw.py"
  fi
else
  printf '  skip  python3 not found — the deck-draw snippet was NOT executed\n'
fi
echo

# ------------------------------------------------------- 48. the scoped reroll family
# WHY: the user's principle — explicit commands are crucial because LLMs are
# unpredictable. Only .reroll (riddles) and .reroll visual (all open axes) existed,
# so there was no way to redraw ONE aspect (character, art, setting…) without
# re-rolling everything or hand-revising. v2.46.0 adds the scoped .reroll <aspect>
# family, mechanically hooked to the deck draw: the current value goes into
# PREVIOUS, so the redraw cannot return it, and only the deliverables carrying the
# aspect are re-emitted (the 4a dependency map).
echo "48. The scoped reroll family: .reroll <aspect>, one aspect, the PREVIOUS hook"
need "$MODULES/01-commands.md" "\`.reroll <aspect>\`" "the scoped reroll family is a named command"
need "$MODULES/01-commands.md" "\`.reroll character\`" "character is a scoped reroll aspect"
need "$MODULES/01-commands.md" "\`.reroll art\`" "art is a scoped reroll aspect"
need "$MODULES/01-commands.md" "\`.reroll setting\`" "setting is a scoped reroll aspect"
need "$MODULES/01-commands.md" "\`.reroll riddle\` is the same command spelled out" "the riddle alias is explicit"
need "$MODULES/01-commands.md" "never guessed" "an unknown aspect word is asked, never guessed"
need "$MODULES/01-commands.md" "the code excludes what is locked now" "the reroll hook is the PREVIOUS exclusion"
need "$MODULES/05a-story-state.md" "the scoped \`.reroll <aspect>\` family" "Story State names the scoped rerolls"
need "$MODULES/16-checklist.md" "redrew **only the named aspect**" "the final gate scopes the reroll"
need "$BUILD" "\`.reroll <aspect>\`" "the scoped reroll family survives the build"
need "$BUILD" "the code excludes what is locked now" "the PREVIOUS hook survives the build"
echo

# ------------------------------------------------------- 49. Extend speaker attribution
# WHY: a live run proved the gap — Clip 3's Extend delta named the Teller's voice
# ("from the wall crack ... speaks one short line") yet Veo rendered the line on
# the visible victim's lips: nothing in the delta said the man stays silent. The
# Extend contract banned restated constants but never required naming the silent
# party when a delta carries speech. v2.47.2 adds the one-clause guard (speaker
# speaks TO someone; the other silent — no lip movement, no mouthing) to the
# contract (09), the Extend structure (08), and the final gate (16).
echo "49. Extend speaker attribution: speech-carrying deltas name speaker and silence"
need "$MODULES/09-clip-continuity.md" "Name the speaker and the silent party when the delta carries speech" "the Extend contract requires the speaker-silence clause"
need "$MODULES/09-clip-continuity.md" "no lip movement, no mouthing" "the clause bars lip movement and mouthing"
need "$MODULES/08-video-prompt.md" "name the speaker and the silent party in one clause" "the Extend structure mirrors the clause"
need "$MODULES/16-checklist.md" "it names the speaker and the silent party in one clause" "the final gate checks the clause"
need "$BUILD" "Name the speaker and the silent party when the delta carries speech" "the clause survives the build"
echo

# ------------------------------------------------------- 50. wider people decks and summoned-spectacle consequences
# WHY: the people pools were the variety ceiling — VICTIMS was 10/10 human and
# TELLERS 6/6 figure-ish, so a fair die still dealt humans and figures every run.
# v2.47.3 adds non-human victims (animals, animate objects), anchored non-figure
# Tellers (devices, time-with-a-clock), and consequence acts framed as the
# Teller's summoned spectacle (wind, rain, fog, lightning, breakage appearance,
# floor giving way, the Teller's own scream) — all inside the stress-test map,
# all still the Teller's act, scream never the victim's.
echo "50. Wider decks: non-human victims, anchored Tellers, summoned consequences"
need "$MODULES/03b-auto-presets.md" "a stray puppy" "the prose victim list holds animals"
need "$MODULES/03b-auto-presets.md" "a clay doll with stubby limbs" "the prose victim list holds animate objects"
need "$MODULES/03b-auto-presets.md" '"a stray puppy"' "the snippet victim list holds animals"
need "$MODULES/03b-auto-presets.md" '"a clay doll with stubby limbs"' "the snippet victim list holds animate objects"
need "$MODULES/03b-auto-presets.md" "time itself, announced by a cracked wall clock ticking backward" "the prose Teller list holds anchored time"
need "$MODULES/03b-auto-presets.md" "a self-tuning transistor radio" "the prose Teller list holds device Tellers"
need "$MODULES/03b-auto-presets.md" '"time itself, announced by a cracked wall clock ticking backward"' "the snippet Teller list holds anchored time"
need "$MODULES/03b-auto-presets.md" "calls a wind-burst that strips the room" "the prose consequence list holds summoned wind"
need "$MODULES/03b-auto-presets.md" "drops the floor from under them" "the prose consequence list holds the floor giving way"
need "$MODULES/03b-auto-presets.md" "screams its own scream and the lights go out" "the prose consequence list holds the Teller's scream"
need "$MODULES/03b-auto-presets.md" '"calls a wind-burst that strips the room"' "the snippet consequence list holds summoned wind"
need "$MODULES/03b-auto-presets.md" '"screams its own scream and the lights go out"' "the snippet consequence list holds the Teller's scream"
need "$BUILD" '"a stray puppy"' "the wider victim list survives the build"
need "$BUILD" '"calls a wind-burst that strips the room"' "the wider consequence list survives the build"
echo

# ------------------------------------------------------- 51. the status block on auto runs
# WHY: the always-on status block shipped in §4a, the delivery module, and the
# final gate — but neither auto-delivery section restated it, and the auto first
# message is the longest format in the pack. The model obeyed the loud format
# and dropped the quiet rule: a live auto run delivered the full package with
# zero status lines. Outvoted, not missing (lesson 16). v2.47.4 states the
# status-first opening at both auto-delivery sites.
echo "51. The status block opens the auto first message"
need "$MODULES/03b-auto-presets.md" "Open the first message with the 2-line status block" "auto delivery states the status-first opening"
need "$MODULES/11-output-format.md" "open with the 2-line status block (§4a) before the text package" "auto-run delivery states the status-first opening"
need "$BUILD" "Open the first message with the 2-line status block" "the auto status opening survives the build"
need "$BUILD" "open with the 2-line status block (§4a) before the text package" "the auto-run status opening survives the build"
echo

echo "----------------------------------------"
echo "checks: $CHECKED   failed: $FAILED"
[ "$FAILED" -eq 0 ] && echo "validate: PASS" || echo "validate: FAIL"
exit "$FAILED"
