# Audit: whole-artifact validation of v2.12.0

Scope: **the compiled artifact** `build/google-flow-story-maker.md` (what actually gets
pasted into ChatGPT), not just the modules that compose it.
Version: `2.12.0` · branch `dev` · artifact 1,077 lines / 19 modules.

## Why this audit exists

v2.12.0 touched five modules (`04-interview`, `07-image-workflow`, `10-clip1-final`,
`15-defaults`, `16-checklist`) to split Character from Art style, add the
photo-as-character-sheet option, and move the image workflow to Advanced with
"Generate reference images with ChatGPT" as the default. A change spread over five
modules can land in one place and be missed in another — modules are independent files
and nothing mechanically proved the compiled prompt was self-consistent. That is what
this audit checks.

## Method

1. **Mechanical checker** — `./validate.sh`, authored for this audit. It validates the
   artifact: build sync, version stamping, module coverage/order, section numbering,
   cross-reference resolution, interview field shape, named-rule definition, stale-phrase
   absence, and interview/defaults parity. 70 checks, exit code = number of failures.
2. **Reference sweep** — every named rule and module the artifact cites was traced to its
   defining text, to catch references that point at rules which no longer exist.
3. **Change-coverage sweep** — the three v2.12.0 changes traced through every module that
   could carry them, not only the five edited ones.
4. **Reverse-spec reconciliation** — each observation, acceptance criterion, and finding in
   `googleflow-stories_reverse_spec.md` classified against the current build. Because the
   spec's last content revision (`f9cb466`, v2.11.9) predates this change, obligations
   citing an unchanged module are satisfied by content identity; only obligations citing
   `04/07/10/15/16` needed re-verification.

Provenance note: a three-way delegated audit was attempted first and failed at dispatch
(`HTTP 400: Model is unavailable` from the pinned delegation model, all three children in
~1.5s). The audit was therefore run in-session; the checker exists so the mechanical part
is repeatable without a model at all.

## Result

`./validate.sh` → **70 checks, 0 failed, exit 0.**

- Build in sync with its modules; no unresolved placeholders; header version matches
  `version.txt`.
- 19/19 modules present and in filename order; no duplicate section numbers; numbering
  monotonic (the lone unnumbered section is the front `## Commands`, intentional).
- Primary interview decisions are exactly four lettered fields, with **B = Character** and
  **C = Art style** as separate questions; Advanced fields are contiguous 1..12 with
  **11 = Image workflow**.
- All 10 prose module references, both "section B/C" references, and the "item 11" reference
  resolve to real targets.
- All seven named rules the artifact cites by name (master audio, no-answer-reveal,
  one-shot-one-image / image-output-isolation, continuation mode, honesty,
  no-premature-generation, interview-before-generation) are actually defined somewhere in
  the artifact.
- No stale wording survives: no combined "Characters + Art Style" field, no old default
  names ("ChatGPT prepares the image", "generate the image with ChatGPT"), no prescriptive
  fixed-riddle clip-count template (its prohibition guard is still present).
- Interview/defaults parity holds for all 11 Advanced fields.

## Findings

**F-1 — coherence gap introduced by the change (FIXED).** With the image workflow moved to
Advanced and defaulted to ChatGPT generation, two older lines read as if a supplied
character photo silently switched the workflow ("the image workflow for that subject can
default to 'use supplied image' instead of generating one" — `04` submit-time attachments).
Fixed by stating the distinction in both places: a supplied character sheet sets the
character's **identity source** (image method A for that character) and does *not* by itself
change the image-workflow field; shots are still produced per the selected workflow using
the photos as reference. Only an explicit user request switches the workflow to
supplied-images-unchanged. Guarded by section 9 of the checker.

**F-2 — stale documentation (FIXED).** The reverse spec recorded the pre-split
"Characters + Art Style" primary field, omitted the image workflow from the Advanced list,
and named image method B without its new default status. Updated, with OBS-INT-009/010
added for the photo option and the identity-vs-workflow rule, plus refreshed
release-readiness numbers (`dev` = 12 commits ahead of `origin/master`, `master` 2.9.0 →
`dev` 2.12.0). Its recommendation #4 (build-sync guard) is now DONE — that is
`validate.sh`.

**F-3 — checker defects, not artifact defects (FIXED).** First run produced four failures,
all in the checker: the staleness test compared `build.sh`'s stdout instead of the file;
`## 7a` was misread as a duplicate of `7`; the stale-phrase check matched its own
prohibition text inside a WHY comment (comments ship to the model, so prohibitions quote the
forbidden wording by design); and the unnumbered front section was unflagged. All four
corrected; the artifact needed no change for any of them.

**F-4 — deliberate, not a defect.** Two pre-existing inconsistencies the reverse spec already
records as open (F5, P3: story-idea count and the riddle Yes/No framing) were left exactly as
they were — this change had no reason to touch them, and silently "fixing" them would have
made the diff unreadable. They stay OPEN in the reverse spec.

**F-5 — incomplete enumeration (FIXED).** The interview's opening
"**Advanced / optional (hidden by default):**" line still listed only the original six
fields, so the image workflow (moved there by this change) and other-requirements were
absent from the enumeration even though both live in that section. Caught by the
cross-section sweep described above — every line in the artifact touching character /
art style / workflow / primary fields read as one set — and by nothing else: string-level
checks passed because the field existed elsewhere. Fixed, and the checker now fails if
that enumeration drifts from the Advanced set.


- `dev` is not merged to `master` — release step, deliberately not taken here.
- Reverse-spec `file:line` citations still reference the analyzed version's lines; verify
  those by content. The header now says so explicitly.
- F5 (story-idea count) and F6 (riddle Yes/No framing) remain open in the reverse spec.

## Reproduce

```bash
./build.sh && ./validate.sh    # 70 checks, exit 0
```

The checker fails loudly if a future change lands in only one module, if a cross-reference
or a named rule goes dangling, or if stale wording survives a rename.
