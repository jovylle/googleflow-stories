# Reverse-Engineered Specification: Google Flow Story Maker

> **Analyzed:** 2026-10-10 · **Branch:** `dev` · **Version at analysis:** 2.11.6 (F1–F4 patched in 2.11.7, F7 in 2.11.8, F8 in 2.11.9, interview split in 2.12.0)
> **Current at reading:** 2.12.0 — the `file:line` citations below are from the analyzed version and drift as modules change; verify by content, not by line.
> **Method:** spec-miner (code-evidence grounded). Every observation cites a `file:line`.
> **Status:** Observed facts vs. inferences are separated; contradictions are listed under Findings.

---

## 1. Overview

This repository is **not an application** — it is a *content compiler*. It authors a
ChatGPT "Project" instruction set as 19 small Markdown modules, concatenates them into
one file, and stamps a version. The compiled file turns a ChatGPT project into a
creative producer + Google Flow prompt engineer that walks a user from a rough story
idea to a continuity-aware, Flow-ready production package (video prompts + image prompts).

The product is the **compiled prose**, so the "requirements" are behavioral rules the
LLM assistant must follow. Those rules are the thing under test.

---

## 2. Architecture Summary

### Technology stack
- **Authoring format:** Markdown modules with embedded HTML-comment rationale blocks.
- **Build:** POSIX `bash` (`build.sh`) — `cat`/`sort`/`sed`, `set -eu`.
- **Delivery:** manual paste into ChatGPT Project Instructions; optional OSC 52 clipboard (`copy.sh`) and git publish (`publish.sh`).
- **No runtime, no database, no dependencies.** Cache: none relevant.

### Module structure
```
googleflow-stories/
├── modules/                     # authored source (19 files, filename order = doc order)
│   ├── 00-header.md             # title, {{VERSION}}, purpose, research baseline date
│   ├── 01-commands.md           # trigger vocabulary + implicit routing  (unnumbered "## Commands")
│   ├── 02-role.md               # §1  persona, the exactly-two-forms contract, interview-before-generation
│   ├── 03-riddle-prephase.md    # §2  FORM 1 of 2 (one setup form), riddle generator, answer-blind planning, pacing
│   ├── 04-interview.md          # §3  FORM 2 of 2 (one form, primary vs advanced), attachments, Other-on-every-field
│   ├── 05-story-planning.md     # §4  full-video blueprint + master context block
│   ├── 06-model-rules.md        # §5  dated Flow capability snapshot + Extend rule
│   ├── 07-image-workflow.md     # §6  per-scene image methods A–E, one-shot-one-image
│   ├── 08-video-prompt.md       # §7  prompt recipe steps 0–8, master audio rule, VO mode
│   ├── 08a-shot-composition.md  # §7a shot/camera vocabulary, image-output isolation
│   ├── 09-clip-continuity.md    # §8  Extend (default) vs Add clip, per-mode image needs
│   ├── 10-clip1-final.md        # §9  readiness check → Clip 1 prompt → Clip 1 image
│   ├── 11-output-format.md      # §10 delivery styles, collapsed summaries, imgN-M commands
│   ├── 12-budget-quality.md     # §11 credit strategy, no unverified model claims
│   ├── 13-research-policy.md    # §12 source hierarchy, fact/observation/recommendation split
│   ├── 14-style.md              # §13 concise interaction rules, per-story independence
│   ├── 15-defaults.md           # §14 single source of truth for interview defaults
│   ├── 16-checklist.md          # §15 final pre-output checklist
│   └── 17-sources.md            # "## Sources to keep handy" (unnumbered)
├── docs/chatgpt-interactive-components-cheatsheet.md  # reference only; excluded from build
├── build/google-flow-story-maker.md                    # GENERATED — do not hand-edit
├── version.txt · build.sh · copy.sh · publish.sh · build-and-copy.sh
├── validate.sh                  # structural validator for the compiled artifact (v2.12.0)
└── specs/                       # this document + per-change specs + evidence/
```

### Data flow
```
modules/*.md (sorted) --cat--> temp --sed s/{{VERSION}}/$(cat version.txt)/--> build/google-flow-story-maker.md
                                                                                     |
                                                          copy.sh (OSC 52) ----------+-----> ChatGPT Project Instructions ----> user chat
                                                          publish.sh (git) ----------+
```

Build guarantees (verified): modules are concatenated in **filename order** with a blank
line between each; the `{{VERSION}}` token in `00-header.md` is replaced; the output is
written to `build/`. At analysis time `build/` was **byte-identical** to a fresh rebuild
(in sync; version `2.11.6`). `./validate.sh` (added v2.12.0) re-checks that plus module
order, section numbering, cross-reference resolution, field shape and stale-phrase absence.

---

## 3. Observed Functional Requirements (EARS)

### 3.1 Build & publish subsystem

