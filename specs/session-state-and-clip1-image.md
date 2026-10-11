# Spec — Session State (`.start` always Form 1) + Clip 1 Image Ratio (v2.15.0)

Both defects came from a single `.start` in the user's ChatGPT project on 2026-10-11.

## Symptom 1 — "the story option disappeared"

**Observed.** `.start` produced no Form 1 at all. Instead:

> Nagsisimula na tayo sa production... **Naka-lock na ang Tagalog bugtong at ang story topic na Ang Bulaklak na Walang Ugat.** ... kailangan lang nating punan ang **dalawang** visual detail... ang karakter at art style.

Then a "Visual Setup" with only **2** fields (Character, Art style) — 2 of Form 2's 4 primary fields — and a story topic the model had inferred. The user never saw the language / story-type / riddle-source form, i.e. **no "riddle or story or random" choice**.

**Cause: two instruction gaps, one of them introduced by v2.13.0.**

| Gap | Text | Effect |
|---|---|---|
| Mine (v2.13.0) | "never re-ask a question whose answer is **already in hand**" | Scope undefined. The model read "in hand" as "present somewhere in this conversation" → both forms looked settled. |
| Pre-existing | "Do not start generating... unless the user **has already supplied enough information** or explicitly says to skip" | An explicit escape hatch for skipping the interview. |

The thread already contained a locked riddle and a story topic from earlier turns, so the model judged the interview unnecessary, then presented only the fields it could not find. Every individual instruction was defensible; together they authorized a stateful shortcut nobody asked for. `.start` said "from the top", but nothing forbade inferring state, and the loophole was stronger.

**Fixes.**

- `.start` (and `gfs`) shall **always present Form 1 first**, even when the conversation already contains a locked riddle, a chosen story topic, or a completed run. Earlier turns are never a substitute for Form 1.
- **Scope defined:** "already in hand" = a value the user submitted in a form **during the current run — since the most recent `.start`**. Never an earlier turn, an attachment, an uploaded file, or the Instructions text.
- **Pre-filled is not the same as omitted.** A known value pre-fills its field; the field stays visible. Never a partial form asking only for what looks missing, never a skipped form.
- **Form 2 keeps all four primary fields visible** every time it is shown.
- **Skipping requires the user saying to skip** (`.go` or plain words). Enough information pre-fills; it never bypasses.

## Symptom 2 — "the clip 1 image is incomplete"

**Observed.** The generated reference image came back **landscape** for a vertical 9:16 production, and the run's remedy was:

> Dahil landscape ang generated image, i-crop o gumawa ng portrait keyframe sa Google Flow...

So the user was handed a crop workaround in place of a usable reference image. Related tell: captions appearing in the continuity and blueprint sections ("The Instagrammable Cuartel and the Historic Town of Oslob, Cebu!", "Young woman exploring historic castle in Denia", "Casually-Dressed Tourist Exploring Historic Site Carrying Backpack") look like generated-image captions, implying more than one image was produced when only Clip 1's is allowed.

**Fixes.**

- The prompt must state the ratio explicitly and require a composition that fills it ("vertical 9:16 portrait composition, tall framing"), usable without cropping.
- The returned orientation must be **checked**; if wrong, say so in one line and regenerate with the ratio stated more forcefully. **A wrong-ratio image is a failed attempt, not a delivery note** — "crop it in Flow" is not the remedy while regeneration is available. Only after repeated failure report it plainly.
- **Exactly one image this turn** — no images for the character/continuity section, the blueprint section, or anywhere else. Every other image waits for its `imgN-M` command.

## Files changed

| File | What changed |
|---|---|
| `modules/01-commands.md` | `.start` always presents Form 1; prior conversation state never substitutes. |
| `modules/02-role.md` | "Already in hand" scoped to the current run; pre-filled ≠ omitted; the skip-on-enough-information loophole removed. |
| `modules/04-interview.md` | Known story topic stays visible pre-filled, never dropped. |
| `modules/10-clip1-final.md` | Aspect-ratio block + one-image-this-turn block. |
| `validate.sh` | §15 (7 checks) + §16 (4 checks); interview-before-generation cross-reference re-pointed. |
| `specs/googleflow-stories_reverse_spec.md` | OBS-CMD-001 updated, OBS-INT-012/013, OBS-CLIP1-007/008, AC-010/011, v2.15.0 resolution. |
| `version.txt` | 2.14.0 → 2.15.0. |

## Verification

- Guards written first: §15/§16 failed **10/11** before the module edits.
- `./validate.sh` → **112/112 PASS** (was 101). 19 modules, 1,124 lines.
- The validator caught two of my own edit errors on the way: a duplicated sentence in `10-clip1-final.md`, and a named-rule cross-reference (`interview-before-generation contract`) whose defining sentence my rewrite had moved.

## What worked in the same run

Worth recording, because it is evidence the v2.14.0 change landed: the run **did** apply the new riddle-outcome contract — the plan states the riddle stays unanswered *and* adds a consequence ("magkakaroon pa rin ng malinaw na consequence ang hindi nito masagot"), with Clip 2 carrying both a wrong attempt ("maling pagtatangka") and a visible consequence (the gate closing). No silence was reported after the image this time.

## Residual risk

The state rule is only as strong as its scope definition. `.start` mid-production now always re-presents Form 1, which is correct for a fresh run but could feel repetitive to a user who wanted to continue. `.go` remains the sanctioned skip. If a future run still infers state, the next lever is to make Form 1 emit an explicit session marker (e.g. "Run started — Form 1 of 2") so drift is visible in the transcript.
