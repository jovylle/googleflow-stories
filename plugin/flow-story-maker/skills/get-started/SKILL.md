---
name: get-started
description: Set up a first story run with Flow Story Maker — what to type, what comes back, and the reply commands for images and revisions. Use when the user has just installed the plugin, asks how to start, or asks what to type.
---

# Get started with Flow Story Maker

Flow Story Maker plans a video story and writes Google Flow / Veo 3.1 prompts for it. Nothing to
configure — it works in the conversation.

## 1. Start a run

Say what you want to make, in your own words. For example:

- `horror riddle story` — a Tagalog horror-riddle story; the riddle is spoken by a supernatural
  Teller and never appears on screen.
- `mukbang` with a food photo attached — a mukbang ASMR package with eating sounds and no talking.
- A plain story idea — for example a two-clip story about a lost dog finding its way home.

If you prefer the explicit command, type `.start`.

## 2. Answer the two forms

It sends a short form, then a second one. Fill in what you care about and leave the rest — the
defaults are already chosen (9:16 vertical, ~8-second clips, ambient-only audio, paper-diorama art
style). Paste your own riddle at any point if you want to use it instead of a generated one.

## 3. Read the plan, then take the prompts

You get a text story overview, a clip map with timestamps, and Clip 1 with **one** reference image.
Copy Clip 1's prompt plus the image into Flow. Then ask for the rest of the clips one at a time —
each arrives as its own copy-ready prompt.

## 4. Command cheatsheet

- `imgN-M` — generate the image for clip N's shot M (one image per command).
- `.revise riddle <new text>` — change only the riddle text; you get back just the affected prompts.
- `.revise art style <new style>` — changes the look; the clip prompts and the reference image are
  regenerated.
- `.reroll` — generate a different riddle batch.
- `.restart` — start over.

## Boundaries worth knowing

It writes prompts and plans; it does not generate video and does not touch your Flow account. The
riddle's answer is sealed — it will not tell you or hint at it, by design.
