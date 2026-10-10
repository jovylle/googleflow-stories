## 7. Video prompt construction

Write each video prompt so it can be copied directly into Google Flow. Avoid vague direction such as "make it cinematic" without specifying the actual shot. Include only information that is relevant to the clip.

Recommended structure:

1. Reference instruction: how to treat supplied images and what must remain unchanged.
2. Subject and setting: who/what is on screen and where.
3. Main action: one dominant action, with clear timing or progression when useful.
4. Camera and composition: shot size, angle, camera movement, focus, and whether the camera stays fixed.
5. Lighting and visual style: concrete, consistent details.
6. Continuity constraints: unchanged identity, wardrobe, props, location, and positions as required.
7. Audio direction: dialogue, ambience, sound effects, or silence as requested.
8. Ending condition: where the action and camera should end, especially if the next clip must continue from it.

Use concise, concrete language. Do not overload every prompt with redundant adjectives or excessive negative instructions. Prioritize the instructions that affect the visible result most.

### Master audio rule

Unless the user explicitly supplies dialogue/script or asks for speech, every generated video prompt must specify:

- No spoken dialogue.
- No narration or voiceover.
- No subtitles, captions, or on-screen text.
- No text overlays.
- Environmental/ambient audio only, where audio is appropriate.

If the user explicitly asks for dialogue, narration, or on-screen text, follow the provided script and requested content rather than applying the no-speech rule. A locked riddle counts as explicitly supplied speech for the clip that delivers it.

### Voiceover-narration stories

When the user chooses voiceover narration, the story is carried by a narrator speaking over the visuals (for example, a food/cooking short with quick clips of someone preparing a dish). In this mode:

- Have **Veo generate the voiceover audio itself** — do not require the user to record or supply a voice track. If the user does supply a VO script, use its exact wording; otherwise write a concise narration that fits each clip's duration (roughly 2–3 words per second).
- Veo may **still generate ambient sound and effects** (sizzle, chopping, pouring, room tone) underneath the narration so the clip feels alive. State the intended ambience in the audio direction.
- Keep the narration budgeted to the clip length so it is not rushed, and keep the narrator's voice/tone consistent across clips for continuity.
- Visuals follow the usual rules (one dominant beat per clip, continuity between clips); the voiceover ties them together.
