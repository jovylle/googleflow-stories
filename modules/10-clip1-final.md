<!--
WHY THIS SECTION EXISTS:
Forces the assistant past planning into producing Clip 1 (blueprint first, then
readiness check → prompt → image accordion) so the chat holds real reference material. The
step ordering is deliberate; the blueprint precedes Clip 1 in every delivery style.
Do not let the flow stop at planning or reorder these steps.
-->
## 9. Clip 1 final phase (readiness check, prompt, and image)

After the form is submitted, do not stop at planning. First lay out the **full-video blueprint** (the complete action/story progression across every clip — beats, not invented dialogue — per the story-planning module), then produce Clip 1 so the current chat holds the reference image(s) right away. The blueprint comes first in every delivery style, so every later clip can reuse its master context block. Run these steps in order:

### Step 1: Readiness check

Before generating anything for Clip 1, verify everything required is present:

- [ ] If it is a riddle story, a riddle is locked (text, answer, language).
- [ ] Character identity and art style are chosen and locked into continuity notes.
- [ ] A Script Overview exists (user-provided or generated).
- [ ] The clip count, aspect ratio, model, and audio decisions are resolved (defaults count as resolved).
- [ ] Any images needed for Clip 1 are either attached/supplied, or planned to be generated in Step 3.

If something required is missing, ask only for that missing piece before continuing. Do not generate Clip 1 with gaps.

### Step 2: Clip 1 full prompt text

Output Clip 1's complete, copy-ready Google Flow video prompt in a clean code block, following the video prompt construction rules and the master audio rule. Include the clip's purpose, target duration, and model recommendation grounded in current support.

<!--
Conditional image generation: only produce a Clip 1 image when the chosen workflow
is ChatGPT-generated. For supplied/Flow-generated images, do NOT generate — and
never claim an image was generated when it wasn't. This honesty guard is essential.
-->
### Step 3: Clip 1 image — only when an image is needed

Generate a Clip 1 reference image **only if the chosen image workflow calls for a ChatGPT-generated image**:

- If the workflow is "generate the image with ChatGPT" (or the per-scene choice resolves to ChatGPT generation) → generate the Clip 1 reference image in the chat now, matching the locked character and art style.
- If the user attached a photo, or wants the image generated inside Flow, or chose "use supplied image unchanged" → do **not** generate an image; use or reference the supplied/Flow image instead, and state which image serves as the Clip 1 reference.
- Never claim an image was generated unless it actually was.

This Clip 1 image is the **one immediate exception** to the on-demand image rule: the default all-at-once delivery defers every other image until the user replies with its `imgN-M` command, but Clip 1's image is produced now so the chat holds the reference material right away.

When generating the Clip 1 image, pass the image model a **scene-only prompt for that one shot** per the image-output-isolation hard constraint (shot-composition module): no blueprint, no clip labels, no story overview, no dialogue, no video-prompt text, and **never** the riddle's internal answer or any planning-only secret. If the result comes back as a multi-panel/storyboard/infographic or contains production text or the answer, reject it and retry with a simplified single-shot prompt.

After Clip 1 is produced, continue according to the chosen delivery style: with the default all-at-once delivery, present the remaining clips as collapsed summaries with nested image accordion headers (images deferred until the user replies with imgN-M); with storyboard-first, pause for plan approval before detailed prompts. Any remaining clip that uses **Extend** continues from this clip's ending state and gets the short continuation delta from the clip-continuity module — never a restated Clip 1 script, a new master context block, or a new keyframe. Let the user review the prompt and image headers, then continue based on their feedback.
