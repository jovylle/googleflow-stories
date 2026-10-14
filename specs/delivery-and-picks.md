# Delivery and picks — the withheld prompts and the repeated options (v2.37.0)

**Status:** built, `./validate.sh` → **459 checks / 0 failed** · **uncommitted** on `dev` (HEAD `9d451b2`)
**Date:** 2026-10-14 · **Failure class:** an offer that hands over less than it names — a subset where the
range was asked for (a partial prompt list, and the same few picks out of a wide field)
**Supersedes the delivery description in** `googleflow-stories_reverse_spec.md` (the "collapsed summaries"
paragraph), which recorded the previous mechanism.

---

## 1. What was reported

> "I notice when its done processing the 2nd form or overview it seems not giving all the clips prompts it
> should make it available to copy already and as well as the image engridient that I can decide to either
> extend 2nd clip onwards or just generate individual clips use same image ingredient."

> "we fix default picks, and note the default picks will be useful when doing the auto mode"

Asked which "default picks" meant, the answer named the **script, art style, and character** sets:

> "AI must generated truly random and not pick what I think already displayed or trully random from a wide
> range of option."

Asked what the delivery should hand over for Clip 2+, the answer was the whole package rather than either
route alone: **"all clips text prompt and the image engridient."**

---

## 2. The defect

### 2a. The delivery was named after handing over the prompts, and did not hand them over

The delivery style's own label was *"All clips at once (default — **prompts now**, images on demand)"*, and
`modules/11-output-format.md` then defined its default presentation as the opposite:

> "**Collapsed by default = summaries only (the hidden state).** By default, do **not** print the full prompt
> text of every clip."

> "Reveal one clip at a time so only what the user wants is expanded; keep others collapsed as summaries."

> "reprint only those clip prompts … reveal a clip's full copy-ready Google Flow video prompt in its own
> fenced code block only when the user opens it (for example reply `1` for Clip 1)."