- **OBS-BUILD-001** — When `./build.sh` runs, the system shall concatenate `modules/*.md` in filename-sorted order into `build/google-flow-story-maker.md`, inserting one blank line between modules. *(build.sh:37-46)*
- **OBS-BUILD-002** — When building, the system shall replace every `{{VERSION}}` occurrence with the whitespace-trimmed contents of `version.txt`. *(build.sh:23-27,49)*
- **OBS-BUILD-003** — If `version.txt` is missing, the system shall substitute the literal `dev`. *(build.sh:25-27)*
- **OBS-BUILD-004** — When no `.md` modules exist, the system shall abort with a nonzero exit status. *(build.sh:30-33)*
- **OBS-BUILD-005** — When `./copy.sh` runs, the system shall emit an OSC 52 escape carrying the base64 of the build file. *(copy.sh:25)*
- **OBS-BUILD-006** — When `./publish.sh` runs, the system shall rebuild, stage exactly `modules version.txt build/google-flow-story-maker.md`, and commit only when staged changes exist. *(publish.sh:28-40)*
- **OBS-BUILD-007** — When `./publish.sh` runs, the system shall push to the current branch's upstream, setting it with `-u origin <branch>` if unset. *(publish.sh:43-48)*

### 3.2 Command routing *(01-commands.md)*

- **OBS-CMD-001** — When the user message contains `.start` (case-insensitive, dot optional), the system shall present **Form 1 first** and then the interactive interview — **even when the conversation already contains a locked riddle, a chosen story topic, or a completed earlier run**. Earlier turns are never a substitute for Form 1; known values are pre-filled instead. *(01:12; **updated v2.15.0** — previously just "run the riddle pre-phase", which a model could treat as already satisfied by prior conversation state)*
- **OBS-CMD-002** — When the user message contains `gfs`, the system shall treat it as an alias of `.start`. *(01:13)*
- **OBS-CMD-003** — When the user types `.advanced`, the system shall open/expand the Advanced/optional section. *(01:14)*
- **OBS-CMD-004** — When the user types `.go`, the system shall skip the interview and proceed with current answers and defaults. *(01:15)*
- **OBS-CMD-005** — When the user types `.restart`, the system shall discard current story context and begin a fresh interview. *(01:16)*
- **OBS-CMD-006** — While in the riddle pre-phase, when the user types `.reroll`, the system shall discard the current riddle list and generate a fresh batch. *(01:17)*
- **OBS-CMD-007** — When no command is given but the user clearly describes a new story idea, the system shall treat it as an implicit `.start`. *(01:19)*
- **OBS-CMD-008** — When the user has supplied enough detail or says to skip, the system shall treat it as `.go`. *(01:19)*

### 3.3 Riddle pre-phase *(03-riddle-prephase.md)*

- **OBS-RIDDLE-001** — When the story maker starts, the system shall present **Form 1 of 2** (the setup form) before opening the main interview form, as **one** form in a single message submittable in one action; submitting it produces Form 2. *(03:14-16; **updated v2.13.0** — this was previously a chain of separate questions)*
- **OBS-RIDDLE-002** — Before the first question, the system shall show one short line stating the user may attach reference images and notes at any time. *(03:18)*
- **OBS-RIDDLE-003** — Form 1 shall list language first, defaulting to Tagalog preselected. *(03:44,46)*
- **OBS-RIDDLE-004** — Form 1 shall carry the story type (Riddle story / AI Option A / AI Option B / AI Option C / Other / custom) **and**, in that same form, the riddle source — never as a separate follow-up question. *(03:47-55; **updated v2.13.0** — the riddle source was previously asked as a follow-up after the story-type answer)*
- **OBS-RIDDLE-004b** — On submit of Form 1 the system shall route once (non-riddle → straight to Form 2 with the idea carried pre-filled; own riddle → lock immediately; generate → present the candidate list once), and shall not ask anything the form already answered. *(03:57-61; added v2.13.0)*
- **OBS-RIDDLE-005** — When generating riddles, the system shall produce 5–10 candidates, each with a concrete, ordinary, guessable answer noted beside it. *(03:77-79,91)*
- **OBS-RIDDLE-006** — The system shall reject any riddle candidate whose answer is an abstract or genre label rather than a concrete thing. *(03:82)*
- **OBS-RIDDLE-007** — Selecting a riddle from the list shall lock it **in that same single action**, with no confirmation card, no re-listing, and no confirm-after-pick; a confirmation round shall be required **only** when the user edits the riddle text. *(03:103-104; **updated v2.13.0** — was pick, then confirm)*
- **OBS-RIDDLE-008** — On lock, the system shall record the riddle's text, answer, and language and preserve the wording exactly. *(03:106)*
- **OBS-RIDDLE-008b** — After locking a riddle, the system shall immediately open Form 2, with no intervening recap or confirmation turn. *(03:107)*
- **OBS-RIDDLE-009** — While planning a riddle story, the system shall build the plot, visuals, and reactions from the riddle's text/mood only, treating the answer as sealed. *(03:121)*
- **OBS-RIDDLE-010** — After drafting the plan and prompts, the system shall run exactly one leak check against the sealed answer. *(03:123)*
- **OBS-RIDDLE-011** — For riddle stories, the system shall never reveal or hint the answer in speech, on-screen text, captions, imagery, image prompts, or production assets. *(03:130-138; 16:13)*
- **OBS-RIDDLE-012** — The system shall derive the clip count from the specific riddle's length, not a fixed template. *(03:163)*
- **OBS-RIDDLE-013** — The system shall budget spoken lines at roughly 2–3 words/second (≈16–24 words per 8s clip). *(03:159)*
- **OBS-RIDDLE-014 — Riddle never answered.** Every riddle story shall show the riddle **going unanswered**: a silent guessing beat **and** at least one character who attempts it and fails (guesses wrong, gives up, cannot answer). The requirement is an *and*, not an either/or — a story where someone answers correctly is not a valid riddle story. *(03:20,32; 15:18-19; 16:14; added v2.14.0)*
- **OBS-RIDDLE-015 — Consequence always included.** Every riddle story shall include a visible consequence of the riddle going unanswered — the failure costs something the audience can see (a loss, change, danger, price, lost opportunity) — placed in the story's later beats and landing through action/imagery. It is a story beat, never a clue: it must follow from the riddle's wording/mood/situation only and must not reveal, hint at, depict, or be reverse-engineerable into the answer. *(03:34; 15:19; 16:14; 05:42; added v2.14.0)*

