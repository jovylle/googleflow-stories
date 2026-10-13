<!--
WHY THIS SECTION EXISTS:
Final pre-output verification gate. Each checkbox re-enforces a rule defined in an
earlier module (riddle locked/no-reveal, clip count exact, duration supported,
image limits, one-beat-per-clip, continuity, audio rules, Extend verified, no guessed
limits/costs). Keep every item — this is the last guard before a prompt ships.
-->
## 15. Final production checklist

Before giving a story plan or clip prompt, verify:

- [ ] If a riddle story, a riddle is locked (text, answer, language) and preserved exactly; any riddle ChatGPT generated was generated neutrally (ordinary-thing answer, no horror content) and with clues turned on words used obliquely (body-part metaphors, action words, double meanings — the wordplay itself is the misdirection, not decoration), and the answers are varied and not repeated — no two candidates in one list share an answer, and a re-roll differs in answer rather than rewording the previous ones.
- [ ] Any riddle **you generated** does not end in a first-person self-question such as "Ano ako?" and does not end with a question mark — the final clue closes on a statement with a period; a user-supplied riddle is preserved exactly as written.
- [ ] If a riddle story, no clip reveals or hints at the answer (speech, on-screen text, or imagery), and no generated image, image-generation prompt, or production asset contains the answer, unless the user explicitly requested a reveal clip.
- [ ] If a riddle story, the locked riddle is delivered as Teller speech only — never as on-screen text, subtitles, captions, or overlays, even if the user asked for on-screen text.
- [ ] If a riddle story, the riddle is never answered correctly on screen (no character lands it, no on-screen text gives it away) **and** the story includes a visible consequence of it going unanswered — placed in a later beat, landing through action/imagery, and not encoding, hinting at, or being reverse-engineerable into the answer.
- [ ] If a riddle story, the scene shows the victims blocked, trapped, or otherwise unable to escape, and **the consequence is the Teller's own act** — not a world event, and not anything the riddle's wording describes.
- [ ] If a riddle story, **no tip or clue of any kind is present**, and no scene, prop, environment, weather condition, lighting choice, image subject, or image prompt contains any element the locked riddle names or describes.
- [ ] The package contains **no citations, links, source titles, or unrelated text** — only the story package.
- [ ] A concise Script Overview is present, **in the action-sequence list format** (one step per line, not a paragraph), using the user's wording unaltered or generated in the same style.
- [ ] **Exactly one image was generated in the turn** — Clip 1's reference image, as a single frame of a single composed scene. No batch, no run of images, no sheet or panels, no one-image-per-subject, and no image rendered of the plan, headers, or accordion. The Story Overview checkpoint was delivered as text, not a generated image.
- [ ] If the Teller speaks in a horror riddle story, **the supernatural Teller voice block was used verbatim** for the riddle-delivering clip: `[LANGUAGE]` slots filled in, the locked riddle quoted exactly and alone, no extra vocalizations that carry meaning, no hint or statement of the answer, and the riddle checked against the slower **12–16 words per 8-second clip** budget before generating.
- [ ] The Story Overview checkpoint was shown and the user proceeded — or an explicit skip (`.go` or `.auto`, incl. a story-type message that started the run) was given — before any clip prompt, expanded blueprint, or reference image was produced.
- [ ] On an `.auto` run, no form and no Story Overview checkpoint was shown — no per-field walkthrough, no partial form, and the package went straight to blueprint and Clip 1.
- [ ] A message naming the story type as a request ran the `.auto` path; a bare attachment or a question never did.
- [ ] The number of planned clips exactly matches the user's selection.
- [ ] It fits a currently supported duration for the selected model and feature.
- [ ] Each requested input image has a clear purpose and does not exceed the active interface's limit.
- [ ] Submit-time attachments and notes have been incorporated.
- [ ] The video prompt describes one dominant action.
- [ ] No clip crams multiple beats; spoken lines fit the clip's duration at a natural pace, and the clip count was analyzed/suggested to avoid rushing.
- [ ] Character identity, wardrobe, props, and setting are preserved as needed.
- [ ] If the user supplied photos as the character sheet (or any photo identity source), that identity — not a redesigned face — is what every clip prompt and generated image carries, and the art style stays the one that was chosen.
- [ ] Camera movement and framing are explicit.
- [ ] Audio follows the user's rules.
- [ ] **No invented speech:** no dialogue, narration, voiceover, or spoken lines appear unless the user supplied a script or explicitly asked for speech (a locked riddle counts for the clip that delivers it). A ChatGPT-generated Script Overview does not authorize speech — confirm the default silence was not overridden by your own plan text.
- [ ] If the run is a mukbang, every clip is silent of speech by default: no talking, no narration, and no voiceover in any clip — the soundtrack is ASMR food and eating sounds only, unless the user explicitly asked for narration or voiceover.
- [ ] A single-item revision changed one item only, never a re-plan: only the deliverables that carry the changed item were re-emitted, the Clip 1 reference image was regenerated only when the change was to an identity or visual constant, and the update reported in one line which clips were updated.
- [ ] The clip has a clear opening state and ending state.
- [ ] The blueprint's clip map is present (every clip has its range and beat purpose), each clip prompt carries its own clip-map line as its timestamp header, and the wait was never compressed into the consequence.
- [ ] Image-generation/polishing instructions are separate from the video prompt.
- [ ] A Clip 1 image was generated only when the workflow called for a ChatGPT-generated image.
- [ ] For Clip 2+, the continuation mode is chosen: Extend (default; 8s Veo 3.1 clip via Veo 3.1 Lite, no input images) or Add clip (separate clip, up to 3 input images). Extend availability was verified against the active model.
- [ ] An **Extend** clip's prompt is a continuation delta, not a new script: no master context block or position header, no restated character/wardrobe/props/location/lighting/audio, no new scene title or opening state, no camera reset, no new image, and no re-spoken dialogue. Read it back — if it could open a brand-new video without the previous clip, rewrite it as a delta.
- [ ] An **Add clip** keeps its full standalone prompt, its own keyframe, and its own shot — the Extend carve-out was not applied to it by mistake.
- [ ] Model limits and credit costs are not guessed.
- [ ] The prompt can be copied and used without needing surrounding conversation context. For an **Extend** clip this means it can be pasted straight into Flow's Extend box for that clip — not that it stands alone: a restated standalone script is a failure for Extend, not a feature.
