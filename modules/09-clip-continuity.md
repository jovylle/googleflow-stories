<!--
WHY THIS SECTION EXISTS:
Checklist for carrying visual state across clips so cuts read as continuous, plus
the honesty rule that perfect continuity is never guaranteed. Keep the "end each
prompt with a specific final state when the next clip continues" requirement and the
"repeat critical identity/reference constraints in each standalone prompt" guidance
(which applies only to independently generated clips — Clip 1 and Add clips; an
Extend clip gets a continuation delta instead).
-->
## 8. Clip continuity

For each clip after the first, check:

- What visual state is inherited from the previous ending?
- Where are the subject, camera, key props, and other characters?
- What changed since the last clip, and what must remain unchanged?
- Does the next clip begin at a plausible point in the same action or story?
- Is a new keyframe/reference image needed to establish the intended state?

End each prompt with a specific final state when the next clip must continue directly. When appropriate, provide an optional bridge instruction or starting-frame prompt for the next clip. Do not claim perfect continuity is guaranteed: video generation may still alter details.

Do not repeat the entire continuity bible in every clip if a short, unambiguous subset will work. When you repeat critical identity or reference-image constraints, do it inside each **independently generated** clip prompt (Clip 1 and every Add clip) so it remains usable if copied by itself.

**Exception — an Extend clip is not independently generated.** An Extend clip is generated *from* the previous clip, so it inherits that clip's characters, wardrobe, location, lighting, and audio on its own. Restating them does not add continuity — it tells Flow to establish them again, which is exactly how an extension ends up rendering as its own separate video with its own look instead of continuing the base clip. Extend clips therefore use the short continuation prompt defined in the continuation-mode section below, never a standalone prompt.

<!--
Defines the two ways to produce Clip 2+: Extend (default; 8s Veo 3.1 clip via Veo
3.1 Lite, NO input images, NO new keyframe) vs. Add clip (standalone, up to 3 input
images, and REQUIRES its own new keyframe — a clearly different camera shot/angle
that still preserves character/style continuity). These constraints come from the
Extend rule in the model module — keep them aligned and preserve "Extend is the
default" with the fallback-to-Add-clip behavior. The per-mode image-needs summary
exists so later clips plan the right number of reference images (none for Extend,
one per shot for Add clip).
-->
### Clip continuation mode (Clip 2 and onward)

For every clip after Clip 1, choose how it is produced. **Extend is the default**; the user can pick "Add clip" instead.

**Extend (default)**

- Continues directly from the previous clip using Google Flow's Extend feature.
- Available **only when the extension is performed with Veo 3.1 Lite on an 8-second clip** (per the Extend rule in the model section). All Veo 3.1 8s clips qualify, but the extend action itself runs on Veo 3.1 Lite.
- **Accepts no input images.** It relies entirely on the previous clip's ending state plus a text continuation prompt.
- Best for seamless continuation of the same shot/moment at low effort.
- If the previous clip is not an 8-second Veo 3.1 clip (for example, a 10-second Gemini Omni Flash clip, or Omni whose Extend is not yet available), Extend is not available — fall back to Add clip and say so briefly.

**Extend prompt contract — write it as a continuation, never as a new script.**

An Extend clip is the *same take continued*. Its prompt is a short delta: what happens next, and what must stay put. Nothing else. Hard rules:

- **No master context block.** Do not open with "MASTER CONTEXT", "Clip N of M", or any position header. Extend has no memory problem to solve — the base clip *is* the context.
- **Never re-declare the clip.** Do not restate character identity, hair, wardrobe, props, location, path, palette, lighting, or art style. The base clip already carries them. Re-declaring them is the single most common way an extension drifts into being its own separate video.
- **No new scene framing.** Do not give the Extend clip its own scene title, its own opening state, a camera reset, or a fresh "8 seconds · …" setup line that reads like a new clip. It is a continuation of Clip N.
- **No re-spoken dialogue.** Extend clips are silent (ambient audio only) unless the user explicitly asked for continued speech. Never re-print the previous clip's line, and never restate a locked riddle's text.
- **Say what changes, then hold.** Name the one small change (a tilt of the head, magic brightening, a held pause), say to continue the previous clip's framing and camera movement, and give the ending state it settles into: "no cut, no new shot, no re-establishing." Roughly one short paragraph (about 40–70 words). If it runs longer, the length is a symptom of restating — cut it back.
- **No image inputs.** Extend takes no reference image — do not plan, print, or generate one for it (see the image-needs summary).
- **Self-check before shipping.** Read the prompt back and ask: *could this open a brand-new video with no Clip N?* If yes, it is a new script — strip every restated constant and rewrite it as a delta.

Shape it like this (no master block, no restated identity, nothing that re-establishes the scene):

> Continue directly from the previous clip's final frame with the same framing and slow push-in. She stays silent, tilts her head slightly and gives a small playful smile while the golden particles drift brighter through the trees and glint off the puddles. No cut, no new shot, no dialogue. End on the held smile with the magic settled around her raised hand.

**Add clip (option)**

- A separate, newly generated clip, treated like a normal clip.
- **Accepts up to 3 input images** (reference/ingredients, first frame, last frame — never exceed the active interface's limit), each with a clear role.
- Use when the next beat needs new references, a new location/angle, a model other than Veo 3.1 Lite, or a non-8-second duration.
- **Add clip needs its own reference image.** Because it does not inherit the previous clip's frame the way Extend does, an Add-clip Clip 2 (and every Add-clip clip onward) requires **its own new keyframe image** establishing that clip's opening shot. It is fine — and expected — for this to be a **brand-new image at a clearly different camera angle/shot** from the previous clip (different framing, position, or composition), as long as it preserves the locked character identity, wardrobe, and art style for continuity. Treat each Add-clip clip's keyframe like any other shot image: one clean frame per shot, generated on its own `imgN-M` command, following the image-output-isolation rules.

**Image needs by mode (summary).**

- **Extend clip → no new image.** It continues from the previous clip's ending state via text only; do not plan or request a reference image for it.
- **Add clip → one new image per shot.** Plan a fresh keyframe for the clip's shot(s) — a clear, distinct camera shot that still keeps the character/style continuity. A two-shot Add clip needs two images (one per shot), per the shot-composition rule.

When a clip uses Extend, write its prompt as a **continuation delta** per the contract above — no master context block, no restated character/wardrobe/location/lighting/audio constants, no new scene framing, no image inputs, and no dialogue unless continued speech was requested. When it uses Add clip, write a full standalone prompt and list its input images and roles. Always verify Extend availability against the user's active model/interface before relying on it.

**Load-bearing rule:** an Extend clip never gets a new script. If a Clip 2+ prompt could stand alone as a fresh clip (its own scan of the character, costume, setting, and lighting; its own scene title; its own opening frame), it is wrong for Extend — Flow will render it as an independent video instead of a continuation, and the two clips will end up as separate results that do not join. This is the same rule stated in the story-planning and video-prompt modules; keep them aligned.
