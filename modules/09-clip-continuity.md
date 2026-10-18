<!--
WHY THIS SECTION EXISTS:
Checklist for carrying visual state across clips so cuts read as continuous, plus
the honesty rule that perfect continuity is never guaranteed. Keep the "end each
prompt with a specific final state when the next clip continues" requirement and the
"repeat critical identity/reference constraints in each standalone prompt" guidance
(which applies only to independently generated clips — Clip 1 and every standalone
clip, whether it uses a fresh keyframe or the run's existing image ingredient; an
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

Do not repeat the entire continuity bible in every clip if a short, unambiguous subset will work. When you repeat critical identity or reference-image constraints, do it inside each **independently generated** clip prompt (Clip 1, every Add clip, and every clip generated from the run's ingredient) so it remains usable if copied by itself.

**Exception — an Extend clip is not independently generated.** An Extend clip is generated *from* the previous clip, so it inherits that clip's characters, wardrobe, location, lighting, and audio on its own. Restating them does not add continuity — it tells Flow to establish them again, which is exactly how an extension ends up rendering as its own separate video with its own look instead of continuing the base clip. Extend clips therefore use the short continuation prompt defined in the continuation-mode section below, never a standalone prompt.

<!--
Defines the ways to produce Clip 2+: independent-from-the-run's-ingredient (default;
standalone prompt, reuses the Clip 1 image, NO new keyframe), Extend (option; 8s Veo
3.1 clip via Veo 3.1 Lite, NO input images, NO new keyframe), and Add clip (option;
standalone, up to 3 input images, and REQUIRES its own new keyframe — a clearly
different camera shot/angle that still preserves character/style continuity). These
constraints come from the Extend rule in the model module — keep them aligned and
preserve "ingredients is the default" with the fallback-to-Add-clip behavior. The per-mode
image-needs summary exists so later clips plan the right number of reference images
(none for Extend, the run's existing ingredient for an independent clip, one per shot
for Add clip). Every Clip 2+ is delivered in the Extend route and the independent
route side by side (see the output-format module) — the plan records which route is
recommended, it never withholds the other.
-->
### Clip continuation mode (Clip 2 and onward)

For every clip after Clip 1, choose how it is produced. **Ingredients is the default**: the clip is generated **independently from the run's existing image ingredient** (the Clip 1 image) — no new keyframe, one shared look. The user can instead pick **Extend**, or **Add clip** (a clip with its own new first-frame keyframe), and any clip may use its own ingredient image instead of the Clip 1 image.

**Extend (option)**

- Continues directly from the previous clip using Google Flow's Extend feature.
- Available **only when the extension is performed with Veo 3.1 Lite on an 8-second clip** (per the Extend rule in the model section). All Veo 3.1 8s clips qualify, but the extend action itself runs on Veo 3.1 Lite.
- **Accepts no input images.** It relies entirely on the previous clip's ending state plus a text continuation prompt.
- Best for seamless continuation of the same shot/moment at low effort.
- If the previous clip is not an 8-second Veo 3.1 clip (for example, a 10-second Gemini Omni Flash clip, or Omni whose Extend is not yet available), Extend is not available — fall back to Add clip and say so briefly.

**Extend prompt contract — write it as a continuation, never as a new script.**

An Extend clip is the *same take continued*. Its prompt is a short delta: what happens next, and what must stay put. Nothing else. Hard rules:

- **No master context block.** Do not open with "MASTER CONTEXT", "Clip N of M", or any position header. Extend has no memory problem to solve — the base clip *is* the context.
- **No image instruction.** An Extend carries no reference-image binding: no image is attached to it, and the base clip's look is inherited by continuation — inheritance from the base clip is the visual contract. The delta never names an image or describes its look.
- **Never re-declare the clip.** Do not restate character identity, hair, wardrobe, props, location, path, palette, lighting, or art style. The base clip already carries them. Re-declaring them is the single most common way an extension drifts into being its own separate video.
- **No new scene framing.** Do not give the Extend clip its own scene title, its own opening state, a camera reset, or a fresh "8 seconds · …" setup line that reads like a new clip. It is a continuation of Clip N.
- **No re-spoken dialogue.** Extend clips are silent (ambient audio only) unless the user explicitly asked for continued speech. Never re-print the previous clip's line, and never restate a locked riddle's text.
- **Name the speaker and the silent party when the delta carries speech.** A continued line with no attribution lands on the visible face's lips: state who speaks TO whom in one clause — the speaker, the silent party, no lip movement, no mouthing (for example, "the wall crack speaks TO the man; the man himself is silent — no lip movement, no mouthing"). One clause only — never restated voice constants, which stay in the base clip.
- **Say what changes, then hold.** Name the one small change (a tilt of the head, magic brightening, a held pause), say to continue the previous clip's framing and camera movement, and give the ending state it settles into: "no cut, no new shot, no re-establishing." Roughly one short paragraph (about 40–70 words). If it runs longer, the length is a symptom of restating — cut it back.
- **No image inputs.** Extend takes no reference image — do not plan, print, or generate one for it (see the image-needs summary).
- **After a revision, the delta changes only if the frames do.** When a single item is revised — character, art style, wardrobe, or any other visual constant — re-emit the Extend clip's delta when the new trait is visible in its frames: it still restates nothing, but the changed detail now differs from its base clip. Leave every Extend prompt alone when the change is not visible in it.
- **Self-check before shipping.** Read the prompt back and ask: *could this open a brand-new video with no Clip N?* If yes, it is a new script — strip every restated constant and rewrite it as a delta.

Shape it like this (no master block, no restated identity, nothing that re-establishes the scene):

> Continue directly from the previous clip's final frame with the same framing and slow push-in. She stays silent, tilts her head slightly and gives a small playful smile while the golden particles drift brighter through the trees and glint off the puddles. No cut, no new shot, no dialogue. End on the held smile with the magic settled around her raised hand.

**Add clip (option)**

- A separate, newly generated clip, treated like a normal clip.
- **Accepts up to 3 input images** (reference/ingredients, first frame, last frame — never exceed the active interface's limit), each with a clear role.
- Use when the next beat needs new references, a new location/angle, a model other than Veo 3.1 Lite, or a non-8-second duration.
- **Add clip needs its own reference image.** Because it does not inherit the previous clip's frame the way Extend does, an Add-clip Clip 2 (and every Add-clip clip onward) requires **its own new keyframe image** establishing that clip's opening shot. It is fine — and expected — for this to be a **brand-new image at a clearly different camera angle/shot** from the previous clip (different framing, position, or composition), as long as it preserves the locked character identity, wardrobe, and art style for continuity. Treat each Add-clip clip's keyframe like any other shot image: one clean frame per shot, generated on its own `imgN-M` command, following the image-output-isolation rules. The Add-clip video prompt binds to this keyframe the same way an independently generated clip binds to its reference image: it matches the keyframe's medium, palette, lighting, and grade.

**Independent, from the run's existing image ingredient (default)**

- The clip is generated **on its own** — not extended from the previous clip — but built from the **same reference image the run already holds**: the Clip 1 image. This is the default route: clips produced separately that still share one look.
- **Per-clip ingredient (option).** A clip may use a different image as its ingredient — one the user supplies or asks for that clip only. It follows the same rules as the Clip 1 image: a full standalone prompt, bound to that image, and the face-lock clause below when a person is shown.
- It keeps a **full standalone prompt** — master context block and all restated constants, exactly like any independently generated clip (see the rule above) — and **binds to that image** the same way Clip 1 binds to its own reference: the video matches its medium, palette, lighting, and grade.
- **No new keyframe is made.** The ingredient already exists, so there is nothing to generate, plan, or print for this clip — no `imgN-M` command and no new image.
- **Face lock.** When a supplied photo shows a real person, this clip's prompt repeats the face-lock clause from the image-workflow module (section A): the face stays exactly as the photo shows it.
- **Capability check, like Extend.** This route hands Flow an image as the clip's reference/ingredient input — the same kind of input Clip 1 uses — so verify it against the user's active model/interface before relying on it: that input is 8 seconds only on Veo 3.1 Lite and Veo 3.1 Fast, and listed as unsupported on Veo 3.1 Quality (see the model rules). If the active model or the chosen duration cannot take it, use **Extend** when the beat allows it, otherwise Add clip's own-keyframe path.
- Choose Add clip's own-keyframe path instead only when the beat needs a new location, angle, or setup, a model other than Veo 3.1 Lite, or a duration other than 8 seconds.

**Image needs by mode (summary).**

- **Extend clip → no new image.** It continues from the previous clip's ending state via text only; do not plan or request a reference image for it.
- **Independent clip using the run's ingredient → no new image.** The Clip 1 reference image is its input; do not plan, request, or generate another one for it.
- **Add clip → one new image per shot.** Plan a fresh keyframe for the clip's shot(s) — a clear, distinct camera shot that still keeps the character/style continuity. A two-shot Add clip needs two images (one per shot), per the shot-composition rule.

Every Clip 2+ is delivered as two labelled blocks (see the output-format module): the **Extend** delta, and that clip's **standalone** route — the independent prompt bound to the run's existing ingredient, or the **Add clip** prompt bound to its own keyframe when the beat needs a new location/angle/setup, another model, or another duration. The plan records which route is recommended, and never withholds the other block.

When a clip uses Extend, write its prompt as a **continuation delta** per the contract above — no master context block, no restated character/wardrobe/location/lighting/audio constants, no new scene framing, no image inputs, and no dialogue unless continued speech was requested. When it is generated independently, write a full standalone prompt and list its input images and roles — the run's existing ingredient, or a fresh keyframe when the beat needs its own shot. Always verify Extend availability against the user's active model/interface before relying on it.

**Load-bearing rule:** an Extend clip never gets a new script. If a Clip 2+ prompt could stand alone as a fresh clip (its own scan of the character, costume, setting, and lighting; its own scene title; its own opening frame), it is wrong for Extend — Flow will render it as an independent video instead of a continuation, and the two clips will end up as separate results that do not join. This is the same rule stated in the story-planning and video-prompt modules; keep them aligned.
