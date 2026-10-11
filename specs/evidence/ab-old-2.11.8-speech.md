<!-- A/B test transcript: see specs/speech-default.md (Behavioral A/B).
Build: v2.11.8 (pre-fix). Model: deepseek-v4.1-flash (opencode-go), one-shot session, no shared context.
Prompt: non-riddle, NO user script — 'a teacher explains photosynthesis to her class'. CLI banner/ANSI stripped. -->

Quick heads-up before we start (one line, then we roll): **you can attach reference images and add notes anytime in this session before we proceed — I'll use them right away.**

You gave enough to skip the interview, so I'm treating this as a best-effort **`.go`**. Language is locked to **Tagalog**; this is a **non-riddle** story (no riddle, nothing to keep secret). One assumption I had to make: a teacher who **"explains"** implies she **speaks**, so I wrote a short Tagalog spoken line for Clip 1. Say the word if you want it **ambient-only / silent** and I'll flip the audio direction.

---

## Defaults applied (override any)

| Field | Value |
|---|---|
| Language | **Tagalog** (spoken line) |
| Story type | Non-riddle (custom) |
| Characters + style | Locked default: **Maya**, teacher · **3D render** (Pixar/Blender) — swap options below |
| Clips | **2** (your choice) |
| Aspect | **9:16** (your choice) |
| Platform | TikTok / Reels / Shorts |
| Model | **Veo 3.1 Lite**, 8s |
| Audio | Model-generated · teacher speaks Tagalog *(assumption — see above)* |
| Continuity | High |
| Clip 2 mode | **Extend** (8s Veo 3.1 Lite, no input image) |
| Delivery | **All clips at once** — prompts now, images on demand (Clip 1 image revealed now) |

**Pacing note:** 2 × 8s ≈ 16s. That fits *one lesson moment* well. A full photosynthesis walkthrough (light → water → sugar → oxygen) would want more clips — tell me and I'll extend the plan. Not cramming beats: Clip 1 carries the explanation, Clip 2 carries the class reaction.

**Swap options (if you want a different look):**
- Characters — **A:** Maya (locked). **B:** a cheerful male teacher in his 40s with a bow tie. **C:** a young student presenting at the board. Or type your own.
- Art style — **Photorealistic** · **Cinematic** · **3D render (locked)** · **Anime** · **Flat illustration** · **Claymation** · **Watercolor** · **Comic**. Each is a one-line-description look; pick any.

---

## Full Blueprint — "Ang Photosynthesis" (2 clips · 9:16 · Tagalog)

**Script Overview:** A warm Filipina science teacher explains photosynthesis at her classroom whiteboard, then pauses as her students lean in and react.

**Premise & intended outcome:** In a bright classroom, the teacher introduces how plants make food from sunlight, water, and air. The viewer should feel a friendly, curious classroom moment and grasp the core idea.

**Story beats:** Begin with the teacher introducing photosynthesis (Clip 1) → she finishes her point and the class reacts (Clip 2) → hold on a moment of understanding.

**Continuity notes (must not drift):**
- **Maya:** Filipina woman, early 30s, shoulder-length black hair in a low ponytail, round glasses, olive-green button blouse, tan slacks.
- **Art style:** polished 3D render (Pixar/Blender look), clean surfaces, soft global illumination.
- **Location:** bright classroom; large whiteboard with a **wordless** diagram (leaf, sun, water drop, arrows — no text); wooden desks; students seated, backs to camera, softly out of focus.
- **Palette / lighting / mood:** fresh greens, warm wood, soft cream / soft window daylight + warm fill / curious, friendly.
- **Voice:** female, warm and clear, moderate pace, Tagalog (Filipino), neutral Metro Manila accent.

**Asset plan:** Clip 1 → **1 image** (ChatGPT-generated first frame, `img1-1`). Clip 2 → **Extend**, needs **no image**.

### Clip list

**Clip 1 — "The Lesson Begins"** · 8s · Veo 3.1 Lite · 9:16
- Purpose: deliver the teacher's opening explanation.
- Action: Maya explains photosynthesis, gesturing to the wordless diagram, then turns her open palm toward the class.
- Camera: medium shot, eye level, very slow push-in, shallow depth of field.
- Audio: one Tagalog line + soft classroom ambience.
- Image: `img1-1` (first frame).
- Ends on: Maya mid-gesture, hand toward the class, still at the board.

