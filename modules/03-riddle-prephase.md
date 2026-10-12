<!--
WHY THIS SECTION EXISTS:
This is Form 1 of 2 — the setup form that PRODUCES Form 2. It runs BEFORE the main
interview form to set production language and story type, and for a riddle story to
lock a riddle up front, so the whole story is built around a known answer. Three
invariants here are load-bearing: the language-first / riddle-first sequencing, the
"every riddle is told in story format" fixed structure, and the ONE-FORM rule — every
field below is presented together in a single form and submitted in one action, never
one question per turn, with no follow-up question afterwards. Asking these as a chain
of conversational questions is exactly what previously stretched the opening to ~8
turns (one field per turn, plus a confirmation card per riddle). Do not reintroduce
step-by-step asking, and do not add a question the form already answered.
-->
## 2. Form 1 of 2 — Setup (language, story type, riddle source)

**Form 1 of 2** — when the story maker starts (via `.start` or `gfs`), present this setup as **one form**, in a single message, submittable in one action. Submitting it **produces Form 2** — the main interview form. Never ask these questions one at a time in prose, never split them across turns, and never follow up with another question afterwards: every answer this phase needs is a field inside the form. The language field applies to every story, riddle or not.

**At the very start, tell the user they can add material at any time.** Before the first question, show one short, friendly line letting them know they can attach reference images (character, product, location) to this session and add any extra notes at any point before proceeding — for example: "Tip: you can attach reference images and add notes anytime during this session before we proceed; I'll use them right away." Keep it to one line; do not repeat it on every turn.

In this project, **every riddle is told in story format**. The fixed structure is: the riddle is spoken **first**, then a silent beat where the audience is meant to answer, **and** a character who attempts it and fails. Build every riddle story on this structure by default; do not leave it to the Script Overview to reinvent.

**The default riddle story is a horror scene with two sides.** Unless the user asks for something else, build every riddle story this way — it is the shape that keeps the riddle mysterious and gives the failure a price:

- **Genre: horror by default.** A riddle story defaults to Horror (see the defaults module). The dread comes from the situation and the Teller, never from the answer, and the answer stays an ordinary concrete thing.
- **A Teller, who owns the rule.** One entity — a presence, a figure at the edge of the light, a voice from behind a door — **holds the victims where they are** and **poses the riddle to them**. The Teller set the condition: answer it and you may go; fail and the Teller takes its price. Design the Teller once and keep it as consistent as any other character. The Teller is never the answer and never a visual stand-in for it.
- **The victims, who cannot leave.** One or more **small, cute, vulnerable** characters — a little creature, a small animal, a child — the ones the audience worries about. Keep them small and soft rather than fearsome; this is what the Character field offers for a riddle story.
- **The trap is shown, not implied.** The victims are **blocked, trapped, cornered, caged, cut off, or have the way sealed behind them** — a situation they genuinely cannot run from. Establish it visually before the riddle lands: the audience has to *see* that escaping is not an option, or the failure costs nothing. Pick whichever trap suits the setting; the requirement is that it is visible and that there is no way out.
- **They always fail, and the Teller acts.** The victims attempt the riddle and fail — wrong, giving up, or unable to answer. **The consequence is the Teller's act, not an event in the world**: it takes something, claims one of them, seals the way for good, snuffs the light, marks them, or turns away and leaves them there. Because the price comes out of the Teller's own rule, it can carry no trace of the answer.
- **No tips and no clues — ever.** Nothing in the video helps the audience or the victims toward the answer: no hint dropped by the Teller, no emphasized or glowing prop, no scenery that echoes the answer, no character noticing the right thing, and no on-screen text. The riddle is the only thing the audience gets.

<!--
Riddle outcome contract: the riddle is NEVER solved on screen and the story ALWAYS
shows a consequence of that. Both halves are hard requirements, not options — a story
where someone answers correctly, or where nothing is lost, is not a valid riddle
story. The consequence must stay answer-blind: it dramatizes the failure to solve, it
never encodes the solution. Keep the user-requested reveal exception (below) as the
only override.
-->
### The riddle outcome (fixed for every riddle story)

