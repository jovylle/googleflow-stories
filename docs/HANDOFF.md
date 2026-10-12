# Handoff — the GoogleFlow Stories rule pack

Written at closeout so a fresh session can continue without reading a previous conversation.
**Read this file first.** Then `docs/SUMMARY.md` (the version history and the failure class the
versions share), and only the `specs/` file for whatever you are about to change.

## State at closeout (2026-10-11)

| Repo | Version | Branch / HEAD | Checks | Remote |
|---|---|---|---|---|
| `lab/googleflow-stories` (**canonical rules** — you are here) | **2.27.0** | `dev` / `7133c37` | `./validate.sh` → **258 / 0** | GitHub `jovylle/googleflow-stories`, `master` at `05d81ec` (v2.21.0 release merge), `dev` six ahead |
| `lab/flow-story-gpt` (distilled ChatGPT pack) | 1.0.0 | `master` / `5bb876c` | `./validate-gpt.sh` → 28 / 0 | **none — local only** |
| `lab/flow-story-gem` (Gemini + hand-over zip) | 1.0.0 | `master` / `6c3d417` | `./validate-gem.sh` → 36 / 0 | **none — local only** |

Canonical artifact: `build/google-flow-story-maker.md`, **1,236 lines / 150,448 chars**, working tree
clean. `master` is at `05d81ec` (v2.21.0, released 2026-10-12 by merging `dev`) and is **six versions behind `dev`**.

### Version chain since v2.12.0 (all on `dev`)

| Version | Commit | What it fixed |
|---|---|---|
| 2.13.0 | `9a855ca` | Two-form opening: Form 1 (setup) produces Form 2 (production); Character and Art style split into separate questions |
| 2.14.0 | `4b992b2` | Riddle outcome contract (never answered **and** a visible consequence) + no-silent Clip 1 turn |
| 2.15.0 | `b230ab6` | `.start` always begins at Form 1 (no state inference) + Clip 1 image aspect ratio checked |
| 2.16.0 | `ac44c39` | Story Overview checkpoint — approve the story before anything is generated |
| 2.17.0 | `2054896` | Re-roll control stays visible; riddles stop closing on "Ano ako?" |
| 2.18.0 | `bb543d3` | Answer was leaking through the scene → default riddle story is a horror two-entity scene; the riddle's nouns banned from every visual surface |
| 2.19.0 | `1fa995a` | Script Overview renders as a markdown list, not a paragraph |
| 2.20.0 | `7bfdfe2` | One image per request — no batches, sheets, or panels, and the plan is never rendered as an image |
| 2.21.0 | `4c96cfd` | The supernatural Teller voice (riddle horror), vendored from a prompt the user proved in Veo 3.1 Lite, + the heavy-voice duration budget |
| 2.22.0 | `6d766a1` | The `.auto` skip command (`.auto riddle` / `.auto mukbang` + free text): locks the story path, applies all defaults, skips both forms and the checkpoint for that run only; bare attachments never trigger it; `.reroll` re-locks one fresh candidate |
| 2.23.0 | `be16e61` | Neutral riddle generation: candidates are written as if no story exists yet, genre mood is spent on delivery only; the uncanny-answer list is trimmed to genre-agnostic ordinary things; the "good" horror example no longer ends first-person |
| 2.24.0 | `8eb1b1f` | Allocated timestamps: every blueprint carries a clip map (Clip N of M, nominal range, beat purpose), no consequence starts before the final clip, wait and consequence are never compressed into one block, and the shortfall offer covers all three beats |
| 2.25.0 | `76f246f` | Story-type words trigger `.auto`: `horror riddle` / `mukbang` (+ photo) starts the run with no `.start` or typed command; bare attachments, questions, negations, and mid-run mentions never trigger |
| 2.26.0 | `5b72ba5` | Tagalog indirect-description rule: clues turn on words used obliquely (`mukha`/`mata`/`kamay`, double meanings) — wordplay as misdirection, never spooky words, never rewriting a user riddle |
| 2.27.0 | `7133c37` | Overview text-only: no hero/grid/storyboard sheets ever, checkpoint turn imageless, Clip 1 the run's sole image; the old storyboard-first instructions that licensed the sheet are rewritten |

