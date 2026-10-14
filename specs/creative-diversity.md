# Creative diversity — the riddle ensemble stops being one film

**Target:** `Google Flow Story Maker v2.35.0` (`build/google-flow-story-maker.md`)
**Priority:** High
**Scope:** riddle story generation, `.auto riddle`, `.reroll`, character selection, scene composition, image validation
**Status:** implemented in the working tree, uncommitted, `./validate.sh` → **386 / 0**

## The defect

Twelve sample horror-riddle productions came back as one film:

- victim: a small animal — mouse, rabbit, rat, or chick;
- Teller: much larger, supernatural, floating or robed;
- setting: a doorway, tunnel, corridor, bridge, or blocked passage;
- camera: behind the victim, facing the Teller;
- consequence: imprisonment, sealing, or magical blocking.

Random-character requests did not break the pattern.

## Why it happened — nothing mandated any of it

Every item above was **illustrated**, never required. The pack had no rule
producing this formula; it had examples the model read as rules:

| # | Cause | Where |
|---|---|---|
| 1 | Victims specified as "small, cute, vulnerable", with captivity emphasized | `03-riddle-prephase.md` riddle structure |
| 2 | AI character suggestions biased to small vulnerable creatures | `04-interview.md` Form 2 Character |
| 3 | Ready-to-use defaults repeated the same narrow two-entity template | `15-defaults.md` |
| 4 | `.auto riddle` / `.reroll` had no visual-diversity mechanism; `.reroll` changed riddles only | `01-commands.md` |
| 5 | Consequence examples repeated sealing / capturing / blocking | `03-riddle-prephase.md` |
| 6 | Camera *terminology* existed; nothing ever *selected* a viewpoint | `08a-shot-composition.md` |
| 7 | The checklist validated continuity, never novelty | `16-checklist.md` |

This is the mirror image of the class `docs/SUMMARY.md` already names. Earlier
versions were **permission problems** — the model inferred a shortcut from a
loose phrase. This one is a **default-versus-spec problem**: the examples were
read as the requirement, and the absence of a rule was not noticed.

## The fix, mapped to the required changes

### 1. Narrative invariants separated from visual defaults — `03-riddle-prephase.md` §2a

The fixed set is now exactly five items: the Teller poses the locked riddle; the
audience gets a silent beat to guess; a victim attempts and fails; the Teller
causes a visible consequence borne by the victims; the answer is never revealed,
hinted at, or depicted. Section 2a states in plain words that **none of the
fixed items implies any of the free ones**.

Retired by name, in the module that carried them:

- the victims bullet no longer says "small, cute, vulnerable"; the requirement is
  now "the ones the audience is made to fear for", with size, cuteness, species,
  and age explicitly free;
- the Teller bullet no longer lets a shape be assumed — **"Nothing fixes the
  Teller's shape"** — with the one hard constraint kept: whatever it is, it must
  still be able to *speak the riddle in Clip 1*, so a bodiless Teller needs a
  located source for its voice;
- **"Horror is not darkness, robes, giants, or stone corridors."**

### 2. Creative diversity engine — `03-riddle-prephase.md` §2a

Nine axes, each settled **before the blueprint**: victim archetype and form;
Teller archetype and physical form; size relation; the Teller's mechanism of
power; environment and architectural layout; trapping mechanism; camera
viewpoint and composition; art style; consequence.

Two clauses do the work the report asked for:

