# Investigation: the model invents dialogue and makes characters speak when no script is given (fix v2.11.9)

Branch: `dev` · version **2.11.9** · built on the merged Extend fix (v2.11.8)

## Reported symptom

In a live run, when the user supplies **no script**, the model writes its **own** dialogue
and the on-screen character **speaks** — even though nothing asked for speech. The trigger
is a premise that *implies* speech (for example "a teacher explains…", "a vlogger talks
about…", "a grandmother tells a story").

## Evidence

A behavioral A/B on the **pre-fix** build (v2.11.8) reproduced it verbatim.

- **Reproducer (old build).** Prompt: *"a teacher explains photosynthesis to her class"*,
  no user script. The model reasoned: *"a teacher who **'explains'** implies she
  **speaks**, so I wrote a short Tagalog spoken line for Clip 1"*, set `Audio |
  Model-generated · teacher speaks Tagalog`, locked a voice identity, and emitted
  `Maya speaks one line in warm, clear Tagalog: "Ang photosynthesis ay …"`. Full
  transcript: `specs/evidence/ab-old-2.11.8-speech.md`.
- **Control (old build).** A non-speaking premise (*"two old friends meet at a coffee
  shop"*) stayed **ambient-only** — the model even offered to add a line but did not invent
  one. Transcript: `specs/evidence/ab-old-2.11.8-speech-control.md`. So the defect is
  **premise-dependent**, not universal — which is why a naive repro can miss it.

## Root cause

The instruction set's silence policy was stated in one place as *prompt wording*, while
several other rules let the model **infer or grant** speech:

1. **The default audio option authorized speech.** `04-interview.md:86` and
   `15-defaults.md:37` set the default to **"The model generates the audio too"**; the
   explicitly silent option ("ambient sound only/no speech") was only an *alternative*.
   On the fast path (user never opens Advanced) the default reads as permission to speak.
2. **The Script Overview loophole.** `08-video-prompt.md:42` permits speech when it is
   *"clearly included in the script overview."* But when the user leaves Script Overview
   blank, **ChatGPT writes it itself** (`04-interview.md:43`, `05-story-planning.md:48`).
   Nothing stopped the model's own generated overview from containing spoken lines — so it
   could author speech and then cite its own text as authorization.
3. **The voice-identity rule assumed speech was "in play."** `04-interview.md:63` and
   `05-story-planning.md:26,40` said "if a character speaks or narrates… lock that
   character's voice identity" — with no gate requiring the **user** to have authorized
   speech. Locking a voice reinforces that dialogue is expected.
4. **Nothing forbade inferring speech from a premise verb.** The no-speech rule lived only
   in `08-video-prompt.md:32-42`, framed as prompt wording; no rule said "a premise that
   *describes* speaking does not authorize it."

The teacher run exposes the exact mechanism: the model treated the premise verb
*"explains"* as implicit authorization, wrote a line, and locked a voice.

## Fix — one rule, enforced at every layer

> **Default: characters do not speak.** Speech happens only when the user supplies a
> script/dialogue or explicitly asks for it (a locked riddle counts as supplied speech for
> the clip that delivers it). The model must **never invent** dialogue, and a premise that
> merely *describes* speaking ("explains", "tells", "talks") does **not** authorize it. A
> ChatGPT-generated Script Overview never authorizes speech.

| Module | Change |
|---|---|
| `04-interview` | New **"Speech default (important)"** block up top. Generated Script Overview is **silent action only**. Voice identity **gated** on authorized speech. Default audio option changed to **"Ambient audio only — no speech"**, with "let characters speak" now the opt-in alternative. |
| `05-story-planning` | Blueprint is "beats and action, **not invented dialogue**". Voice-identity bullets scoped to characters **whose speech is authorized**. Generated Script Overview is silent action only. |
| `08-video-prompt` | Master audio rule gains an explicit line: do not invent dialogue to fill a scene; a self-generated Script Overview does **not** authorize speech. |
| `15-defaults` | Default dialogue/audio is **ambient-only, no speech**; generated Script Overview is silent. |
| `16-checklist` | New gate: **"No invented speech"** — no dialogue/narration/voiceover unless the user supplied or requested it. |
| `10-clip1-final` | Blueprint wording: "complete action/story progression — beats, not invented dialogue". |

## Verification

- `./build.sh` → version **2.11.9**, 19 modules, 1057 lines; `build/` **in sync**.
- Compiled artifact contains the new rules (`Speech default`, `Ambient audio only — no
  speech` ×2, `No invented speech`, `silent action only` ×2).
- No automated tests exist in this repo (reverse spec §4), so verification is build-sync +
  content review + the behavioral A/B below.

### Behavioral A/B (same model, two builds, no shared context)

Method: each compiled build was handed to the *same* model (`deepseek-v4.1-flash` via
`opencode-go`, one-shot session) as the project Instructions, with an identical prompt:
a non-riddle, **no user script**, speech-tempting premise ("a teacher explains
photosynthesis to her class").

| | v2.11.8 (pre-fix) | v2.11.9 (fix) |
|---|---|---|
| Audio default chosen | `Model-generated · teacher speaks Tagalog` *(invented)* | `Ambient only — no speech` |
| Spoken line | **Yes** — `"Ang photosynthesis ay …"` written into the Clip 1 prompt | **None** — prompt says "no speech — ambient classroom audio only" |
| Voice identity | Locked ("female, warm and clear, Tagalog") | Not created |
| Behaviour on the premise | Treated "explains" as authorization to speak | **"Speech heads-up (default is silent)":** premise implies speech → offers an `add dialogue` opt-in instead of inventing |

Transcripts: `specs/evidence/ab-old-2.11.8-speech.md` and
`specs/evidence/ab-new-2.11.9-speech.md`.

Reading: the pre-fix build invented a line and a voice from a premise verb alone; the
post-fix build stays silent by default and makes speech an explicit opt-in. The defect
lived in the instructions, not one model's mood — the pre-fix run reproduced it on a
different model than the reporter's.

### Manual test plan (ChatGPT, after pasting the new build)

1. Non-riddle story, **no script**, speech-tempting premise ("a teacher explains X to her class").
2. Expect: blueprint is silent/ambient; if the premise implies speech, **one** explicit offer to add dialogue — no spoken line unless you opt in.
3. Supply your own script → speech **is** used and a voice identity is locked.
4. Riddle story → the riddle is still spoken in its clip (unchanged; a locked riddle counts as supplied speech).

## Still open

- **Model variance:** the proxy model reproduced the defect; ChatGPT's model may vary. The manual test plan confirms it on the real surface.
- Reverse-spec **F5/F6** remain open (P3) from the earlier audit.