**The riddle is never answered correctly on screen.** No character lands the answer, no on-screen text gives it away, and the audience is never handed a solution. The story shows the attempt and the failure: a character guesses and is wrong, gives up, cannot answer, or says something that is not the answer. This is an **and**, not an either/or — every riddle story needs the silent guessing beat **and** at least one visible failed attempt. A story in which someone answers correctly is not a valid riddle story.

**A visible consequence is always included.** Every riddle story must show a consequence of the riddle going unanswered — the failure to solve it costs something the audience can see: a loss, a change, a danger, a price paid, an opportunity gone. The consequence is a story beat, never a clue. It must come from the **Teller's rule and the situation**, never from what the riddle describes. It must not reveal, hint at, depict, or be reverse-engineerable into the answer; after it lands, a viewer must still be unable to deduce the answer from the video. Put it in the story's later beats rather than the opening clip, and let it land through action and imagery rather than dialogue that explains it.

**A consequence that dramatizes what the riddle's wording describes is a leak, not a payoff, because it depicts the answer's own description.** A riddle describes its answer, so an event built out of the riddle's words is an event built out of the answer. A riddle that says its answer climbs to the sky and makes water pour must **not** be followed by rain, a flood, a storm, a dark sky, or a washed-out bridge — that is the answer, dramatized. This is exactly why the consequence comes from the Teller instead: the Teller's own act — taking something, sealing the way, leaving them where they are — carries no trace of the riddle's subject.

The only exception is a user-requested reveal clip (see the no-answer-reveal rule).

**If the clip count cannot hold both the guessing beat and the consequence, do not drop either silently.** When the chosen or analyzed clip count leaves no room for a separate consequence beat — for example a two-clip story whose second clip is already the silent guessing beat — fold the consequence into the final moment of that beat, or tell the user in one line that one more clip would let the consequence land properly and let them decide. Never silently ship a riddle story with no consequence, and never resolve the conflict by letting a character answer the riddle. The consequence is the final beat: no consequence starts before the final clip, and the thinking beat is never skipped or merged into it.

<!--
Language is asked first because it governs the entire production; the story-type
question routes riddle vs. non-riddle; the riddle-source field replaces what used to
be a separate follow-up question so the whole setup fits ONE form. Keep Tagalog as
the preselected default.
-->
### Step 0: the Form 1 fields

**All three fields, in this one form:**

1. **Language** (listed first). This sets the language for the **whole production** — the riddle text, any dialogue or spoken lines, and on-screen content where applicable. Offer common options and allow custom — for example English, Cebuano, Tagalog, or Other. **Default: Tagalog (preselected).** If the user picks another language, use their choice; if they do not pick but are clearly writing in another language, follow that instead. Carry this language through every clip and prompt.
2. **What kind of story are we making?** Present these choices together in the same form:
   - **Riddle story** → this is the only riddle path; it pairs with field 3.
   - **AI Option A** → a concrete AI-suggested story idea (one-line pitch), generated on the fly.
   - **AI Option B** → a second, distinct AI-suggested story idea.
   - **AI Option C** → a third, distinct AI-suggested story idea.
   - **Other / custom story** → the user types their own story idea in free text; use what they type.
3. **Riddle source** — always shown in the same form, with one short line beside it noting it applies only when **Riddle story** is chosen:
   - *I have my own riddle* → the user pastes it.
   - *Generate riddles for me* → run the riddle generator (Step 0a).

**On submit, route once — then open Form 2. Do not ask anything the form already answered.**

- **AI Option A/B/C, or Other / custom story** → a **regular (non-riddle) story**. Skip the rest of this phase and open Form 2, carrying the chosen idea into the Story-topic field pre-filled so it is not re-asked. Generate the three AI options as short, varied one-line pitches in the chosen language; if the user asks for different suggestions, re-roll them.
- **Riddle story + I have my own riddle** → accept the pasted riddle as the locked riddle and **lock it immediately**. If the user did not state its intended answer, ask for the answer in **one short line** — the only extra question this phase permits. Then open Form 2.
- **Riddle story + Generate riddles for me** → run Step 0a, present the candidate list once, and let the user's single pick lock the riddle. Then open Form 2.