### 3.4 Interview *(04-interview.md)*

- **OBS-INT-001** — The system shall show only **Story topic, Character, Art style, and Image generation topic (subject/material)** by default, with Character and Art style as **two separate questions**. *(04:15; **updated v2.12.0** — was one combined "Characters + Art Style" field)*
- **OBS-INT-002** — The system shall hide clip count, aspect ratio, platform, video model, audio, continuity, clip continuation, delivery, **image workflow**, and other requirements behind an "Advanced / optional" toggle with defaults applied. *(04:16; image workflow moved here in v2.12.0)*
- **OBS-INT-009** — When the user picks "Use my uploaded photo(s) as the character sheet source," the system shall treat the attached photos as the locked identity source, preserve the person as they appear, and ask for a photo instead of inventing a face when none is attached. *(04:B1; added v2.12.0)*
- **OBS-INT-010** — The system shall default the image workflow to **"Generate reference images with ChatGPT"**, and a supplied character sheet shall be an identity source (method A) only, not a silent workflow switch. *(04:item 11, submit-time attachments; 07:A; added v2.12.0)*
- **OBS-INT-011** — The interview shall be presented as **Form 2 of 2**: all four primary fields together in one form in one message, submitted in a single action, never as a sequence of steps or per-field turns, and never re-asking anything Form 1 already collected or re-confirming a locked riddle. *(04:16; added v2.13.0 — this is the fix for the ~8-turn opening)*
- **OBS-INT-012 — Known values pre-fill, never remove.** "Already in hand" shall mean a value the user submitted in a form **during the current run (since the most recent `.start`)** — never something that merely appeared earlier in the conversation, in an attachment, or in the Instructions. A known value shall be shown pre-filled in its field; **pre-filled is not the same as omitted**. The system shall never present a partial form asking only for what looks missing, and never skip a whole form because the conversation appears to know the answers. *(02:13-14; 04:46-47; added v2.15.0)*
- **OBS-INT-013 — Skipping requires the user.** The only authorization to skip a form shall be the user saying to skip (a skip command such as `.go`, or plain words meaning skip the setup). Having enough information already shall not authorize skipping — it pre-fills the form, which is still shown. *(02:16; added v2.15.0)*
- **OBS-INT-003** — The system shall allow immediate submit without opening Advanced or confirming ordinary defaults. *(04:89)*
- **OBS-INT-004** — For every multiple-choice field, the system shall provide an "Other" option that accepts custom input verbatim. *(04:91)*
- **OBS-INT-005** — When the form is presented, the system shall tell the user (one short line) they may attach images and notes before submitting. *(04:104)*
- **OBS-INT-006** — On submit, the system shall read the answers together with submit-time attachments and notes. *(04:105-107)*
- **OBS-INT-007** — When attachments arrive before, during, at, or after submit, the system shall incorporate them without restarting the interview. *(04:118-124)*
- **OBS-INT-008** — The system shall not claim to have inspected an attachment that is not present in the conversation. *(04:109,126)*

### 3.5 Story planning *(05-story-planning.md)*

- **OBS-PLAN-001** — Immediately after the first submit — **and after the Story Overview checkpoint** — before generating any clip, the system shall lay out the entire video as one connected plan across every clip. *(05:50; updated v2.16.0)*
- **OBS-PLAN-005 — Story Overview checkpoint.** Immediately after Form 2 is submitted and before any clip prompt, expanded blueprint, or image, the system shall show a short Story Overview checkpoint — Script Overview, the arc in one line, the consequence in plain words, the clip count with each clip's one-line role, and a line confirming the seal — then stop. It is **not a form**: no fields, no required input, never labeled Form 3, never split across turns. It shall not require an answer: anything other than a change request (a tap, `.go`, "ok", "proceed", or fresh instructions) is approval, and the full package follows in the next message. A change request is revised and proceeded from; a second uninvited checkpoint is never presented. `.go` skips it entirely. *(05:14-42; 02:12; 11:51-52; 16:16; added v2.16.0)*
- **OBS-PLAN-006 — Clip-count shortfall raised at the checkpoint.** If the clip count cannot hold both the guessing beat and the consequence, the system shall raise it at the checkpoint in one line, with the option of one more clip, and let the user decide before anything is generated — never let it surface in a finished plan. *(05:38; moved from post-hoc in v2.16.0)*
- **OBS-PLAN-002** — The system shall place a master context block at the top of every clip prompt. *(05:34-44; 08:14)*
- **OBS-PLAN-003** — The blueprint shall cover Script Overview, premise/outcome, story beats, an exact clip/shot list, continuity notes, and an asset plan. *(05:46-53)*
- **OBS-PLAN-004** — The system shall keep each clip centered on one dominant beat. *(05:55; 03:128)*

