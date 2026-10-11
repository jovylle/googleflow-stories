<!--
WHY THIS SECTION EXISTS:
The riddle pre-phase runs BEFORE the main interview to set production language and
lock a riddle up front, so the whole story is built around a known answer. This
ordering (language first, then story-type) and the "every riddle is told in story
format" fixed structure are intentional invariants. Do not move this after the
interview or loosen the language-first / riddle-first sequencing.
-->
## 2. Riddle pre-phase (runs before the main form)

When the story maker starts (via `.start` or `gfs`), run this short pre-phase **before** opening the main interview form. It first sets the production language, then decides whether the story is a riddle and, if so, locks a riddle first so the rest of the production is built around a known answer. The language question applies to every story, riddle or not.

**At the very start, tell the user they can add material at any time.** Before the first question, show one short, friendly line letting them know they can attach reference images (character, product, location) to this session and add any extra notes at any point before proceeding — for example: "Tip: you can attach reference images and add notes anytime during this session before we proceed; I'll use them right away." Keep it to one line; do not repeat it on every turn.

In this project, **every riddle is told in story format**. The fixed structure is: the riddle is spoken **first**, then the story continues with either a silent beat where the audience is meant to answer, or another character who reacts but never answers correctly. Build every riddle story on this structure by default; do not leave it to the Script Overview to reinvent.

<!--
Language is asked first because it governs the entire production; the story-type
question routes riddle vs. non-riddle and must only trigger the own-vs-generate
follow-up for the Riddle story choice. Keep Tagalog as the preselected default.
-->
### Step 0: Language and riddle check

Ask these up front, as the very first questions, before the main form:

1. **Language** (ask this first). This sets the language for the **whole production** — the riddle text, any dialogue or spoken lines, and on-screen content where applicable. Offer common options and allow custom — for example English, Cebuano, Tagalog, or Other. **Default: Tagalog (preselected).** If the user picks another language, use their choice; if they do not pick but are clearly writing in another language, follow that instead. Carry this language through every clip and prompt.
2. **What kind of story are we making?** Present these choices together:
   - **Riddle story** → this is the only riddle path. If the user picks it, **then** ask a follow-up: do they *have their own riddle* or *want the generator to create riddles for them?*
     - *I have my own riddle* → the user pastes it. Accept it as the locked riddle, confirm its intended answer, and continue to the main form.
     - *Generate riddles for me* → run the riddle generator skill (Step 0a).
   - **AI Option A** → a concrete AI-suggested story idea (one-line pitch), generated on the fly.
   - **AI Option B** → a second, distinct AI-suggested story idea.
   - **AI Option C** → a third, distinct AI-suggested story idea.
   - **Other / custom story** → the user types their own story idea in free text; use what they type.

   Picking any AI option or "Other / custom story" means a **regular (non-riddle) story** — skip the rest of this pre-phase and open the main form, carrying the chosen idea into the Story-topic field so it is not re-asked. Generate the three AI options as short, varied one-line pitches in the chosen language; if the user asks for different suggestions, re-roll them. Only the **Riddle story** choice triggers the own-vs-generate follow-up above.

<!--
The generator must produce ACTUAL riddles, not themed noun-phrases. The hard rules
below define a riddle (indirect clues → one concrete ordinary answer), reject
abstract/genre "answers" (e.g. "hateful ghost", "monster doppelganger"), and apply
genre mood to the WORDING, not the answer (horror = eerie phrasing, ordinary answer
like shadow/mirror/clock). The simple-words, not-too-short, not-too-easy, and
spoken-duration rules keep riddles fair and clip-length — do not relax them. The
self-check at the end is a quality gate: drop any candidate whose answer is not a
real guessable thing. Added after a session produced non-riddles for horror.
-->
### Step 0a: Riddle generator skill

Generate a list of **5–10 candidate riddles** in the chosen language, each with its answer noted for the user.

**What a riddle actually is (enforce this).** A riddle describes a hidden answer **indirectly**, through clues, metaphor, or misdirection, so the listener has to *work out* an answer that is then obviously correct in hindsight. The answer must be a **single, concrete, ordinary thing** — an everyday object, natural phenomenon, body part, animal, or common concept (for example: shadow, echo, mirror, clock, candle, wind, footprints, a book). It is **not** a mood word, a genre label, or a vague scary/abstract noun.

- A valid riddle has: (1) a **setup** that describes the answer obliquely (often via personification or paradox — "has a face but no eyes"), (2) **fair clues** that point to exactly one answer, and (3) a **single clean answer** that is a real, nameable thing.
- **Reject non-riddles.** Do not output an entry whose "answer" is an abstract/undefined phrase like "monster doppelganger", "hateful ghost", "the darkness", or "evil" — these are themes, not answers. If a candidate's answer is not a concrete, guessable thing, discard it and generate another.

Quality rules:

- Use **simple, everyday words**. Avoid obscure or overly literary vocabulary.
- Do **not** make riddles too short. Each should have enough words to give fair, layered clues rather than a one-line giveaway.
- Avoid wording that makes the answer **too easy to guess** — no near-synonyms of the answer, no obvious direct naming of the thing.
- Keep each riddle self-contained and solvable from its clues, with **exactly one** sensible answer.
- **Fit the spoken duration.** Keep each riddle short enough to be spoken naturally within one clip of the selected model (roughly 16–24 words for an 8-second clip). If a strong riddle runs longer, note that it will need its own clip or a longer-duration model, per the pacing rules below.
- Note the answer beside each option so the user can judge quality.

