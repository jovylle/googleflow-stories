# Reverse-Engineered Specification: Google Flow Story Maker

> **Analyzed:** 2026-10-10 · **Branch:** `dev` · **Version:** 2.11.6 (findings F1–F4 patched in 2.11.7)
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
│   ├── 02-role.md               # §1  persona + interview-before-generation contract
│   ├── 03-riddle-prephase.md    # §2  language-first, riddle generator, answer-blind planning, pacing
│   ├── 04-interview.md          # §3  primary vs advanced wizard, attachments, Other-on-every-field
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
└── specs/                       # this document
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
(in sync; version `2.11.6`).

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

- **OBS-CMD-001** — When the user message contains `.start` (case-insensitive, dot optional), the system shall run the riddle pre-phase then the interactive interview. *(01:12)*
- **OBS-CMD-002** — When the user message contains `gfs`, the system shall treat it as an alias of `.start`. *(01:13)*
- **OBS-CMD-003** — When the user types `.advanced`, the system shall open/expand the Advanced/optional section. *(01:14)*
- **OBS-CMD-004** — When the user types `.go`, the system shall skip the interview and proceed with current answers and defaults. *(01:15)*
- **OBS-CMD-005** — When the user types `.restart`, the system shall discard current story context and begin a fresh interview. *(01:16)*
- **OBS-CMD-006** — While in the riddle pre-phase, when the user types `.reroll`, the system shall discard the current riddle list and generate a fresh batch. *(01:17)*
- **OBS-CMD-007** — When no command is given but the user clearly describes a new story idea, the system shall treat it as an implicit `.start`. *(01:19)*
- **OBS-CMD-008** — When the user has supplied enough detail or says to skip, the system shall treat it as `.go`. *(01:19)*

### 3.3 Riddle pre-phase *(03-riddle-prephase.md)*

- **OBS-RIDDLE-001** — When the story maker starts, the system shall run the riddle pre-phase before opening the main interview form. *(03:11)*
- **OBS-RIDDLE-002** — Before the first question, the system shall show one short line stating the user may attach reference images and notes at any time. *(03:13)*
- **OBS-RIDDLE-003** — The system shall ask language first, defaulting to Tagalog preselected. *(03:26)*
- **OBS-RIDDLE-004** — When the user chooses "Riddle story", the system shall then ask whether the user has their own riddle or wants generated riddles. *(03:28-30)*
- **OBS-RIDDLE-005** — When generating riddles, the system shall produce 5–10 candidates, each with a concrete, ordinary, guessable answer noted beside it. *(03:50-52,64)*
- **OBS-RIDDLE-006** — The system shall reject any riddle candidate whose answer is an abstract or genre label rather than a concrete thing. *(03:55)*
- **OBS-RIDDLE-007** — When the user locks a riddle, the system shall record its text, answer, and language and preserve the wording exactly. *(03:78)*
- **OBS-RIDDLE-008** — While planning a riddle story, the system shall build the plot, visuals, and reactions from the riddle's text/mood only, treating the answer as sealed. *(03:92)*
- **OBS-RIDDLE-009** — After drafting the plan and prompts, the system shall run exactly one leak check against the sealed answer. *(03:94)*
- **OBS-RIDDLE-010** — For riddle stories, the system shall never reveal or hint the answer in speech, on-screen text, captions, imagery, image prompts, or production assets. *(03:101-109; 16:13)*
- **OBS-RIDDLE-011** — The system shall derive the clip count from the specific riddle's length, not a fixed template. *(03:133-136)*
- **OBS-RIDDLE-012** — The system shall budget spoken lines at roughly 2–3 words/second (≈16–24 words per 8s clip). *(03:129)*

### 3.4 Interview *(04-interview.md)*

- **OBS-INT-001** — The system shall show only Story topic, Characters + Art Style, and Image generation topic by default. *(04:15)*
- **OBS-INT-002** — The system shall hide clip count, aspect ratio, platform, model, audio, continuity, and delivery behind an "Advanced / optional" toggle with defaults applied. *(04:16)*
- **OBS-INT-003** — The system shall allow immediate submit without opening Advanced or confirming ordinary defaults. *(04:89)*
- **OBS-INT-004** — For every multiple-choice field, the system shall provide an "Other" option that accepts custom input verbatim. *(04:91)*
- **OBS-INT-005** — When the form is presented, the system shall tell the user (one short line) they may attach images and notes before submitting. *(04:104)*
- **OBS-INT-006** — On submit, the system shall read the answers together with submit-time attachments and notes. *(04:105-107)*
- **OBS-INT-007** — When attachments arrive before, during, at, or after submit, the system shall incorporate them without restarting the interview. *(04:118-124)*
- **OBS-INT-008** — The system shall not claim to have inspected an attachment that is not present in the conversation. *(04:109,126)*

