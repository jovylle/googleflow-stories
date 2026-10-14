# The answer bank — generated riddles stop repeating

**Change:** v2.36.0 · **Target:** `build/google-flow-story-maker.md` (the `.md` source instructions)
**Status:** built, `./validate.sh` → **415 checks / 0 failed** · **uncommitted**
**Priority:** High — reported from live sessions: *"most of its first options are just the same riddles I
keep seeing on its random generator its absolutely not picking on the 1K riddle answers I gave."*

## The defect

Starting a **new session** and asking for a riddle story produced the same handful of riddles again and
again. The user had supplied a 1,000-answer list and the generator acted as if it did not exist.

The user's tell:

```
[[ 1. May leeg ngun.. [27 lines] .. n upang mabasa. Sagot: Liham ]]
```

A stable 27-line window from the head of a numbered `Sagot:` list, recurring every session. A fixed head
window is what a retrieval with no sampling looks like: the same first entries, every time.

## Root cause

Two independent halves, and only the first one is in this repo's control:

1. **The pack had never heard of the bank.** `grep -rn "answer bank\|answer pool\|1,?000 answer\|seed bank\|BUG-0"
   modules/ docs/ specs/ validate.sh build/` → **0 hits.** Nothing connected the supplied list to the
   generator, so the generator invented an answer every time.
2. **Inventing an answer converges.** The only answers *present in the context* were the illustrations
   printed in Step 0a of the riddle pre-phase — `salamin`, `kandila`, `anino`, `orasan` — plus whatever
   the model had already produced in that conversation. The instruction said answers came "from anywhere
   in the ordinary world" and to vary them; "the ordinary world" is not a pool, "vary" is not a sampling
   rule, and nothing recorded what had already been used. The two most frequent answers in the user's own
   bank (`salamin`, `kandila`) are also the two illustrations.

The pack had exactly two riddle sources before this change — *the user pastes their own riddle* and
*generate riddles for me* — and no way to say "draw from this list".

## What the bank actually is

