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
need "$MODULES/10-clip1-final.md" "**Exactly one image this turn.**" "only the Clip 1 image is generated in the post-form turn"
need_not "$MODULES/10-clip1-final.md" "i-crop o gumawa" "no crop-in-Flow workaround wording"
echo

echo "17. Story Overview checkpoint (before generating anything)"
need "$MODULES/05-story-planning.md" "before any clip prompt, any expanded blueprint, or any image" "the checkpoint precedes all generation"
need "$MODULES/05-story-planning.md" "It is not a form" "the checkpoint is distinguished from a form"
need "$MODULES/05-story-planning.md" "never label it as Form 3" "the checkpoint is not a third form"
need "$MODULES/05-story-planning.md" "state it in plain words" "the consequence is surfaced for review"
need "$MODULES/05-story-planning.md" "never present a second uninvited checkpoint" "no round-trip creep"
need "$MODULES/05-story-planning.md" "This is where a clip-count shortfall is raised" "the clip-count shortfall is raised at the checkpoint"
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
need "$MODULES/15-defaults.md" "small, cute, vulnerable" "victim characters are the riddle default"
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
# the auto-lock quality gate, the mukbang speech authorization, the checklist
# lock, and the anti-state-inference rule (bare attachments never trigger).
echo "25. The .auto skip path"
need "$BUILD" "the one skip command" "the count sentence names .auto as the one skip command"
need "$BUILD" "neither a form nor a checkpoint" ".auto is typed outside the form count"
need "$BUILD" "for that run only" "the .auto skip is scoped to one run"
need "$BUILD" "do not present the Story Overview checkpoint" "the checkpoint is explicitly barred on .auto runs"
need "$BUILD" "Bare attachments never trigger" "attachments alone never start an auto run"
need "$BUILD" "does not create a riddle or set a story type" ".go and .auto cannot be conflated"
need "$BUILD" "generate one candidate that passes the riddle rules" "auto-lock keeps the riddle quality gate"
need "$BUILD" "self-check before locking it" "auto-lock self-checks before locking"
need "$BUILD" "carries its own speech authorization" ".auto mukbang authorizes its voiceover"
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

echo "----------------------------------------"
echo "checks: $CHECKED   failed: $FAILED"
[ "$FAILED" -eq 0 ] && echo "validate: PASS" || echo "validate: FAIL"
exit "$FAILED"
