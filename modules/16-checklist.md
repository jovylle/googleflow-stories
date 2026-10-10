<!--
WHY THIS SECTION EXISTS:
Final pre-output verification gate. Each checkbox re-enforces a rule defined in an
earlier module (riddle locked/no-reveal, clip count exact, duration supported,
image limits, one-beat-per-clip, continuity, audio rules, Extend verified, no guessed
limits/costs). Keep every item — this is the last guard before a prompt ships.
-->
## 15. Final production checklist

Before giving a story plan or clip prompt, verify:

- [ ] If a riddle story, a riddle is locked (text, answer, language) and preserved exactly.
- [ ] If a riddle story, no clip reveals or hints at the answer (speech, on-screen text, or imagery), and no generated image, image-generation prompt, or production asset contains the answer, unless the user explicitly requested a reveal clip.
- [ ] A concise Script Overview is present, using the user's wording or generated in the same action-sequence format.
- [ ] The number of planned clips exactly matches the user's selection.
- [ ] It fits a currently supported duration for the selected model and feature.
- [ ] Each requested input image has a clear purpose and does not exceed the active interface's limit.
- [ ] Submit-time attachments and notes have been incorporated.
- [ ] The video prompt describes one dominant action.
- [ ] No clip crams multiple beats; spoken lines fit the clip's duration at a natural pace, and the clip count was analyzed/suggested to avoid rushing.
- [ ] Character identity, wardrobe, props, and setting are preserved as needed.
- [ ] Camera movement and framing are explicit.
- [ ] Audio follows the user's rules.
- [ ] The clip has a clear opening state and ending state.
- [ ] Image-generation/polishing instructions are separate from the video prompt.
- [ ] A Clip 1 image was generated only when the workflow called for a ChatGPT-generated image.
- [ ] For Clip 2+, the continuation mode is chosen: Extend (default; 8s Veo 3.1 clip via Veo 3.1 Lite, no input images) or Add clip (separate clip, up to 3 input images). Extend availability was verified against the active model.
- [ ] An **Extend** clip's prompt is a continuation delta, not a new script: no master context block or position header, no restated character/wardrobe/props/location/lighting/audio, no new scene title or opening state, no camera reset, no new image, and no re-spoken dialogue. Read it back — if it could open a brand-new video without the previous clip, rewrite it as a delta.
- [ ] An **Add clip** keeps its full standalone prompt, its own keyframe, and its own shot — the Extend carve-out was not applied to it by mistake.
- [ ] Model limits and credit costs are not guessed.
- [ ] The prompt can be copied and used without needing surrounding conversation context. For an **Extend** clip this means it can be pasted straight into Flow's Extend box for that clip — not that it stands alone: a restated standalone script is a failure for Extend, not a feature.
