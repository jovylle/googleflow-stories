## 2. Riddle pre-phase (runs before the main form)

When the story maker starts (via `.start`), run this short pre-phase **before** opening the main interview form. It decides whether the story is a riddle and, if so, locks a riddle first so the rest of the production is built around a known answer.

In this project, **every riddle is told in story format**. The fixed structure is: the riddle is spoken **first**, then the story continues with either a silent beat where the audience is meant to answer, or another character who reacts but never answers correctly. Build every riddle story on this structure by default; do not leave it to the Script Overview to reinvent.

### Step 0: Riddle check

Ask up front, as the first questions, before the main form:

1. **Riddle language** (ask this first). Offer common options and allow custom — for example English, Cebuano, Tagalog, or Other. This language governs the riddle text itself.
2. **Is this a riddle story?** Present the choice and the riddle source together, so the source options are visible right away (not hidden behind a second question):
   - **No, create a regular story** → skip the rest of this pre-phase and open the main form.
   - **Yes, build the story around a riddle — I have my own riddle** → the user pastes it. Accept it as the locked riddle, confirm its intended answer, and continue to the main form.
   - **Yes, build the story around a riddle — use the riddle generator** → run the riddle generator skill (Step 0a).

### Step 0a: Riddle generator skill

Generate a list of **5–10 candidate riddles** in the chosen language, each with its answer noted for the user. Quality rules:

- Use **simple, everyday words**. Avoid obscure or overly literary vocabulary.
- Do **not** make riddles too short. Each should have enough words to give fair, layered clues rather than a one-line giveaway.
- Avoid wording that makes the answer **too easy to guess** — no near-synonyms of the answer, no obvious direct naming of the thing.
- Keep each riddle self-contained and solvable from its clues.
- **Fit the spoken duration.** Keep each riddle short enough to be spoken naturally within one clip of the selected model (roughly 16–24 words for an 8-second clip). If a strong riddle runs longer, note that it will need its own clip or a longer-duration model, per the pacing rules below.
- Note the answer beside each option so the user can judge quality.

Then:

- Present the numbered list and let the user **pick one**, **edit one**, or **re-roll** (`.reroll`) for a brand-new batch.
- The user may re-roll as many times as they like.
- When the user picks (or edits and confirms) a riddle, **lock it**: record the final riddle text, its answer, and the language. This locked riddle becomes the backbone of the Script Overview and clip plan.

### After the riddle is set

Carry the locked riddle into the main form and story plan. Apply the fixed riddle structure: the riddle is the **opening spoken line** (in Clip 1), followed by a silent beat for the audience to answer, or a character who reacts without answering correctly. Keep later clips consistent with this and preserve the riddle's exact wording and language.

### No-answer-reveal rule (riddle stories)

For any riddle story, **never reveal or hint at the answer** in the video output:

- Do not state, spell, imply, or visually depict the answer in any clip's spoken lines, on-screen text, captions, or imagery.
- Do not add clues beyond the riddle's own wording that would make the answer easy to deduce. Reacting characters must not accidentally give it away.
- The silent beat is for the audience to guess; leave it unanswered. If a character reacts, they react without answering correctly.
- The internal answer is recorded only to guide planning and keep the team consistent — it is never surfaced to the viewer.
- If the user explicitly asks for a reveal clip, confirm first, then treat that as an intentional exception for that specific clip only.

### Pacing and clip-count planning (flexible)

A single clip is bound by the selected model's maximum duration (for example, Veo 3.1 Lite caps at 8 seconds). Cramming several beats into one clip makes the model rush — a character blurting the whole riddle, a pause, and a reaction squashed into 8 seconds. Prevent this by planning pacing before writing prompts. Do not force a fixed split; analyze and recommend.

Rules:

- **One dominant beat per clip.** A beat is one unit of action or story moment — speaking the riddle, the silent think-pause, or the reaction are each separate beats. Do not put more than one dominant beat in a clip.
- **Budget spoken lines to the clip duration.** At a natural pace, roughly 2–3 words per second — about 16–24 words fit in 8 seconds, 20–30 in 10 seconds, leaving headroom for breathing and framing. If a line will not fit, it needs its own clip, a longer-duration model, or a trim.
- **Analyze and suggest the clip count.** Before prompts, estimate how many clips the riddle and story actually need so nothing is rushed. Present the suggested clip count and the beat each clip carries. If it differs from the user's chosen clip count, explain why and let them accept, adjust, or override.
- **Suggest script changes to fit.** If a riddle or line is too long for a single clip, propose concrete options: split across clips, shorten/rephrase while preserving meaning and the no-answer-reveal rule, or recommend a longer-duration model (frame model suggestions as recommendations grounded in current support, not guarantees). Never silently rewrite a locked riddle — show the proposed change and get approval.
- **Keep good continuation.** When beats span multiple clips, each clip must start from the previous clip's ending state (subject position, expression, framing, lighting) so the sequence reads as one continuous moment. Provide a short bridge/continuity note between clips.
- **Typical riddle pacing** (adjust to the actual riddle length and model): Clip 1 delivers the riddle; a following clip holds the silent think-beat; a further clip carries the reaction. Collapse to fewer clips only when the content genuinely fits one clip's duration without rushing.
