# Spec — v2.41.0: the image-prompt trailer and the voice timbre slot

Two live-run defects from the same named failure class — **something fixed in prose
but with no mandated carrier in the actual prompt**: ChatGPT reads the rulebook once
and the prompt every time, so a rule that never reaches the prompt text is outvoted
by every nudge inside it.

## Live-run evidence (user-supplied transcripts)

1. **Storyboard-shaped images, twice** — a 6-panel sheet with numbered panels,
   `0:04` timestamp chips, per-panel captions, and a `Video Model: Veo 3 (Google Flow)`
   metadata bar — the plan rendered as an image. The pack's prose bans (v2.20's
   one-image rule, v2.27's text-only overview, the image-output-isolation
   constraint) were all present and all obeyed by the *prompts* — and the image
   models rendered the infographic anyway. The acceptance gate did reject the
   frames (it worked), but rejection alone keeps costing image credits and turns.
2. **A hardcoded deep male voice on a Teller that is not deep or male** — a small
   ash-gray shopkeeper (visually female-presenting) spoke with "an impossibly deep,
   inhuman male voice… ancient creature… thousands of years." The v2.21.0 vendored
   voice block carried its timbre as constants, overriding the locked Teller design
   that §2a explicitly frees ("Nothing fixes the Teller's shape"). ChatGPT's own
   hand-rolled repair ("VOICE IDENTITY — FEMALE SUPERNATURAL TELLER: distinctly
   feminine vocal identity despite its unnaturally low pitch") demonstrated the
   correct design in the wild: derive the timbre from the locked design, keep the
   delivery architecture.

## Fix A — the image-prompt trailer (module 07, §44)

Every image prompt ends with a fixed verbatim trailer ("One single frame of one
composed scene — a single shot. No storyboard, no panels, no numbered cards, no
grids, no timestamp chips, no captions, titles, watermarks, labels, or any text or
documentation in the image. Display no plan, no production notes.") — inside the
generation call, not in prose. Escalation when the shape returns anyway: regenerate
with the trailer repeated as the prompt's **opening** sentence; a second failure is
reported (never presented) with the copy-ready prompt offered for Flow-side
generation. Planned in-scene signage stays legal — the trailer kills layout text,
never planned props.

## Fix B — the voice timbre slot (module 08)

The block's template now reads `…speaks in [LANGUAGE] with [VOICE TIMBRE — filled
from the Teller's locked voice identity]`. The proven v2.21.0 deep-voice wording
survives **verbatim** as the default fill for an imposing, humanoid-scale, or
design-unspecified entity — nothing the user proved is lost. Every other Teller
gets a timbre written from its own design: a child speaks with an uncanny child's
voice, a female-presenting Teller with a deep supernatural female voice, a small
puppet with its own small voice. **Forcing the deep male timbre onto a locked
design that contradicts it is a checklist defect.** The delivery architecture
never varies: slow cadence, long ominous pauses (so the 12–16 words/8-second
budget holds for any timbre), the spatial surround, "not a normal human lowering
their voice", the negative tail, the verbatim line, the answer seal. New
**one-speaker rule**: the clip prompt names its speaker — the Teller — and every
victim stays silent (no speech, no lip-sync, no audible wrong answer).

## Answering "where is audio decided"

- **Voice timbre:** locked when the Teller design is locked (§2a), carried in the
  continuity notes as a locked voice identity, filled into the slot at prompt time.
- **Ambience/environment:** decided with the environment axis (§2a choice 5) and
  stated per clip in the prompt's audio line. The block after this fix *carries*
  those decisions instead of overriding them.

## Honest limits

The trailer's own history says it plainly: the first storyboard sheet here was the
second live run to produce one. The trailer is the strongest prompt-side tool there
is, and the gate escalation is real — but until a run proves the image tool honours
the trailer, assume occasional failure and keep the Flow-side fallback. The timbre
slot is verifiable in ChatGPT's printed prompt (look for `[VOICE TIMBRE]` filled
from the design), so that fix is far easier to confirm.

## Live follow-up (2026-10-17) — the trailer's first live test failed; root cause classified

The predicted failure arrived: an `.auto riddle` first-person-POV run generated its Clip 1
ingredient and the image tool returned **two invented storyboard sheets** — with the
trailer verbatim at the end of the prompt. The user's screenshots settle the class: the
sheets were not the planned scene gridded, they were **different stories entirely** —
English riddles (the run was Tagalog), invented answers printed in red ("A MIRROR",
"A CLOCK" — neither is the run's sealed answer), invented metadata ("CLIP COUNT: 8 clips",
"ASPECT RATIO: 16:9 (YouTube)" against a 9:16 two-clip run), zero scene elements (no
felt, no stairwell, no doll, no amber light), and a landscape canvas against a portrait
ask. One header did match the conversation's concept ("Horror Riddle (First Person POV)").

**Root cause:** the image tool composes from the conversation's *concept* plus its prior
of what "horror riddle storyboard" sheets look like — it does not execute the scene
prompt. No prompt-side wording can fix a render the prompt does not drive; that is why
the same class failed before the trailer (v2.41.0's two runs) and after it.

**What held:** the machinery did exactly what v2.41.0 shipped — two attempts, both
refused at the gate, nothing faked, the copy-ready prompt handed over with the Flow-side
fallback. The run lost nothing but two generations.

**What shipped (v2.44.0):** the Flow-first rule in module 07 — a first-person-POV
ingredient, or any shape that already returned a storyboard sheet this conversation, is
offered the Flow-side fallback first (the copy-ready prompt for Google Flow), at most one
in-chat attempt, the acceptance gate as the net. §44 +3 checks (638 / 0).
