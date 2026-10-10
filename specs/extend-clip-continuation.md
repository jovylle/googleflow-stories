# Investigation: an Extend clip rendered as its own separate video (fix v2.11.8)

Branch: `fix/extend-clip-continuation` · worktree: `../googleflow-stories-extend-fix`

## Reported symptom

In a live run of the story maker (Tagalog riddle, 2 clips, Clip 2 = **Extend**), the
model wrote Clip 2 as a **new script** instead of a continuation, so Clips 1 and 2 came
out as two separate results that do not join — even though Clip 2 was explicitly an
extension of Clip 1.

Evidence from the run (abridged):

- The blueprint gave Clip 2 its own scene framing: `Clip 2: Ang mahiwagang paghihintay
  … Ending: … Pacing note: …`
- The delivered Clip 2 prompt opened correctly — *"Continue directly from Clip 1 using
  Veo 3.1 Lite Extend"* — but then restated the whole production:
  *"Preserve the elf's exact appearance, platinum-blonde hair, flower accessories,
  pointed ears, sage-green capelet, cream embroidered dress, brown satchel, and boots.
  Keep the same twilight woodland path, wet ground, puddles, rustic fencing, lanterns,
  and anime-inspired fantasy style."*

The continuation *instruction* was there. The failure is that it was wrapped in a
complete standalone script — the prompt is self-sufficient, so it establishes the scene
from scratch instead of continuing footage that already exists.

## Root cause

The instruction set had no concept of "an Extend clip's prompt is a delta." Four rules
required the opposite, and nothing carved Extend out of them:

1. `05-story-planning` — the master context block is "**included at the top of every
   clip's video prompt**", and the clip list requires each clip's own subject, setting,
   camera, and audio spec.
2. `08-video-prompt` — step 0: "Include this at the top of **every** clip prompt — each
   clip is generated individually with no memory of the others."
3. `09-clip-continuity` — "repeat critical identity or reference-image constraints inside
   each **standalone** prompt so it remains usable if copied by itself", followed by a
   single soft clause ("write its prompt as a continuation") that reads as a style note,
   not a prohibition.
4. `11-output-format` + `16-checklist` reinforced it: every clip ships as a copy-ready
   standalone prompt in its own code block, and the final gate demanded "can be copied
   and used without needing surrounding conversation context."

The model satisfied all four rules for Clip 2 by restating the scene in a fresh master
block. That is a new script by construction. **Inference, not verified inside Flow:**
whether Extend strictly requires a delta prompt could not be tested from this repo. What
*is* verifiable is that the instructions produced a Clip 2 prompt that is
indistinguishable from a fresh clip's prompt — which contradicts the Extend workflow the
user selected, and is the mechanism by which the two clips end up as separate videos.

## Fix — one rule, enforced at every layer

> **An Extend clip is the same take continued. Its prompt is a short continuation
> delta** — continue the previous clip's framing and motion → the one change → the
> ending state → audio continuity. No master block, no restated constants, no new scene
> framing, no camera reset, no new image, no re-spoken dialogue.

| Module | Change |
|---|---|
| `09-clip-continuity` (owner) | New **Extend prompt contract**: 7 hard rules, a shaped example, and a self-check ("could this open a brand-new video with no Clip N?"). The standalone-prompt rule is now scoped to *independently generated* clips (Clip 1, Add clips). Closing load-bearing rule states the consequence. |
| `05-story-planning` | Master block scoped to independently generated clips, with an explicit Extend exception; blueprint describes an Extend clip as a continuation of the clip before it; clip-list entry for Extend is continuation-only; voice-identity bullet scoped. |
| `08-video-prompt` | Step 0 scoped; new **Structure for an Extend clip** — the 4-item delta shape (continue framing → one change → ending state → audio), with "delete anything that restates identity". |
| `11-output-format` | Extend clip summaries read "Continuation of Clip N (Extend) — no new shot, no image input"; the revealed block must be a delta, with length as the tell. |
| `06-model-rules` | Extend rule states the prompt shape next to "no input images". |
| `04-interview` | Field 9 (Clip continuation) notes the delta, so the rule is visible at the point of choice. |
| `10-clip1-final` | Remaining Extend clips continue from Clip 1's ending state with a delta — never a restated Clip 1 script or a new keyframe. |
| `15-defaults` | Continuation default carries the delta rule (defaults are a config surface). |
| `16-checklist` | Two new gates: the Extend prompt is a delta (with the read-back test); an Add clip kept its full standalone prompt. |

## Verification

- `./build.sh` → version **2.11.8**, 19 modules, 1050 lines; `build/` in sync.
- Two consecutive rebuilds produce byte-identical output (deterministic).
- The compiled artifact contains the contract; the only remaining "standalone prompt"
  mentions are the intentional ones (scoped to independent clips / Add clip).
- No automated tests exist in this repo (see reverse spec §4), so verification is
  build-sync + content review + the manual test below.

### Manual test plan (ChatGPT, after pasting the new build)

1. Run the same Tagalog riddle, 2 clips, Clip continuation = Extend.
2. Blueprint: Clip 2 is listed as a **continuation**, not a new scene with its own title/setup.
3. Reveal Clip 2: a short delta paragraph — no `MASTER CONTEXT`, no restated costume/location/lighting/audio, no position header.
4. Clip 2 shows **no image header** and no `imgN-M`.
5. Paste it into Flow's Extend for Clip 1: the result should continue Clip 1's final frame rather than re-establish the scene.

## Still open

- Whether Extend is actually available in the user's Flow account/region. If it is not, the
  correct behaviour is the documented fallback to **Add clip**, which legitimately produces
  two non-joining clips.
- Clip 1's riddle length vs the 8-second budget (separate pacing concern from the same run;
  covered by the existing pacing rule).
- Reverse-spec F5/F6 remain open (P3) from the earlier audit.