## What to do next, in order

1. **Re-paste the artifact.** The live ChatGPT project is still running **v2.12.0** — none of the fifteen
   versions of fixes above are in it. Paste `build/google-flow-story-maker.md` and just say `horror riddle`
   (no `.start` needed anymore) for a Tagalog end-to-end: neutral riddle list with oblique wordplay
   (`mukha`/`kamay`-style clues), text-only overview, timestamped clip map with the wait in its own clip.
   Then say `mukbang` with a photo.
   This is the only step that produces evidence.
2. **Calibrate the heavy-voice word budget.** v2.21.0 set it to **12–16 words per 8-second clip**
   from the voice's stated pace (~1.5–2 words/sec), not from a timing. Ask the user for the riddle's
   word count and whether it fit their 8s clip, then correct the figure in `03-riddle-prephase.md`
   (two places), `08-video-prompt.md`, and `16-checklist.md` **together** — a budget stated in
   several modules is obeyed from whichever copy is read last.
3. **Decide the three unactioned defects** (below). None are shipped; all were reported from live runs.
4. **Then** rebuild the distilled packs, or accept that they are stale (see open items).

## Unactioned defects (reported from live runs, awaiting a go-ahead)

1. **The consequence names the actor but not the victim.** `03-riddle-prephase.md` says the
   consequence is the Teller's own act; a Tagalog phrasing rendered as *the Teller* being punished.
   The missing sentence is **the victims pay, the Teller acts**.
2. **A victim option got cast as the Teller.** The Character field offers victims, but a run promoted
   the chosen victim to the Teller (an "imposing unsettling figure") and left the victims with no
   locked design. Proposed: **two explicit slots** — victims and a separately-designed Teller — that
   may never silently merge.
3. **A ceiling-length riddle gets squeezed.** A 24-word riddle at a normal pace is ~9.6 s before the
   mandated silence; the run chose "keep every beat" and squeezed delivery. v2.21.0's budget handles
   the heavy-voice case; the general case should still **offer** a third clip or a higher-fidelity
   model rather than silently squeeze.

## Open items (decide later, none blocking)

- **The distilled packs are nine versions behind** (`flow-story-gpt` 1.0.0, `flow-story-gem` 1.0.0, both
  built against canonical v2.12.0). Their checkers still pass because they check *their own* artifact;
  nothing tells you they are stale. Rebuilding is not a pure re-run: the GPT pack's instruction field
  is **7,681 of 8,000 chars — 319 chars of headroom**, and v2.21.0's voice block alone is **1,620
  chars** (its whole section, 4,163). The voice block has to live in a **knowledge file** (retrieved)
  or the pack needs a genuine re-distill — pasting it into the instruction field is impossible.
- **`dev` → `master` merge** is taken through v2.21.0 (`05d81ec`, 2026-10-12). Note for the next release: `master`'s old release commit was itself a merge whose side `dev` never had, so `--ff-only` fails — merge with `--no-ff` (it applied with zero conflicts this time), rebuild, revalidate, then commit and push.
- **Neither pack repo has a git remote.** They exist only on this disk.
- **Form 2 sometimes renders with no submit button.** Reported 2026-10-12: the fields show, the submit control doesn't (long form + collapsed Advanced suspected). Workaround is `.go` or a prose line with the picks. Fix queued: require a visible submit button plus the text fallback in `04-interview.md`, mirrored in the checklist with guards — buttons are progressive enhancement only, same rule as the image `imgN-M` buttons.
- **The website / parallel-storybuilding system** the user asked about earlier was deferred with
  "make this properly work first". Do not re-raise it unprompted. If it is ever built, hold it to one
  rule: it consumes the compiled artifact and `validate.sh` as its source of truth, and re-implements
  nothing — otherwise every future rule fix has to land twice.