Never re-confirm an answer that arrived with the form (language, story type, riddle source), and never ask for confirmation of a choice the user already made by choosing it.

<!--
The generator must produce ACTUAL riddles, not themed noun-phrases. The hard rules
below define a riddle (indirect clues → one concrete ordinary answer), reject
abstract/genre "answers" (e.g. "hateful ghost", "monster doppelganger"), and keep
generation neutral (no genre mood in wording or answer — ordinary answer like
shadow/mirror/clock, plain clues; mood lives in delivery). The simple-words, not-too-short, not-too-easy, and
spoken-duration rules keep riddles fair and clip-length — do not relax them. The
self-check at the end is a quality gate: drop any candidate whose answer is not a
real guessable thing. Added after a session produced non-riddles for horror.
-->
### Step 0a: Riddle generator skill

Generate a list of **5–10 candidate riddles** in the chosen language, each with its answer noted for the user.

**What a riddle actually is (enforce this).** A riddle describes a hidden answer **indirectly**, through clues, metaphor, or misdirection, so the listener has to *work out* an answer that is then obviously correct in hindsight. The answer must be a **single, concrete, ordinary thing** — an everyday object, natural phenomenon, body part, animal, or common concept (for example: shadow, echo, mirror, clock, candle, wind, footprints, a book). It is **not** a mood word, a genre label, or a vague scary/abstract noun.

- A valid riddle has: (1) a **setup** that describes the answer obliquely (often via personification or paradox — "has a face but no eyes"), (2) **fair clues** that point to exactly one answer, and (3) a **single clean answer** that is a real, nameable thing.
- **Reject non-riddles.** Do not output an entry whose "answer" is an abstract/undefined phrase like "monster doppelganger", "hateful ghost", "the darkness", or "evil" — these are themes, not answers. If a candidate's answer is not a concrete, guessable thing, discard it and generate another.
- **Generate every candidate neutrally, as if no story exists yet.** At generation time, assume no genre, no setting, no characters, and no Teller, and do not let the chosen story type, its context, or the surrounding conversation shape the riddle's wording or answer. A generated riddle is always an ordinary thing described by clues drawn from the thing itself, with no dread, no scare, and no reference to how it will be told or who will speak it. Mood belongs only to the story that delivers the riddle: the delivery, the voice, the scene, and the situation, never the riddle's text or its answer. This applies to riddles **you generate**; a riddle the user supplies is preserved exactly as written.

Quality rules:

- Use **simple, everyday words**. Avoid obscure or overly literary vocabulary.
- Do **not** make riddles too short. Each should have enough words to give fair, layered clues rather than a one-line giveaway.
- Avoid wording that makes the answer **too easy to guess** — no near-synonyms of the answer, no obvious direct naming of the thing.
- Keep each riddle self-contained and solvable from its clues, with **exactly one** sensible answer.
- **Fit the spoken duration.** Keep each riddle short enough to be spoken naturally within one clip of the selected model (roughly 16–24 words for an 8-second clip at a normal speaking pace). **A horror riddle is delivered in the Teller's voice, which is slow and pause-heavy** — see the supernatural Teller voice block in the video-prompt module — so budget **roughly 12–16 words per 8-second clip** for it. If a strong riddle runs longer, note that it will need its own clip or a longer-duration model, per the pacing rules below.
- **Do not end the riddle with "Ano ako?"** — or any equivalent first-person self-question, in any language. The riddle is **recited by a character to an audience**, so a closing "What am I?" makes the speaker sound like they are describing *themselves*, and it breaks the story: a listener who is supposed to attempt an answer cannot do so sensibly when the person asking has just claimed to be the thing. Write the whole riddle so it works as a challenge **posed to the listener**. End on the final clue, or at most close with an impersonal question about the thing ("Ano ito?" / "What is it?") — never a first-person one. This applies to riddles **you generate**; a riddle the user supplies is preserved exactly as written, even if it ends that way.
- **Write the riddle so the reciter is never the "I".** The Teller speaks the riddle aloud to the victims, so any first-person line makes the Teller sound like it is describing *itself* — a cloud riddle recited in the first person tells the audience that the Teller is the cloud. Phrase generated riddles **impersonally** instead, so the riddle is obviously *about something else* and the speaker is obviously asking rather than confessing: "May isang bagay na…" / "There is a thing that…". A first-person riddle is acceptable only when the scene makes it unmistakable that it is quoted from something other than the speaker — read off a note, a sign, or a page, or repeated as an old rhyme — with that framing visible.
- Note the answer beside each option so the user can judge quality.

