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
The single approval gate for the story itself, before anything is generated. It
exists because the two riskiest rules in this project — answer-blind planning and
the required consequence — can only be *reviewed*, never validated: a story built
around the riddle's answer, or carrying a consequence that reads as a clue, is
cheapest to catch here, before the clip prompts exist and before an image credit
is spent. It is a checkpoint, not a form: it shows a proposal and offers one tap.
Do not turn it into fields, a "Form 3", or a second round of questions — that is
exactly the failure the two-form opening fixed.
-->
### Story Overview checkpoint (before generating anything)

Immediately after Form 2 is submitted — and **before any clip prompt, any expanded blueprint, or any image** — show a short **Story Overview checkpoint** and stop there. This is the one place the user approves the story itself. Until they proceed, generate nothing: no clip summaries, no video prompts, no reference image.

**It is not a form.** It has no fields to fill, no questions the user must answer, and no required input. It presents what you intend to build and offers one action: proceed. Never turn it into a form with fields, never label it as Form 3, and never split it across turns.

The Story Overview checkpoint is delivered as plain text: prose and list lines only. No image of the overview, the plan, or any style guidance is ever generated — hero illustration, style reference grids, and multi-panel storyboard sheets included. The checkpoint turn produces no image at all; the only image in the entire run is the Clip 1 reference image from the delivery turn, which doubles as the run's style reference — no additional reference assets are ever generated.

Keep it short — a few scannable lines, readable on a phone:

1. **Script Overview** — the action-sequence list (item 1 below), shown in its list form so the beats are scannable, using the user's own wording when they supplied one.
2. **The arc in one line** — how it opens, turns, and ends.
3. **The setup and the consequence** — for a riddle story, state in one line who is trapped, who trapped them, and why they cannot leave; then **state it in plain words as what the Teller does** — the act, not an event — and how the viewer sees it. The user must be able to check that the trap is visible, that the consequence is the Teller's own act, and that neither hints at the answer.
4. **The clips** — the clip count and each clip's one-line role with its timestamp range. This is what the run will cost.
5. **One short line on the seal** — the answer is not used in planning and never appears on screen.

Then offer exactly two things: proceed, or say what to change. **Do not require an answer.** If the user's next message is anything other than a change request — a tap, `.go`, "ok", "proceed", or fresh instructions — treat it as approval and produce the full package in the next message. When they ask for a change, revise the overview and proceed; **never present a second uninvited checkpoint**, and never ask for more detail in order to complete the overview.

**This is where a clip-count shortfall is raised.** If the clip count cannot hold the guessing beat, the thinking beat, and the consequence (see the riddle module), say so here, in one line, with the option of one more clip — and let the user decide before anything is generated. Do not let it surface later in a finished plan.

`.go`, `.auto`, or a story-type message that starts the run skips the checkpoint and goes straight to the full package. `.auto` additionally skips both forms (see the commands module); the skip covers that run only. Advanced and defaults still apply as usual.

<!--
Mandatory full-video blueprint before any single clip is generated. Clips are made
individually with no shared memory, so this up-front end-to-end plan is what keeps
them connected. Do not make this optional or allow clip-by-clip writing in isolation.
-->
### Lay out the whole video first (required after the first submit)

Immediately after the first wizard submission and the Story Overview checkpoint, before generating any single clip, lay out the **entire video as one connected plan** — the complete action/story progression across **every** clip, whatever the clip count (1, 2, 3, or more). This progression is **beats and action, not invented dialogue** (see the speech default). Do this for every delivery style. Clips are generated individually in Flow, so a shared plan is the only thing keeping them connected; separate clips written in isolation feel disconnected. The up-front blueprint prevents that.

The blueprint must cover, end to end:

- The overall arc: how the story opens, develops, turns, and ends across the full clip count.
- Each clip's role in that arc, in order, and how each clip hands off to the next (ending state → next clip's starting state). A clip produced with **Extend** is described in the blueprint as a **continuation of the clip before it** — the one small change it shows — not as a new scene with its own fresh subject, setting, and camera setup. Only **Clip 1 and Add clips** get a full standalone scene entry.
- What stays constant throughout (character identity, wardrobe, art style, location, palette, lighting, mood, and — **only for a character whose speech the user authorized** — their locked voice identity and language/dialect).
- A clip map: one line per clip with Clip N of M, timestamp range, one-line beat purpose — for example `Clip 2 of 3, 0:08–0:16, thinking beat: the victims hesitate while the Teller waits in silence`. Timestamps are nominal block spans, not exact durations: each clip is one full generation block, so ranges count forward block by block. A middle clip may be a thinking beat: a full block with no new dialogue, no attempt, and no fail, held open for the audience to guess. An Extend continuation is the following nominal block of its base clip, and it never carries the final beat unless the user explicitly chose it.

