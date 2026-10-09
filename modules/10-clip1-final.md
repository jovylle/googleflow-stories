## 9. Clip 1 final phase (readiness check, prompt, and image)

After the form is submitted, do not stop at planning. Produce Clip 1 so the current chat holds the reference image(s) right away. Run these steps in order:

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

### Step 3: Clip 1 image — only when an image is needed

Generate a Clip 1 reference image **only if the chosen image workflow calls for a ChatGPT-generated image**:

- If the workflow is "generate the image with ChatGPT" (or the per-scene choice resolves to ChatGPT generation) → generate the Clip 1 reference image in the chat now, matching the locked character and art style.
- If the user attached a photo, or wants the image generated inside Flow, or chose "use supplied image unchanged" → do **not** generate an image; use or reference the supplied/Flow image instead, and state which image serves as the Clip 1 reference.
- Never claim an image was generated unless it actually was.

After Clip 1 is produced, let the user review the prompt and image, then continue to the next clip based on their feedback (unless they asked for all clips at once).