### 3.6 Model rules *(06-model-rules.md)*

- **OBS-MODEL-001** — When current capabilities affect the output and web access exists, the system shall check official compatibility documentation before advising. *(06:11)*
- **OBS-MODEL-002** — The system shall treat the listed per-model capabilities as a dated snapshot (2026-10-10), not guarantees. *(06:19,68)*
- **OBS-MODEL-003** — The system shall state that all Veo 3.1 8s clips can be extended, but extension itself must run on Veo 3.1 Lite and accepts no input images. *(06:54-56)*

### 3.7 Image workflow *(07, 08a)*

- **OBS-IMG-001** — The system shall use exactly one clean frame per shot, never a collage/grid/split-screen/panel. *(07:10; 08a:18-23)*
- **OBS-IMG-002** — The system shall select the image method per scene from A (user-supplied), B (**Generate reference images with ChatGPT** — the default), C (in-Flow), D (polish), E (mixed). *(07:12-42; B renamed and marked default in v2.12.0)*
- **OBS-IMG-003** — The system shall not alter a real person's face/body/identity/clothing unless requested. *(07:17,34)*
- **OBS-IMG-004** — The system shall not describe an image as generated unless it actually was. *(07:36)*
- **OBS-IMG-005** — When calling the image model, the system shall pass a scene-only prompt for one shot with no production docs, labels, dialogue, or secrets. *(08a:36-43)*
- **OBS-IMG-006** — When image generation fails or returns a composite, the system shall retry a simplified single-shot prompt, never combine shots. *(08a:22,44)*

### 3.8 Video prompt *(08-video-prompt.md)*

- **OBS-VP-001** — The system shall build each prompt in steps 0–8 with the master context block first. *(08:12-22)*
- **OBS-VP-002** — Unless dialogue/script is supplied or speech is requested, the system shall specify no dialogue, narration, subtitles, captions, or text overlays (ambient only). *(08:34-40)*
- **OBS-VP-003** — When voiceover narration is chosen, the system shall have Veo generate the voiceover itself and not require a user-recorded track. *(08:49-55)*

### 3.9 Clip continuity *(09-clip-continuity.md)*

- **OBS-CONT-001** — For every clip after Clip 1, the system shall choose Extend (default) or Add clip. *(09:34)*
- **OBS-CONT-002** — Extend shall be available only when performed with Veo 3.1 Lite on an 8s Veo 3.1 clip, accepting no input images. *(09:39-40)*
- **OBS-CONT-003** — When the previous clip is not a valid 8s Veo 3.1 clip, the system shall fall back to Add clip. *(09:42)*
- **OBS-CONT-004** — Add clip shall accept up to 3 input images and require its own new keyframe, one clean frame per shot. *(09:47-49,54)*

### 3.10 Clip 1 final phase *(10-clip1-final.md)*

- **OBS-CLIP1-001** — After submit, the system shall lay out the full-video blueprint and then produce Clip 1 (not stop at planning). *(10:10)*
- **OBS-CLIP1-002** — Before generating Clip 1, the system shall run a readiness check (riddle locked, identity/style locked, Script Overview present, decisions resolved, images available or planned). *(10:14-22)*
- **OBS-CLIP1-003** — The system shall generate a Clip 1 image only when the chosen workflow calls for a ChatGPT-generated image. *(10:35-38)*
- **OBS-CLIP1-004** — When generating the Clip 1 image, the system shall pass a scene-only prompt free of blueprint, labels, dialogue, and secrets. *(10:45)*
- **OBS-CLIP1-005 — Turn never goes silent.** The system shall write the blueprint and Clip 1's prompt text **before** generating the reference image, generate the image **as the last action of the turn**, and open the turn with one short line saying the image is being generated and may take a moment — never an empty or placeholder reply. *(10:12; 14:13; added v2.14.0)*
- **OBS-CLIP1-006 — Explicit failure path.** If image generation is unavailable, fails, or the workflow is not ChatGPT-generated, the system shall say so in one short line immediately and still deliver the rest of the package (blueprint, Clip 1 prompt, remaining clip headers), rather than stalling until the user asks for progress. *(10:12; 14:13; added v2.14.0)*
- **OBS-CLIP1-007 — Image matches the video's aspect ratio.** The Clip 1 image prompt shall state the target aspect ratio explicitly and require a composition that fills it (a vertical portrait image for a vertical production, usable without cropping). The system shall check the returned orientation and, if it is wrong, say so in one line and regenerate with the ratio stated more forcefully — a wrong-ratio image is a failed attempt, not a delivery note, and "crop it in Flow" is not the remedy while a regeneration is available. *(10:47; added v2.15.0)*
- **OBS-CLIP1-008 — Exactly one image this turn.** The post-form turn shall generate only the Clip 1 reference image — no images for the character/continuity section, the blueprint section, or any other section. Every other image waits for its `imgN-M` command. *(10:49; added v2.15.0)*

### 3.11 Output format *(11-output-format.md)*

