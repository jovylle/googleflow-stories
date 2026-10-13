---
name: flow-story-maker
description: Turn a story idea, a riddle, or a photo into a Google Flow / Veo 3.1 production package — story overview, timestamped clip map, one reference image prompt, and copy-ready video prompts per clip, including Tagalog horror-riddle and mukbang ASMR paths. Use when the user asks for a video story plan, a riddle story, a mukbang ASMR package, Flow/Veo clip prompts, or a revision to one item of such a plan.
---

# Flow Story Maker

Read `references/gfs-instructions.md` **in full before your first reply** in a run, then follow it as
the operating manual for the entire run. That file is the complete rulebook — the interview, the
riddle rules, the clip map, the image rules, and the prompt construction. This file only routes you
into it and states the boundaries.

## When this runs

- The user wants a video story planned or produced as Flow/Veo prompts.
- The user names a story type, for example a horror riddle story or a mukbang story.
- The user supplies a photo and wants a prompt package built around it.
- The user wants one item of an already-planned production changed.

## The workflow, in order

1. **Interview.** Run the two-form flow exactly as the rulebook defines it. Do not ask per-field
   questions and do not add a riddle-confirmation round.
2. **Riddle (riddle productions only).** Generate or accept the riddle under the rulebook's riddle
   rules. Lock it, then treat its answer as sealed: the answer is never shown to the user and never
   used as design input, only checked once at the end for leaks.
3. **Story overview.** Deliver it as **text only** — one short block. No image in that turn.
4. **Clip map.** Per-clip lines with allocated timestamps and one-line beat purposes, including the
   thinking beat and the final-clip consequence.
5. **Clip 1 and the reference image.** Write the blueprint and Clip 1's prompt text first, then
   generate **exactly one image** for the run, as the last action of the turn.
6. **Remaining clips.** A prompt per clip, each opening with its timestamp header, carrying its audio
   direction, and bound to the reference image's visual qualities.

## Never

- Never display the riddle as on-screen text, subtitles, captions, or overlays — it is spoken.
- Never invent dialogue, narration, voiceover, or any speech the user did not supply or request.
- Never produce more than one image per request, and never a sheet, grid, or storyboard of images.
- Never reveal, hint at, or design around the riddle's answer.

## Output the user receives

The overview text, the clip map, the Clip 1 prompt plus its reference image, and a copy-ready prompt
for every clip. On a single-item revision, only the deliverables carrying the changed item, reported
in one line.

## Ask, stop, or decline

- Ask at the Story Overview checkpoint when the plan cannot fit the beats the user asked for.
- Ask in one line when a revision does not fit the locked plan, instead of silently re-planning.
- Decline to invent content the rulebook marks as user-supplied only — a script, a locked riddle's
  wording, or the answer.

## Priority

The user's explicit instructions in the conversation override the rulebook. The rulebook overrides
this router. When the two disagree about a step, follow the rulebook.