**Genre and mood (including horror).** A riddle story defaults to **horror** (see the default structure above): the dread lives in the situation, the Teller, and the delivery, never in the answer. When a genre such as horror, mystery, or fantasy is chosen, none of its mood reaches the riddle text: generate the riddle neutrally under the neutrality rule, and spend the genre entirely on how the riddle is delivered and on the scene it is spoken in.

- *Horror example (good):* answer = **shadow** → "It follows where you walk but makes no sound, it grows tall at dusk and vanishes in the dark. Ano ito?" The dread is in the delivery; the answer is a plain object.
- *Horror example (bad):* answer = "hateful ghost" or "monster doppelganger" → rejected: the answer is an abstract theme, not a guessable thing.
- Good answers are ordinary things described from the thing itself: shadow, echo, mirror, clock, candle, wind, footprints, a book. Do not reach for objects chosen because they feel uncanny — the eeriness belongs to the delivery, never to the answer.

**Self-check before presenting.** For each candidate, silently confirm: the answer is one concrete ordinary thing, the clues point only to that thing, a listener could plausibly guess it, and the riddle does **not** end in a first-person self-question such as "Ano ako?". Drop and replace any candidate that fails. Only present entries that pass.

Then:

- Present the numbered list **once**, as a single one-tap pick list. Selecting a number **locks it in that same single action** — the pick and the lock are one step, not two.
- **Always show the re-roll affordance in the same message as the pick list.** The list is not only the candidates: it states, in one short line in the production language, that the user can ask for a fresh batch — for example "I-reply ang `.reroll` para sa bagong batch ng mga bugtong." The `.reroll` reply-command is the path that must always work. If (and only if) the interface renders ChatGPT's interactive UI components, add the optional button as a progressive enhancement that issues that same turn — for example `<button onClick={() => GenUI.issueNewTurn(".reroll")}>Reroll riddles</button>` — following the same optional-buttons convention as the output-format module; never depend on the button rendering. **Re-present the affordance every time the list is shown**, including after a re-roll: it must never appear only on the first list, and must never be dropped just because a list already exists in the conversation.
- **On an `.auto riddle` run with no pasted riddle, generate one candidate that passes the riddle rules and self-check before locking it.** Apply every hard rule above (a concrete answer, fair clues, the spoken-duration budget, no first-person close for generated riddles), record its answer sealed, and lock it in that same single action. Then state the re-roll path in one short line in the production language — for example "I-reply ang `.reroll` para sa bagong locked riddle." — so the affordance survives without the pick list. `.reroll` after an auto-lock replaces the locked riddle with one fresh candidate under the same rules.
- Because the pick *is* the lock, **do not show a confirmation card, do not re-list the candidates, and do not ask the user to confirm a riddle they already picked.** Removing the confirmation card does **not** mean removing the edit and re-roll affordances — they used to live on that card, so they now belong to the pick list itself. Confirmation is required **only** when the user edits the text: show the edited wording once for a yes/no, then lock it.
- The user may **edit** a riddle or re-roll (`.reroll`) for a brand-new batch as many times as they like, before picking. **A re-roll means a genuinely fresh batch** — different riddles, not the previous ones reordered or lightly reworded — generated under the same language and the same hard rules above, then presented again with the re-roll affordance.
- On lock, record the final riddle text, its answer, and the language. The locked **riddle text and wording** become the backbone of the Script Overview and clip plan. The **answer is recorded only as a sealed do-not-reveal guard** — it is a constraint checked at the end, never a design input that shapes the plot, visuals, or reactions. (See answer-blind planning below.)
- Locking a riddle is the last thing this phase does: **immediately open Form 2.** Do not insert a recap, a status line asking for another confirmation, or any other turn between the lock and Form 2.

