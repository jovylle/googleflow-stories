# Handoff — Veo video result correction

Written 2026-10-18 so a fresh session can correct renders without re-learning.
Pack: `googleflow-stories` v2.47.1 (`build/google-flow-story-maker-2.47.1.md`).
Read first: `docs/veo-stress-tests.md` §§6–7, `docs/HANDOFF.md` lessons 13–17,
`flow-min-helper/VEO-FLOW-NOTES.md`. Credit pool: 3×50 daily (don't burn it on retries).

## Defect → correction (only moves proven to render)

| What you see | Cause (proven) | Correct by |
|---|---|---|
| Kitchen old-woman + young-man frame | ChatGPT image concept carryover, 4/4 | Discard frame; generate from isolated-prompt button turn or Flow text-to-image; never retry inside package turn |
| Storyboard/panels/captions in image | Image tool infographic prior | Regen with trailer as opening sentence, once; then Flow fallback + do-not-use line |
| Character orientation flips mid-clip | Stochastic Veo fail (1/2) | Re-roll same prompt (not a rewrite); if repeats, make the turn its own dominant action or lock the camera off |
| Unrequested angle changes | Extra camera instructions invite drift | Cut to one movement term (`locked-off` or `one slow push-in`); delete secondary moves |
| No camera shake at all | Shake renders nothing, ever | Delete the shake ask; show impact effects in frame (dust, debris, stagger) |
| Ground won't crack / debris local only | Earthquake physics unreliable | Show destruction appearance (settled rubble, dust) not the force |
| Choreography falls apart | Multi-step actions unreliable | One dominant motion per clip + max one effect; split beats across clips |
| Wrong speaker speaks / victim says Teller line | Clip prompts lacked master block, verbatim voice, named ingredient binding, and picked no route | Reissue with Clip N of M header + master block, verbatim Teller block with design-matched timbre, named Clip 1 ingredient, Extend delta and standalone route as separate blocks, victim silent; regenerate once |
| Wrong answer vibe / answer shows through | Consequence built from riddle wording | Rebuild consequence from Teller's rule only (take/seal/claim/mark), never riddle nouns |

## Process per bad clip

1. Name the defect from the table — no new diagnosis for known classes.
2. Apply that row's correction only; never re-plan the story (Story State locks hold).
3. Regenerate once. Still bad → Flow fallback or Extend from a good clip, then stop.
4. Log the case (prompt + defect + fix + hit/miss) under `docs/veo-stress-tests.md` style entries.

## Logged cases

- 2026-10-18, "The Last Screening" (3 clips, wall-presence Teller): Veo swapped speakers (victim spoke Teller lines). Cause: prompts had no master block, thin voice line with mismatched deep-male timbre on a small presence, unnamed image binding, one ambiguous "Independent or Extend" block; Clip 2 gave the victim a spoken guess against the one-speaker rule. Fix: reissued with headers + master blocks, verbatim Teller block (small fissure-voice timbre), named ingredient, split routes, Clip 2 silent. Hit — user reports corrected prompts render correctly.

## Verify before calling it done

- Cast/setting/viewpoint match the locked draw; no answer clue anywhere.
- One movement per shot, orientation held, no shake asks, effect inside proven map.
- Status 2-liner still opens any pack reply about the fix.
