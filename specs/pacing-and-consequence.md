# Pacing and consequence clarity — the two riddle shapes and the drawn count (v2.42.0)

**Status:** built, `./build.sh && ./validate.sh` → **612 checks / 0 failed** (was 575 at
v2.41.0; +37, all in the new §45) · in the working tree on `dev`, on top of `6056679`
(v2.41.0 + the tabled plan this version executes)
**Date:** 2026-10-17 · **Failure class:** a beat given a clip it cannot fill — a full
8-second block manufactured out of nothing but a pause — and a consequence that is
technically present but not *readable*: the viewer cannot see what was lost. Plus one
documentation class in the same transcript: a capability table that no longer matches the
user's actual Flow UI.

---

## 1. What was reported

The clean-project live run of v2.41.0 produced a 4-clip plan for a short riddle: the
riddle clip, an **empty 8-second wait block** (no dialogue, no attempt, no fail — the
prompted silence), a failed attempt, and the consequence. The user's verdict, verbatim:

> "4 clips is too long"

> "the consequence is not visually clear"

Two follow-ups from the same conversation shaped this version:

> "auto riddle can go 2clips or 3clips python-randomly"

— the clip count of an auto riddle run is to be **drawn by executed code**, 2 or 3, not
picked by the model and not fixed at 3.

And one UI fact the user verified against their own Flow:

> Veo 3.1 Lite shows **8-second clips only** on their plan — the Flow help page lists
> 4s/6s/8s for Lite, but their UI offers 8s only. Plan on 8-second blocks, period.

---

## 2. The defect

### 2a. The pack licensed the empty wait clip

Three sites, one shape: `05-story-planning.md` said *"A middle clip may be a thinking
beat: a full block with no new dialogue, no attempt, and no fail, held open for the
audience to guess"* — an explicit permission to spend a whole 8-second generation on
nothing — and *"do not compress them into one"* as an absolute bar against the wait and
the consequence sharing a clip. `03-riddle-prephase.md`'s pacing example walked the same
path (*"a following clip holds the silent think-beat"*). The model did exactly what the
text permitted: 32 seconds of video for a riddle that needs 24.

### 2b. The consequence was a beat without a contract

The pack required a consequence, required it in the final clip, and required it to be
answer-blind — but said nothing about **what must be on screen**. A final clip that
*something happens, vaguely, off to the side* satisfied every sentence and satisfied
nobody watching. The user's report is the acceptance criterion: you must be able to see
what was lost.

### 2c. The capability table no longer matched the user's UI

`06-model-rules.md` listed Lite as "4, 6, or 8 seconds" and left the reader to pick. On
the user's plan only 8-second blocks exist. A plan built on a 4- or 6-second option is
unbuildable in their Flow, and every duration budget in the pack (12–16 words/8s for the
Teller voice) assumes 8-second blocks anyway.

---

## 3. The fix

### 3a. The two shapes (module 03, §pacing)

Every short-riddle story now runs on one of two beat distributions, and **there is no
dedicated empty wait clip in either**:

| shape | Clip 1 | Clip 2 | Clip 3 |
|---|---|---|---|
| **3 clips** | the riddle, spoken | silent beat (front) + failed attempt (back) | the consequence |
| **2 clips** | the riddle, spoken | silent beat → failed attempt → consequence, each separately readable | — |

- A clip carries one dominant beat **plus only the shape's own adjacency**, and every
  beat sharing a clip must stay separately readable (never blurred into one).
- The guided-run clip count is still derived from *this* riddle, presented as a
  recommendation with the beat each clip carries; a riddle too long for its spoken clip
  still spreads, with the shortfall offer (an extra clip, a longer-duration model, or an
  approved trim) raised at the checkpoint.
- "Do not reintroduce a fixed riddle=3 template" survives verbatim: the shapes are the
  default *arrangements*, not a per-riddle word-count shortcut.

### 3b. The auto shape draw (module 03b, §2c — the user's amendment)

An auto riddle run **draws its shape** — never assumes the longer one. The draw is
code-backed like the ingredient draw, shipped verbatim (zero indent, lists editable in
place):

```python
# Auto riddle shape draw — run once per auto riddle run, before the blueprint.
# Edit the list here to change what the draw can pick; never edit the run.
import secrets

CLIP_COUNTS = [2, 3]

print("clips =", secrets.SystemRandom().choice(CLIP_COUNTS))
```

Two decisions stated in the pack itself:

- **The draw is exempt from the deck's no-repeat rule.** With two values, "never the
  previous run's entry" would force strict 2-3-2-3 alternation — a metronome, not a
  draw — and a repeated count is not the convergence that rule exists to stop. Worst
  case accepted: two 3s in a row. *(User may veto; the exemption sentence is one line.)*
- **Fallback honesty:** without code execution, the draw comes from the same two values
  by the external seed, and the run says the shape draw was **not code-backed** — the
  same honesty line the ingredient draw already carries.

§14's clip-count default (2 clips, guided form) is overridden by the draw on **auto
riddle runs only**; mukbang and jokes keep their shapes.

### 3c. The consequence reads on screen (modules 03, 05, 15, 16)

New contract, mirrored at every site: the final clip shows **the Teller's one act, what
it does to the victims, and their visible reaction** — the viewer must see what was
lost. One act, staged plainly: **no explanation, no ambiguity**. It stays answer-blind;
the act, not an event in the world.

### 3d. Module 06 corrected to the live UI