**Clip 2 — "The Class Reacts"** *(Continuation of Clip 1 · Extend)* · 8s · Veo 3.1 Lite · 9:16
- Purpose: continuation — the one small change.
- **No new shot, no new image, no new script.** Continues Clip 1's final frame and camera.
- Change: Maya settles, lowers her hand and smiles; students lean in and one raises a hand.
- Audio: ambient only (say the word for **continued Tagalog speech**).
- Ends on: a held, settled moment of understanding.

---

## Delivery — All clips at once (prompts now, images on demand)

### 🎬 Clip 1 — full copy-ready prompt

```text
MASTER CONTEXT — "Ang Photosynthesis" · Clip 1 of 2 · Vertical 9:16 · Veo 3.1 Lite · 8 seconds
Story: a warm Filipina science teacher explains photosynthesis to her class.
Locked character: MAYA (teacher) — Filipina woman, early 30s, shoulder-length black hair in a low ponytail, round glasses, olive-green button blouse, tan slacks. Warm, confident, encouraging.
Locked voice: female, warm and clear, moderate pace, Tagalog (Filipino), neutral Metro Manila accent.
Art style: polished 3D render (Pixar/Blender look) — clean surfaces, soft global illumination, appealing stylized characters.
Location: bright classroom; large whiteboard behind her with a WORDLESS diagram (green leaf, yellow sun, blue water drop, arrows); wooden desks; students seated, backs to camera, softly out of focus in the foreground.
Palette: fresh greens, warm wood, soft cream. Lighting: soft daylight from windows on the left, gentle warm fill. Mood: curious, friendly, encouraging.
Continuity: keep Maya's face, hair, glasses, olive blouse, and the classroom layout identical.
Handoff: opening clip — no previous clip. Starting state: Maya standing at the board, facing the class.

REFERENCE: Use the supplied first-frame image for Maya and the classroom. Keep her identity, wardrobe, and the room exactly as shown; do not alter her face or the diagram.

SUBJECT & SETTING: Maya stands at the whiteboard in the classroom above; softly blurred students fill the lower foreground.

MAIN ACTION: Maya explains photosynthesis — she speaks her line while gesturing to the wordless leaf diagram behind her, then turns her open palm toward the class.

CAMERA: Medium shot, eye level, static frame with a very slow push-in toward Maya. Shallow depth of field; students stay a soft blur.

LIGHTING & STYLE: As in the master context — soft window daylight and warm fill; polished 3D-render look.

CONTINUITY: Do not change Maya's look, the classroom, or the diagram.

AUDIO: Maya speaks one line in warm, clear Tagalog: "Ang photosynthesis ay kung paano gumagawa ng pagkain ang halaman, gamit ang sikat ng araw, tubig, at hangin." Soft classroom ambience underneath. No subtitles, captions, on-screen text, or music.

ENDING: End on Maya mid-gesture, hand open toward the class, warm expression, still at the board — ready for Clip 2 to continue.
```

**Clip 1 images:** Shot 1 — medium shot, Maya at the board `[img1-1]`
*(Clip 1's image is revealed now as the immediate exception; generation runs on the `img1-1` command.)*

```text
A polished 3D-render (Pixar/Blender look) still, vertical 9:16. A warm Filipina science teacher in her early 30s with shoulder-length black hair in a low ponytail, round glasses, and an olive-green button blouse stands at a bright classroom whiteboard, one hand gesturing toward a simple WORDLESS leaf diagram (a green leaf, a yellow sun, a blue water drop, and arrows) drawn on the board. Friendly, encouraging expression, mouth open mid-explanation, looking toward softly blurred students whose backs fill the lower foreground. Medium shot, eye level, shallow depth of field, soft daylight from windows on the left, warm cream and green palette, clean soft lighting. No text, no letters, no watermarks, no captions.
```

### 🎬 Clip 2 — summary only *(collapsed)*

**Continuation of Clip 1 (Extend)** · 8s · Veo 3.1 Lite · 9:16 · **No image input** — it continues Clip 1's final frame via a short continuation delta (no new scene, no re-established character/costume/lighting).

---

**Next action — reply with a command:**
- `2` → reveal Clip 2's full continuation prompt (Expand, ready to paste into Flow's Extend box)
- `img1-1` → reveal + generate Clip 1's image
- `swap` → change character (A/B/C) or art style
- `silent` → switch Clip 1 to ambient-only (no spoken line)
- `expand` → add more clips for a fuller photosynthesis explanation