## Commands

```bash
cd /Volumes/DevSSD/fore/lab/googleflow-stories
printf '2.22.0\n' > version.txt   # bump first; the build substitutes {{VERSION}}
./build.sh && ./validate.sh       # 258 checks today (plus docs/HANDOFF.md freshness)

# while working on one area, read only the new section's red:
./validate.sh 2>&1 | sed -n '/^23\./,$p'
```

Never hand-edit `build/` — edit `modules/*.md`, rebuild, revalidate. `validate.sh` reads the
**compiled artifact** for most checks and the modules for the per-section guards, so a stale build
shows up as failures rather than passing quietly.

## Key files

- `modules/03-riddle-prephase.md` — the riddle story's fixed horror structure, the Teller, the
  answer-blind rules, the spoken-duration budgets.
- `modules/04-interview.md` — the two forms; Form 2's four primary fields (Character is pitched as
  **victims**).
- `modules/08-video-prompt.md` — prompt construction, the master audio rule, and **the supernatural
  Teller voice block**.
- `modules/10-clip1-final.md` — the Clip 1 gate: exactly one image, one composed scene, ratio checked.
- `modules/16-checklist.md` — the self-check a run performs before delivering.
- `validate.sh` — one section per fix area, plus a handoff-freshness section; §20 riddle-structure, §21 Script Overview list, §22 image count, §23 voice block.
- `docs/SUMMARY.md` — one row per version, plus the failure class they share.
- `specs/googleflow-stories_reverse_spec.md` — the reverse spec: observations (`OBS-*`), acceptance
  criteria (`AC-*`), and a resolution-status block per version. `specs/image-count-one-per-request.md`
  and the other per-version specs carry the longer reasoning.

## What we learned (the transferable part)

The generalisable rules are written up in the `instruction-pack-delivery` skill — read it before
changing anything here. The short version, as it applies to this repo:

1. **A rule the artifact already states several times, violated anyway, was outvoted — not missing.**
   v2.20.0: the one-image rule appeared five or six times, including nearly verbatim; six *other*
   sentences said more ("1-3 images per clip" as a **planning target**, "identify the role of every
   image" with a role list, "for each scene", the plural inside a method's name, a per-clip image
   accordion of headers). The fix was to **delete** the strongest pull and trap it with a `need_not`
   — not to add a seventh statement of the rule. Same shape as v2.18.0, where a sentence *requiring*
   the consequence to follow from the riddle's wording was the leak.
2. **Banning an output does not remove the pathway that produces it.** v2.18.0's junk titles came
   back because the *lookup* was still permitted; v2.20.0 therefore banned web/image-library searches
   for style references outright rather than adding another "no citations" line.
3. **A prompt that describes a performance needs a slot for the content.** The user's proven 215-word
   voice prompt contains **zero words for the entity to say** — pasted alone it relies on the model
   inventing the Tagalog, which for a riddle story means an invented line and a possible answer leak.
   The vendored version adds the locked-riddle line plus "says nothing else", and keeps the negative
   tail verbatim, because *"not a normal human lowering their voice"* is doing the real work.
4. **A change that alters pacing invalidates every budget that assumed the old pacing.** A slow,
   pause-heavy delivery is not 2–3 words/second; shipping the voice without re-deriving the spoken
   budget would have reproduced the squeezed-delivery defect on every riddle.
5. **`validate.sh` proves a rule is present, not that a run obeys it.** Every version above was
   written guards-first (red before green) and every one of them is only *proven* by the next live
   run. Say that plainly when reporting — the honest limit is the point.
6. **The user's own words are the one thing the pack may not rewrite.** A user-written Script Overview
   is never reworded (it is split at their own boundaries); a user-supplied riddle is preserved
   verbatim, including a closing "Ano ako?" that generated riddles are banned from.