Measured from `data/riddle-answer-bank.json` (the user's *Filipino Riddle Answer Bank* v1.0.0):

| Property | Value |
|---|---|
| Entries | **1,000** (`BUG-0001` → `BUG-1000`) |
| Distinct answer strings | 1,000 |
| **Families** (head-noun / bare answer) | **865** |
| Entries that are a variant of another entry | **135** (`salamin` ×12, `susi` ×11, `kandila` ×10, `ibon` ×5 …) |
| Multi-word answers | 194 (e.g. `kandila sa mesa`, `susi ng paaralan`) |
| **Description-shaped entries** (not a thing to guess) | **21** (`orasan na walang kamay`, `liham na walang pirma`, `salaming walang repleksiyon`) |
| Categories | 10 · Difficulty: `medium` / `hard` · `used`: all `false` |
| `attributes` | **empty on all 1,000** (the bank's own note says to populate them before production clue generation) |

The family count is the operative number: answer uniqueness alone would still have allowed a batch of
`kandila`, `kandila sa mesa`, `kandila sa kusina`, `susi`, `susi ng paaralan` — five "distinct" answers
that a listener hears as two riddles about a candle and a key.

## The design

Three pieces, all mechanical:

1. **`data/riddle-answer-bank.json`** — the bank, verbatim, in the repo.
2. **`scripts/build-answer-bank.py`** → **`modules/03a-answer-bank.md` (§2c)** — the bank rendered for the
   model. One line per answer: `NNNN answer`, plus `[family]` when the family is not the answer itself,
   plus `[not-an-answer]` on the 21 description-shaped entries. The 4-digit prefix is the bank's own id.
   The family is **derived** by the script, never hand-listed, so re-running it on a changed bank cannot
   drift. `--check` re-renders in memory and diffs, and `validate.sh` §40 runs it — a stale module fails
   the build.
3. **§2b, the selection protocol** (`modules/03-riddle-prephase.md`) — the part that was missing:
   - the bank **is the set to choose from**; the Step 0a illustrations are illustrations, and the
     generator's own invention is not a source;
   - **spread a batch across the whole bank** — `1,000 / N` stride from a start index the run picks for
     itself; **never start at 0001**, never take the first few entries, never reuse a start in one
     conversation, and pick a fresh start on every re-roll (so `.reroll` draws from a different part of
     the bank, not a reshuffle of the same five);
   - **no two candidates in one batch may share a family**, and no family repeats across the batches of
     one conversation;
   - **skip entries that are not answers**, and skip an entry whose family or answer is already used —
     the candidate count is made up by stepping along the spread, never by dropping to four candidates;
   - when the user keeps a list, the used answers are kept in an `ANSWERS-USED` record on the plan record
     (planning state only — the sealed answer never reaches a clip prompt, an image prompt, or the story);
   - **nothing about the bank changes the riddle text**: the riddle is still written fresh under every
     hard rule in Step 0a, and the answer still never leaks.

### Alternatives rejected

- **"Just tell it to vary more."** That is what the pack already said. A property with no mechanism does
  not appear; this is the same failure shape as v2.35.0 (illustrations read as the spec).
- **Ship the bank as a ChatGPT project file.** The user chose the embedded module: one paste, no upload to
  keep in sync, and no retrieval step that can silently return the head of a list.
- **Prune the 135 variant entries.** Rejected by the user, and unnecessary: tagged families give the same
  effect non-destructively, and a variant (`kandila sa mesa`) is a *better* riddle answer than the bare
  noun when the batch does not already contain `kandila`.
- **A used-ledger only.** Insufficient on its own — a ledger that is never read from a spread still starts
  at the top and walks forward, so consecutive batches stay clustered.

## Evidence

`specs/evidence/answer-pool-dry-run.tsv` — 30 picks over 6 batches, produced by **applying §2b to the real
bank** (`specs/evidence/score-answer-pool-dry-run.py` re-derives every expectation from the JSON, so the
sample cannot certify itself). `./validate.sh` §40 runs the scorer:

```
PASS  every pick is a real bank entry (index, answer, family recomputed)  — 30/30 verified
PASS  no [not-an-answer] entry was picked as an answer  — picked []
PASS  no two candidates in one batch share a family  — 0 collisions in 6 batches
PASS  no family repeats anywhere in the sample  — repeated: []
PASS  each batch is evenly spread across the bank (gaps 80-320)  — 5 picks per batch, stride ~200
PASS  no batch started at the head of the list  — starting indexes: 0317, 0742, 0088, 0559, 0913, 0205
PASS  the head decile is not over-represented  — 2/30 picks in the first 100 indexes (fair share 3)
PASS  no two batches started at the same index
PASS  the picks span at least 8 of the bank's 10 deciles  — 10/10 covered (span 0005-0976)
PASS  picks do not drift back onto the illustration answers  — 1/30 (salamin sa kusina)

answer-pool dry run: 30 picks, all 10 criteria met
```

One criterion was corrected while writing it, and the correction is recorded rather than hidden: it first
required that *no pick* land in the first 40 indexes. A batch that wraps round the end of the bank
legitimately reaches a low index, so the criterion was replaced by the two tests that actually describe
the defect — no batch *starts* at the head, and the head decile is not over-represented. The sample was not
adjusted to fit the test; the test was fixed to measure the right thing.

### Validator coverage (`validate.sh` §40, 29 checks)

Bank module present with its 1,000 answers and its `[not-an-answer]` tags; §2b present with each rule
(the source sentence, the illustrations-are-not-the-menu sentence, the spread subsection, "never start at
0001", the family subsection, the batch family rule, the skip subsection, the advance-the-spread rule, the
used-record, the no-invented-history rule, the no-bank fallback); every mirror site points at the bank
(Form 1's generator path, the retired ordinary-world line, the defaults row, the checklist item); both
survive the build; the module is not stale; the dry run still passes; and two `need_not` traps hold the
retired "draw answers from anywhere in the ordinary world" wording out of both the module and the build.

## Acceptance criteria

| # | Criterion | Result |
|---|---|---|
| 1 | The pack knows the bank exists | ✅ §2c embedded, §2b consumes it, 4 mirror sites point at it |
| 2 | A generated answer is a bank entry, never an invention | ✅ stated in §2b, the defaults row, the checklist item |
| 3 | Picks are spread over the bank, not taken from its head | ✅ §2b stride rule + 2 dry-run criteria |
| 4 | No batch pairs a thing with its own variant | ✅ family rule + dry-run criterion 3 |
| 5 | A re-roll draws from a different part of the bank | ✅ fresh start index, stated in §2b and `01-commands.md` |
| 6 | Description-shaped entries are never used as answers | ✅ tagged `[not-an-answer]`, skipped, dry-run criterion 2 |
| 7 | The illustrations are not the menu any more | ✅ retired line trapped by `need_not`; 1/30 in the dry run |
| 8 | The answer still never leaks | ✅ unchanged: sealed, planning-record only, banned from prompts |
| 9 | A stale bank module cannot ship | ✅ `--check` wired into §40 |
| 10 | `./validate.sh` stays green | ✅ **415 / 0** |

## Honest limits

- **The dry run is not a live run.** It proves the protocol *as written* produces a spread batch; only a
  live ChatGPT session proves the model follows it. Nothing here has been through ChatGPT yet.
- **The pack cannot force enumeration.** Asking a model to count through 1,000 lines is not reliable. §2b
  therefore asks for a stride (a start index, a fixed step) rather than "count to 1,000 and pick one" —
  but the stride is executed by the model, not by code, so the first live runs are the real test.
- **The bank's `attributes` are empty on all 1,000 entries.** The bank's own header says to populate them
  before production clue generation; nothing in this change depends on them (families are derived), but the
  clue quality of a generated riddle is still unmeasured.
- **Nothing prevents a user-supplied riddle from repeating.** A pasted riddle is preserved verbatim, by
  design — this change governs generated riddles only.

## Live-run recipe (the only step that produces evidence)

In a **new** session — so no conversation memory can help it — run `horror riddle` twice:

1. The two candidate lists must draw visibly different answers.
2. The same answer must not come back in the second batch.
3. No list may pair a thing with its own variant (`kandila` beside `kandila sa mesa`).
4. `salamin`, `kandila`, `anino`, `orasan` may appear only when the spread lands there — not by default,
   and not as most of a list.
5. Each candidate still shows its riddle with its answer noted, and the plan record carries the drawn
   indexes while the story text carries none of them.
