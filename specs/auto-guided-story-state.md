# Spec — v2.39.0: Two modes, the option decks, and Story State locks

## The failure class (one more instance)

Every version in this pack is the same class: the instructions left the model room to
decide what was implied, and it decided wrong. v2.39.0 is that class four times over,
reported by the user as design problems rather than from a single live run:

1. **The trigger was ambiguous.** v2.25.0 made a message that named the story type
   (`horror riddle`) an `.auto` authorization — so "riddle" could mean "run it for me"
   or "let's make a story", and the pack had to guess. The guess is removed: **only
   the word `auto` before the type authorizes auto mode**; a type named without it is
   a guided-mode start (an implicit `.start`, forms first).
2. **Auto chose free-form.** An auto run that settles nine axes freely produces output
   the user has to correct. Now an auto run draws **only from the option decks
   (section 2c)** — user-vetted presets and allowed lists, drawn at random (external
   seed, never the head of the deck, never the previous run's draw). The deck is the
   user's file to edit; the run may not exceed it.
3. **The locks lived in prose.** `.revise` (v2.32.0) said "one item changes" but the
   locks were scattered sentences across a long conversation. Now the **Story State
   (section 4a)** holds every settled value as its own field, **locked the moment it
   is chosen — identically hard in auto and guided mode** (the mode decides who chose,
   never how well it is protected). A revision propagates **only along the dependency
   map**; anything unreachable stays byte-identical. Approval **seals** a version; a
   later edit bumps the version by one and marks **only dependent images and prompts**
   for regeneration. Worked example, pinned by a guard: changing Clip 2's camera
   preserves the locked riddle and character, and re-checks Clip 3's opening state.
4. **Auto's delivery held images back.** The default delivery keeps images on demand
   (v2.20.0's one-image rule), but an auto run is a "run it for me" contract — it
   delivers **prompts first as text**, then **every required reference image, one per
   message, each a separate clean frame** — never a collage. The one-image-per-action
   rule is sequenced, not relaxed.

## The riddle sources (three, in order)

1. **User-pasted text** — locked exactly as written, never rewritten.
2. **The Notion riddle log** (when connected) — read before choosing (reject repeats,
   same answer family, reworded same-clue riddles), written on lock (`Chosen`) and on
   the user's word (`Done` + Flow link). Unavailable → say the riddle was **not
   logged**; never claim a check or write that did not happen.
3. **AI-generated** — the default, under the answer-source rule (2b).

The **pick-riddle-first modifier** (`auto riddle, lets pick riddle first`) defers the
riddle lock and renders one selection form: **ten generated candidates from ten
different answer families**, a **custom riddle box** (paste → verbatim lock), and a
**Scan Notion button** (progressive enhancement; typed fallback always works).
Riddle-only for now — the mechanism extends to other aspects later if reached for.

**One conversation holds one story.** A second, different story in the same chat is
pointed to a fresh chat in one line; `.revise`/`.reroll` on the delivered story still
work.

## What shipped

- `modules/03b-auto-presets.md` (new, **§2c**) — the trigger boundary, the option
  decks (R1–R3 riddle presets, mukbang M1, jokes J1 + allowed look lists), the
  randomness rules, missing-attachment asking, auto delivery order, the
  pick-riddle-first form, and the Notion log protocol.
- `modules/05a-story-state.md` (new, **§4a**) — the Story State schema, field locks,
  the dependency map, seals and versions, the worked example.
- `modules/01-commands.md` — trigger cases rewritten (auto ± dot; type-without-auto =
  guided; one-story rule; `.go` never applies decks; `.revise` tied to the locks;
  pick-first named).
- `modules/02-role.md`, `modules/04-interview.md` — the auto-trigger boundary mirrors.
- `modules/03-riddle-prephase.md` — §2a gains "Auto runs draw from the option decks";
  Step 0a honours the pick-first modifier.
- `modules/05-story-planning.md`, `modules/10-clip1-final.md` — "only image in the
  run" claims scoped to non-auto runs; checkpoint-skip list no longer includes
  story-type messages.
- `modules/11-output-format.md` — **auto-run delivery** subsection.
- `modules/15-defaults.md` — the auto-mode defaults paragraph rewritten around the decks.
- `modules/16-checklist.md` — eight new gate items; the two trigger items rewritten.
- `validate.sh` — §28 rewritten for the new trigger contract; §39's two auto-look
  guards retargeted to the deck; §30's Clip-1-sole-image literal scoped; new **§42**
  (58 checks) pinning all of it, red-first.
- Artifact rebuilt: 1,507 → ~1,641 lines.

## Honest limits

The validator proves the rules are present, not that a run obeys them. The live
ChatGPT project is still on v2.12.0 and nothing here is proven until it is pasted and
run: `auto riddle` twice (different presets, no shared picks), `auto riddle pick
riddle first` (the form renders, a pasted riddle locks verbatim), `horror riddle`
alone (guided, forms first), a mukbang without a face photo (asked for, not invented),
and a Clip 2 camera `.revise` (everything else byte-identical, version bumped).
