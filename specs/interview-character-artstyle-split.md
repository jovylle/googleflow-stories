# Change: split Character and Art style; photo-as-character-sheet; image workflow moves to Advanced (v2.12.0)

Branch: `dev` · version **2.12.0** · built on the speech-default fix (v2.11.9)

## Requested change

Three edits to the interactive interview (the `.start` flow), all from the user's live use of the form:

1. **Character and Art style are two separate questions.** They were one combined primary field ("B. Characters + Art Style"), which read as a single answer slot. They are now asked one after the other, each with its own options.
2. **The character question keeps a custom option** — it already had AI Character A / B / C and "Other"; the global "every selectable field offers an Other" rule now visibly applies to it as its own question.
3. **The character question gains "Use my uploaded photo(s) as the character sheet source."** Attached photos become the locked identity source for every image and video prompt.
4. **Image workflow becomes an Advanced field, defaulting to "Generate reference images with ChatGPT."** Previously it sat inside the primary "Image generation topic" field; the primary field now covers the image *subject/material* only.

## What actually changed

| Module | Change |
|---|---|
| `04-interview` | Primary set is now four fields: Story topic, **Character**, **Art style**, Image generation topic (subject/material). Old section B split into **B. Character** (free-text, AI A/B/C, "Other", photo-as-character-sheet, identity lock, voice-identity gate) and **C. Art style** (its own question + the named style list). Image generation topic renumbered **D** and reduced to subject/material. Image workflow added as Advanced item **11** (Other requirements renumbered 12). WHY-comments updated so the split and the Advanced placement are not re-merged. |
| `07-image-workflow` | Method **B** renamed to **"Generate reference images with ChatGPT (default)"** and marked as the default selected in Advanced. |
| `10-clip1-final` | Readiness check accepts supplied character-sheet photos as the locked identity source; Clip 1 wording now names the default workflow rather than quoting an old label. |
| `15-defaults` | "Characters + Art Style" default split into separate **Character** and **Art style** defaults; image workflow default moved from Primary to Advanced as **"Generate reference images with ChatGPT"**. |
| `16-checklist` | New gate: a supplied photo identity is what every prompt/image carries — not a redesigned face — and the chosen art style holds. |
| `version.txt` | 2.11.9 → 2.12.0 |

The optional "2 paired pitches" shortcut (character concept + matching art style) survives, but is explicitly **opt-in and never the default**, so it cannot re-couple the two questions.

## Verification

- `./build.sh` → version **2.12.0**, 19 modules, **1076 lines**; `build/google-flow-story-maker.md` in sync with the modules.
- No stale combined label remains: `grep -rn "Characters + Art Style" modules/ build/ README.md` → none.
- Compiled artifact contains `**B. Character**`, `**C. Art style**`, `**D. Image generation topic**`, the character-sheet option, and `Generate reference images with ChatGPT` in the Advanced item, the defaults module, the image-workflow module, and the Clip 1 phase.
- Advanced list numbering in `04-interview` reads 1–12 with image workflow at 11.
- No automated tests exist in this repo (reverse spec §4), so verification is build-sync + content review + the manual pass below.

## Manual test plan (ChatGPT, after pasting the new build)

1. Type `.start` and accept the defaults through the language and story-type questions.
2. Expect **two separate primary questions**: Character (with AI A/B/C, "Other", and "Use my uploaded photo(s) as the character sheet source") and, after it, Art style (named styles + "Other").
3. Attach a photo, pick the character-sheet option → the identity is locked from the photo and restated in the Clip 1 master context block; no new face is invented.
4. Open Advanced → **Image workflow** is present with **Generate reference images with ChatGPT** preselected; the primary "Image generation topic" field asks only for the subject/material.

## Still open

- The reverse spec (`specs/googleflow-stories_reverse_spec.md`) still records the pre-split observation **OBS-INT-001** ("Story topic, Characters + Art Style, and Image generation topic"), and its line citations now drift. Not refreshed here — the reverse spec is a dated snapshot of the build it audited.
