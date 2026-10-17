# Google Flow Story Maker — Status Summary

*As of v2.47.1 · 2026-10-18 · branch `dev`*

## What it is

A **ChatGPT project** that turns ChatGPT into a creative producer and Google Flow
prompt engineer: a user goes from a rough idea (or a Filipino riddle) to a
continuity-aware, copy-ready Google Flow production package — story plan, clip
prompts, and a reference image.

The generator **is the project's Instructions**. There is no app, no server, no
API. That single fact drives everything below.

## How it works

```
modules/*.md   →   build.sh   →   build/google-flow-story-maker.md   →   paste into ChatGPT Instructions
                                        ↑
                                  validate.sh (669 checks, exit 0 before commit)
```

- **21 modules**, one concern each, concatenated in filename order. Authored
  source is `modules/`; the build output is generated and never hand-edited.
- **One compiled file, not many** — deliberately. ChatGPT's file retrieval is
  not reliable for routing between near-identical documents, so the whole
  instruction set ships as a single paste.
- **669 validator checks.** The validator tests the *compiled artifact*, not the
  modules: build sync, version stamping, module order, section numbering,
  cross-reference resolution, interview field shape, defaults parity, the
  two-form contract, and stale-wording traps (`need_not`). Guards are written
  **red first** — a new rule fails before the module edit that satisfies it.
- `master` = production (v2.21.0). `dev` = current work (v2.45.0).

## The versions that matter

