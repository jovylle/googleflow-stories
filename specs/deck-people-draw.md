# People in the deck and a mechanical no-repeat (v2.45.0)

**Status:** built, `./build.sh && ./validate.sh` → **658 checks / 0 failed** (was 638 at
v2.44.0; +20, all in the new §47, written red-first) · in the working tree on `dev`, on
top of `9da7f34`
**Date:** 2026-10-17 · **Failure class:** three consecutive live auto-riddle runs
converged into one film — the same stairwell, the same elderly-woman Teller, the same
young-man victim — and two of the three runs claimed "Python randomized" with no code or
output shown. Randomness was the label, not the mechanism.

---

## 1. What was reported

The user pasted three `.auto riddle` runs back to back and challenged the result:

> "first of all character and art and setting not random at all. why 3 cases have same
> shits"

They were right, twice over.

## 2. The defect

### 2a. The decks had no people lists

The option decks covered preset, setting, art style, consequence act, and clip count —
**victim, Teller, and size relation were never in any deck**. On an auto run those axes
were free-invented, and free invention is model prior: the same young man, the same
elderly woman, the same stairwell every time. This is the v2.35.0 disease surviving
inside auto mode: §2a fixed free selection for guided runs, but the v2.39.0 deck redesign
gave auto four look lists and nobody put people in them.

### 2b. The draw was unverifiable where it mattered most

Run 1 printed the code and its output; runs 2 and 3 only *said* "Python randomized". An
unprinted draw cannot be checked against the no-repeat rule, cannot be compared with the
previous run's picks, and is exactly where a simulated (model-picked) draw hides — the
defect §2b/§43 were built to prevent.

## 3. What v2.45.0 ships

1. **People in the deck (2c).** New user-vetted, editable-in-place lists: **victim forms**
   (a young man, a young woman, an elderly man, a teenage student, two siblings, a
   night-shift worker), **Teller forms** (an elderly woman, an elderly man, a child who
   never ages, a faceless figure in old formal wear, a small doll or puppet, a tall thin
   shadow with a human outline), **size relations** (Teller larger / smaller / equal).
   §2a states it: **the cast is drawn, never free-invented.**
2. **One printed deck draw.** The §2c snippet now draws count + preset + setting + style +
   consequence + victim + Teller + size in a single `secrets.SystemRandom()` run, and the
   final gate (15) requires the printed output in the plan.
3. **No-repeat as code, not diligence.** The previous run's printed values are pasted into
   `PREVIOUS`; `fresh()` excludes them from the pool, so the dice cannot land on a value
   the last run took (an exhausted list falls back to full contents). The output's first
   line — `excluding: …` — makes the paste **visible**: `nothing (first draw in this
   conversation)` on a second-or-later run is a defect the user can see. Clip count stays
   exempt (the 2-3-2-3 metronome reason). Cross-conversation variety still needs the
   Notion log or a fingerprint ledger — stated honestly in the pack.
4. **Evidence.** `specs/evidence/run-shape-draw.py` executes the shipped snippet: 60 runs,
   both counts, every value inside its list, and with `PREVIOUS` filled the excluded
   values never land. §47 — 20 checks, red-first (658 / 21 failed before the module
   edits, 658 / 0 after).

## 4. Honest limits

The `PREVIOUS` paste is still a model action — it can be skipped, which is why the gate
checks the printed `excluding:` line instead of trusting the claim. Within one
conversation no-repeat is now mechanical; across conversations it remains a ledger
question, not a snippet question.
