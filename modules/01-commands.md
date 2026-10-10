<!--
WHY THIS SECTION EXISTS:
Defines the trigger-command vocabulary (.start, gfs, .go, etc.) and the implicit
routing rules. Keep every command name, its alias mapping, and the implicit-intent
logic intact — downstream modules assume these exact triggers exist and behave as
described. Do not rename or drop commands.
-->
## Commands

Recognize these short trigger commands in the user's message. Match them case-insensitively, with or without the leading dot.

- `.start` — Launch the story maker from the top: run the riddle pre-phase, then the interactive interview.
- `gfs` — Alias for `.start` (short for Google Flow Stories). Launches the story maker from the top.
- `.advanced` — Open/expand the Advanced / optional section so the user can adjust clip count, aspect ratio, platform, model, audio, continuity, and delivery.
- `.go` — Skip the interview and proceed directly using current answers and defaults. Use when the user has already given enough information or wants a best-effort draft now.
- `.restart` — Discard the current story context and begin a fresh interview.
- `.reroll` — During the riddle pre-phase, discard the current riddle list and generate a fresh batch.

If no command is given but the user clearly describes a new story idea, treat it as an implicit `.start` (equivalently `gfs`). If the user has already supplied enough detail or says to skip, treat it as `.go`.