| Version | Change | The failure it fixed |
|---|---|---|
| v2.46.1 | **No photoreal style, no real human face in the deck** — at the user's call, the photoreal art styles (live-action night, VHS tape, found-footage phone, 1930s monster film) and the human-faced Teller forms (elderly woman, elderly man, ageless child) are out; six drawn/painted/constructed styles and six faceless-or-constructed Teller forms remain (faceless figure, doll or puppet, thin shadow, mannequin in the victim's clothes, headless priest, the unseen presence). Victims stay human, rendered in the chosen stylized medium. Trap-pinned: the live-action style cannot re-enter the deck (§47 +2) | Photoreal horror faces are a render liability and what the user asked out — horror lands on silhouettes, absence, and constructed forms |
| v2.46.0 | **The scoped reroll family** — `.reroll <aspect>`: `.reroll character` (victim + Teller + size as one casting), `.reroll art`, `.reroll setting`, `.reroll consequence`, `.reroll camera`, `.reroll trap` — one named aspect redrawn, everything else locked; the redraw runs the deck draw with the current value in `PREVIOUS`, so the same value **cannot** return; unknown aspect words are asked, never guessed; `.reroll riddle` named as the alias of `.reroll`; only the deliverables carrying the aspect are re-emitted (§4a dependency map). §48 — 11 checks, red-first | Two commands (`.reroll` / `.reroll visual`) forced all-or-nothing: redraw everything or hand-revise — and an LLM left to interpret a vague reroll request changes whatever it likes. Explicit commands are the user's stated principle: unpredictability is countered with exact words |
| v2.45.1 | **Wilder decks** — the draw pools widened at the user's call: settings 5→**12** (a flooded barangay street, a funeral wake with an empty coffin, a deserted cockfighting arena, a bamboo bridge over a foggy river…), art styles 4→**10** (VHS 1980s tape, grainy found-footage phone, 1930s monster film, aninaw shadow-puppet silhouettes, Pinoy horror komik, Caravaggio candlelight…), victim forms 6→**10**, Teller forms 6→**10** (a mannequin wearing the victim's own clothes, a headless priest, an unseen presence that speaks from inside the walls…), size relations 3→**4** — ~1.15M combinations against ~26k before, all still low-motion and answer-blind | The v2.45.0 mechanism was sound but the pools were too small to feel random |
| v2.45.0 | **People in the deck + a mechanical no-repeat** — three live auto-riddle runs converged into one film (stairwell ×3, elderly-woman Teller ×3, young-man victim ×3): the decks had **no people lists**, so victim/Teller/size were free-invented = model prior; and two of three runs claimed "Python randomized" with no code or output shown. The deck draw now ships **victim/Teller/size lists** drawn by the same `secrets.SystemRandom()` snippet as everything else, and no-repeat is **code, not diligence**: the previous run's printed values are pasted into `PREVIOUS` and excluded from the pool, the output's `excluding:` line makes the paste visible, and the printed draw is a checklist gate. §47 — 20 checks, red-first | Free-invented people converge — three runs, one film — and an unprinted draw is unverifiable: "Python randomized" without output is exactly where fake randomness hides |
| v2.44.0 | **Flow-first for unusual-shape ingredients** — the image tool's first live test of the trailer failed: a first-person-POV ingredient came back twice as **invented storyboard sheets** (different stories, English riddles, the invented answers printed in red, wrong language/aspect/count, zero scene elements) with the trailer verbatim in the prompt — the tool composes from the conversation's *concept*, not the scene prompt. Module 7 now offers the **Flow-side fallback first** for a first-person-POV ingredient or any shape that already returned a sheet this conversation — at most one in-chat attempt, the acceptance gate as the net. §44 +3 checks | The trailer cannot fix a render the scene prompt does not drive; the only reliable generator for the ingredient frame is Flow itself, which is scene-faithful |
| v2.43.0 | **Effect capabilities from the live stress tests** — the user's five stress tests + orientation sub-test (`docs/veo-stress-tests.md`) become pack rules: a **capability map** in module 5 (reliable: weather, lightning, wind, debris, breakage *appearance*, close-up reveal, simple reactions; unreliable: earthquake ground motion, requested camera shake — entirely absent — multi-step choreography, mid-clip orientation reversal), the **auto deck guard** (2c) and the **guided free-selection filter** (2a) keeping every option inside the map, **camera limits** (7a: no shake asks, one movement per shot, orientation held within a clip), and three gate items (15). §46 — 23 checks, red-first | The pack could propose options the model does not render: the stress tests showed requested camera shake renders **nothing**, earthquake physics fails, choreography is weak, and a walking character's orientation can flip mid-clip. Options and prompts now stay inside what is proven to render — spectacle is safe, motion is not |
| v2.42.0 | **Two riddle shapes + a consequence that reads** — a short-riddle story runs on the 3-clip shape (riddle / silent beat + failed attempt / consequence) or the 2-clip shape (riddle / silent beat + failed attempt + consequence, each separately readable, the consequence in the back half); the dedicated empty 8s wait clip is retired; an auto riddle run **draws** its shape — 2 or 3 — by actually executed `secrets.SystemRandom()` (`CLIP_COUNTS = [2, 3]`), never assuming the longer one; the final clip's consequence must **read on screen** (the Teller's one act, what it does to the victims, their visible reaction — no explanation, no ambiguity); module 06's capability table corrected to the live UI (Lite: 8-second clips only on this plan and the only model that performs the Extend; Fast/Quality: no extend; every plan is 8-second blocks); the live-run-proven prompt habits written into §7 (**camera first, spoken lines in quotation marks, ambience and effects named, negatives as a plain list**) | The clean-project live run planned **four clips** — the third a dedicated empty 8s wait block (no dialogue, no attempt, no fail) — and the user's verdict was precise: *"4 clips is too long"* — the silent wait dragged — and the consequence was **not visually clear**: you could not see what was lost. Each shape now pairs the silent beat with the failed attempt instead of giving the wait its own clip, and the consequence carries an on-screen contract: the Teller's one act, what it does to the victims, their visible reaction |
| v2.41.0 | **Image-prompt trailer + voice timbre slot** — every image prompt ends verbatim with "One single frame of one composed scene — a single shot. No storyboard, no panels, no numbered cards, no grids, no timestamp chips, no captions, titles, watermarks, labels…"; storyboard-shaped return → regenerate with the trailer as the opening sentence, a second failure reported with the copy-ready prompt offered for Flow-side generation. The voice block's timbre becomes a slot filled from the locked Teller design — deep-male wording survives only as the imposing-entity default; forcing it onto a child/female/small Teller is a checklist defect; new one-speaker rule (the Teller speaks, every victim silent) | Two live runs, one class: fixed in prose, no carrier in the prompt. ChatGPT's image tool read only the prompt and rendered 6-panel storyboard sheets (numbered panels, 0:04 chips, captions, a "Video Model" metadata bar) despite every prose ban; and the vendored voice block's hardcoded "impossibly deep, inhuman male voice" spoke the locked riddle through a small, visually female shopkeeper — the block's timbre was a constant, so it overrode the Teller design §2a had freed |
| v2.40.0 | **Code-backed randomness** — when ChatGPT's Python tool is available, every generated riddle's category/subcategory/characteristics/difficulty is drawn by actually executed `secrets.SystemRandom()` from user-editable lists (§2b); no simulated randomness, no drawn category swapped for an easier one, one draw per candidate, unique answers; answers are **randomness-guided, not uniformly random** (stated in the pack); fallback says the draw was **not code-backed**; auto's deck look-draws ride the same draw (§2c) | The wide-draw rules ask a language model for variety, and **a language model cannot roll dice** — even with a mechanism (v2.39.0's date/time seed), the roll ran inside the model, which drifts back to the head of its habits. The user's fix: randomize the ingredients with real code before writing, then find objects that fit |
| v2.39.0 | **Two modes, the option decks, Story State locks** — only `auto <type>` (± dot) triggers auto; a bare story type starts guided mode; auto draws only from user-vetted option decks (§2c: R1–R3 low-motion riddle presets, mukbang M1, jokes J1), seeded externally, never repeating the last draw; Story State (§4a) locks every field identically in both modes, scopes revisions to a dependency map, seals approved versions, and marks only dependent images/prompts for regeneration; auto delivers prompts first, then every required reference image one per message as separate clean frames; `pick riddle first` renders ten candidates + a custom box + a Notion scan; the Notion riddle log is read and written honestly; one conversation holds one story | Four permission gaps in one design: a story type named without `auto` was *read as* an auto authorization (v2.25.0's implicit trigger made the mode ambiguous); an auto run that chose free-form produced output needing correction; the revision locks lived only in prose, so a revision could drift into settled details; and auto delivered Clip 1's image while leaving later required images on demand — the user left an auto run with an incomplete package |
| v2.12.0 | Split Character and Art style; photo-as-identity; audit + validator born | Ambiguous "character sheet" conflating identity with image workflow |
| v2.13.0 | **Two-form opening** — Form 1 (setup) *produces* Form 2 (production) | ~8 turns of per-field questioning. `02-role.md` literally said "manageable, interactive steps" |
| v2.14.0 | **Riddle outcome contract** + no-silent-turn rule | The riddle ending was an *either/or*, so failing to answer was optional and a consequence was never required. Turn ordering let the chat sit on an empty reply while the image rendered |
| v2.15.0 | **`.start` always begins at Form 1** + image ratio discipline | In a thread already holding a locked riddle, `.start` skipped Form 1 entirely and showed 2 of Form 2's 4 fields. The image came back landscape for a 9:16 production |
| v2.16.0 | **Story Overview checkpoint** — the story is approved before anything is generated | The review gate existed but only under the non-default "Storyboard first" style; the default generated everything (including an image credit) in the same message as the overview |
| v2.17.0 | **Re-roll control stays visible** + riddles stop closing on "Ano ako?" | Removing the per-riddle confirmation card in v2.13.0 also removed the only place the reroll control rendered; "Ano ako?" made the reciting character claim to be the answer |
| v2.18.0 | **The answer showed through the scene.** Default riddle story is now a horror two-entity scene (Teller + trapped small victims), and everything the riddle names is banned from the visuals | The rule "the consequence must follow from the riddle's wording" *required* dramatizing the answer's own description — a cloud riddle got a dark sky and a washed-out bridge |
| v2.19.0 | **Script Overview is a markdown list** — one action step per line, instead of a prose paragraph | It was specified as "exactly one concise sentence", which is the worst shape for the one artifact the user actually reads and checks |
| v2.20.0 | **One image means one image.** A package turn generates exactly one image (Clip 1's), never a batch, sheet, or panel set — and never an image of the plan itself | Six places in the file said *more*: "1-3 images per clip" as a **planning target**, "identify the role of every image" with a role list, "for each scene", "up to two shots = two images", the plural in the method's name, and an image accordion of headers. A run returned ~8 multi-panel storyboards instead of one Clip 1 frame |
| v2.21.0 | **The supernatural Teller voice**, vendored from a prompt the user proved in Veo 3.1 Lite — plus the spoken-line slot it was missing and a duration budget that reflects the voice's slower pace | The audio side of a riddle story was one line in the prompt ("dialogue, ambience, sound effects, or silence as requested") and a six-adjective voice note. The proven prompt is 215 words of voice + audio production, with the negative-constraint tail doing the real work |
| v2.22.0 | **The `.auto` skip command** — `.auto riddle` / `.auto mukbang` locks the story path, applies defaults, and skips both forms plus the checkpoint for that run only | Users who know what they want were paying the full two-form + checkpoint cost every run; the checkpoint gate (v2.16.0) stays default-on for interactive runs, `.auto` is explicit per-run skip authorization |
| v2.23.0 | **Neutral riddle generation** — candidates are written as if no story exists yet; horror mood goes to delivery, never to riddle text or answer | Live runs returned non-riddles for horror: answers were themes (`multo`, `kababalaghan`), every riddle first-person ending `Ano ako?` — all already banned, all outvoted by the horror context. The old text even licensed the drift ("apply the mood to the wording") |
| v2.24.0 | **Allocated timestamps** — the blueprint carries a per-clip map (range + beat purpose), the consequence is held to the final clip, and the shortfall offer covers the wait too | Live runs collapsed the thinking beat: straight from riddle to consequence with no pause. The rule existed as prose with no timestamps, so nothing held the pause open; ranges are nominal 8s blocks, and the checkpoint now shows the allocation before any clip is spent |
| v2.25.0 | **Story-type words start the run** — `horror riddle`, `mukbang` + photo, no command needed | The project exists to make stories, so naming the product is the command; the trigger is request-shaped (questions, negations, bare photos, and mid-run mentions never fire), which keeps the v2.15.0 state-inference hole shut |
| v2.26.0 | **Tagalog indirect-description rule** — clues turn on oblique everyday words, wordplay as misdirection | The generator named answers directly or reached for spooky words; now `orasan`-style clues work through `mukha`/`kamay` double meanings, scoped to generated riddles in the chosen language |
| v2.27.0 | **Overview text-only** — the checkpoint is prose, Clip 1 is the run's sole image | Your screenshot caught the overview rendered as a hero + style-grid + storyboard sheet with the riddle as readable text; the old storyboard-first instructions licensed it, so they were rewritten, not just overruled |
| v2.28.0 | **Riddle spoken-only** — speech permission is never text permission | Your video showed the riddle displayed on screen; the "counts as supplied speech" sentence licensed it, so it now ends in "and nothing else," with the ban holding even when text is requested |
| v2.29.0 | **Mukbang ASMR default** — silent of speech, eating sounds only | Mukbang shipped with a standing voiceover authorization; now no talking, narration, or voiceover unless you ask — chewing, sizzle, crunch, slurp carry the soundtrack |
| v2.30.0 | **Flat riddle endings** — no trailing `?`, command not invitation | Veo 3.1's Tagalog question intonation sounded inviting; generated riddles now close flat on a period (`Ano ito.`), while your pasted riddles stay verbatim |
| v2.31.0 | **Riddle variety** — the example list stopped being a menu | The same eight-noun list appeared twice in the generator rules, so every batch came back alike; the pool is now widened and explicitly non-exhaustive, answers must differ within a batch, and a re-roll differs in answer, not wording |
| v2.32.0 | **`.revise` single-item revision** — change one item, get only the affected prompts | Late changes meant re-printing the package; now `.revise <item>` keeps everything locked and re-emits only what carries the change — a riddle swap reprints just the clip that speaks it, a character or art-style change re-emits the clip prompts and regenerates the Clip 1 reference image |
| v2.33.0 | **Reference-image binding** — the video must look like the image you gave it | Clip prompts described lighting and style in the abstract, so the video could drift from the reference image; each independently generated prompt now names its image and must match its medium, render quality, palette, lighting, and grade, a supplied photo stays photographic, and an Extend delta carries no binding because inheriting the base clip's look is the contract |
| v2.38.0 | **The 1,000-answer bank is withdrawn** — the pack ships no answer table | The user's call on v2.36.0's embedded bank. §2c, `data/riddle-answer-bank.json`, its generator, the pool's dry run and §40's freshness check are gone; §2b becomes the **answer-source rule** (draw across the ordinary world and across categories, never reuse an answer already offered, the illustrations are not a menu, `.reroll` draws from unused categories) and every pointing site was retargeted. Four traps fail the build if the bank returns. Artifact 2,561 → **1,507 lines**; the list itself is archived outside the repo |
| v2.37.2 | **The review repairs** — the two delivery blocks follow each clip's own route (Extend + ingredient-bound **or** Add clip), the ingredient hand-over has a supplied/Flow carve-out, and the ingredient-as-input capability is verified like Extend's | An independent review of v2.37.0/v2.37.1 found that "both routes for every Clip 2+" printed a keyframe-free prompt for beats the pack routes through Add clip and omitted that clip's real prompt; that the ingredient's scope swallowed Add clips; that the hand-over assumed a chat-side image even when the user supplied one or Flow made it; and that the new route named no model capability. All four fixed across 11 (both subsections), 15, 04, 05, 09, 10, 16, plus the 08/09 master-block enumerations, the 05 asset plan and Form 1's option set |
| v2.37.1 | **The forms guard** — no autonomous picking without the user's own auto trigger; Form 1 and then Form 2 are always presented and waited for | v2.37.0's §3a said an auto-mode pick is what fills a field "when the user runs `.auto`, or leaves a field blank", which reads as permission for the pack to choose for the user — against the pack's own invariant that nothing is generated before Form 1 and Form 2 are submitted. The wording now states the limit in §3a and §14, §16 gates it, and the blank-field licence is a retired-phrase trap |
| v2.37.0 | **Deliver everything the user came for** — the delivery turn prints every clip's full prompt, hands over the run's image ingredient, and prints both continuation routes for Clip 2+; every proposed set (story ideas, characters, art style) comes from a wide fresh range | The style was named "prompts now" but printed collapsed summaries and revealed a prompt only on a numbered reply, so the delivery turn held nothing to copy — *"it seems not giving all the clips prompts it should make it available to copy already"*. The picks had the bank's defect in miniature: a fixed set with no rotation rule is read from its head, so the same two ideas, three characters, and first art style returned every run. Now: all prompts in full in clip order, each in its own fenced block; the Clip 1 image handed over as the **ingredient** with its copy-ready prompt; **both** routes for each Clip 2+ (Extend delta, and an independent prompt bound to that same image needing no new keyframe); and **§3a** requires every proposed set to be drawn fresh from a wide range, differ in kind, and never re-offer what the conversation showed — including in auto mode, which must not reuse the last run's picks |
| v2.36.0 | **The answer bank is the generator's answer source** — a generated riddle's answer is drawn by an even spread across the user's 1,000-answer bank, not invented | A fresh session offered the same riddles every time. Nothing in the pack referenced the 1,000-answer bank the user had supplied, so each run invented an answer and converged on the illustrations in Step 0a (`salamin`, `kandila`, `anino`, `orasan`) — examples, read as the menu. The bank is embedded as §2c and §2b is the protocol that samples it: an even spread across the whole bank (never its head, never an invention), one **family** per batch (so `kandila sa mesa` can never follow `kandila`), `[not-an-answer]` entries skipped, an `ANSWERS-USED` record honoured, and the answer still sealed |
| v2.35.0 | **Creative diversity engine** — the riddle's structure is fixed, its look is chosen fresh every run | Twelve productions came back as one film: a small animal in a doorway or corridor, a much larger floating robed Teller, shot from behind the victim, ending with the way sealed. None of it was mandated — "small, cute, vulnerable" victims, passage-shaped traps, and sealing-shaped consequences were the *examples*, and nothing ever selected a camera. §2a splits the invariants from the visual defaults, settles nine axes each run, requires them to reduce to one coherent situation, blocks reuse of the recent design, and records a planning-only fingerprint; `.reroll visual` re-rolls the look without touching the riddle, the camera viewpoint is an explicit axis, and an image acceptance gate rejects a frame that swaps the species, scale, setting, or viewpoint — and **reports** a persistent mismatch instead of replanning the story around it |

## The pattern worth naming

**Every bug so far is the same class: the instructions left the model room to
decide what was implied, and it decided wrong.**

- v2.13.0 — "manageable, interactive steps" *implied* many turns.
- v2.14.0 — an `or` *implied* that the consequence was optional; nothing *said*
  the turn had to stay visible while an image rendered.
- v2.15.0 — "an answer already in hand" *implied* prior conversation state
  counted as settled, so both forms were skipped.

None of these were content problems. They were **permission problems** — gaps
where the model could reasonably infer a shortcut. Every fix has been to close
the gap: replace `or` with `and`, name the order of operations, define the scope
of a phrase, and add a guard so the wording cannot drift back.

**v2.35.0 is the same class, inverted: the examples read as the spec.** The
rulebook never required a small animal, a giant robed Teller, a corridor, or a
rear-view camera — it *illustrated* victims with "small, cute, vulnerable",
traps with blocked passages, and consequences with sealing and imprisonment, and
named no camera at all. A run obeyed the illustrations and ignored the absence
of the rules. So section 2a does to the visual defaults what earlier versions did
to the permission gaps: names them as illustrations, requires an explicit choice
in their place, and traps the retired phrases in the validator so the narrow
formula cannot return by drift.

**v2.37.0 is the same class a third time, in the other direction: a rule that hands over less than it names.**
The delivery style was called "prompts now" while the mechanism printed collapsed summaries and revealed a
prompt only on a numbered reply, so the prompt text — the one thing the user came for — was absent from the
delivery turn. And the option sets the pack *proposes* (story ideas, character concepts, art-style names) came
back as the same few picks every run, because a fixed set with no rotation rule is read from its head. Same fix
shape as the bank's: hand over the whole thing (every prompt, the ingredient, both routes) and give the proposed
sets a wide range, a spread, and a no-repeat record (§3a).

**v2.36.0 is the same class again: a rule that asks for a property with nothing that can produce it.**
The pack already said answers were drawn "from anywhere in the ordinary world" and that they varied — but
"the ordinary world" named no pool, "vary" named no sampling rule, and nothing recorded what had already
been used, so the only answers with any presence in the context were the four illustrations printed in Step
0a. The fix is not another sentence asking for variety; it is a real pool (the bank), a sampling rule that
spreads across it, a family rule that catches a thing and its own variant, and a used-record. Any pack that
asks for a property it never supplies is one session away from converging.

This is the single most transferable lesson for anything built on top of this.

## Honest limits

- **The validator proves the instruction is present, not that a run obeyed it.**
  Content rules — the riddle never being answered, a consequence actually
  landing, an image being the right ratio — can only be judged by reading a real
  run. Guard coverage is a floor, not a proof.
- **ChatGPT Go has no API.** Nothing can drive generation programmatically on
  this plan. Any tool around it either tracks state or bridges to a local model.
- Content correctness depends on the user's own review of a generated story.

## Related documents

- `specs/googleflow-stories_reverse_spec.md` — the full reverse spec: every
  observation, acceptance criterion, and line citation, with per-version
  resolution notes.
- Per-change specs: `two-form-flow.md`, `riddle-outcome-and-clip1-stall.md`,
  `session-state-and-clip1-image.md`, `interview-character-artstyle-split.md`,
  `validation-v2.12.0.md`, `creative-diversity.md` (v2.35.0 — the diversity
  regression, the nine axes, the dry-run sample, and the scoring rubric),
  `riddle-answer-pool.md` (v2.36.0 — the repetition defect, the bank's contents,
  the selection protocol, the dry run, and the scoring rubric),
  `delivery-and-picks.md` (v2.37.0 — the withheld prompts, the image ingredient,
  the two continuation routes, and the suggestion-variety rule), `pacing-and-consequence.md`
  (v2.42.0 — the dragged empty wait, the two shapes, the drawn 2-or-3 count, the
  consequence-visibility contract, and the live UI capability correction), and
  `effect-capabilities.md` (v2.43.0 — the stress-test log turned into the capability map,
  the deck guard, the guided filter, and the camera limits), and
  `deck-people-draw.md` (v2.45.0 — the people lists, the `PREVIOUS` paste, and the
  printed draw).
- `docs/chatgpt-interactive-components-cheatsheet.md` — the native-control
  reference the two forms are built from.
