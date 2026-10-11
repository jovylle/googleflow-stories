# Spec — Riddle Outcome Contract + No-Silent-Clip-1 (v2.14.0)

Two follow-ups from the first live run of v2.13.0 (the two-form opening).

## 1. Riddle outcome contract (never answered + consequence)

**Requested:** "make note on the riddles, that it always fails to be answered and there's consequence always included on the video."

**Problem with the previous rule.** The fixed structure was an either/or, in three places:

> the riddle is spoken **first**, then the story continues with **either** a silent beat where the audience is meant to answer, **or** another character who reacts but never answers correctly
> — `03-riddle-prephase.md:20` (old), mirrored in `15-defaults.md:18` and `03:122`

Two defects:

1. An `or` lets the model ship a story where nobody visibly fails to solve the riddle — the failure is optional.
2. **Nothing required a consequence at all.** A riddle story could end with nothing lost, changed, or paid for.

**New rule.** Both halves are hard requirements:

- **The riddle is never answered correctly on screen.** No character lands it, no on-screen text gives it away, no solution is handed to the audience. The story shows the attempt *and* the failure: guesses wrong, gives up, cannot answer, or says something that is not the answer.
- **A visible consequence is always included.** Going unanswered costs something the audience can see — a loss, a change, a danger, a price paid, an opportunity gone. It lands in a later beat, through action and imagery rather than explaining dialogue.

**Answer-blindness preserved.** The consequence follows from the riddle's wording, mood, and situation *only*. It must not reveal, hint at, depict, or be reverse-engineerable into the answer — after it lands, a viewer must still not be able to deduce the answer from the video. This keeps it a story beat rather than a clue dressed as one.

**Clip-count conflict resolved (the 2-clip case).** The observed run used 2 clips with Clip 2 already the silent guessing beat, leaving the consequence nowhere to land. The rule now states: do not drop either silently — fold the consequence into the final moment of the guessing beat, or tell the user in one line that one more clip would let it land and let them decide. It must never be resolved by letting a character answer the riddle.

_The only override remains a user-requested reveal clip (already defined in the no-answer-reveal rule)._

## 2. No silent turn (the Clip 1 image stall)

**Observed:** after Form 2 was submitted, the chat sat on an empty reply, and only produced the blueprint and prompts once the user prompted it with "so? what now". The reference image had been generated — the work had happened, the user just saw nothing while it did.

**Diagnosis: turn ordering, not a missing stop condition.** Nothing in the artifact asked for a pause (`grep` for wait/pause/stop found no such instruction — the only "wait" was the storyboard-first exception and the word "pause" in a beat description). The post-form turn must write a full multi-clip blueprint, a copy-ready Clip 1 prompt, *and* render an image. Image rendering is slow, so on the observed run the text was not on screen while the user waited, and the turn looked dead.

**Fix (ordering + explicit failure path):**

- Write the blueprint and Clip 1's prompt text **first**; generate the image **as the last action of the turn** — never before the text, never in a turn with no visible text.
- Open the turn with one short line saying the reference image is being generated now and may take a moment.
- **Explicit failure path:** if generation is unavailable, fails, or the workflow is not ChatGPT-generated, say so in one short line immediately and still deliver the rest of the package. Never stall until the user asks for progress.

## Files changed

| File | What changed |
|---|---|
| `modules/03-riddle-prephase.md` | New "The riddle outcome (fixed for every riddle story)" section (never answered + consequence + clip-count conflict); the fixed-structure line and the reveal rule updated from either/or to **and**; the post-lock carry-over line updated. |
| `modules/15-defaults.md` | Riddle structure + new riddle-outcome default line. |
| `modules/16-checklist.md` | New final-checklist item verifying both halves. |
| `modules/05-story-planning.md` | Master-context block now carries the outcome contract. |
| `modules/10-clip1-final.md` | New "**Never go silent.**" block at the top of the Clip 1 phase. |
| `modules/14-style.md` | "Never leave a turn without visible text" style rule. |
| `validate.sh` | §13 (10 checks) + §14 (4 checks). |
| `specs/googleflow-stories_reverse_spec.md` | OBS-RIDDLE-014/015, OBS-CLIP1-005/006, AC-008/AC-009, re-cited 03 line numbers, v2.14.0 resolution section. |
| `version.txt` | 2.13.0 → 2.14.0. |

## Verification

- Guards written first: §13 and §14 failed **10/10** before the module edits.
- `./validate.sh` → **100/100 PASS** (was 87).
- Compile: 19 modules, 1,116 lines.
- Reverse-spec citations for `03-riddle-prephase.md` were re-derived from the edited file rather than adjusted by arithmetic, because the inserted sections shifted every later line number.

## Residual risk

The consequence rule is a *content* requirement, so it can only be judged by reading a generated story — the validator can prove the instruction is present, not that a given run obeyed it. Check a real run: does a character attempt the riddle and fail, and does something visibly cost the story because it went unanswered? If a run produces a consequence that reads as a clue, the leak check is the place to catch it.