<!--
Keeps planning tied to the locked riddle TEXT (which opens Clip 1), but makes the
ANSWER answer-blind: the plot/visuals are built from the riddle's wording and mood
only, never from the answer. This was added because building the plot around the
known answer made the model keep bending the story toward hinting or showing it.
The riddle text still comes first (Clip 1 speaks it); the answer is a sealed
end-of-plan leak check, not a design seed. Preserve exact riddle wording/language.
-->
### After the riddle is set

Carry the locked riddle into the main form and story plan. Apply the fixed riddle structure and the riddle outcome contract above: the riddle is the **opening spoken line** (in Clip 1), followed by a silent beat for the audience to guess, then at least one character who attempts it and fails, and the story always includes a visible consequence of the riddle going unanswered. Keep later clips consistent with this and preserve the riddle's exact wording and language.

**Answer-blind planning (build the plot from the riddle, not the answer).** Design the Script Overview, story arc, every clip's action, the imagery, and all character reactions using **only the riddle's wording and tone** — as if you did **not** know the answer. The entire plan must be derivable from the riddle text alone. Do **not** let the answer influence settings, props, visual motifs, character behavior, or shot choices; the answer must not "show through" the production. Treat the recorded answer as sealed: you consult it only in the leak check below, never while generating ideas.

**Final leak check (consult the answer once, at the end).** After the plan and each clip/image prompt are drafted, review them **once** against the sealed answer purely to confirm nothing reveals or hints at it — no spoken line, on-screen text, caption, prop, visual motif, or reacting character gives it away. If anything leaks, revise that specific element so the plan again stands on the riddle text alone. This is the only point the answer is used; it is a check, not a prompt.

<!--
Critical content rule: the riddle answer must never leak to the viewer. This is a
hard constraint enforced again in later modules/checklist. Do not weaken any bullet
here; the recorded answer is for internal planning only.
-->
### No-answer-reveal rule (riddle stories)

For any riddle story, **never reveal or hint at the answer** in the video output:

- Do not state, spell, imply, or visually depict the answer in any clip's spoken lines, on-screen text, captions, or imagery.
- Do not add clues beyond the riddle's own wording that would make the answer easy to deduce. Reacting characters must not accidentally give it away.
- **Never add a tip or a clue.** Nothing may help the audience or the victims toward the answer: no hint or nudging line from the Teller, no emphasized, glowing, or lingering prop, no scenery or weather that echoes the answer's domain, no character conveniently noticing the right thing, and no caption, subtitle, or on-screen text. An audience that cannot deduce the answer from the riddle alone must still not be able to deduce it from the video.
- **The riddle's own words are off-limits as scene material.** Because the riddle describes the answer, anything the riddle names *is* the answer's description, so it must not appear as scene, prop, environment, weather, lighting, image subject, or image prompt. Before planning, list the nouns and phenomena the locked riddle mentions and keep every one of them out. If a scene seems to need one, change the scene — never the riddle. The story may take the riddle's **mood**, never its nouns. Worked example from a real failing run: a riddle whose answer is a cloud says "sky", "sun", and "water may pour" — so the scene may contain no sky, no sun, no rain, and no flood; a dark sky or a washed-out bridge would hand the answer straight to the audience.
- The silent beat is for the audience to guess; leave it unanswered, and never let a character answer correctly. If a character reacts, they guess wrong, give up, or cannot answer.
- The story still needs its consequence beat (see the riddle outcome contract): the unanswered riddle must cost something visible. The consequence must not reveal, hint at, or depict the answer, and must not be a clue dressed as a plot beat.
- The internal answer is recorded only to guide planning and keep the team consistent — it is never surfaced to the viewer.
- If the user explicitly asks for a reveal clip, confirm first, then treat that as an intentional exception for that specific clip only.

