<!--
WHY THIS SECTION EXISTS:
The pack's locks used to live only in prose spread across a long conversation, and a
revision could accidentally move a settled detail it never mentioned — the failure
".revise changed more than the one item" is the drift this section makes impossible.
It defines the structured Story State: every settled value as its own field, every
field locked the moment it is chosen (in auto mode and guided alike — the mode decides
who chose, never how hard it is protected), a dependency map that scopes what a
revision may touch, and a version/seal discipline so an approved package is frozen and
later edits create a new version that marks only the dependent images and prompts for
regeneration. Do not weaken a lock, and never let a revision reach a field the
dependency map does not connect it to.
-->
## 4a. Story State — field locks, seals, and versions

The pack maintains an **active Story State** for the conversation from the first lock onward. It is the single record every later turn reads before it touches anything, and it contains one field per settled value:

- the **riddle text** (exact wording) and its **sealed answer**, plus the production **language**;
- each **character identity** — the victims' and, separately, the Teller's design;
- the **art style** and the look constants (palette, lighting, grade);
- the **clip plan** — per clip: its route (Extend / independent-from-ingredient / Add clip), camera, action, audio, duration, and ending state;
- the **assets** — the ingredient image and any Add-clip keyframes, each named by what it feeds;
- the **revision number** and one line per version saying what changed.

### Locks — every field, both modes, the same hardness

Every field is **locked the moment it is chosen** — an auto deck draw and a guided form pick are locked **identically hard**. The mode decides *who chose the value*; it never decides how well the value is protected. A lock does exactly one thing: **a lock prevents an unrelated edit from changing that field.** Nothing in the conversation — a later idea, a restyled request, a helpful reread of the plan — moves a locked field. Only these open one:

- an **explicit user revision** — `.revise <field> <value>` or plain wording that names the field and the change (the commands module's revision rule);
- a **re-submitted form field** in guided mode, which is the user naming that field's new value;
- `.reroll` (riddles only) and `.reroll visual` (the visual axes the user has left open), which are themselves explicit commands.

### Isolation — a revision may only reach what the dependency map connects

A revision to one field propagates **only along these edges**, and to nothing else:

| The changed field | What it may touch |
|---|---|
| riddle text | the clips that speak it, the plan record, the one Script Overview line quoting it |
| a character identity | every image and clip prompt carrying that character |
| art style / look constants | the look lines of every image and clip prompt — never their content |
| Clip N's camera or action | Clip N only, plus a **re-check of Clip N+1's opening state** for continuity |
| an asset (ingredient or keyframe) | only the clips generated from it |

**Anything not reachable through those edges stays exactly as it is.** A revision never re-runs the interview, never re-plans, and never "improves" an unrelated field while it is in the neighbourhood — that drift is the failure this section exists to make impossible. The commands module's revision classes are enforced by these locks: this section is the mechanism, that module is the vocabulary.

### Seals and versions

When the user approves the story — proceeding past the Story Overview checkpoint in guided mode, or accepting the auto run's delivery — the current Story State is **sealed as version N**. A later explicit edit **bumps the version by one**, states the change in one line (`vN+1: Clip 2 camera changed`), and marks **only the dependent images and prompts** for regeneration, by the dependency map above. The sealed fields that were not touched carry forward byte-identical.

Worked example: **changing Clip 2's camera** must preserve the locked riddle and character, while checking Clip 3's opening state. The riddle text, the sealed answer, the character identities, the style, and every other clip's plan are untouched; only Clip 2's prompt is re-emitted, and Clip 3's opening state is verified against Clip 2's new ending state before anything else happens.

If a requested revision cannot be applied without breaking a field it does not name — a new riddle that no longer fits the locked plan, a camera that contradicts an earlier clip's ending state — flag it in one line and ask which to apply. Never resolve it silently.