### 3.5 Story planning *(05-story-planning.md)*

- **OBS-PLAN-001** — Immediately after the first submit, before generating any clip, the system shall lay out the entire video as one connected plan across every clip. *(05:20)*
- **OBS-PLAN-002** — The system shall place a master context block at the top of every clip prompt. *(05:34-44; 08:14)*
- **OBS-PLAN-003** — The blueprint shall cover Script Overview, premise/outcome, story beats, an exact clip/shot list, continuity notes, and an asset plan. *(05:46-53)*
- **OBS-PLAN-004** — The system shall keep each clip centered on one dominant beat. *(05:55; 03:128)*

### 3.6 Model rules *(06-model-rules.md)*

- **OBS-MODEL-001** — When current capabilities affect the output and web access exists, the system shall check official compatibility documentation before advising. *(06:11)*
- **OBS-MODEL-002** — The system shall treat the listed per-model capabilities as a dated snapshot (2026-10-10), not guarantees. *(06:19,68)*
- **OBS-MODEL-003** — The system shall state that all Veo 3.1 8s clips can be extended, but extension itself must run on Veo 3.1 Lite and accepts no input images. *(06:54-56)*

### 3.7 Image workflow *(07, 08a)*

- **OBS-IMG-001** — The system shall use exactly one clean frame per shot, never a collage/grid/split-screen/panel. *(07:10; 08a:18-23)*
- **OBS-IMG-002** — The system shall select the image method per scene from A (user-supplied), B (ChatGPT-generated), C (in-Flow), D (polish), E (mixed). *(07:12-41)*
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
- **OBS-CLIP1-004** — When generating the Clip 1 image, the system shall pass a scene-only prompt free of blueprint, labels, dialogue, and secrets. *(10:41)*

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
- There is no test suite; the only mechanical verification is the build-sync check.

---

## 5. Inferred Acceptance Criteria

- **AC-001 — Build reproducibility.** Given `modules/` and `version.txt`, when `./build.sh` runs, then `build/google-flow-story-maker.md` equals a fresh concatenation with `{{VERSION}}` substituted and exits 0. *(verified true)*
- **AC-002 — Command launch.** Given a fresh project, when the user types `.start` or `gfs`, then the riddle pre-phase (language first) runs before the interview. *(03:11,26)*
- **AC-003 — Fast submit.** Given the interview, when the user submits without opening Advanced, then generation proceeds using documented defaults. *(04:89; 15)*
- **AC-004 — Answer never leaks.** Given a locked riddle, when clips and images are produced, then no speech/text/imagery/image-prompt reveals the answer. *(03:92-109)*
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

No security-class issues found beyond the intentional secret-sealing rules (which are well-specified).

### Resolution status — patch v2.11.7 (branch `dev`)

- **F1 — FIXED.** Canonical rule: Clip 1's image is produced immediately by the Clip 1 final phase; every other image waits for `imgN-M`. Stated in `10-clip1-final.md` and referenced from `04-interview.md`, `11-output-format.md`, `15-defaults.md`.
- **F2 — FIXED.** `15-defaults.md` now matches the interview: **AI Character A/B/C** (three) plus a shortcut of **2 paired pitches**.
- **F3 — FIXED.** Added a "Clip continuation (Clip 2+)" field to the interview's Advanced list (`04-interview.md`), matching `15-defaults.md` / `09-clip-continuity.md`.
- **F4 — FIXED.** Added a "Command handling in this flow" note to `04-interview.md` wiring `.advanced`, `.go`, and `.restart`.
- **F5, F6 — OPEN (P3).** Story-idea count (3 vs 2) and riddle Yes/No framing intentionally left unchanged; documented here for a later pass.

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

- **Divergence:** `dev` is **7 commits ahead of `origin/master`** and **8 ahead of local `master`**; linear history, **no merge commits**; `origin/master` is an ancestor of `dev` → **fast-forward merge**.
- **Version:** `master` = `2.9.0` → `dev` = `2.11.6`.
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
4. **Add a build-sync guard.** A tiny CI/pre-commit check that `build/` equals a fresh rebuild would catch hand-edits and version drift.
5. **Date-stamp the modules** the same way the cheatsheet is stamped, and note a re-verify cadence for the model-capability snapshot.
6. **Document F5/F6** as intentional, or align the counts.