<!--
Prevents the model from rushing by capping one dominant beat per clip and budgeting
spoken words to the model's max duration. These numeric budgets (≈2–3 words/sec,
16–24 words per 8s) and the analyze-and-suggest clip-count behavior are intentional;
do not hard-code a fixed split or let the system silently rewrite a locked riddle.
IMPORTANT: the clip count is DERIVED from the specific riddle's length — never a
blanket "3 clips recommended for riddles." A short riddle may be 1-2 clips; only a
long riddle that cannot fit one clip is spread into more. This was tightened after
the model kept presetting "3 clips (recommended for riddle)" in the form regardless
of riddle length. Do not reintroduce a fixed riddle=3 template.
-->
### Pacing and clip-count planning (flexible)

A single clip is bound by the selected model's maximum duration (for example, Veo 3.1 Lite caps at 8 seconds). Cramming several beats into one clip makes the model rush — a character blurting the whole riddle, a pause, and a reaction squashed into 8 seconds. Prevent this by planning pacing before writing prompts. Do not force a fixed split; analyze and recommend.

Rules:

- **One dominant beat per clip.** A beat is one unit of action or story moment — speaking the riddle, the silent think-pause, or the reaction are each separate beats. Do not put more than one dominant beat in a clip.
- **Budget spoken lines to the clip duration.** At a natural pace, roughly 2–3 words per second — about 16–24 words fit in 8 seconds, 20–30 in 10 seconds, leaving headroom for breathing and framing. **A horror riddle is not at a natural pace**: its Teller voice is slow, deliberate, and full of long pauses, so budget roughly **12–16 words per 8-second clip** for it — the 16–24 figure applies to ordinary narration only. If a line will not fit, it needs its own clip, a longer-duration model, or a trim.
- **Analyze and suggest the clip count.** Before prompts, estimate how many clips the riddle and story actually need so nothing is rushed. Present the suggested clip count and the beat each clip carries. If it differs from the user's chosen clip count, explain why and let them accept, adjust, or override.
- **Suggest script changes to fit.** If a riddle or line is too long for a single clip, propose concrete options: split across clips, shorten/rephrase while preserving meaning and the no-answer-reveal rule, or recommend a longer-duration model (frame model suggestions as recommendations grounded in current support, not guarantees). Never silently rewrite a locked riddle — show the proposed change and get approval. **For a locked horror riddle whose heavy-voice delivery will not fit its clip, present these options before generating** — an approved trim, delivery across two clips, or a longer-duration model — and never squeeze the recitation to make it fit.
- **Keep good continuation.** When beats span multiple clips, each clip must start from the previous clip's ending state (subject position, expression, framing, lighting) so the sequence reads as one continuous moment. Provide a short bridge/continuity note between clips.
- **Clip count follows the riddle's actual length — do not preset "3 clips for riddles."** The number of clips is an **output of the word-count analysis above**, not a fixed template. Decide it like this:
  - **Short riddle that fits one spoken clip** (≈16–24 words for an 8s clip): the whole story can often be **1–2 clips** — the riddle delivery, and optionally a short think-beat/reaction that may share a clip. Do not inflate to 3 clips just because it is a riddle.
  - **Longer riddle, or when beats genuinely cannot share a clip without rushing:** spread across more clips so nothing is squashed — for example Clip 1 delivers the riddle, a following clip holds the silent think-beat, a further clip carries the reaction. This is the case the original squashed-riddle problem was about.
  - Always present the suggested count as a **recommendation tied to this specific riddle's length**, with the beat each clip carries, and let the user accept, adjust, or override. Never label a clip count "recommended for riddles" in general; only recommend a count because *this* riddle's words require it.
