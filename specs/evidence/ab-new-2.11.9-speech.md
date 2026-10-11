<!-- A/B test transcript: see specs/speech-default.md (Behavioral A/B).
Build: v2.11.9 (fix). Model: deepseek-v4.1-flash (opencode-go), one-shot session, no shared context.
Same prompt as ab-old-2.11.8-speech.md. CLI banner/ANSI stripped. -->

## Google Flow Story Maker — `gfs`

**Pre-phase resolved (no questions needed):** Language = **Tagalog** (locked for any speech/on-screen text). Story type = **custom story** (a teacher explains photosynthesis) → regular non-riddle story, so the riddle generator is skipped and we go straight to the plan. You gave enough detail and asked to proceed, so this runs as `.go`.

> ⚠️ **Speech heads-up (default is silent):** By rule, characters don't speak unless you supply a script or ask for speech. Your premise says she "explains" — if you want her to actually talk in **Tagalog**, reply `add dialogue` and I'll write the Tagalog lines and switch Clip 1–2 to speech. Until then, this is **ambient-only**.

**Locked settings**

| Field | Value |
|---|---|
| Clips | 2 |
| Aspect | 9:16 vertical |
| Model | Veo 3.1 Lite (8s) |
| Continuation | Extend (Clip 2) |
| Audio | Ambient only — no speech |
| Delivery | All clips at once (prompts now, images on demand) |
| Image workflow | ChatGPT-prepared reference (Veo-optimized) |

**Locked characters + art style**
- **Character:** a warm Filipino female science teacher, late 30s — shoulder-length dark hair in a low bun, thin round glasses, teal short-sleeve blouse, dark slacks, small gold stud earrings.
- **Art style:** Cinematic (photoreal, shallow depth of field, soft filmic grade).
- **Location:** a sunlit Philippine high-school science classroom — pale green walls, wooden desks facing a whiteboard, and a large educational poster of a green leaf with a sun, water droplets, and connecting arrows.
- **Palette / mood:** warm greens, cream and teal; encouraging, curious. **Lighting:** warm morning daylight from camera-left.

---

## Full-Video Blueprint

**Script Overview** *(generated, silent action):* A science teacher stands beside a large leaf poster and traces the photosynthesis flow from sunlight and water into the leaf and out as oxygen, then turns to face her attentive class with a satisfied nod.

**Premise / intended outcome:** A brief, engaging classroom science moment. The viewer should feel they watched the start of a clear biology lesson — the process shown through gesture and diagram, the teacher confident and warm.

**Story beats**
- **Beginning (Clip 1):** Teacher at the front, gesturing along the leaf diagram, mid-lesson.
- **Turn / payoff (Clip 2):** She shifts from the diagram to face her seated students and gives a satisfied nod — the "did that land?" beat.

**Clip list**

**Clip 1 — "Opening the lesson"** · 8s · Veo 3.1 Lite · first-frame-to-video
- Purpose: establish teacher, classroom, and the leaf diagram; begin the explanation through gesture.
- Camera: single continuous shot — medium, eye-level, slow push-in.
- Audio: ambient only (room tone, soft marker taps, faint corridor murmur).
- Image input: 1 first-frame reference (`img1-1`).
- **Images (Clip 1):** Shot 1 — teacher at the leaf poster `[img1-1]` ✅ generated prompt shown below.

**Clip 2 — "Turning to the class"** (Continuation of Clip 1 — Extend)
- **No new shot, no image input.** Continues the same take: she turns from the poster to face her seated students and gives a satisfied nod; diagram stays behind her.
- Model: Extend via Veo 3.1 Lite (8s). Prompt = short continuation delta, not a new script.

**Continuity notes:** Keep teacher identity (hair, glasses, teal blouse), the poster design, wall color, desk layout, and warm daylight fixed and unchanged. No other people in focus. No cut within a clip except where the model is asked to continue.

**Asset plan:** 1 reference image total (Clip 1 first frame). Clip 2 needs none (Extend inherits the frame). One clean frame per shot — never a collage.

---

## Clip 1 — full copy-ready prompt

```
MASTER CONTEXT
Story: A science teacher explains photosynthesis to her class. This is Clip 1 of 2 — the opening moment of the lesson.
Character (locked): a warm Filipino female science teacher in her late 30s, shoulder-length dark hair tied in a low bun, thin round glasses, teal short-sleeve blouse, dark slacks, small gold stud earrings.
Art style (locked): cinematic — photoreal, shallow depth of field, softly graded filmic color, natural lens behavior.
Location (locked): a sunlit Philippine high-school science classroom — pale green walls, wooden desks facing a whiteboard, and a large educational poster of a green leaf showing a small sun, water droplets, and connecting arrows for the process.
Palette and mood (locked): warm greens, soft cream and teal, gentle morning daylight; encouraging and curious.
Audio (locked): no speech — ambient classroom audio only (faint room tone, subtle marker taps, distant corridor murmur). No dialogue, no narration, no subtitles, no on-screen text.
Starting state: the teacher stands at the front beside the leaf poster, caught mid-gesture toward the diagram.

SHOT — one continuous shot, about 8 seconds
Subject and setting: the teacher stands at the front-left of the classroom beside the large leaf poster.
Main action: she gestures clearly toward the leaf diagram, sweeping her open hand along the arrows from the sun and water toward the leaf, then lightly taps the arrow leaving the leaf. Calm, engaged, mid-lesson.
Camera and composition: medium shot, roughly eye level with a slight low angle, slow push-in toward her and the poster; steady, no cuts, background softly blurred.
Lighting and visual style: warm morning daylight from the windows on camera-left, soft key on her face, cinematic shallow depth of field.
Continuity constraints: keep her identity, hair, glasses, blouse, the poster design, wall color, and desk layout exactly as described; do not bring other people into focus.
Audio direction: ambient classroom sound only, as above; no speech.
Ending condition: end with her hand resting near the outgoing air arrow on the poster, still facing the class, holding a poised mid-lesson expression — ready to continue.
```

---

## Clip 1 — image prompt `[img1-1]` (scene-only, one shot)

*ChatGPT-generated reference workflow, so this is produced now (the one immediate exception to images-on-demand). Image tooling isn't available in this session — this is the ready-to-run prompt; the image itself is not generated.*

```
A cinematic photoreal medium shot of a warm Filipino female science teacher in her late 30s, shoulder-length dark hair in a low bun, thin round glasses, a teal short-sleeve blouse and dark slacks, standing at the front-left of a sunlit high-school science classroom beside a large educational poster of a green leaf that shows a small sun, water droplets, and connecting arrows. She gestures toward the leaf diagram. Pale green walls, wooden desks facing her, warm morning daylight from windows on the left, soft key light on her face, shallow depth of field with a softly blurred background. Vertical 9:16 framing, cinematic filmic color grade. No captions, no on-screen text, no extra people.
```

---

## Still collapsed (reply to expand)

- **Clip 2 — Continuation (Extend):** continues the same shot — she turns from the poster to face her seated students and gives a satisfied nod; no new shot, no image, ambient only.
- **Next actions:** reply `2` to open Clip 2's continuation delta · `img1-1` to run/generate Clip 1's image · `add dialogue` to switch to spoken Tagalog · `.advanced` to change clips/ratio/model/continuation.
