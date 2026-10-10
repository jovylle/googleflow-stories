## 4. Story development and shot planning

<!--
WHY THIS SECTION EXISTS:
Clips are generated one at a time in Google Flow, each from its own prompt, so
without a single shared plan the clips drift and feel disconnected. This section
forces a full-video blueprint up front and a repeated "master context block" so
every individually generated clip stays part of one coherent story. Do not weaken
the "lay out the whole video after the first submit" rule or the master-block
requirement without an explicit instruction to do so.
-->

<!--
Mandatory full-video blueprint before any single clip is generated. Clips are made
individually with no shared memory, so this up-front end-to-end plan is what keeps
them connected. Do not make this optional or allow clip-by-clip writing in isolation.
-->
### Lay out the whole video first (required after the first submit)

Immediately after the first wizard submission, before generating any single clip, lay out the **entire video as one connected plan** — the complete action/story progression across **every** clip, whatever the clip count (1, 2, 3, or more). This progression is **beats and action, not invented dialogue** (see the speech default). Do this for every delivery style. Clips are generated individually in Flow, so a shared plan is the only thing keeping them connected; separate clips written in isolation feel disconnected. The up-front blueprint prevents that.

The blueprint must cover, end to end:

- The overall arc: how the story opens, develops, turns, and ends across the full clip count.
- Each clip's role in that arc, in order, and how each clip hands off to the next (ending state → next clip's starting state). A clip produced with **Extend** is described in the blueprint as a **continuation of the clip before it** — the one small change it shows — not as a new scene with its own fresh subject, setting, and camera setup. Only **Clip 1 and Add clips** get a full standalone scene entry.
- What stays constant throughout (character identity, wardrobe, art style, location, palette, lighting, mood, and — **only for a character whose speech the user authorized** — their locked voice identity and language/dialect).

<!--
The master context block is repeated at the top of EVERY clip prompt because each
clip is generated with no memory of the others; it carries the constants and the
handoff that make separate clips read as one video. This is referenced by the
video-prompt module (step 0) — keep the concept and name consistent.
-->
### Master context block (repeat inside every independently generated clip prompt)

Because each clip is generated from its own prompt with no memory of the others, define a short **master context block** once, then include it (or a tight subset of it) at the top of **every** clip's video prompt so each clip carries the whole-story context. The master block states:

- Story one-liner and the clip's position (for example, "Clip 2 of 3").
- Locked character identity + art style, key wardrobe/props, location, palette, lighting, and mood that must not drift.
- **Locked audio/voice identity for each character whose speech is authorized** — who they are, their voice qualities (gender, age impression, tone, accent, pace, energy) and the language/dialect they speak in. Because each independently generated clip has no memory of the others, this must be restated in every such clip prompt so a character's voice does not change between clips (an Extend clip continues the base clip's audio — do not restate or contradict it). If no speech is authorized (the default; silent/ambient-only), state that explicitly instead.
- The immediately preceding clip's ending state and this clip's required starting state, so the cut reads as continuous.
- Any locked riddle text/language constraints that apply.

Keep it concise — repeat only the constants and the handoff, not the entire plan. This master block is what makes individually generated clips feel like one video.

**Exception — Extend clips carry no master block.** A Clip 2+ that continues the previous clip with **Extend** is not independently generated: it is rendered from the base clip, so character, wardrobe, location, lighting, and audio are already on screen. Give it the short continuation delta defined in the clip-continuity module instead — no master context block, no restated constants, no new scene framing. Handing a full master block to an Extend clip is what makes Flow establish the scene a second time, so the extension renders as its own separate video instead of continuing the first one. **Add clip** (the alternative continuation mode) *is* independently generated and keeps the full block.

Before video prompts, create a compact plan appropriate to the requested delivery style:

1. Script Overview: exactly one concise sentence in an action-sequence format that states how the video unfolds across the requested clips. Use the user's sentence if provided; otherwise generate one in the same style. Preserve explicit per-clip speech/silence instructions here. If you generate the overview yourself, write it as silent action — do not put dialogue or spoken lines into a Script Overview you authored; only the user's own overview, an explicit speech request, or a locked riddle authorizes speech. If a riddle was locked, build the overview around **delivering that riddle's text** — plan from the riddle's wording and mood only, **not** from its answer (answer-blind planning, per the riddle module). The answer is a sealed leak check, never a plot input.
2. Premise and intended outcome: briefly describe what happens and what the viewer should feel or understand.
3. Story beats: beginning, development, turning point, and ending/payoff as appropriate to the genre and clip count.
4. Clip list / shot list: create exactly the requested number of clips. For each, specify its purpose, supported target duration, subject, setting, main action, camera framing/movement, continuity details, audio needs, and image inputs. For a Clip 2+ produced with **Extend**, specify only its continuation purpose, the one small change it shows ("no image input, no new script, no new shot") — do not write it a fresh subject/setting/camera spec or a new scene title, because the base clip already establishes all of that. An **Add clip** gets the full spec above, plus its own keyframe.
5. Continuity notes when needed: stable character appearance, clothing, props, location layout, time of day, lighting, color palette, and details that must not drift between clips.
6. Asset plan: indicate which reference images should be created or supplied for each clip. Prefer a small, deliberate set of references over a pile of loosely related images.

Keep each clip centered on one dominant action or clear beat. Avoid cramming a sequence of unrelated actions into one short generation. Use a separate clip when a new action, angle, location, or story beat needs its own control.

Use a storyboard-first approach for stories that need continuity: settle the key visual design and keyframes before spending video credits. When possible, make a scene's primary storyboard image already contain the intended character, outfit, background, composition, and props. This reduces the amount left for the video model to guess, but does not guarantee perfect consistency.
