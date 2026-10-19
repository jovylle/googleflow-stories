# Flow Riddles (FR)

Standalone instructions for **English riddles** told through short Google Flow horror stories. The riddle is the main product. The story, voice, and acting exist to make the audience listen, guess, and feel the cost of a failed answer.

Send `FR` or `.fr` to make one complete riddle story in one response. Do not show forms, candidate lists, or approval rounds. Follow extra details supplied with the command.

## Riddle log

Notion: [Flow Riddles — Riddle Log](https://app.notion.com/p/c4cdd54b3c2c44e0bdfe023e4bb97af0). One row represents one riddle chosen for a story. It stores the exact **Riddle**, **Answer**, **Answer Family**, **Stage** (`Chosen` or `Done`), **Chosen On**, **Done On**, optional **Flow Link**, and **Notes**. The **Done Riddles** view shows only finished videos; **All Riddles** includes chosen riddles too.

Before choosing a new riddle, read the log when the Notion connection is available. Reject an exact repeat and any answer already present under the same answer family, whether its row is Chosen or Done. Check the riddle's meaning too: a reworded riddle with the same clues and answer is still a repeat. After locking a fresh riddle, create one row with `Stage = Chosen` and the current `Chosen On` date; do not create duplicate rows after retries. Change it to `Done` and set `Done On` only when the user says the video is finished, and add its Flow link when supplied. If Notion access is unavailable, use the visible conversation to avoid repeats and state briefly that the new riddle was **not logged**; never claim a database check or write that did not happen.

## Choose one excellent English riddle

Privately draft at least three candidates from different ordinary answer families. Select the strongest candidate only after these checks:

1. **One real answer.** The answer is a familiar, concrete, nameable thing. At least two true, indirect clues lead to it. Reject any riddle with another equally plausible answer, a false clue, or a near-synonym giveaway.
2. **Natural English.** The wording is easy to say aloud and the wordplay works in English itself. Reject awkward translations, obscure vocabulary, and generic lines that could describe dozens of objects.
3. **Neutral wording.** No ghost, curse, threat, or scene detail is used to make the riddle sound scary. Horror belongs to the performance. A generated riddle never makes the Teller sound like the answer by saying “I am…”, and never ends with “What am I?”
4. **Spoken fit.** Favor about 12–16 words for one 8-second clip with the Teller's slow delivery and pauses. Count the actual words and leave room to breathe. If the user's supplied riddle runs longer, give it more spoken time; preserve their wording exactly.
5. **Novelty.** Reject answer families and clue structures already used in the Notion log or visible conversation. Do not repeatedly fall back to the same famous riddle objects.

Keep the chosen answer private. Never put it in a Flow video prompt, image prompt, visible prop, scenery, gesture, subtitle, victim guess, or consequence. The exact riddle appears in the video prompt only as the Teller's spoken line. If the user asks for the answer, provide it separately.

## Let the acting serve the riddle

Choose a fresh, coherent horror situation that does not illustrate the answer. Default to three 8-second clips:

1. **Challenge:** Show why the victims cannot leave. The Teller speaks the exact English riddle **once**, clearly and slowly. Its movement is controlled so the clues remain intelligible.
2. **Thinking and failure:** Hold a genuine silent interval for the viewer to guess. Then a victim visibly tries and fails or gives up, using a specific action rather than generic fear. Do not invent a spoken guess or show a clue.
3. **Price:** The Teller performs one visible act. The victims pay, and their reaction makes the loss clear. The price follows the Teller's rule, never the answer or the riddle's imagery. Nobody solves the riddle on screen.

Keep the Teller and victims distinct and visually consistent. Vary their forms, scale, setting, trap, camera, style, and consequence across runs. Give each clip one dominant beat and filmable gestures. Add clips when a supplied riddle needs more time; never squeeze out the silent guess, failed attempt, or consequence.

## Deliver at once

Print the chosen riddle and a short three-clip beat map, then **every complete, copy-ready Google Flow video prompt** in its own code block. Each prompt includes duration, visual action, camera, continuity, audio, and ending state. Clip 1 includes the exact riddle and supernatural English Teller voice; later clips contain no invented dialogue. Provide a separate one-shot Clip 1 reference-image prompt with no answer clue. If image generation is available, show all text before requesting one image so the prompts are never withheld by the image response. These are production prompts, not rendered video clips.

Before delivery, verify the riddle is fair, fresh, natural, and timed; the answer remains sealed; the viewer has time to guess; a victim fails visibly; the Teller acts; and the victims pay.
