# Google Flow Story Maker — Status Summary

*As of v2.15.0 · 2026-10-11 · branch `dev`*

## What it is

A **ChatGPT project** that turns ChatGPT into a creative producer and Google Flow
prompt engineer: a user goes from a rough idea (or a Filipino riddle) to a
continuity-aware, copy-ready Google Flow production package — story plan, clip
prompts, and a reference image.

The generator **is the project's Instructions**. There is no app, no server, no
API. That single fact drives everything below.

## How it works

```
modules/*.md   →   build.sh   →   build/google-flow-story-maker.md   →   paste into ChatGPT Instructions
                                        ↑
                                  validate.sh (112 checks, exit 0 before commit)
```

- **19 modules**, one concern each, concatenated in filename order. Authored
  source is `modules/`; the build output is generated and never hand-edited.
- **One compiled file, not many** — deliberately. ChatGPT's file retrieval is
  not reliable for routing between near-identical documents, so the whole
  instruction set ships as a single paste.
- **112 validator checks.** The validator tests the *compiled artifact*, not the
  modules: build sync, version stamping, module order, section numbering,
  cross-reference resolution, interview field shape, defaults parity, the
  two-form contract, and stale-wording traps (`need_not`). Guards are written
  **red first** — a new rule fails before the module edit that satisfies it.
- `master` = production (still v2.12.0). `dev` = current work (v2.15.0).

## The versions that matter

| Version | Change | The failure it fixed |
|---|---|---|
| v2.12.0 | Split Character and Art style; photo-as-identity; audit + validator born | Ambiguous "character sheet" conflating identity with image workflow |
| v2.13.0 | **Two-form opening** — Form 1 (setup) *produces* Form 2 (production) | ~8 turns of per-field questioning. `02-role.md` literally said "manageable, interactive steps" |
| v2.14.0 | **Riddle outcome contract** + no-silent-turn rule | The riddle ending was an *either/or*, so failing to answer was optional and a consequence was never required. Turn ordering let the chat sit on an empty reply while the image rendered |
| v2.15.0 | **`.start` always begins at Form 1** + image ratio discipline | In a thread already holding a locked riddle, `.start` skipped Form 1 entirely and showed 2 of Form 2's 4 fields. The image came back landscape for a 9:16 production |
| v2.16.0 | **Story Overview checkpoint** — the story is approved before anything is generated | The review gate existed but only under the non-default "Storyboard first" style; the default generated everything (including an image credit) in the same message as the overview |
| v2.17.0 | **Re-roll control stays visible** + riddles stop closing on "Ano ako?" | Removing the per-riddle confirmation card in v2.13.0 also removed the only place the reroll control rendered; "Ano ako?" made the reciting character claim to be the answer |
| v2.18.0 | **The answer showed through the scene.** Default riddle story is now a horror two-entity scene (Teller + trapped small victims), and everything the riddle names is banned from the visuals | The rule "the consequence must follow from the riddle's wording" *required* dramatizing the answer's own description — a cloud riddle got a dark sky and a washed-out bridge |
| v2.19.0 | **Script Overview is a markdown list** — one action step per line, instead of a prose paragraph | It was specified as "exactly one concise sentence", which is the worst shape for the one artifact the user actually reads and checks |
| v2.20.0 | **One image means one image.** A package turn generates exactly one image (Clip 1's), never a batch, sheet, or panel set — and never an image of the plan itself | Six places in the file said *more*: "1-3 images per clip" as a **planning target**, "identify the role of every image" with a role list, "for each scene", "up to two shots = two images", the plural in the method's name, and an image accordion of headers. A run returned ~8 multi-panel storyboards instead of one Clip 1 frame |
| v2.21.0 | **The supernatural Teller voice**, vendored from a prompt the user proved in Veo 3.1 Lite — plus the spoken-line slot it was missing and a duration budget that reflects the voice's slower pace | The audio side of a riddle story was one line in the prompt ("dialogue, ambience, sound effects, or silence as requested") and a six-adjective voice note. The proven prompt is 215 words of voice + audio production, with the negative-constraint tail doing the real work |

## The pattern worth naming

**Every bug so far is the same class: the instructions left the model room to
decide what was implied, and it decided wrong.**

- v2.13.0 — "manageable, interactive steps" *implied* many turns.
- v2.14.0 — an `or` *implied* that the consequence was optional; nothing *said*
  the turn had to stay visible while an image rendered.
- v2.15.0 — "an answer already in hand" *implied* prior conversation state
  counted as settled, so both forms were skipped.

None of these were content problems. They were **permission problems** — gaps
where the model could reasonably infer a shortcut. Every fix has been to close
the gap: replace `or` with `and`, name the order of operations, define the scope
of a phrase, and add a guard so the wording cannot drift back.

This is the single most transferable lesson for anything built on top of this.

## Honest limits

- **The validator proves the instruction is present, not that a run obeyed it.**
  Content rules — the riddle never being answered, a consequence actually
  landing, an image being the right ratio — can only be judged by reading a real
  run. Guard coverage is a floor, not a proof.
- **ChatGPT Go has no API.** Nothing can drive generation programmatically on
  this plan. Any tool around it either tracks state or bridges to a local model.
- Content correctness depends on the user's own review of a generated story.

## Related documents

- `specs/googleflow-stories_reverse_spec.md` — the full reverse spec: every
  observation, acceptance criterion, and line citation, with per-version
  resolution notes.
- Per-change specs: `two-form-flow.md`, `riddle-outcome-and-clip1-stall.md`,
  `session-state-and-clip1-image.md`, `interview-character-artstyle-split.md`,
  `validation-v2.12.0.md`.
- `docs/chatgpt-interactive-components-cheatsheet.md` — the native-control
  reference the two forms are built from.