- **OBS-OUT-001** — The system shall show only per-clip summaries and nested image accordion headers by default (full prompts hidden). *(11:31)*
- **OBS-OUT-002** — When the user replies with a clip number, the system shall reveal that clip's full prompt in its own fenced code block. *(11:32)*
- **OBS-OUT-003** — When the user replies `imgN-M`, the system shall reveal that shot's image prompt and generate exactly one image. *(11:33,37)*
- **OBS-OUT-004** — The system shall keep each video/image prompt separately copyable and never merge clips into one giant prompt. *(11:54)*
- **OBS-OUT-005** — The system shall not depend on raw `<details>` or clickable buttons rendering; numbered reply-commands are the reliable path. *(11:29,35-36)*
- **OBS-OUT-006** — An Extend clip shall show no image header; an Add clip shall show its `imgN-M` header(s). *(11:53)*

### 3.12 Budget, research, style, checklist

- **OBS-BUDG-001** — When credit efficiency matters, the system shall recommend a small test generation for uncertain shots. *(12:12)*
- **OBS-BUDG-002** — The system shall not state a model is better for a shot type without current reliable evidence. *(12:14)*
- **OBS-RES-001** — When current information is material, the system shall browse and apply the source order official docs → model docs → community. *(13:10-14)*
- **OBS-RES-002** — The system shall separate documented fact, community observation, and recommendation. *(13:16-20)*
- **OBS-RES-003** — The system shall not reuse a stale credit amount, plan allowance, or limit; the active interface overrides stale docs. *(13:22)*
- **OBS-STYLE-001** — The system shall be concise, ask only outcome-affecting questions, and never ask the user to repeat provided information. *(14:10-16)*
- **OBS-STYLE-002** — The system shall treat each new story as independent unless the user asks to reuse prior material. *(14:17)*
- **OBS-CHK-001** — Before giving a story plan or clip prompt, the system shall run the final production checklist. *(16:10-29)*

---

## 4. Observed Non-Functional Requirements

### Determinism / portability
- Build is deterministic given `modules/` + `version.txt`; verified byte-identical to a fresh rebuild. *(build.sh; verified)*
- Scripts use `set -eu` and target stock macOS bash + Linux. *(README:29)*

### Trust / honesty guards
- Never claim an image was generated unless it was. *(07:36; 10:39)*
- Never claim to have inspected an unavailable attachment. *(04:109,126)*
- Never claim a generated result was seen. *(11:55)*
- Never guess model limits or credit costs. *(16:28; 13:22)*
- Fact/observation/recommendation separation. *(13:16-20)*

### Time sensitivity
- Research baseline stamped `2026-10-10`. *(00:9; 06:19)*
- Interactive-components cheatsheet explicitly marked time-sensitive, re-verify against a live surface. *(docs/...cheatsheet.md:10-17)*

### Secret handling
- Riddle answer is sealed: never in clips, images, image prompts, or assets. *(03:101-109; 08a:42; 16:13)*

### No testing infrastructure
- There is no behavioural test suite. Mechanical verification is `./validate.sh` (build sync, version stamping, module order, section numbering, cross-reference resolution, stale-phrase absence, interview field shape, defaults parity) plus content review. Behavioural changes are verified by A/B runs of the compiled artifact — see `specs/evidence/`.

---

## 5. Inferred Acceptance Criteria

- **AC-001 — Build reproducibility.** Given `modules/` and `version.txt`, when `./build.sh` runs, then `build/google-flow-story-maker.md` equals a fresh concatenation with `{{VERSION}}` substituted and exits 0. *(verified true)*
- **AC-002 — Command launch.** Given a fresh project, when the user types `.start` or `gfs`, then **Form 1 of 2** (language first, as one form) runs before the interview, and submitting it produces **Form 2 of 2**. *(03:14-16,44,46; updated v2.13.0)*
- **AC-007 — Two-form opening.** Given a fresh project and a riddle story with "Generate riddles for me," when the user works through to production, then the interaction asks for at most two form submissions plus one single-tap riddle pick — no per-field interview turns and no riddle confirmation round. *(02:12; 03:16,57-61,103-107; 04:16; added v2.13.0)*
- **AC-008 — Riddle outcome.** Given a locked riddle story, when the plan and clips are produced, then no character ever answers the riddle correctly, the guessing beat and at least one failed attempt both appear, and the video shows a visible consequence of the riddle going unanswered that does not hint at or encode the answer. *(03:20,32,34; 16:14; added v2.14.0)*
- **AC-009 — No silent turn.** Given the Form 2 submission, when Clip 1 is produced, then the user sees the blueprint and Clip 1's prompt text before the reference image finishes, and the turn never returns an empty or placeholder reply. *(10:12; 14:13; added v2.14.0)*
- **AC-010 — `.start` restarts at Form 1.** Given a conversation that already contains a locked riddle and a chosen story topic, when the user types `.start`, then Form 1 is presented again with those values pre-filled — nothing is skipped because it looked already known. *(01:12; 02:13-16; added v2.15.0)*
- **AC-011 — Form 2 stays whole.** Given a riddle locked during the current run, when Form 2 is presented, then all four primary fields are visible with the known ones pre-filled — no field is dropped and no partial "what's still missing" form is shown. *(02:13-14; 04:16,46-47; added v2.15.0)*
- **AC-012 — Story Overview gate before spending.** Given a submitted Form 2, when the run continues, then a short Story Overview checkpoint (overview, arc, consequence, clip roles, seal line) appears before any clip prompt, expanded blueprint, or image is produced; a plain "proceed" or a tap continues into the full package; and a change request is revised then proceeded from — never a second uninvited checkpoint, never a form with fields. *(05:14-42; 11:51-52; added v2.16.0)*
- **AC-003 — Fast submit.** Given the interview, when the user submits without opening Advanced, then generation proceeds using documented defaults. *(04:89; 15)*
- **AC-004 — Answer never leaks.** Given a locked riddle, when clips and images are produced, then no speech/text/imagery/image-prompt reveals the answer. *(03:106-123)*
- **AC-005 — One image per command.** Given a clip summary, when the user sends `imgN-M`, then exactly one image is revealed and generated. *(11:33,37)*
- **AC-006 — Continuity handoff.** Given Clip 2+, when it uses Extend, then it takes no image input and continues from the prior frame; when it uses Add clip, then it has its own new keyframe. *(09:36-54)*

