# Spec — v2.40.0: Code-backed randomness for the riddle ingredient draw

## The failure class

"A rule that asks for a property with nothing that can produce it" (v2.36.0's named
class) has one more layer: even when the pack *does* supply a mechanism (v2.39.0's
wide-draw rules, external date/time seed), the mechanism runs inside the model — and
**a language model cannot roll dice.** Left to itself it returns to the head of its
habits, which is the convergence defect sections 2a/2b/3a all exist to stop.

## The fix (user-supplied idea, implemented verbatim)

When ChatGPT's Python tool is available, the draw runs as **code, not the model**:
`secrets.SystemRandom()` picks every generated riddle's **category → subcategory →
characteristics (material/shape/movement/function) → difficulty** from lists shipped
in §2b ("Code-backed randomness (when Python is available)") — user-editable in
place, deck-style. ChatGPT then finds a **real object fitting the drawn constraints**
and writes the riddle under the Step 0a hard rules.

Hard rules carried with it:

- **Python must actually execute** — never simulated randomness from model-picked numbers.
- **No category swapping** — a drawn category may not be exchanged for an easier one;
  redraw (by code) instead.
- **One draw per candidate**; batch answers stay unique; the §2b batch/family rules hold.
- **Honest limit, stated in the pack:** the answers are **randomness-guided, not
  uniformly random across all possible objects** — the model still chooses the object.
- **Fallback:** code execution unavailable → ordinary-world wide-draw rule, with a
  one-line statement that the draw was **not code-backed**; never claim a Python
  draw that did not run.

**Scope:** every generated riddle, both modes (guided Step 0a and auto), plus one line
in §2c letting auto's deck look-draws (preset/setting/style) ride the same code-backed
draw when available. Guided mode's free nine-axis selection (2a) is untouched — this
only upgrades *how the dice are rolled*, not who may choose what.

**Deliberate deviation from the user's draft prompt:** candidates keep their answers
beside them in the pick list (existing Step 0a behavior — the user judges quality
before locking; the lock seals). The draft's "display riddles first, then answers"
would have changed that contract; not taken.

## What shipped

- `modules/03-riddle-prephase.md` — §2b's new subsection (the draw, the lists, the
  hard rules, the honesty line, the fallback) + the Step 0a pointer.
- `modules/03b-auto-presets.md` — auto's deck draws are code-backed when available.
- `modules/16-checklist.md` — one new gate item (Python ran, not simulated, no swap,
  fallback stated).
- `validate.sh` — new **§43** (17 checks), red-first: it failed against the artifact
  before the module edits existed.
- Artifact rebuilt; version 2.40.0; HANDOFF/SUMMARY updated.

## Honest limits

The validator proves the instruction is present. Whether ChatGPT actually runs the
Python (or quietly "forgets") is only observable live — the test is a `auto riddle`
run where you ask it to show the Python output. And the deeper limit is named in the
pack itself: ingredient-level randomness makes repetition structurally unlikely, not
mathematically uniform.
