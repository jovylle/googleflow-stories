# Spec — Two-Form Opening (v2.13.0)

**Change:** Collapse the story maker's opening from a chain of conversational questions into exactly **two forms**, where Form 1 produces Form 2.

**Trigger:** Live observation in the ChatGPT project *Google Flow Stories Dev*. A single riddle story took ~8 interactive turns to reach production.

## Observed failure (from the real transcript)

| Turn | ChatGPT did | Instruction that caused it |
|---|---|---|
| 1 | Confirmation card: "Tama ba ang teksto at sagot?" | `03:29` (old) "confirm its intended answer" |
| 2 | Re-listed all 8 candidates instead of locking | `03:76` (old) pick *or* edit, with no single-tap lock |
| 3 | Rerolled to 8 new riddles | `03:77` (old) — fine in itself, but became the only way forward |
| 4 | Second confirmation card, for #8 | same as turn 1 |
| 5 | Locked only after an explicit confirmation message | `03:78` (old) "the user picks (or edits **and confirms**)" |
| 6 | **Hakbang 1:** Story Topic + Script Overview | `02:12` (old) "manageable, interactive **steps**" |
| 7 | **Hakbang 2:** Character | `04:20` (old) listed primary fields but never required one form |
| 8 | **Hakbang 3:** Art style, … | same as turn 7 |

The model was compliant. The instructions ordered the behavior.

## New contract

> The whole opening is exactly two forms. Form 1 gathers setup and produces Form 2. Form 2 gathers production answers. Never split a form's fields across turns, never re-ask a question already answered, and never ask the user to confirm a selection they already made by selecting it.

### Form 1 of 2 — setup (`03-riddle-prephase.md`)
One form, one message, one submit. Three fields together:
1. **Language** — default Tagalog.
2. **Story type** — Riddle story / AI Option A / AI Option B / AI Option C / Other custom.
3. **Riddle source** — my own riddle / generate for me. Always shown; applies only to the Riddle story choice.

Routes once on submit: non-riddle → Form 2 with the idea pre-filled; own riddle → lock immediately (ask for the answer in one line only if it is missing); generate → present the candidate list once.

### Riddle pick — the single deliberate exception
One numbered list (5–10 candidates). A pick **locks in that same action**. No confirmation card, no re-listing. Confirmation survives only for an *edited* riddle. Locking is immediately followed by Form 2.

### Form 2 of 2 — production (`04-interview.md`)
One form, one message, one submit. All four primary fields together: Story topic + Script Overview (A), Character (B), Art style (C), Image subject/material (D). Advanced stays collapsed with defaults applied.

## Preserved invariants (explicitly not changed)

- Language-first and riddle-first sequencing.
- Every riddle told in story format (riddle spoken first, then silent beat / non-answering reactor).
- Step 0a riddle quality: concrete single ordinary answer, indirect clues, reject abstract "answers", simple words, not too short, not too easy, spoken fit ≈16–24 words / 8s, horror mood in the *wording* not the answer, self-check before presenting.
- Answer-blind planning and the single end-of-plan leak check.
- No-answer-reveal in any viewer-facing output.
- Clip count derived from the specific riddle's length (never a fixed "3 for riddles" template).
- Interview primary/advanced split, the four A–D lettering, Character and Art style as separate questions, image workflow in Advanced.

## Files changed

| File | What changed |
|---|---|
| `modules/02-role.md` | Removed "manageable, interactive steps"; added the two-form contract and the bans on per-field turns / re-asking / confirm-a-selection. |
| `modules/03-riddle-prephase.md` | §2 retitled **Form 1 of 2**; one-form intro; Step 0 became the three-field Form 1 with one-shot routing; the chained follow-up removed; pick-then-confirm replaced with single-tap lock + immediate Form 2. |
| `modules/04-interview.md` | §3 retitled **Form 2 of 2**; one-form presentation rule and the sequencing/re-asking bans. |
| `modules/14-style.md` | One form per phase; never re-ask or confirm a made selection. |
| `modules/15-defaults.md` | Pre-phase mirror reconciled to Form 1's shape; riddle toggle is a choice row, not Yes/No (**closes F6**). |
| `validate.sh` | New §12 (11 checks) incl. `need_not` traps for the stale phrasings. |
| `specs/googleflow-stories_reverse_spec.md` | §3.3/§3.4 observations, AC-002, new AC-007, F6 marked FIXED, v2.13.0 resolution section. |
| `version.txt` | 2.12.0 → 2.13.0. |

## Verification

- `./validate.sh` → **87/87 PASS** (was 76).
- The §12 guards were written first and failed 9/9 before the module edits (red → green), so they provably detect the regression they claim to.
- Compile: 19 modules, 1,096 lines.

## Residual risk

Instructions are not a runtime guard — ChatGPT can still emit a clarifying question. Mitigations: the rule is stated in three modules (`02`, `04`, `14`), the forms are explicitly labeled "Form 1 of 2" / "Form 2 of 2" so drift is visible to the user, and `.go` remains the escape hatch. If a future session shows extra turns, re-check the §12 guards rather than accepting it as model noise.