---

## 6. Findings — Contradictions & Gaps (with evidence)

| # | Sev | Finding | Evidence |
|---|-----|---------|----------|
| F1 | **P1** | **Clip 1 image timing is contradictory.** Module 10 says generate the Clip 1 image *now* ("holds the reference image(s) right away", "generate the Clip 1 reference image in the chat now"), but Modules 04/11/15 state a blanket *"do not generate images yet"* / *"images on demand"* / *"do not generate images until the user picks a shot."* The default all-at-once path is therefore ambiguous: is Clip 1's image immediate (carve-out) or deferred like the rest? | 10:10,37,43 vs 04:86, 11:52, 15:40 |
| F2 | P2 | **Character-option count drifts.** §B1 says always offer **AI Character A / B / C** (three); §B3 and the defaults say offer **2 paired options**. | 04:48 vs 04:59, 15:25 |
| F3 | P2 | **Clip-continuation field missing from the interview.** Defaults and continuity define "Clip 2+ → Extend by default / Add clip" but the Advanced list in the interview has no matching field (items 1–10 omit it). A documented default has no control. | 15:39, 09:32-54 vs 04:78-87 |
| F4 | P2 | **Commands defined but unwired.** `.advanced`, `.go`, `.restart` appear only in `01-commands.md`; no downstream module reinforces them. (`.start`/`gfs` appear in 03; `.reroll` appears in 03.) | 01:14-16 vs grep of all other modules |
| F5 | P3 | **Story-idea count differs by surface.** Pre-phase offers **AI Option A/B/C** (three); interview help suggests **2 story ideas**. Probably intentional (different contexts) but undocumented as such. | 03:31-34 vs 04:32, 15:23 |
| F6 | P3 | **Riddle-toggle framing differs.** Defaults frame it as Yes/No ("No by default"); the pre-phase presents a 6-way choice with no stated default. | 15:15 vs 03:27-36 |
| F7 | **P1** | **Extend clips were written as new scripts.** The master-context and standalone-prompt rules required *every* clip — including a Clip 2+ produced with Extend — to carry a full master block and ship as a copy-ready standalone prompt, so an extension was planned, prompted, and presented as a fresh clip. Result: Clip 1 and Clip 2 render as two separate videos that do not join. | 05:36-44, 08:14, 09:20, 11:52, 16:29 vs 09:56 |
| F8 | **P1** | **Characters speak with no script.** The default audio option ("The model generates the audio too"), the auto-generated Script Overview loophole, and an ungated voice-identity rule let the model invent dialogue and make a character speak when the user supplied no script — triggered by a premise that implies speech ("explains", "tells"). | 04:86, 15:37, 08:42, 04:43, 05:48, 04:63 vs 08:45 |

No security-class issues found beyond the intentional secret-sealing rules (which are well-specified).

### Resolution status — patches v2.11.7 / v2.11.8 / v2.11.9 (branch `dev`)

- **F1 — FIXED.** Canonical rule: Clip 1's image is produced immediately by the Clip 1 final phase; every other image waits for `imgN-M`. Stated in `10-clip1-final.md` and referenced from `04-interview.md`, `11-output-format.md`, `15-defaults.md`.
- **F2 — FIXED.** `15-defaults.md` now matches the interview: **AI Character A/B/C** (three) plus a shortcut of **2 paired pitches**.
- **F3 — FIXED.** Added a "Clip continuation (Clip 2+)" field to the interview's Advanced list (`04-interview.md`), matching `15-defaults.md` / `09-clip-continuity.md`.
- **F4 — FIXED.** Added a "Command handling in this flow" note to `04-interview.md` wiring `.advanced`, `.go`, and `.restart`.
- **F7 — FIXED (v2.11.8).** An Extend clip now gets a short continuation delta, not a new script: master block and standalone-prompt rules are scoped to independently generated clips (Clip 1 and Add clips), with the contract owned by `09-clip-continuity.md` and cross-referenced from 05/06/08/10/11/15/16 and interview field 9. See `specs/extend-clip-continuation.md`.
- **F8 — FIXED (v2.11.9).** Default is now **ambient-only / no speech**; a ChatGPT-generated Script Overview never authorizes speech; voice identity is gated on authorized speech; the master audio rule forbids inventing dialogue. See `specs/speech-default.md`.
- **F2 — CLOSED BY DESIGN (v2.12.0).** The competing counts are gone: the character question offers **AI Character A/B/C** + "Other" + the photo option, and the 2 paired pitches are now an explicitly opt-in shortcut inside the *Art style* question ("never the default"), so the two answers stay independent.
- **F5 — OPEN (P3).** Story-idea count (3 in the pre-phase vs 2 in the interview help) intentionally left unchanged; documented here for a later pass.
- **F6 — FIXED (v2.13.0).** The Yes/No framing is gone. `15-defaults.md` now describes the same single choice row the pre-phase presents (Riddle story / AI Option A/B/C / Other), with **non-riddle** as the default and an explicit "not a Yes/No toggle followed by a second question" instruction. The riddle source is a field in that form, not a follow-up.

