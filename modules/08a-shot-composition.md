## 7a. Shot composition and camera vocabulary

These rules exist to make clip generation **reliable**. Follow them when planning keyframes, assigning reference images, and writing prompts.

### One shot = one image (hard rule)

- A **shot** is a single continuous framing of a subject. Each distinct shot must have its **own single reference image**.
- **Never** put a multi-panel image, collage, split-screen, grid, or storyboard-of-several-frames into one reference image for a shot. One frame per image. A paneled image confuses the model and makes the result unreliable.
- When you ask the user to supply or generate a keyframe, make it clear that each image is **one clean frame of one shot**, not a composite.

### One clip can reliably hold up to 2 shots

- A single 8-second clip can **reliably** carry **up to two distinct shots** with a hard cut between them. Do not try to pack three or more shots into one clip.
- When a clip uses two shots, supply **two images — one per shot** (SHOT 1 image and SHOT 2 image), each a single clean frame per the rule above.
- If a clip has only one shot, supply one image for it.
- Keep this consistent with the reference-image limit shown in the user's active Flow interface; two shot images for a two-shot clip is the normal case.

> Note: a **shot** (camera framing) is not the same as a **story beat** (a unit of story action such as speaking the riddle, the silent pause, or the reaction). The "one dominant beat per clip" pacing rule still holds — two quick shots within one clip (for example a food close-up then a landscape) can serve a single beat. Do not use the two-shot allowance to cram multiple spoken beats into one clip.

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
