# Handoff — the GoogleFlow Stories rule pack

Written at closeout so a fresh session can continue without reading a previous conversation.
**Read this file first.** Then `docs/SUMMARY.md` (the version history and the failure class the
versions share), and only the `specs/` file for whatever you are about to change.

## Current update (2026-10-14)

The working tree carries **v2.37.0** (the delivery + picks fix) on top of **v2.36.0** (the answer bank),
**v2.35.0** (creative diversity) and **v2.34.0** (live-run fixes). v2.34.0 and v2.35.0 were built together in
the tree, so one commit carries that pair (`9d451b2`); **v2.36.0 and v2.37.0 are both uncommitted** — two
failure classes, so split them into two commits if they are committed together.

**v2.37.0 hands over what the user came for: every clip prompt, the image ingredient, and both ways of
generating the clips — and stops offering the same few picks.** Two narrowed offers in one failure class:
a subset handed over where the user asked for the range.

1. **The delivery turn withheld the prompts.** The style is named "prompts now", but the output module
   printed *collapsed summaries* and revealed a prompt only when the user replied `1`, `2`, … — so the
   delivery turn ended with nothing to copy. Reported live: *"it seems not giving all the clips prompts it
   should make it available to copy already"*. The delivery turn now prints **every clip's complete prompt**,
   in clip order, each in its own fenced code block under a short summary line; it hands over the **image
   ingredient** (the Clip 1 image plus its copy-ready image prompt); and for every Clip 2+ it prints **both**
   continuation routes side by side — the **Extend** delta and the **independent** prompt bound to that same
   image — labelled, with one line saying the user picks one, never both. The independent route is new: a
   standalone clip generated from the ingredient the run already holds, needing **no new keyframe**. Images
   stay on demand (one image per action; Clip 1's excepted), and a compact summary view is opt-in, never the
   default.
2. **The picks repeated.** The story ideas, the AI Character A/B/C concepts, the art-style set, and the
   generated Script Overview came back as the same few options run after run — a fixed set with no rotation
   rule is read from its head, the same defect the answer bank fixed for riddle answers. New **§3a
   (suggestion variety)** is one rule every site points at: draw from a wide range instead of the head of a
   set, differ in kind rather than in adjectives, never re-offer what this conversation has already shown,
   do not always start from the same place, and always hand the choice over. §14 states the point the user
   made explicitly — **these defaults are the auto-mode picks**, so an auto run must never reuse the previous
   run's picks.

`validate.sh` §41 (44 checks) keeps all of it wired in and the artifact was rebuilt. None of this is
provable offline: the guards pin wording and structure, and a live run is still the only thing that shows the
delivery prints the prompts and that two consecutive runs offer different picks.

**v2.36.0 makes the answer bank the generator's answer source.** A fresh session kept offering the same
riddles, and the reason was that the generator's answers came from nowhere: nothing in the pack referenced
the 1,000-answer **Filipino Riddle Answer Bank** (v1.0.0) the user had supplied, so every run invented an
answer and converged on the illustrations printed in Step 0a — `salamin`, `kandila`, `anino`, `orasan` —
which were meant as examples and read as the menu. The bank is now embedded as **§2c**
(`modules/03a-answer-bank.md`, generated from `data/riddle-answer-bank.json` by
`scripts/build-answer-bank.py`, whose freshness `validate.sh` re-checks on every run), and **§2b** is the
protocol that consumes it: an answer is a bank entry drawn by an **even spread across the whole bank** —
never the head of the list, never an invented answer — no two candidates in one batch may share an **answer
family** (so `kandila sa mesa` can never follow `kandila`), entries tagged `[not-an-answer]` are skipped, an
`ANSWERS-USED` record is honoured when the user keeps one, and the chosen answer stays sealed and out of
every clip and image prompt. All 1,000 answers are distinct strings, but they collapse to **865 families**: 135 entries are variants
of another entry (`kandila sa mesa` beside `kandila` — `salamin` has 12 members, `susi` 11, `kandila`
10), and 21 are description-shaped (`orasan na walang kamay`). That is why the family rule, not answer
uniqueness alone, is what actually stops a batch repeating. `validate.sh` §40 keeps all of
it wired in, and `specs/evidence/score-answer-pool-dry-run.py` scores a 30-pick dry run of the protocol.

The v2.35.0 report below is retained as the previous closeout of the same day.

**v2.35.0 closes a creative-diversity regression.** Twelve sample horror-riddle productions came back as
one film: a small animal (mouse, rabbit, chick) cornered in a doorway, corridor, or tunnel by something
much larger that floated and wore robes, shot from behind the victim, ending with the way sealed. The
formula was never mandated — the victim bullet said "small, cute, vulnerable", the trap bullet listed only
passage-shaped traps, the consequence bullet listed only sealing and claiming, and nothing ever selected a
camera. The model read the defaults as the spec. `03-riddle-prephase.md` gains **§2a, a creative-diversity
engine**: the riddle's invariants are separated from its visual defaults, nine axes (victim form, Teller
form, size relation, the Teller's mechanism, environment, trap, camera viewpoint, art style, consequence)
are settled fresh every run, the combination must reduce to one coherent situation, a recent-design
non-reuse rule applies, and a one-line planning-only **fingerprint** is written on the plan record and
compared before the blueprint. `.reroll visual` changes the look without touching the riddle; `.auto riddle`
runs the selection automatically. `08a` gains an explicit camera-**viewpoint** axis (the rear-view figure
facing a larger centred one is now named as one option among many, not the house style), and `07` gains an
**image acceptance gate** — a frame that swaps the species, the scale, the setting, or the viewpoint is
regenerated, and a persistent failure is reported rather than the plan being silently rewritten to match the
image. That gate is the fix for the run that planned a turquoise salamander and a floating wooden mask and
shipped rabbit-and-mouse adventurers in a temple corridor instead.

`validate.sh` has sections 38 (v2.34.0) and 39 (v2.35.0) for these contracts; the compiled artifact was
rebuilt from the modules. The plugin package embeds a copy of the rulebook and must be rebuilt for its opt-in
checks (`VALIDATE_PLUGIN=1`) to pass at the new version. These checks confirm wording and build consistency;
a fresh ChatGPT/Flow run is still the only thing that can judge model behaviour.
The older state and next-step list below are retained as a snapshot of the previous
closeout, not as current instructions. No release, deployment, or live-project paste
was performed by this update.

### Plugin package brought up to date (2026-10-14)

The plugin was stale: `plugin.json` was at **2.33.0** while the pack was at **2.35.0**, its embedded
rulebook predated v2.34.0/v2.35.0, and `dist/` held the old ZIP. It is rebuilt at **2.35.0** and now
declares the four listing URLs the portal imports from the package. The published requirements were
re-read on 2026-10-14 and both checkers were extended to cover them: manifest field caps (`author`,
URL lengths), the four `interface` URLs (https, ≤1024, no embedded credentials), prompt uniqueness,
icon format/size/dimension rules including the dashboard's 512px PNG, and — under `CHECK_URLS=1` —
reachability of the four live URLs. The one requirement no package change can satisfy is the
guidelines' note that *skills-only plugins may be subject to additional eligibility requirements for
listing in the Directory*. Nothing was uploaded, submitted, or deployed.

## State at closeout (2026-10-11)

| Repo | Version | Branch / HEAD | Checks | Remote |
|---|---|---|---|---|
| `lab/googleflow-stories` (**canonical rules** — you are here) | **2.37.0** | `dev` / `9d451b2` **+ v2.36.0 & v2.37.0 uncommitted** | `./validate.sh` → **459 / 0** | GitHub `jovylle/googleflow-stories`, `master` at `05d81ec` (v2.21.0 release merge), `dev` fifteen ahead |
| `lab/flow-story-gpt` (distilled ChatGPT pack) | 1.0.0 | `master` / `5bb876c` | `./validate-gpt.sh` → 28 / 0 | **none — local only** |
| `lab/flow-story-gem` (Gemini + hand-over zip) | 1.0.0 | `master` / `6c3d417` | `./validate-gem.sh` → 36 / 0 | **none — local only** |

Canonical artifact: `build/google-flow-story-maker.md`, **2,508 lines / 209,518 chars**, rebuilt from the
modules and **uncommitted** (v2.36.0 + v2.37.0). `master` is at `05d81ec` (v2.21.0, released 2026-10-12 by merging `dev`) and is **sixteen versions behind `dev`**.

### Version chain since v2.12.0 (all on `dev`)

| Version | Commit | What it fixed |
|---|---|---|
| 2.13.0 | `9a855ca` | Two-form opening: Form 1 (setup) produces Form 2 (production); Character and Art style split into separate questions |
| 2.14.0 | `4b992b2` | Riddle outcome contract (never answered **and** a visible consequence) + no-silent Clip 1 turn |
| 2.15.0 | `b230ab6` | `.start` always begins at Form 1 (no state inference) + Clip 1 image aspect ratio checked |
| 2.16.0 | `ac44c39` | Story Overview checkpoint — approve the story before anything is generated |
| 2.17.0 | `2054896` | Re-roll control stays visible; riddles stop closing on "Ano ako?" |
| 2.18.0 | `bb543d3` | Answer was leaking through the scene → default riddle story is a horror two-entity scene; the riddle's nouns banned from every visual surface |
| 2.19.0 | `1fa995a` | Script Overview renders as a markdown list, not a paragraph |
| 2.20.0 | `7bfdfe2` | One image per request — no batches, sheets, or panels, and the plan is never rendered as an image |
| 2.21.0 | `4c96cfd` | The supernatural Teller voice (riddle horror), vendored from a prompt the user proved in Veo 3.1 Lite, + the heavy-voice duration budget |
| 2.22.0 | `6d766a1` | The `.auto` skip command (`.auto riddle` / `.auto mukbang` + free text): locks the story path, applies all defaults, skips both forms and the checkpoint for that run only; bare attachments never trigger it; `.reroll` re-locks one fresh candidate |
| 2.23.0 | `be16e61` | Neutral riddle generation: candidates are written as if no story exists yet, genre mood is spent on delivery only; the uncanny-answer list is trimmed to genre-agnostic ordinary things; the "good" horror example no longer ends first-person |
| 2.24.0 | `8eb1b1f` | Allocated timestamps: every blueprint carries a clip map (Clip N of M, nominal range, beat purpose), no consequence starts before the final clip, wait and consequence are never compressed into one block, and the shortfall offer covers all three beats |
| 2.25.0 | `76f246f` | Story-type words trigger `.auto`: `horror riddle` / `mukbang` (+ photo) starts the run with no `.start` or typed command; bare attachments, questions, negations, and mid-run mentions never trigger |
| 2.26.0 | `5b72ba5` | Tagalog indirect-description rule: clues turn on words used obliquely (`mukha`/`mata`/`kamay`, double meanings) — wordplay as misdirection, never spooky words, never rewriting a user riddle |
| 2.27.0 | `7133c37` | Overview text-only: no hero/grid/storyboard sheets ever, checkpoint turn imageless, Clip 1 the run's sole image; the old storyboard-first instructions that licensed the sheet are rewritten |
| 2.28.0 | `132d806` | Riddle spoken-only: speech authorization never authorizes text — the locked riddle reaches the audience through the Teller's voice alone, even when on-screen text is requested |
| 2.29.0 | `cd47047` | Mukbang ASMR default: silent of speech — no talking, narration, or voiceover; soundtrack is eating sounds only unless narration is explicitly requested |
| 2.30.0 | `1697e78` | Flat riddle endings: generated riddles never end with `?` — the Teller issues a challenge, not an invitation; user riddles stay verbatim |
| 2.31.0 | `3205861` | Riddle variety: the same eight-noun example list appeared twice and read as a menu — the pool is widened and named as illustrations, answers must be unique within a batch, and a re-roll differs in answer, not wording |
| 2.32.0 | `1669843` | `.revise` single-item revision: one item changes, everything else stays locked, only the deliverables carrying it are re-emitted — a local change (riddle text) reprints just the clip that speaks it, while character/art style also regenerate the Clip 1 reference image |
| 2.33.0 | `aa75e38` | Reference-image binding: every independently generated clip prompt names its image and must match its medium, render quality, palette, lighting, and grade; a supplied photo stays photographic; an Extend delta carries no image binding (its inheritance is the contract) |
| 2.34.0 | `9d451b2` | Live-run reliability: the consequence has an explicit actor and victim (**the victims pay, the Teller acts**), the Character choice cannot become the Teller, a duration shortfall is surfaced at the overview instead of squeezing the line, and Form 2 ends with a visible Submit button plus a `.go`/text fallback |
| 2.37.0 | *(uncommitted)* | **Deliver everything the user came for**: the delivery turn prints **every clip's prompt in full** (each in its own fenced code block — no summary in place of a prompt, no prompt behind a number reply), hands over the run's **image ingredient** (the Clip 1 image + its copy-ready image prompt), and prints **both** routes for each Clip 2+ (the Extend delta and the independent prompt bound to that same image, no new keyframe); and **§3a suggestion variety** makes every proposed set — story ideas, AI Character A/B/C, the art-style list, the generated Script Overview — come from a wide fresh range instead of the head of a fixed set. §14 states it: **these defaults are the auto-mode picks**, and an auto run must not reuse the last run's |
| 2.36.0 | *(uncommitted)* | Answer bank: the generator's answers come from the user's 1,000-answer bank (embedded as **§2c**, generated from `data/riddle-answer-bank.json`), drawn by an **even spread** across it (**§2b**) — never the head of the list, never an invented answer, never the illustrations; no two candidates in a batch may share an **answer family**, `[not-an-answer]` entries are skipped, and an `ANSWERS-USED` record is honoured when the user keeps one |
| 2.35.0 | `9d451b2` | Creative diversity: **§2a creative-diversity engine** (invariants vs visual defaults, nine axes settled fresh each run, one-coherent-situation test, recent-design non-reuse, planning-only fingerprint), `.reroll visual`, an explicit camera-**viewpoint** axis, and an **image acceptance gate** that regenerates a frame which swaps the subjects, species, scale, setting, or viewpoint rather than letting the image quietly rewrite the plan |

## Public ChatGPT plugin (`plugin/`)

The public-directory plugin package lives here and embeds a generated copy of this artifact.

- **Package:** `plugin/flow-story-maker/` — portable Agent Plugins manifest (`plugin.json`), two skills
  (`flow-story-maker` + the `get-started` onboarding skill), square SVG icons, and
  `skills/flow-story-maker/references/gfs-instructions.md` (the generated rulebook).
- **Build:** `./plugin/build-plugin.sh` — rebuilds the pack, stamps the plugin version from `version.txt`
  (pack and plugin versions move together), refreshes the embedded copy, writes
  `plugin/dist/flow-story-maker-<version>.zip` (only the current version's ZIP is kept).
- **Validate:** `./plugin/validate-plugin.sh` — manifest field limits, the four listing URLs, icon rules,
  skills layout, the marketplace catalog, brand-colour contrast, freshness, secret hygiene, ZIP contents.
  Add `CHECK_URLS=1` for the same run plus reachability of the four live URLs. Guarded by
  `validate.sh` §37 so the package cannot rot silently — §37 also fails if the manifest loses any of
  the four listing URLs. The reported total counts *passing* checks only, so it shrinks when a failure
  suppresses a downstream group (a version mismatch skips the ZIP-content group); read the FAIL lines.
- **Distribution (live route):** `.agents/plugins/marketplace.json` at the repo root is a one-entry
  catalog pointing at `./plugin/flow-story-maker`. Install with
  `codex plugin marketplace add jovylle/googleflow-stories --ref dev`, then install **Flow Story Maker**
  from the **Flow Story Maker Plugins** marketplace in the desktop app's Plugins Directory. `--ref dev`
  is required because the default branch does not carry the plugin yet; never add `--sparse`, since
  `source.path` is resolved from the marketplace root and a sparse checkout of `.agents/plugins` alone
  would leave the package behind.
- **Public-directory status (2026-10-14): blocked.** The ZIP uploaded, and the dashboard came back with
  three findings: skills-only submissions are not being accepted at this time (portal policy — no
  package change clears it), the name/description references another AI model or platform, and the
  category could not be confirmed. The last two would need a brand-neutral listing (no Google Flow /
  Veo 3.1 in the metadata, and a neutral `displayName`, since "Flow" is the platform's name) plus a
  purpose-first description. Only an MCP-backed **second** plugin reopens the directory, and that is a
  product change, not packaging. Findings verbatim in `plugin/docs/SUBMISSION.md`.
- **Submission:** `plugin/docs/SUBMISSION.md` — re-read against the published docs on 2026-10-14;
  portal steps plus what is still on the user: developer verification, the dashboard's primary icon
  (`plugin/dist/icon/flow-story-maker-512.png`), and confirming the dashboard's category list.
  The four listing URLs now live in `plugin.json` as `websiteURL`, `supportURL`,
  `privacyPolicyURL`, `termsOfServiceURL`, because the portal imports listing metadata from the package
  and does not fill those fields from `homepage` or `author.url`.
- **Constraint that cannot be undone later:** the package stays **skills-only**. Adding an MCP server to
  an existing skills-only plugin is not supported, and a ZIP with `hooks/` or `.app.json` cannot be
  submitted at all. An MCP-backed version would have to be a second plugin.
- **Naming:** deliberately `flow-story-maker` / "Flow Story Maker" — "Google" stays out of the name and
  subtitle. The portal's automated check rejects this posture anyway: it flagged the listing for
  referencing another AI model or platform, since the description names Google Flow and Veo 3.1 and the
  display name carries "Flow". Any future listing needs a neutral name and a description that describes
  the target as "a video-generation platform and model you already use".
- **Website:** `site/` in this repo, deployed to Cloudflare Pages project `flow-story-maker` on
  **https://gfs.uft1.com** (landing + `/privacy` + `/support` + `/terms` — the four URLs the directory
  asks for). Redeploy: `npx wrangler pages deploy site --project-name flow-story-maker --branch main`.
  The landing page now carries the real install path — the plugin is **not in the public directory**
  (skills-only submissions are paused) but installs from this repo's marketplace — so no listing claim
  appears before a listing exists.

## What to do next, in order

1. **Re-paste the artifact.** The live ChatGPT project is still running **v2.12.0** — none of the twenty
   versions of fixes above are in it. Paste `build/google-flow-story-maker.md` and just say `horror riddle`
   (no `.start` needed anymore) for a Tagalog end-to-end: neutral riddle list with oblique wordplay
   (`mukha`/`kamay`-style clues), varied answers that are not the same eight every batch, flat period endings,
   text-only overview, spoken-only riddle (never displayed),
   timestamped clip map with the wait in its own clip.
   Then say `mukbang` with a photo (expect ASMR eating sounds, no talking). After any of it is planned,
   try `.revise riddle <new text>` and check that only the riddle-bearing clip prompt comes back.
   Check the clip prompts carry their timestamp header, an audio line, and the reference-image binding
   (medium, palette, lighting, grade).
   For **diversity** specifically (v2.35.0), run `horror riddle` or `.auto riddle` three or four times in the
   same chat and compare the ensembles: different victim forms (not another small mammal), at least one Teller
   that is not larger, different settings (not another doorway), different viewpoints (not another rear-view
   figure). Then try `.reroll visual` and confirm the riddle text is untouched while the look changes, and
   check the plan record carries the fingerprint line while the story text does not. `specs/creative-diversity.md`
   holds the dry-run sample and the scoring rubric to judge it against.
   For the **answer bank** (v2.36.0), start a **new session** — no conversation memory can help it there — and run
   `horror riddle` twice. The two candidate lists must draw visibly different answers, and the same answer must
   not come back in the second batch; no list may pair a thing with its own variant (`kandila` beside
   `kandila sa mesa`); `salamin`, `kandila`, `anino`, and `orasan` may appear only if the spread lands there, not
   by default; and each candidate must still show its riddle with its answer noted. `specs/riddle-answer-pool.md`
   holds that change's dry run and rubric.
   For the **delivery + picks** (v2.37.0), after any plan is approved check the delivery turn itself: it must
   print **every** clip's full prompt (not summaries you expand with a number), hand over the Clip 1 image
   together with its copy-ready image prompt as the run's **ingredient**, and print **both** routes for each
   Clip 2+ — the Extend delta and the independent prompt bound to that image. Then start a **new session** and
   run `horror riddle` twice: the two story ideas, the three character concepts, and the art-style set must
   differ between the runs, and no run may re-offer an option the conversation already showed.
   `specs/delivery-and-picks.md` holds that change's rubric.
   This is the only step that produces evidence.
2. **Calibrate the heavy-voice word budget.** v2.21.0 set it to **12–16 words per 8-second clip**
   from the voice's stated pace (~1.5–2 words/sec), not from a timing. Ask the user for the riddle's
   word count and whether it fit their 8s clip, then correct the figure in `03-riddle-prephase.md`
   (two places), `08-video-prompt.md`, and `16-checklist.md` **together** — a budget stated in
   several modules is obeyed from whichever copy is read last.
3. **Decide the three unactioned defects** (below). None are shipped; all were reported from live runs.
4. **Then** rebuild the distilled packs, or accept that they are stale (see open items).
5. **Publish the plugin.** The package is refreshed to **2.35.0** and validates (59 offline checks, 63
   with `CHECK_URLS=1`), and the four listing URLs are live and now declared in `plugin.json`
   (https://gfs.uft1.com — privacy `/privacy`, support `/support`, terms `/terms`). What is left is
   developer identity verification, the dashboard's primary icon, and the ZIP upload
   (`plugin/docs/SUBMISSION.md`).

## Previously unactioned defects (addressed in v2.34.0; awaiting live verification)

1. **The consequence names the actor but not the victim.** `03-riddle-prephase.md` says the
   consequence is the Teller's own act; a Tagalog phrasing rendered as *the Teller* being punished.
   The missing sentence is **the victims pay, the Teller acts**.
2. **A victim option got cast as the Teller.** The Character field offers victims, but a run promoted
   the chosen victim to the Teller (an "imposing unsettling figure") and left the victims with no
   locked design. Proposed: **two explicit slots** — victims and a separately-designed Teller — that
   may never silently merge.
3. **A ceiling-length riddle gets squeezed.** A 24-word riddle at a normal pace is ~9.6 s before the
   mandated silence; the run chose "keep every beat" and squeezed delivery. v2.21.0's budget handles
   the heavy-voice case; the general case should still **offer** a third clip or a higher-fidelity
   model rather than silently squeeze.

## Open items (decide later, none blocking)

- **The distilled packs are nine versions behind** (`flow-story-gpt` 1.0.0, `flow-story-gem` 1.0.0, both
  built against canonical v2.12.0). Their checkers still pass because they check *their own* artifact;
  nothing tells you they are stale. Rebuilding is not a pure re-run: the GPT pack's instruction field
  is **7,681 of 8,000 chars — 319 chars of headroom**, and v2.21.0's voice block alone is **1,620
  chars** (its whole section, 4,163). The voice block has to live in a **knowledge file** (retrieved)
  or the pack needs a genuine re-distill — pasting it into the instruction field is impossible.
- **`dev` → `master` merge** is taken through v2.21.0 (`05d81ec`, 2026-10-12). Note for the next release: `master`'s old release commit was itself a merge whose side `dev` never had, so `--ff-only` fails — merge with `--no-ff` (it applied with zero conflicts this time), rebuild, revalidate, then commit and push.
- **Neither pack repo has a git remote.** They exist only on this disk.
- **Form 2 sometimes rendered with no submit button.** Reported 2026-10-12: the fields showed, the submit control did not (long form + collapsed Advanced suspected). v2.34.0 now requires a visible Submit button outside Advanced and a `.go`/text fallback, mirrored in the checklist and validator. A live run still needs to confirm the control renders.
- **The website / parallel-storybuilding system** the user asked about earlier was deferred with
  "make this properly work first". Do not re-raise it unprompted. If it is ever built, hold it to one
  rule: it consumes the compiled artifact and `validate.sh` as its source of truth, and re-implements
  nothing — otherwise every future rule fix has to land twice.

## Commands

```bash
cd /Volumes/DevSSD/fore/lab/googleflow-stories
printf '2.22.0\n' > version.txt   # bump first; the build substitutes {{VERSION}}
./build.sh && ./validate.sh       # 459 checks today (plus docs/HANDOFF.md freshness)

# while working on one area, read only the new section's red:
./validate.sh 2>&1 | sed -n '/^23\./,$p'
```

Never hand-edit `build/` — edit `modules/*.md`, rebuild, revalidate. `validate.sh` reads the
**compiled artifact** for most checks and the modules for the per-section guards, so a stale build
shows up as failures rather than passing quietly.

## Key files

- `modules/03-riddle-prephase.md` — the riddle story's fixed horror structure, the Teller, the
  answer-blind rules, the spoken-duration budgets, **§2a the creative-diversity engine** (the nine axes,
  the coherence test, recent-design non-reuse, the planning-only fingerprint), and **§2b the answer-bank
  selection protocol** (even spread across the bank, one family per batch, the skip rules, the used-record).
- `modules/03a-answer-bank.md` — **§2c, the 1,000-answer bank.** Generated, never hand-edited: edit
  `data/riddle-answer-bank.json` and run `scripts/build-answer-bank.py`. Each line is
  `NNNN answer [family] [not-an-answer]`; the family tag is what the batch rule checks.
- `modules/04-interview.md` — the two forms; Form 2's four primary fields (Character is pitched as
  **victims**, varied in archetype rather than all small mammals).
- `modules/07-image-workflow.md` — the image methods A–E and the **image acceptance gate** (verify the frame
  against the plan; regenerate a mismatch; report a persistent failure instead of replanning around it).
- `modules/08a-shot-composition.md` — the one-shot/one-image hard rules and the camera vocabulary, including
  the explicit **camera viewpoint** axis (the rear-view figure facing a larger centred one is one option, not
  the house style).
- `modules/08-video-prompt.md` — prompt construction, the master audio rule, and **the supernatural
  Teller voice block**.
- `modules/10-clip1-final.md` — the Clip 1 gate: exactly one image, one composed scene, ratio checked.
- `modules/16-checklist.md` — the self-check a run performs before delivering.
- `validate.sh` — one section per fix area, plus a handoff-freshness section; §20 riddle-structure, §21 Script Overview list, §22 image count, §23 voice block.
- `docs/SUMMARY.md` — one row per version, plus the failure class they share.
- `specs/googleflow-stories_reverse_spec.md` — the reverse spec: observations (`OBS-*`), acceptance
  criteria (`AC-*`), and a resolution-status block per version. `specs/image-count-one-per-request.md`
  and the other per-version specs carry the longer reasoning.

## What we learned (the transferable part)

The generalisable rules are written up in the `instruction-pack-delivery` skill — read it before
changing anything here. The short version, as it applies to this repo:

1. **A rule the artifact already states several times, violated anyway, was outvoted — not missing.**
   v2.20.0: the one-image rule appeared five or six times, including nearly verbatim; six *other*
   sentences said more ("1-3 images per clip" as a **planning target**, "identify the role of every
   image" with a role list, "for each scene", the plural inside a method's name, a per-clip image
   accordion of headers). The fix was to **delete** the strongest pull and trap it with a `need_not`
   — not to add a seventh statement of the rule. Same shape as v2.18.0, where a sentence *requiring*
   the consequence to follow from the riddle's wording was the leak.
2. **Banning an output does not remove the pathway that produces it.** v2.18.0's junk titles came
   back because the *lookup* was still permitted; v2.20.0 therefore banned web/image-library searches
   for style references outright rather than adding another "no citations" line.
3. **A prompt that describes a performance needs a slot for the content.** The user's proven 215-word
   voice prompt contains **zero words for the entity to say** — pasted alone it relies on the model
   inventing the Tagalog, which for a riddle story means an invented line and a possible answer leak.
   The vendored version adds the locked-riddle line plus "says nothing else", and keeps the negative
   tail verbatim, because *"not a normal human lowering their voice"* is doing the real work.
4. **A change that alters pacing invalidates every budget that assumed the old pacing.** A slow,
   pause-heavy delivery is not 2–3 words/second; shipping the voice without re-deriving the spoken
   budget would have reproduced the squeezed-delivery defect on every riddle.
5. **An example list with no source and no memory is a menu.** v2.36.0: the pack already told the model to
   draw answers "from anywhere in the ordinary world" and to vary them, and the same handful came back in every
   session — because "vary" named no pool, no sampling rule, and no record of what had already been used. The
   fix was not another sentence asking for variety; it was a real pool, an even spread across it, a family rule
   that catches `X` next to `X sa Y`, and a used-record. Watch for the shape: a rule that *asks for* a property
   with nothing in the pack that can *produce* it.
6. **`validate.sh` proves a rule is present, not that a run obeys it.** Every version above was
   written guards-first (red before green) and every one of them is only *proven* by the next live
   run. Say that plainly when reporting — the honest limit is the point.
7. **The user's own words are the one thing the pack may not rewrite.** A user-written Script Overview
   is never reworded (it is split at their own boundaries); a user-supplied riddle is preserved
   verbatim, including a closing "Ano ako?" that generated riddles are banned from.
8. **A deliverable named after handing something over has to contain it.** v2.37.0: the delivery style was
   called "prompts now" while the mechanism printed collapsed summaries and revealed a prompt only on a
   numbered reply, so the turn ended with nothing to copy. Check what the user *leaves the turn holding* —
   the name of the style is not the delivery.
9. **A set with no rotation rule is read from its head.** v2.37.0: the same two story ideas, three
   characters, and first art style came back every run — not because the list was short, but because nothing
   moved between runs and the first entry is the de-facto default. Same fix as the answer bank (a wide range,
   a spread, a no-repeat record), applied to what the pack *proposes* rather than what it draws as an answer.