### Resolution status — v2.12.0 (`dev`)

- **Interview split.** The primary set is Story topic / Character / Art style / Image generation topic (subject-material only). The combined "Characters + Art Style" field is gone; Art style is its own question carrying the named-style list.
- **Photo-as-character-sheet.** New option in the character question: photos become the locked identity source, the person is preserved, and both the Clip 1 readiness check and the final checklist accept that source.
- **Image workflow → Advanced.** Default renamed to **"Generate reference images with ChatGPT"**; the primary image field now covers subject/material only. See `specs/interview-character-artstyle-split.md` and the whole-artifact audit in `specs/validation-v2.12.0.md`.

### Resolution status — v2.16.0 (`dev`)

**The Story Overview checkpoint — the story is now approved before anything is spent.**

Requested directly: *"before processing the submitted form 2, it should give some script overview or story overview."*

The capability already existed but was locked behind a non-default option. `11-output-format.md`'s **"Storyboard first"** style already did Script Overview → premise/arc → clip list → asset plan → *"wait for the user to approve or adjust"*. The **default** style ("All clips at once") showed the Script Overview and then generated the clip summaries, prompts, and the Clip 1 image in the same message. So nothing new was invented: the existing review gate was promoted to the default path.

- **Where.** New `### Story Overview checkpoint (before generating anything)` at the top of `05-story-planning.md`, before "Lay out the whole video first" — which now sequences after it.
- **Why it pays off.** The two riskiest rules in the project can only be *reviewed*, never validated: answer-blind planning, and the v2.14.0 required consequence. The checkpoint is the cheapest place to catch a story built around the answer, or a consequence that reads as a clue — before the clip prompts exist and before an image credit is spent. It also gives the user's taste a point of entry, since Form 2's story topic is one line while the model's story is the actual creative product.
- **Form vs checkpoint — the contract was extended, not broken.** `02-role.md` now reads *"exactly two forms, plus one Story Overview checkpoint"*, and states the distinction: a form **asks for input**, a checkpoint only **shows a proposal for approval**. The checkpoint has no fields, is never labeled Form 3, is never split across turns, and never requires an answer — anything other than a change request is approval. `.go` skips it.
- **Round-trip creep is guarded.** A change request is revised and proceeded from; a second uninvited checkpoint is explicitly banned, and the checkpoint may never ask for more detail in order to complete itself. This is the specific way the gate could have regressed into the multi-round questioning that v2.13.0 removed.
- **Integration.** The clip-count shortfall rule from v2.14.0 now surfaces *here* (OBS-PLAN-006) instead of in a finished plan. Default delivery (`11:51-52`) waits; the checklist gained the gate check. Guards: `validate.sh` §17, 10 checks. Count 113 → 123.

### Resolution status — v2.15.0 (`dev`)

Two defects from the second live run, both surfaced by the same `.start`.

- **Form 1 skipped; Form 2 arrived partial.** Observed: `.start` in a thread that already held a locked riddle and a story topic produced **no Form 1 at all** — and a "Visual Setup" carrying only Character and Art style, i.e. 2 of Form 2's 4 primary fields, with a story topic the model had inferred rather than the user chosen. Two instruction gaps allowed it: `02-role.md` said "never re-ask a question whose answer is already in hand" (added in v2.13.0 — **my wording**, ambiguous about scope) and the older interview-before-generation rule carried an escape hatch, "unless the user has already supplied enough information". Both let the model treat prior conversation state as settled input. Fixes: `.start` now always presents Form 1 and states that earlier turns are never a substitute; "already in hand" is scoped to values submitted in a form **during the current run**; **pre-filled is not the same as omitted**; Form 2 keeps all four primary fields visible; and the only way to skip a form is the user saying to skip it.
- **Clip 1 image wrong aspect ratio.** Observed: the reference image came back landscape for a vertical 9:16 production, and the run's remedy was to tell the user to crop in Flow. The rule now requires the prompt to state the ratio explicitly, the returned orientation to be checked, and a regeneration before any crop workaround — "a wrong-ratio image is a failed attempt, not a delivery note". Also pinned: **exactly one image this turn** (the observed captions in the continuity and blueprint sections suggest extra images were generated).
- **Guards.** `validate.sh` §15 and §16. Check count 101 → 112. The named-rule cross-reference for the interview-before-generation contract was re-pointed at its new defining sentence.

### Resolution status — v2.14.0 (`dev`)

Two follow-ups from the first live run of v2.13.0.

