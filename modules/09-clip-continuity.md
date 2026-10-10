<!--
WHY THIS SECTION EXISTS:
Checklist for carrying visual state across clips so cuts read as continuous, plus
the honesty rule that perfect continuity is never guaranteed. Keep the "end each
prompt with a specific final state when the next clip continues" requirement and the
"repeat critical identity/reference constraints in each standalone prompt" guidance.
-->
## 8. Clip continuity

For each clip after the first, check:

- What visual state is inherited from the previous ending?
- Where are the subject, camera, key props, and other characters?
- What changed since the last clip, and what must remain unchanged?
- Does the next clip begin at a plausible point in the same action or story?
- Is a new keyframe/reference image needed to establish the intended state?

End each prompt with a specific final state when the next clip must continue directly. When appropriate, provide an optional bridge instruction or starting-frame prompt for the next clip. Do not claim perfect continuity is guaranteed: video generation may still alter details.

Do not repeat the entire continuity bible in every clip if a short, unambiguous subset will work. However, repeat critical identity or reference-image constraints inside each standalone prompt so it remains usable if copied by itself.

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

**Add clip (option)**

- A separate, newly generated clip, treated like a normal clip.
- **Accepts up to 3 input images** (reference/ingredients, first frame, last frame — never exceed the active interface's limit), each with a clear role.
- Use when the next beat needs new references, a new location/angle, a model other than Veo 3.1 Lite, or a non-8-second duration.
- **Add clip needs its own reference image.** Because it does not inherit the previous clip's frame the way Extend does, an Add-clip Clip 2 (and every Add-clip clip onward) requires **its own new keyframe image** establishing that clip's opening shot. It is fine — and expected — for this to be a **brand-new image at a clearly different camera angle/shot** from the previous clip (different framing, position, or composition), as long as it preserves the locked character identity, wardrobe, and art style for continuity. Treat each Add-clip clip's keyframe like any other shot image: one clean frame per shot, generated on its own `imgN-M` command, following the image-output-isolation rules.

**Image needs by mode (summary).**

- **Extend clip → no new image.** It continues from the previous clip's ending state via text only; do not plan or request a reference image for it.
- **Add clip → one new image per shot.** Plan a fresh keyframe for the clip's shot(s) — a clear, distinct camera shot that still keeps the character/style continuity. A two-shot Add clip needs two images (one per shot), per the shot-composition rule.

When a clip uses Extend, write its prompt as a continuation (no image inputs, continue-from-previous framing). When it uses Add clip, write a full standalone prompt and list its input images and roles. Always verify Extend availability against the user's active model/interface before relying on it.
