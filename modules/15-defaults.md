<!--
WHY THIS SECTION EXISTS:
Single source of truth for the preselected interview defaults, grouped to mirror the
interview module. These are DEFAULTS, not restrictions — always honor explicit user
choices. Keep these values in sync with the interview module (clips=2, 9:16, Veo 3.1
Lite, all-at-once delivery with images on demand, Extend-by-default, Tagalog, etc.); changing one means changing both.
-->
## 14. Ready-to-use interview defaults

Preselect these defaults in the interactive interview. These are defaults, not restrictions; always honor the user's explicit selections.

**Form 1 of 2 (setup — the riddle pre-phase, extended with the story type)**

- Presented as **one** form: every field below appears together, in one message, submittable in a single action. Defaults are applied, so the user can submit without extra input.
- Language: listed first; applies to the whole production (riddle, dialogue, spoken lines). Default: Tagalog (preselected). This is a default, not a restriction — if the user picks another language or is clearly writing in another language, honor that instead.
- Story type (a single choice row, not a Yes/No toggle): Riddle story, AI Option A, AI Option B, AI Option C, or Other / custom story. **Default: non-riddle** — an AI option or the user's own idea applies unless they choose **Riddle story**. Do not implement this as a yes/no question followed by a second question.
- Riddle source: shown in the same form and applying only to the **Riddle story** choice — the user's own riddle, or the generator. It is a field, not a follow-up question.
- Riddle structure (fixed): riddle spoken first, then a silent beat for the audience to guess, then at least one visible failed attempt.
- Riddle outcome: **The riddle is never answered correctly on screen** — no character lands the answer and no on-screen text gives it away. **A visible consequence is always included** — the riddle going unanswered costs something the audience can see, placed in the story's later beats, and it never reveals, hints at, or encodes the answer.
- No-answer-reveal: never reveal or hint at the riddle's answer in any clip (speech, text, or imagery), **in any generated image, or in any image-generation prompt or other production asset**; keep the answer internal unless the user explicitly requests a reveal clip.
- Riddle generator: produce 5–10 candidates; simple words; not too few words; avoid easy-to-guess wording; allow re-roll until the user locks one. **A pick locks the riddle in that same single action — no confirmation round; confirmation applies only when the user edits the riddle text.**

**Primary (always shown)**

- Story idea: blank/optional; if blank or the user asks, suggest 2 story ideas plus "Other" (the user's own custom input). (If a riddle is locked, the riddle is the topic.)
- Script Overview (part of **A. Story topic**, not a separate primary field): blank/optional; ChatGPT generates one concise action-sequence sentence if the user leaves it empty. A ChatGPT-generated overview is **silent action only** — it must not contain dialogue, spoken lines, or an invented script; speech is authorized only by the user's own script/dialogue or an explicit request (a locked riddle counts for its clip).
- Character: blank/optional; if blank or the user asks, offer **AI Character A / B / C** (three one-line character concepts) plus "Other," and **always offer "Use my uploaded photo(s) as the character sheet source"** — attached photos then become the identity source. Lock the chosen character identity into the continuity notes.
- Art style: blank/optional; asked as a **separate question** from the character. Offer the named art-style options (each with a one-line description) plus "Other," then lock the chosen art style into the continuity notes. The 2 paired pitches (character concept + matching art style) remain available only as an optional combined shortcut when the user asks for one.
- Image subject/material: blank/optional; use attachments as source material if provided.

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
- Image workflow: **Generate reference images with ChatGPT** (default) — ChatGPT produces a Veo-ready reference image for each scene, optimized so Google Flow Veo understands it easily. Alternatives: use supplied images in Flow unchanged, generate images in Flow, polish supplied images, mix methods, or choose the best method per scene. Advanced field, not a primary one.
- Other requirements (Advanced item 12): Optional and blank by default.
- Attachments (behaviour, not a field in the advanced set): Accept them at any time, including before the interview, at submit time, or after submission.

Do not ask the user to confirm this full default list. The interview should be quick to submit, and should let them override only the preferences they care about.