- **Riddle outcome contract (never answered + consequence).** The fixed structure was an either/or ("a silent beat … *or* another character who reacts but never answers correctly"), which allowed a story where nobody visibly fails to solve the riddle and nothing is lost. Now the guessing beat **and** at least one failed attempt are both required, and every riddle story must show a visible consequence of the riddle going unanswered — placed in a later beat, landing through action/imagery, and answer-blind so it cannot encode the solution. Mirrored in `15-defaults.md`, `16-checklist.md`, and `05-story-planning.md`.
- **No silent turn (Clip 1 image stall).** Observed: after Form 2 was submitted, the chat sat on an empty reply while the reference image generated, and only produced the blueprint/prompts after the user prompted it. Nothing in the artifact asked for a pause, so the fix is turn *ordering* rather than a new stop condition: the blueprint and Clip 1 prompt text are written **before** the image is generated, the image is the **last** action of the turn, the turn opens with a one-line "generating the reference image now" notice, and an explicit failure path (unavailable / failed / not a ChatGPT-generated workflow) delivers the rest of the package instead of stalling. Stated in `10-clip1-final.md` and mirrored in `14-style.md`.
- **Guards.** `validate.sh` §13 and §14 pin both, including `need_not` traps for the old either/or wording. Check count 87 → 100.

### Resolution status — v2.13.0 (`dev`)

The opening was observed in a live ChatGPT project taking ~8 turns before production: a confirmation card per riddle pick, a re-listing instead of a lock, and the Form 2 fields arriving one per turn ("Hakbang 1", "Hakbang 2", …). The cause was instruction wording, not model drift — `02-role.md` literally asked for "manageable, interactive steps", and the pre-phase was specified as a chain of questions with a follow-up and a pick-then-confirm lock.

- **Two-form contract.** `02-role.md` now states the whole opening is exactly two forms; `03` is **Form 1 of 2** (one setup form), `04` is **Form 2 of 2** (one production form presented in a single message). Per-field sequencing and re-asking settled answers are banned in `02`, `04`, and `14-style.md`.
- **Riddle source folded into Form 1.** The own-vs-generate follow-up question is gone; the choice is field 3 of the same form. Routing happens once on submit.
- **Single-tap lock.** Picking a riddle locks it in that same action, with no confirmation card and no re-listing; confirmation survives only for an edited riddle. Locking is immediately followed by Form 2 with no intervening turn.
- **Guards.** `validate.sh` §12 pins all of the above, including `need_not` traps for the stale phrasings that caused the problem. Check count 76 → 87.

---

## 7. Uncertainties and Questions

- [ ] **F1 resolution:** Should Clip 1's image be generated immediately (seed the chat) while Clips 2+ stay on demand — or should all images wait for `imgN-M`? Needs a single canonical statement.
- [ ] Does the target ChatGPT surface actually render the interactive components the cheatsheet describes, or only the numbered-command fallback? (cheatsheet is flagged time-sensitive)
- [ ] Are `.advanced`/`.go`/`.restart` honored in practice despite no downstream wiring?
- [ ] Is the "Other" option on *every* field reliably produced by the model, or only where explicitly spelled out?
- [ ] Which Flow models does the user's account/region actually expose (Veo 3.1 Lite, Omni Flash)? Affects Extend availability.
- [ ] Should the compiled artifact be published to a raw URL as part of the release, or is paste-into-ChatGPT still the workflow?

---

## 8. Release Readiness — `dev` → `master`

- **Divergence (refreshed for v2.12.0):** `dev` is **12 commits ahead of `origin/master`** and **13 ahead of local `master`**; linear history, **no merge commits**; `origin/master` is an ancestor of `dev` → **fast-forward merge**.
- **Version:** `master` = `2.9.0` → `dev` = `2.12.0`.
- **Scope shipped:** riddle hardening (03, 08a, 09), interview `Other` rule (04), answer-blind planning (03), `publish.sh`, and the docs cheatsheet. 13 files, +662/−52.
- **Build:** `build/` is **in sync** with modules + version on `dev`. ✅
- **New on dev, absent from master:** `publish.sh`, `docs/chatgpt-interactive-components-cheatsheet.md`. Neither is part of the compiled output — no build impact.
- **Working tree:** clean; `dev` == `origin/dev`.
- **No automated tests.** Only verification is build-sync + content review.
- **Blocking recommendation:** resolve **F1** (or explicitly document the Clip-1 carve-out in 04/11/15) before merging, since it is a live behavioral contradiction in the default delivery path.

---

## 9. Recommendations

1. **Fix F1 first (P1).** Make the Clip 1/on-demand boundary explicit in all four modules (04, 10, 11, 15). Pick one canonical sentence: e.g. *"By default, produce the Clip 1 image now; defer Clips 2+ to on-demand `imgN-M`."*
2. **Reconcile F2/F3 (P2).** Pick one character-option count (recommend 3 to match the pre-phase pattern, or 2 to match the paired shortcut) and either add a "Clip continuation" advanced field or remove it from the defaults.
3. **Wire or prune F4.** Reference `.advanced` in the interview module, and `.go`/`.restart` where they apply — or drop them from the command list to avoid promising unhandled triggers.
4. **Add a build-sync guard. — DONE (v2.12.0).** `./validate.sh` performs the build-sync check plus artifact-structure checks; wire it into a pre-commit hook or CI if desired.
5. **Date-stamp the modules** the same way the cheatsheet is stamped, and note a re-verify cadence for the model-capability snapshot.
6. **Document F5/F6** as intentional, or align the counts.
