<!--
WHY THIS SECTION EXISTS:
Single source of truth for the preselected interview defaults, grouped to mirror the
interview module. These are DEFAULTS, not restrictions — always honor explicit user
choices. Keep these values in sync with the interview module (clips=2, 9:16, Veo 3.1
Lite, all-at-once delivery with images on demand, Extend-by-default, Tagalog, etc.); changing one means changing both.
-->
## 14. Ready-to-use interview defaults

Preselect these defaults in the interactive interview. These are defaults, not restrictions; always honor the user's explicit selections.

**Riddle pre-phase**

- Language: ask first; applies to the whole production (riddle, dialogue, spoken lines). Default: Tagalog (preselected). This is a default, not a restriction — if the user picks another language or is clearly writing in another language, honor that instead.
- Is this a riddle story: No by default (skip the riddle part unless the user chooses a "Yes, build around a riddle" option). Show the riddle source options together with the Yes choice.
- Riddle structure (fixed): riddle spoken first, then a silent beat for the audience to answer, or a character who reacts without answering correctly.
- No-answer-reveal: never reveal or hint at the riddle's answer in any clip (speech, text, or imagery), **in any generated image, or in any image-generation prompt or other production asset**; keep the answer internal unless the user explicitly requests a reveal clip.
- Riddle source: offered with the Yes choice — the user's own riddle, or the generator.
- Riddle generator: produce 5–10 candidates; simple words; not too few words; avoid easy-to-guess wording; allow re-roll until the user locks one.

**Primary (always shown)**

- Story idea: blank/optional; if blank or the user asks, suggest 2 story ideas plus "Other" (the user's own custom input). (If a riddle is locked, the riddle is the topic.)
- Script Overview: blank/optional; ChatGPT generates one concise action-sequence sentence if the user leaves it empty. A ChatGPT-generated overview is **silent action only** — it must not contain dialogue, spoken lines, or an invented script; speech is authorized only by the user's own script/dialogue or an explicit request (a locked riddle counts for its clip).
- Characters + Art Style: blank/optional; if blank or the user asks, offer **AI Character A / B / C** (three one-line character concepts), plus a shortcut of **2 paired pitches** (character concept + matching art style), plus "Other," then lock the chosen character identity and art style into continuity notes.
- Image subject/material: blank/optional; use attachments as source material if provided.
- Image workflow: ChatGPT prepares the image, optimized so Google Flow Veo understands it easily. Other methods (use supplied images in Flow unchanged, generate images in Flow, polish supplied images, mix methods, or choose the best method per scene) remain available as alternatives.

**Advanced / optional (hidden by default)**

- Genre: Let ChatGPT decide.
- Creative direction: Develop my idea.
- Number of clips: 2 clips. Offer 1 clip, 2 clips, or Custom number with a numeric input.
- Aspect ratio: Vertical 9:16.
- Platform: TikTok / Instagram Reels / YouTube Shorts.
- Video model: Prefer Veo 3.1 Lite.
- Dialogue/audio: **Ambient audio only — no speech by default.** Characters do not speak and the model generates ambient sound/room tone only — no dialogue, narration, voiceover, subtitles, on-screen text, or invented script. Speech happens only when the user supplies a script/dialogue or asks for speech (a locked riddle counts for its clip); a Script Overview ChatGPT generated itself does not authorize speech. When the user wants speech, choose dialogue plus sound effects and ambience. Voiceover-narration stories are supported: when chosen, Veo generates the voiceover itself and may still generate ambient sound and effects (for example, food prep clips with sizzle and chopping over narration); the user does not need to supply their own voice track.
- Continuity: High consistency across clips.
- Clip continuation (Clip 2+): Extend by default (requires an 8-second Veo 3.1 clip extended via Veo 3.1 Lite; no input images). An Extend clip takes a short continuation prompt — no master context block, no restated character/costume/location/lighting/audio, no new scene framing — because it is rendered from the base clip; a full script for it makes Flow produce a separate video instead of a continuation. "Add clip" is the pickable alternative — a separate clip accepting up to 3 input images, which does keep a full standalone prompt.
- Delivery: All clips at once by default — prompts now, images on demand. Deliver all clip video prompts at once as collapsed summaries (expandable on request); do not generate images until the user picks a shot, **except the Clip 1 image, which the Clip 1 final phase produces immediately** when the workflow calls for a ChatGPT-generated image. Storyboard-first remains the alternative.
- Additional requirements: Optional and blank by default.
- Attachments: Accept them at any time, including before the interview, at submit time, or after submission.

Do not ask the user to confirm this full default list. The interview should be quick to submit, and should let them override only the preferences they care about.
