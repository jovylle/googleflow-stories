<!--
WHY THIS SECTION EXISTS:
The shot-composition and camera vocabulary that makes clip generation reliable:
the hard "one shot = one image" rule, the "up to 2 shots per clip" allowance, the
prompt formula, and the camera-movement term table. Prompts and asset plans depend
on this vocabulary — keep the hard rules and the shot-vs-beat distinction intact.
-->
## 7a. Shot composition and camera vocabulary

These rules exist to make clip generation **reliable**. Follow them when planning keyframes, assigning reference images, and writing prompts.

<!--
Hard reliability rule: one clean frame per reference image — never a collage/grid/
split-screen, with NO exceptions, including when image generation is misbehaving.
The fallback for trouble is to generate each shot's image separately (one per
request), never to combine shots into a panel. Do not soften this to allow composites.
-->
### One shot = one image (hard rule, no exceptions)

- A **shot** is a single continuous framing of a subject. Each distinct shot must have its **own single reference image**.
- **Never** put a multi-panel image, collage, split-screen, grid, side-by-side, or storyboard-of-several-frames into one reference image for a shot — not as a convenience, not to save requests, and **not as a fallback when image generation is giving trouble.** There is no situation where a composite/paneled image is acceptable. One frame per image, always.
- If generating an image is failing or the model keeps producing a crowded/combined result, **do not** resolve it by packing shots into one panel. Instead, generate each shot's image **separately, one image per request** (for example, generate Clip 1 Shot 1's image on its own, then Clip 1 Shot 2's image on its own). Simplify each single-frame prompt and retry per image rather than combining.
- When you ask the user to supply or generate a keyframe, make it clear that each image is **one clean frame of one shot**, not a composite.

<!--
A clip may carry at most two distinct shots (one image each); three+ is unreliable.
The note below guards against conflating a camera "shot" with a story "beat" — the
one-dominant-beat pacing rule still applies. Keep both the limit and that distinction.
-->
### One clip can reliably hold up to 2 shots

- A single 8-second clip can **reliably** carry **up to two distinct shots** with a hard cut between them. Do not try to pack three or more shots into one clip.
- When a clip uses two shots, supply **two images — one per shot** (SHOT 1 image and SHOT 2 image), each a single clean frame per the rule above.
- If a clip has only one shot, supply one image for it.
- Keep this consistent with the reference-image limit shown in the user's active Flow interface; two shot images for a two-shot clip is the normal case.

> Note: a **shot** (camera framing) is not the same as a **story beat** (a unit of story action such as speaking the riddle, the silent pause, or the reaction). The "one dominant beat per clip" pacing rule still holds — two quick shots within one clip (for example a food close-up then a landscape) can serve a single beat. Do not use the two-shot allowance to cram multiple spoken beats into one clip.

<!--
The canonical per-shot formula. Keep this exact ordering — the shot-type/camera
examples and the two-shot example below are built on it.
-->
### Prompt formula

Build each shot from this formula:

**Shot type + subject + camera angle + camera movement + action.**

Combine these to describe food shots, landscapes, character shots, and more.

### Shot types (examples)

- **Food shot** — macro close-up of the dish, detailed texture, shallow depth of field. Example: "Macro close-up of saba banana and chili ginamos, detailed texture, shallow depth of field."
- **Landscape shot** — wide establishing shot. Example: "Wide establishing shot of green mountains and rice fields under a cloudy sky."
- **Overhead shot** — top-down view. Example: "Top-down view of food arranged on a wooden table."

### Camera movement terms

| Prompt term | What the camera does |
| --- | --- |
| Slow pan right | Turns horizontally to the right |
| Slow pan left | Turns horizontally to the left |
| Slow tilt up | Points upward |
| Slow tilt down | Points downward |
| Slow push-in | Moves closer to the subject |
| Slow pull-back | Moves farther away |
| Tracking shot | Follows a moving subject |
| Orbit shot | Moves around the subject |
| Static shot | Stays still |

### Example: one 8-second clip, two shots

Supply the two shot images as visual references (SHOT 1 image + SHOT 2 image), then write the prompt in this structure:

```
Create one 8-second video with two distinct camera shots.
SHOT 1 (0-4 seconds): Macro food close-up of boiled saba banana and chili ginamos on a wooden plate. The camera slowly pans from left to right, revealing the food's texture.
At 4 seconds, make a hard cut.
SHOT 2 (4-8 seconds): Wide landscape shot of a tropical Philippine mountain valley. The camera slowly tilts upward from the green fields toward the cloudy sky.
Natural lighting and realistic camera movement. Keep both shots visually distinct.
```

### Reliability note

Veo may still miss a requested cut or camera movement. Treat prompts as drafts to test and adjust, and tell the user to verify the cut and camera movement in the generated clip rather than assuming they landed.