**Genre and mood (including horror).** When a genre like horror, mystery, or fantasy is chosen, apply the mood to the **wording and imagery of the riddle**, not to the answer. The answer stays an ordinary concrete thing; the clues are what feel eerie, suspenseful, or whimsical.

- *Horror example (good):* answer = **shadow** → "I follow where you walk but make no sound, I grow tall at dusk and vanish in the dark. What am I?" The dread is in the phrasing; the answer is a plain object.
- *Horror example (bad):* answer = "hateful ghost" or "monster doppelganger" → rejected: the answer is an abstract theme, not a guessable thing.
- Good horror answers are ordinary things that *feel* uncanny when described obliquely: shadow, mirror, reflection, breath, heartbeat, footsteps, a clock ticking, a candle, a locked door, an empty chair, the wind, a photograph.

**Self-check before presenting.** For each candidate, silently confirm: the answer is one concrete ordinary thing, the clues point only to that thing, and a listener could plausibly guess it. Drop and replace any candidate that fails. Only present entries that pass.

Then:

- Present the numbered list and let the user **pick one**, **edit one**, or **re-roll** (`.reroll`) for a brand-new batch.
- The user may re-roll as many times as they like.
- When the user picks (or edits and confirms) a riddle, **lock it**: record the final riddle text, its answer, and the language. The locked **riddle text and wording** become the backbone of the Script Overview and clip plan. The **answer is recorded only as a sealed do-not-reveal guard** — it is a constraint checked at the end, never a design input that shapes the plot, visuals, or reactions. (See answer-blind planning below.)

<!--
Keeps planning tied to the locked riddle TEXT (which opens Clip 1), but makes the
ANSWER answer-blind: the plot/visuals are built from the riddle's wording and mood
only, never from the answer. This was added because building the plot around the
known answer made the model keep bending the story toward hinting or showing it.
The riddle text still comes first (Clip 1 speaks it); the answer is a sealed
end-of-plan leak check, not a design seed. Preserve exact riddle wording/language.
-->
### After the riddle is set

Carry the locked riddle into the main form and story plan. Apply the fixed riddle structure: the riddle is the **opening spoken line** (in Clip 1), followed by a silent beat for the audience to answer, or a character who reacts without answering correctly. Keep later clips consistent with this and preserve the riddle's exact wording and language.

**Answer-blind planning (build the plot from the riddle, not the answer).** Design the Script Overview, story arc, every clip's action, the imagery, and all character reactions using **only the riddle's wording, tone, and mood** — as if you did **not** know the answer. The entire plan must be derivable from the riddle text alone. Do **not** let the answer influence settings, props, visual motifs, character behavior, or shot choices; the answer must not "show through" the production. Treat the recorded answer as sealed: you consult it only in the leak check below, never while generating ideas.

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
- The silent beat is for the audience to guess; leave it unanswered. If a character reacts, they react without answering correctly.
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
- **Budget spoken lines to the clip duration.** At a natural pace, roughly 2–3 words per second — about 16–24 words fit in 8 seconds, 20–30 in 10 seconds, leaving headroom for breathing and framing. If a line will not fit, it needs its own clip, a longer-duration model, or a trim.
- **Analyze and suggest the clip count.** Before prompts, estimate how many clips the riddle and story actually need so nothing is rushed. Present the suggested clip count and the beat each clip carries. If it differs from the user's chosen clip count, explain why and let them accept, adjust, or override.
- **Suggest script changes to fit.** If a riddle or line is too long for a single clip, propose concrete options: split across clips, shorten/rephrase while preserving meaning and the no-answer-reveal rule, or recommend a longer-duration model (frame model suggestions as recommendations grounded in current support, not guarantees). Never silently rewrite a locked riddle — show the proposed change and get approval.
- **Keep good continuation.** When beats span multiple clips, each clip must start from the previous clip's ending state (subject position, expression, framing, lighting) so the sequence reads as one continuous moment. Provide a short bridge/continuity note between clips.
- **Clip count follows the riddle's actual length — do not preset "3 clips for riddles."** The number of clips is an **output of the word-count analysis above**, not a fixed template. Decide it like this:
  - **Short riddle that fits one spoken clip** (≈16–24 words for an 8s clip): the whole story can often be **1–2 clips** — the riddle delivery, and optionally a short think-beat/reaction that may share a clip. Do not inflate to 3 clips just because it is a riddle.
  - **Longer riddle, or when beats genuinely cannot share a clip without rushing:** spread across more clips so nothing is squashed — for example Clip 1 delivers the riddle, a following clip holds the silent think-beat, a further clip carries the reaction. This is the case the original squashed-riddle problem was about.
  - Always present the suggested count as a **recommendation tied to this specific riddle's length**, with the beat each clip carries, and let the user accept, adjust, or override. Never label a clip count "recommended for riddles" in general; only recommend a count because *this* riddle's words require it.
