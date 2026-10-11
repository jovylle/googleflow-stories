# Google Flow Story Maker

A **ChatGPT project** that turns ChatGPT into a creative producer and Google Flow prompt engineer, guiding a user from a rough story idea to a continuity-aware, Google Flow-ready production package.

The instructions are authored as small modules and compiled into **one** file to paste into the ChatGPT project.

## Repository layout

```
.
├── modules/        # authored source — edit these (one concern per file)
├── version.txt     # the version number stamped into the build
├── build.sh        # concatenates modules (in filename order) → build/
├── build/
│   └── google-flow-story-maker.md   # GENERATED — paste this into ChatGPT
├── docs/           # SUMMARY.md (version history) + HANDOFF.md (resume point)
├── specs/          # reverse spec, per-change specs, A/B evidence
├── validate.sh     # structural validation of the compiled file
└── README.md
```

**Resuming work here?** Read `docs/HANDOFF.md` first — it carries the current state, the next
steps in order, the unactioned defects, and the open questions. Nothing else needs a previous
conversation.

- Modules are concatenated in **filename order** (`00-`, `01-`, `02-`, …), so the numeric prefixes define the document order.
- The `{{VERSION}}` placeholder in `modules/00-header.md` is replaced with the contents of `version.txt` at build time.
- `build/google-flow-story-maker.md` is generated — do not hand-edit it. Edit the modules and rebuild.

## Build

```bash
./build.sh
```

Outputs `build/google-flow-story-maker.md` (portable; works on stock macOS bash and Linux).

## Validate

```bash
./validate.sh
```

Checks the **compiled artifact** (not just the modules): build sync, version
stamping, every module present in filename order, section numbering,
cross-reference resolution, the interview's primary/advanced field shape, defaults
parity between the interview and defaults modules, the two-form flow contract
(Form 1 produces Form 2 — no per-field turns, no riddle confirmation round), and
absence of stale wording.
Exit code 0 = pass. Run it before committing.

## Use in ChatGPT

1. Run `./build.sh`.
2. Paste the contents of `build/google-flow-story-maker.md` into the ChatGPT project's **Instructions**.
3. Start a chat and type `.start` to launch the story maker.

Keeping a single compiled file avoids relying on ChatGPT's file retrieval (RAG) to assemble instructions, which is not reliable for routing between near-identical documents.

## Branch model

- `master` — production. The compiled instructions here are the ones in active use.
- `dev` — work in progress. Develop and test module changes here, then merge to `master` to release.

Versioning is handled by git branches (and `version.txt`), not by multiple instruction files.

## Editing workflow

1. Switch to `dev`.
2. Edit the relevant file(s) in `modules/`. Bump `version.txt` if releasing.
3. Run `./build.sh` and review `build/google-flow-story-maker.md`.
4. Run `./validate.sh` — it must pass before committing.
5. Commit, and merge to `master` when ready to release.