- **coherence** — the nine choices must reduce to *one situation*, not a collage
  (mechanism and trap are the same physics; the camera is composed for the chosen
  size relation; the consequence follows from the Teller's rule);
- **"the examples illustrate the kind of choice that works and are not a menu"** —
  the same non-exhaustive framing v2.31.0 used for riddle nouns, applied to the
  ensemble.

**Inverted size — a Teller visibly smaller than the victim — must be weighed every
run**, because a large Teller was the runaway default. Explicit user selections
win: `.reroll visual` re-selects only the open axes, and says so in one line when
every axis is locked.

### 3. Recent-design avoidance — `03-riddle-prephase.md` §2a

For random, `.reroll visual`, and `.auto riddle` runs: no repeat of the previous
run's victim archetype, Teller silhouette, or environment-and-camera combination,
and **a materially different composition rather than a recoloured one**. The
record checked against is a fingerprint ledger if the user keeps one, otherwise
the designs visible in the conversation.

The honesty clause is deliberate: **"Never invent a history you cannot see, and
never claim to have avoided a run you cannot read."** With no record available the
run says the ensemble was chosen fresh. Graceful degradation, no fabrication.

### 4. Variety made testable — the planning-only fingerprint

```
victim_type | teller_form | size_relation | setting | trap | camera | consequence | style
```

Written once before the blueprint, recorded in the blueprint's continuity notes,
compared with the recent record **before** writing — and scoped four ways: never
in the Script Overview, never in the Story Overview checkpoint, never in a clip
prompt or asset, and **never passed to the image model in whole or in part**.

### 5. Camera selection — `08a-shot-composition.md`

A new **camera viewpoint** axis with twelve viewpoints (front-facing, side-on,
overhead, low-angle, high-angle, eye-level, extreme wide, extreme close,
over-the-shoulder, POV, ground level, tracking/orbit), and the old house framing
named and demoted in one line:

> **Do not default to a rear-view figure facing a larger centred one.** That
> single composition is the most-repeated frame in this pack's output, and it is
> one option in the list above — not the house style.

The viewpoint must be **stated in the image prompt** so image and video agree. The
one-shot/one-image constraint is untouched.

### 6. Image-to-blueprint verification — `07-image-workflow.md`

The bug the report names: a run planned a turquoise salamander and a floating
wooden mask inside a hollow tree and shipped rabbit-and-mouse adventurers in
temple corridors with a robed apparition — the image tool silently rewrote the
plan. A new **image acceptance gate** checks, before any frame is presented:
subjects, species and physical design, relative scale, environment, viewpoint,
medium and palette, no unplanned props, no answer clue, no panels/labels/
production documentation.

Material failure → **regenerate** with a tighter scene-only prompt that names the
failed item. Persistent failure → **report it and let the user decide**:

> **Report a repeated failure; never quietly replan.** […] Do **not** edit the
> plan, the blueprint, the characters, the setting, or the story to match what
> the image returned. The plan is what the user approved; the image follows it,
> not the reverse.

That sentence is the actual fix. A gate with no report rule just licenses
accepting the wrong frame.

### 7. Reroll commands — `01-commands.md`

`.reroll` is now explicitly scoped: **"changes riddles only — it never changes
the look of the production."** New `.reroll visual` re-selects the ensemble axes,
re-emits the deliverables that carry them (blueprint + continuity notes, Clip 1
reference image, regenerated clip prompts), and leaves the locked riddle text, its
sealed answer, the language, and the clip count **exactly** as they are.
`.auto riddle` now runs the selection automatically, and the `.auto` default in
`15-defaults.md` says so.

### 8. Workflow contracts preserved

Unchanged and re-asserted by the validator: exact locked-riddle text and sealed
answer; no-answer-leak rules; Tagalog language preference; the horror audio
requirements and the supernatural Teller voice block; Veo clip-length budgeting;
Form 1 / Form 2; the Story Overview checkpoint; one clean reference image per
generation request; Extend versus Add Clip; continuity and character identity;
user-provided image priority.

### 9. Instruction duplication resolved

The narrow assumption lived in **four** places. All four were updated, and the
engine was written **once** in §2a; the others now point at it rather than
restating it:

| Place | Before | After |
|---|---|---|
| `03-riddle-prephase.md` structure | "small, cute, vulnerable" victims; passage-shaped traps | victims = who the audience fears for; traps need not be architectural; **§2a owns the ensemble** |
| `04-interview.md` Form 2 Character | pitches three small vulnerable creatures | three pitches differing in **archetype and form**, "not all small mammals or birds" |
| `15-defaults.md` riddle structure + Character + `.auto` | repeated the narrow template | defers to §2a, adds the archetype-variety requirement, runs the selection on `.auto` |
| `16-checklist.md` final gate | continuity only | three added items: the ensemble was chosen for this run; the fingerprint was written, compared, and never surfaced; the image acceptance gate was run |

No section contradicts §2a: the earlier three were rewritten to point at it, not
appended to.

## Conflicts resolved

1. **"Vulnerable" vs "varied victims."** Read as *small and soft* before; now defined
   as *what is at stake*, which is checkable and does not constrain form.
2. **"The trap must be visible and unescapable" vs "not every story is a passage."**
   The old trap bullet listed only passage shapes, so "pick whichever trap suits
   the setting" picked a passage every time. Non-architectural traps are now named
   in the same list, and the passage is demoted to one option.
3. **"The consequence is the Teller's act" vs the narrow act examples.** The
   examples stay (they are what makes "the Teller acts, the victims pay" concrete,
   v2.34.0) but are labelled "not the set to choose from", with sealing/claiming
   removed from default status.
4. **Camera terminology vs no camera policy.** Vocabulary without a selector was
   the gap; the viewpoint axis is the selector, and the house framing is named.
5. **The fingerprint vs the image-only constraint.** The fingerprint is exactly the
   kind of internal planning state the image-output-isolation rule bans, so §2a and
   the checklist both state it never reaches an image prompt. Without that clause
   the two rules would have contradicted each other.
6. **`.reroll` vs `.reroll visual`.** Scoped rather than overloaded: `.reroll`
   stays riddle-only so existing behavior is not broken.

## Verification

### Validator — `./validate.sh` → **386 / 0**, `validate: PASS`

New section **39** (49 guards — 43 `need` anchors and 6 stale-wording `need_not` traps, plus the wired-in dry run; all 51 lines report `ok`) pins: the §2a section and its invariants; the
retired victim wording; "Nothing fixes the Teller's shape"; the Teller must still
speak; the nine axes; the inverted-size clause; non-architectural traps; the
illustration-not-menu framing; the coherence test; recent-design non-reuse;
anti-recolouring; the fingerprint's scope and its ban on reaching the image model;
locked axes winning; no invented history; the `.auto` selection; all three other
modules pointing at §2a; `.reroll` scoping and `.reroll visual`; the viewpoint
axis and the demoted rear-view framing; the image acceptance gate and its report
rule; the Clip 1 gate; the three new checklist items; and four stale-wording traps.

Section **20** had a guard that *required* `"small, cute, vulnerable"` in the
defaults module — the validator was enforcing the defect. It now requires the
per-run deferral to §2a instead.

### Dry run — 12 productions, `13/13` criteria met

`specs/evidence/diversity-dry-run.tsv` holds twelve ensembles produced by working
§2a's axes by hand; `specs/evidence/score-diversity-dry-run.py` scores them
against the report's acceptance criteria. Both are wired into `validate.sh`, so a
sample that stops clearing the bars fails the build.

```
Creative-diversity dry run — acceptance criteria (section 2a)

  PASS  12+ productions in the sample                                            12 productions
  PASS  3+ distinct size relationships                                           5 distinct: bodiless, equal, inverted, larger, smaller
  PASS  not every victim is a small mammal or bird                               0/12 are small-mammal/bird (runs —)
  PASS  not every Teller is a giant cloaked humanoid                             0/12 are giant-cloaked-humanoid (runs —)
  PASS  settings avoid doors/gates/corridors/bridges (<= 2)                      0/12 passage settings (runs —)
  PASS  6+ distinct camera viewpoints                                            12 distinct: extreme close on hands | extreme wide | eye-level | front-facing | ground level | high-angle | low-angle from the step | over-the-shoulder | overhead top-down | point of view, the child's eyes | side-on profile | tracking orbit
  PASS  the rear-view figure facing a larger centred one is not the house style  0/12 rear-view framing (runs —)
  PASS  5+ meaningfully different consequences                                   12 distinct acts
  PASS  sealing/capturing is not the default consequence                         1/12 end in sealing (runs 9)
  PASS  no consecutive run repeats the recent design                             no repeats
  PASS  all victim archetypes distinct across the sample                         0 duplicate(s)
  PASS  all Teller forms distinct across the sample                              0 duplicate(s)
  PASS  all environment+camera pairs distinct across the sample                  0 duplicate(s)

summary: 13/13 criteria met
result: PASS — the axes produce a varied set and the set clears every stated bar
```

The sample, in one line each:

| # | Victim | Teller | Size | Setting / camera | Consequence |
|---|---|---|---|---|---|
| 1 | adult ward cleaner | the intercom, bodiless | n/a | hospital ward 03:00 / overhead | takes her name |
| 2 | adult photographer | the bride, ordinary | equal | empty reception hall / side-on | substitutes her into the photos |
| 3 | stone lion on a step | an older librarian | **smaller** | library reading room / low-angle | makes it forget what it guarded |
| 4 | a shoal of anchovies | the tide | larger | open water at night / extreme wide | moves them somewhere |
| 5 | a factory robot arm | an older welder | **smaller** | factory floor, work lights / ground level | marks them |
| 6 | a child | the family dog | equal | kitchen at 06:00 / POV (child's eyes) | makes her forget something needed |
| 7 | adult postman | a crowd speaking as one | equal | market street at noon / front-facing | takes what he carried |
| 8 | adult understudy | a mirror | equal | backstage dressing room / over-the-shoulder | substitutes one of them |
| 9 | a cave-diving team | a small brass bell | **inverted** | flooded basement / high-angle | seals their way out |
| 10 | two elderly siblings | a fog | larger | field at dusk / extreme close | claims one of them |
| 11 | adult gardener | a child's effigy in a scarecrow | equal | allotment, early morning / eye-level | leaves, takes the exit with it |
| 12 | a shift of bakers | the bakery oven | equal | bakery before dawn / tracking orbit | marks all of them |

The scorer found a real defect while it was being written: row 12 carried a
stray twelfth field, and `dict(zip(header, fields))` silently shifted every axis
after it, so a trap string was scored as a camera. The loader now fails loudly on
a field-count mismatch — evidence that a mechanical check on a hand-authored
sample needs its own guard.

### Not yet verified — the honest limit

**No live ChatGPT run was performed.** The dry run proves the rulebook's axes can
produce a varied set and that the set clears every stated bar; it cannot prove a
model will obey §2a. The behavioural test is a fresh ChatGPT run: three or four
`.auto riddle` productions in one chat, comparing victim forms, at least one
non-larger Teller, settings, and viewpoints; then `.reroll visual` to confirm the
riddle text survives untouched while the look changes. That is step 1 of
`docs/HANDOFF.md`'s next-steps list, and it is the only step that produces
behavioural evidence.

The repo has no behavioural test suite (see `specs/googleflow-stories_reverse_spec.md`
§4). Everything above is build-sync, wording, and dry-run evidence.

## Files changed

`version.txt` · `modules/01-commands.md` · `modules/03-riddle-prephase.md` ·
`modules/04-interview.md` · `modules/05-story-planning.md` ·
`modules/07-image-workflow.md` · `modules/08a-shot-composition.md` ·
`modules/10-clip1-final.md` · `modules/15-defaults.md` · `modules/16-checklist.md` ·
`validate.sh` · `build/google-flow-story-maker.md` (generated) ·
`docs/HANDOFF.md` · `docs/SUMMARY.md` · this spec ·
`specs/evidence/diversity-dry-run.tsv` · `specs/evidence/score-diversity-dry-run.py`