- **Veo 3.1 Lite: 8-second clips only on the user's plan** (4s/6s noted as existing on
  some accounts; never planned for here). *Verified live against the user's own Flow UI
  (2026-10-17).*
- **Lite is the only model that performs the Extend** (8s clips, both ratios); Fast and
  Quality take no extend; Quality takes no ingredients; video-to-video unsupported on
  the Veo three. Omni Flash marked a dated snapshot, not a planning basis.
- The project-wide rule: **plan on 8-second blocks, period.**

### 3e. The live-run prompt habits (module 08, §7)

Four habits the user's own proven Flow prompts share, now written into prompt
construction: **camera first** (shot size, angle, movement before the action), spoken
lines **in quotation marks**, ambience and specific effects **named** in the audio line
("ambient only" says what is absent, not what is heard), and negative constraints as a
**plain list**. *(The tabled plan filed these near module 06; they land in §7, prompt
construction, so the rule has one canonical home.)*

### 3f. Mirrors updated

| file | change |
|---|---|
| `modules/03-riddle-prephase.md` | consequence-reads-on-screen paragraph; shapes + pacing bullets; conflict paragraph rewritten (2-clip example removed); comment pins the auto carve-out; the dedicated-wait example retired |
| `modules/03b-auto-presets.md` | new **shape draw** block with the shipped snippet, the no-repeat exemption + reason, the fallback line |
| `modules/05-story-planning.md` | clip-map example now shows the paired beat; "empty wait block is never planned" replaces the license; the wait/consequence rule re-cut ("sharing the final clip never merges them"); shortfall offer re-pointed |
| `modules/06-model-rules.md` | capability table rewritten to the live UI; 8-second planning rule; Omni demoted to snapshot |
| `modules/08-video-prompt.md` | the four live-run prompt habits |
| `modules/15-defaults.md` | consequence mirror; auto clause gains the shape draw; clip-count default notes the auto override |
| `modules/16-checklist.md` | count matches the selection *or the draw*; shapes + no empty wait; consequence reads on screen; the drawn-by-snippet item |
| `validate.sh` | **§45** — 37 checks (31 presence, 4 retired-phrase traps, 1 executed-snippet test), written red-first. §27's and §38's re-pointed literals (`sharing the final clip never merges them`; `offer one more clip or a longer-duration model`) rode the same change |
| `specs/evidence/run-shape-draw.py` | new — extracts the shipped snippet from `modules/03b-auto-presets.md` and executes it 60× (real `secrets` entropy), asserting `clips = 2` or `3` every time and both values across runs |
| `version.txt` | `2.41.0` → **`2.42.0`** |

---

## 4. Evidence

**What is verified here (offline):**

| # | criterion | result |
|---|---|---|
| 1 | `./build.sh && ./validate.sh` | ✅ **612 / 0** |
| 2 | red-first: §45 run against the unmodified pack | ✅ **38 FAIL** — every new need, the re-pointed §27/§38 literals, the snippet test, **and all four traps catching the real stale text** (03:190 "a following clip holds the silent think-beat", 05:60 "a full block with no new dialogue, no attempt, and no fail", 05:62 "do not compress them into one", 16:54 "was never compressed into the consequence") |
| 3 | the four traps flip to green only after the rewrites | ✅ (the flip is the proof the retired licenses are gone) |
| 4 | the shipped snippet is executed, not just quoted | ✅ `specs/evidence/run-shape-draw.py`: 60 runs, both 2 and 3 drawn, nothing else; a snippet that becomes a constant or stops running fails the build |
| 5 | pre-existing invariants untouched — riddle never answered, answer-blind consequence, one-image rules, checkpoint, `.auto` skip, code-backed ingredient draw (§43), deck pins (§42) | ✅ all still green |
| 6 | handoff freshness (§24) forces `docs/HANDOFF.md` to name 2.42.0 | ✅ |
| 7 | `VALIDATE_PLUGIN=1` still fails (plugin stale by choice, untouched this round) | ✅ unchanged |

**What is NOT verified — and cannot be, offline:**

- **No live run.** The guards prove the shapes, the contract, and the draw are *present
  and unambiguous* in the compiled artifact. They cannot show that a run obeys the draw
  in the plan, pairs the beats without blurring them, or stages a readable consequence.
  That is the next live transcript — the rubric in §5 exists to judge it.
- The 2-vs-3 distribution is a fair coin by construction (`choice` over two values), but
  only repeated live runs show the model consuming the drawn count rather than
  re-deciding.

---

## 5. Live-run rubric

| what to do | what must be true |
|---|---|
| `.auto riddle`, two or three times | each plan shows a clip count of **2 or 3** — never 4 — and the count was drawn (the journey names the code-backed shape draw) |
| read the plan's clip map | **no dedicated empty wait clip**: the silent beat shares a clip with the failed attempt (and, in the 2-clip shape, with the consequence), each separately readable |
| watch the final clip's prompt | the consequence names the Teller's **one act**, what it does to the victims, and **their visible reaction** — no explanation text |
| hit the 2-clip shape | Clip 2 reads silence → attempt → consequence, in that order, never a blur; the consequence occupies the back half |
| `horror riddle` (guided) once | the plan recommends a shape tied to this riddle and lets the user accept/adjust; Advanced still pre-fills 2 clips |
| read any delivered prompt | camera first, spoken lines quoted, ambience/effects named, negatives as a plain list |