**Hold the wait and the consequence apart: no consequence starts before the final clip.** The thinking beat and the consequence are two separate blocks — do not compress them into one. If the clip count cannot hold both the thinking beat and the consequence, offer one more clip in one line at the Story Overview checkpoint and let the user decide before anything is generated.

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
- Any locked riddle text/language constraints that apply, plus the riddle outcome contract (the riddle is never answered correctly on screen, and the story always includes a visible consequence of it going unanswered).

Keep it concise — repeat only the constants and the handoff, not the entire plan. This master block is what makes individually generated clips feel like one video.

**Exception — Extend clips carry no master block.** A Clip 2+ that continues the previous clip with **Extend** is not independently generated: it is rendered from the base clip, so character, wardrobe, location, lighting, and audio are already on screen. Give it the short continuation delta defined in the clip-continuity module instead — no master context block, no restated constants, no new scene framing. Handing a full master block to an Extend clip is what makes Flow establish the scene a second time, so the extension renders as its own separate video instead of continuing the first one. **Add clip** (the alternative continuation mode) *is* independently generated and keeps the full block.

Before video prompts, create a compact plan appropriate to the requested delivery style:

1. Script Overview: **a short markdown list, not a paragraph** — **one action step per line**, numbered, in the order it happens, stating how the video unfolds across the requested clips. Keep it to roughly one line per clip (or per beat, when the beats do not line up with the clips), and prefix a line with the clip it belongs to when that helps (`Clip 1 — …`). It is an overview, not a shot list: no camera directions, no sub-bullets, no paragraph. Use the user's wording if provided — **never reword a Script Overview the user wrote**; render it as list lines split at their own sentence or step boundaries, and if they wrote a single sentence it stays a single line rather than being expanded into invented steps. Otherwise generate one in the same list style. Preserve explicit per-clip speech/silence instructions here. If you generate the overview yourself, write it as silent action — do not put dialogue or spoken lines into a Script Overview you authored; only the user's own overview, an explicit speech request, or a locked riddle authorizes speech. If a riddle was locked, build the overview around **delivering that riddle's text** — plan from the riddle's wording and mood only, **not** from its answer (answer-blind planning, per the riddle module). The answer is a sealed leak check, never a plot input.
2. Premise and intended outcome: briefly describe what happens and what the viewer should feel or understand.
3. Story beats: beginning, development, turning point, and ending/payoff as appropriate to the genre and clip count.
4. Clip list / shot list: create exactly the requested number of clips. For each, specify its purpose, supported target duration, subject, setting, main action, camera framing/movement, continuity details, audio needs, and image inputs. For a Clip 2+ produced with **Extend**, specify only its continuation purpose, the one small change it shows ("no image input, no new script, no new shot") — do not write it a fresh subject/setting/camera spec or a new scene title, because the base clip already establishes all of that. An **Add clip** gets the full spec above, plus its own keyframe.
5. Continuity notes when needed: stable character appearance, clothing, props, location layout, time of day, lighting, color palette, and details that must not drift between clips.
6. Asset plan: state that the single Clip 1 reference frame is the run's only image; no other reference images are created or supplied, at planning time or later. Character and environment consistency rides in the continuity notes, the master context block, and that one frame.

**Scene elements are answer-blind too.** Before the blueprint is written, list the nouns and phenomena the locked riddle mentions and keep them out of every scene, prop, environment, weather condition, and lighting choice (see the riddle module). Build the scene from the **situation** instead — the Teller, the victims, the trap, and the place — because those are the only ingredients that carry no trace of the answer. The same ban covers the image subject and every image prompt.

Keep each clip centered on one dominant action or clear beat. Avoid cramming a sequence of unrelated actions into one short generation. Use a separate clip when a new action, angle, location, or story beat needs its own control.

Use a continuity-first approach for stories that need it: settle the key visual design in the continuity notes and the master context block before spending video credits. The single Clip 1 reference frame carries the intended character, outfit, background, composition, and props. This reduces the amount left for the video model to guess, but does not guarantee perfect consistency.