So the approved-overview turn produced summary lines and image headers; the prompt text arrived only after
the user typed a number, one clip at a time. Since the prompts are the artifact the user copies into Flow,
the delivery turn — the turn that exists to hand them over — contained nothing to copy. Two mirrored sites
repeated the same mechanism (`modules/04-interview.md` delivery field, `modules/15-defaults.md` delivery
default, `modules/10-clip1-final.md`'s "continue after Clip 1").

### 2b. The image ingredient was never handed over as an ingredient

The Clip 1 image existed and was generated immediately, but the pack only ever described it as *the*
reference image. Nothing said it was **the ingredient every clip is built from**, and the delivery turn did
not print its copy-ready image prompt — so the user had an image with no stated role and no re-usable prompt
for it.

### 2c. The route the user actually wanted had no contract

`modules/09-clip-continuity.md` offered exactly two ways to produce Clip 2+:

| route | image input | keyframe |
|---|---|---|
| **Extend** | none (no image binding at all) | none |
| **Add clip** | up to 3 input images | **requires its own new keyframe** |

"Generate the individual clips from the same image" fell between them: it is not Extend (which takes no
image), and it is not Add clip as written (which demands a fresh keyframe per clip). A user who wants one
shared look across separately generated clips had no path and no vocabulary for it.

### 2d. Every option set the pack offered repeated, because a fixed set is read from its head

The story ideas (2 per run), the AI Character A/B/C concepts, and the art-style list are *proposed* by the
pack whenever the user leaves a field blank. Nothing rotated them: the art-style block was the same eight
rows in the same order, the story ideas came from the same two shapes, and the character pitch carried an
archetype rule that applied only to riddle victims (`§2a`). Result: the same two ideas, the same three
characters, and the same first art style, run after run.

This is **the answer-bank defect in miniature** — a source with no sampler is read from the top:

| | answer bank (v2.36.0) | offered sets (v2.37.0) |
|---|---|---|
| source | `data/riddle-answer-bank.json`, 1,000 entries | a wide field of story shapes / archetypes / looks |
| sampler | even spread, stride from a non-head start | draw across the range, never the head of a fixed set |
| repeat guard | one *family* per batch | never re-offer what this conversation showed |
| record | `ANSWERS-USED` | "do not always start from the same place" between runs |
| consumer | the riddle generator | the user's own blank-field picks **and auto mode** |

The auto-mode link is what the report called out: `.auto` fills its fields from the defaults list, so the
defaults *are* the auto-mode picks — a fixed set there means every auto run is the previous one retitled.
§14 said auto mode runs "the creative-diversity selection (2a)" for the riddle's *look* but said nothing
about the picks themselves.

---

## 3. The fix

### 3a. Delivery turn (module 11, `### Delivery turn`)

- **Every clip's complete prompt, in clip order, each in its own fenced code block**, under a short summary
  line (number, duration, model, aspect, input images, continuity note). A summary line is a header, never a
  substitute; no prompt is withheld behind a `1`/`2` reply.
- **The image ingredient, in the same turn**: the Clip 1 image plus its **complete copy-ready image prompt**
  in its own fenced block, with one line saying every clip is built from it — "the input image an independent
  clip uses, and the look an Extend clip continues".
- **Both continuation routes for every Clip 2+**, labelled and separate, with one line saying the user picks
  **one, never both**: the **Extend** delta (restates nothing, no image) and the **independent** prompt (full
  master context block, bound to the ingredient). The two are never merged — a merged block is wrong for both.
- **Images stay on demand** (one image per action, `imgN-M`; Clip 1's excepted). The numbered reply-commands
  now toggle *images only* — the prompts need no command.
- **A compact view is opt-in, never the default** ("just the summaries" on request).

### 3b. The third continuation route (module 09)

New **"Independent, from the run's existing image ingredient"**: a standalone clip generated from the image
the run already holds. Full standalone prompt, binds to that image the way Clip 1 binds to its own — and
**no new keyframe is made**, because the ingredient already exists. Add clip's own-keyframe path remains for a
new location, angle, setup, a different model, or a non-8-second duration. The image-needs summary gains the
matching row: *"Independent clip using the run's ingredient → no new image."*

### 3c. Suggestion variety — new §3a (module 04)

One rule, every site pointing at it (the §2a/§2b pattern): the sets this pack proposes — story ideas, AI
Option A/B/C, AI Character A/B/C, the art-style set, the generated Script Overview — are **proposals for this
run, never the pack's standing menu**:

1. Draw from a wide range, **not from the head of a set** (a set offered in the same order every run is read
   from its top every run).
2. Vary the axis that matters — differ in **kind** (archetype, form, subject, medium, structure), not in
   costume, colour, adjective, or numbering.
3. **Never re-offer what this conversation has already shown** (picked or not).
4. Do not always start from the same place; a re-roll produces a different set, same field, same count.
5. Offer the range and hand the choice over (always "Other"; a locked pick is never re-rolled).
6. **These are the auto-mode picks** — an auto run must not reuse the previous run's picks.
7. Fields, count, order, and defaults are unchanged: no new questions, no extra round trips; nothing here
   touches a locked riddle, its answer source (2b/2c), or the ensemble (2a).

### 3d. Mirrors updated

| file | change |
|---|---|
| `modules/11-output-format.md` | delivery contract rewritten; the "Interactive presentation" heading became the delivery turn; retired "collapsed by default" |
| `modules/09-clip-continuity.md` | third route + image-needs row + "the plan records a recommendation, never withholds the other route" |
| `modules/10-clip1-final.md` | Clip 1's image named as the **run's image ingredient**; the continue-after-Clip-1 step prints all prompts and both routes |
| `modules/04-interview.md` | Advanced items 9 (continuation) and 10 (delivery); story ideas, script overview, character options and art-style set all point at **§3a** |
| `modules/15-defaults.md` | delivery default, continuation default, and the auto-mode bullet now say the defaults **are** the auto-mode picks; primary rows point at §3a |
| `modules/05-story-planning.md` | clip list records the recommended route and states both are printed; "independently generated clips" replaces "Add clips" |
| `modules/16-checklist.md` | five new final-gate items: prompts printed, both routes shipped, ingredient handed over, ingredient binding, picks from 3a |
| `validate.sh` | **§41** — 44 checks (33 presence, 11 retired-phrase traps) |
| `version.txt` | `2.36.0` → **`2.37.0`** |

---

## 4. Evidence

**What is verified here (offline):**

| # | criterion | result |
|---|---|---|
| 1 | `./build.sh && ./validate.sh` | ✅ **459 / 0** |
| 2 | §41 presence guards (delivery, ingredient, both routes, §3a) | ✅ 33 / 33 |
| 3 | retired collapsed-delivery wording is gone from every site **and** the artifact | ✅ 11 / 11 traps |
| 4 | the new §3a section survives the build, numbering stays monotonic (`3`, `3a`, `4`) | ✅ |
| 5 | `VALIDATE_PLUGIN` checks stay opt-in and untouched by this change | ✅ (`VALIDATE_PLUGIN=1` still fails 3 — plugin stale at 2.33.0, unchanged by this version) |
| 6 | rulings this change must not relax — one image per action, image acceptance gate, overview checkpoint, fingerprint secrecy, Extend's no-binding carve-out | ✅ all §16/§22/§17/§39/§36 guards still green |

**What is NOT verified — and cannot be, offline:**

- **No live run.** The guards prove the delivery contract is *present and unambiguous* in the compiled
  artifact; they cannot show the model prints every prompt. That is one live transcript away.
- **No dry run is possible for the picks.** The answer bank could be scored because it is a finite JSON file
  and a sampler can be run over it mechanically. The offered sets come from the model, so there is nothing to
  run: §3a can only be written clearly, guarded for presence, and checked in a live run. Saying otherwise
  would be inventing evidence.

---

## 5. Live-run rubric

| what to do | what must be true |
|---|---|
| approve the Story Overview | the next message contains **every** clip's prompt in full, each in its own fenced block — no "reply 1 for Clip 1" |
| read the same message | the Clip 1 image is present **and** its image prompt is printed as a copyable block, named as the ingredient every clip is built from |
| read any Clip 2+ | **two** labelled blocks: the Extend delta (a short paragraph, no image, nothing restated) and the independent prompt (full master block, naming the Clip 1 image as its input) — plus one line saying to use one of them |
| count the clips | the number of prompts matches the requested clip count, and no clip is left for a later turn |
| new session, `horror riddle`, twice | the two story-idea pairs, the three character concepts, and the art-style sets differ between the runs; the first-listed art style is not identical both times |
| while one conversation is open | a re-roll ("different ideas") returns genuinely different options, not the same ones reordered |
| `.auto riddle` twice | the second run does not reuse the first run's character concept, art style, or story shape |
| say "just the summaries" | the compact view appears **because it was asked for** — and never otherwise |
