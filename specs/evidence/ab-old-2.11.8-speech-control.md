<!-- Control: same old build, a non-speaking premise stayed ambient-only (bug did NOT trigger). -->

## Setup

- **Trigger:** `gfs` → story maker launched from the top.
- **Riddle pre-phase:** skipped — your story is a regular (non-riddle) drama, so there's no riddle to lock.
- **Language:** Tagalog (carried through the production).
- **Using your given answers:** 2 clips · 9:16 vertical · Veo 3.1 Lite · all clips at once (prompts now, images on demand). Remaining choices use defaults.
- **Tip:** you can attach reference images (faces, the coffee-shop location) and add notes anytime — I'll fold them straight in.

**One default you may want to flip:** you specified Tagalog, but not *speech*. Per the master audio rule, I've defaulted to **ambient-only (no dialogue)**. If you want a short spoken Tagalog exchange ("Sino 'yan? … Ikaw ba 'yan?!"), say the word and I'll rewrite the audio direction for both clips. Everything below assumes ambient-only.

---

## Readiness check ✔

- [x] Non-riddle story — no riddle needed
- [x] Characters + art style locked (defaults chosen below — swappable)
- [x] Script Overview present
- [x] Clips = 2 · 9:16 · Veo 3.1 Lite · audio resolved (ambient only)
- [x] Clip 1 image planned (ChatGPT keyframe, `img1-1`)

**Locked defaults (say the word to change):**
- **Characters:** *Marisol* — mid-60s Filipina woman, silver-streaked hair in a loose bun, round tortoiseshell glasses, mustard knit cardigan over a cream blouse. *Dante* — mid-60s Filipino man, short gray hair, weathered kind face, dark navy polo, worn brown leather watch.
- **Art style:** Cinematic (photoreal, graded like film — shallow depth of field, warm key light).
- **Genre:** warm slice-of-life drama.

---

# Full blueprint — "Reunion at the Coffee Shop"

**Script Overview:** In a warmly sunlit coffee shop, one old friend lifts her gaze from her cup and recognizes the other across the room, and that first spark of recognition blooms into a slow, joyful reunion as they rise and move into a warm embrace.

**Premise & intended outcome:** Two people who lost touch for years land in the same café by chance. The viewer should feel the quiet shock of familiarity, then the warmth of a friendship that never really expired.

**Story beats**
- **Beginning (Clip 1):** *Recognition* — the spark. Marisol looks up and realizes who she's seeing.
- **Turning point → payoff (Clip 2):** *The reunion* — the recognition breaks into delight; they close the distance and embrace.

**Clip list (2 clips, 9:16, Veo 3.1 Lite)**

| Clip | Beat | Duration / Model | Image input | Continuity |
|---|---|---|---|---|
| **1** | Recognition | 8s · Veo 3.1 Lite | 1 image (`img1-1`, ChatGPT keyframe) | Opening clip; ends on Marisol's recognition smile, gaze across the room |
| **2** | The reunion | 8s · Veo 3.1 Lite (**Extend**) | **No image input** — continues Clip 1 | Starts exactly from Clip 1's final frame; same framing, no cut, no re-establishing |

**Continuity notes (must not drift):** Marisol's identity, glasses, bun, cardigan; Dante's gray hair, navy polo, watch; the wooden table, her cup, the large window, and the golden late-afternoon light; warm amber/honey/soft-green palette; the same café space.

**Asset plan:** One deliberate reference — **`img1-1`**, Clip 1's opening keyframe (ChatGPT-generated, scene-only). Clip 2 is an **Extend** clip, so it needs **no** new image.

**Model note (baseline, re-verify in your Flow UI):** Veo 3.1 Lite supports 4/6/8s portrait, and all Veo 3.1 8s clips can be **extended** — the Extend action itself runs on Veo 3.1 Lite and takes no input images. That's why Clip 2 uses Extend, not a new keyframe.

---

## Clip 1 — full copy-ready prompt

**Purpose:** the moment of recognition (one dominant beat). **Duration:** 8s · **Model:** Veo 3.1 Lite · **Aspect:** 9:16 · **Image input:** `img1-1` (opening keyframe).

```
MASTER CONTEXT — "Reunion at the Coffee Shop" (2 clips, vertical 9:16).
Clip 1 of 2 — the moment of recognition.
Constants: warm cinematic photorealistic look; a sunlit neighborhood coffee shop in the Philippines, late afternoon; wooden tables, hanging plants, a large window with soft golden light spilling in; palette of warm amber, honey, and soft green; mood nostalgic and tender.
CHARACTER A (Marisol): mid-60s Filipina woman, silver-streaked hair in a loose bun, round tortoiseshell glasses, mustard knit cardigan over a cream blouse, gentle lined face.
CHARACTER B (Dante, seen softly): mid-60s Filipino man, short gray hair, weathered kind face, dark navy polo, worn brown leather watch.
AUDIO/VOICE: no speech — ambient coffee-shop sound only (soft patron murmur, clink of cups, low distant music). No dialogue, no narration, no subtitles, no on-screen text.
Continuity: this is the opening clip; the end state must be Marisol looking across the room with recognition on her face, so Clip 2 can continue from it.

REFERENCE: Use the attached keyframe (img1-1) as the exact opening frame — keep Marisol's face, wardrobe, the table, the window light, and the coffee shop unchanged.

SUBJECT & SETTING: Marisol seated alone at a wooden table beside the large sunlit window, a half-finished cup of coffee in front of her. Far across the room, Dante stands near the entrance, softly out of focus.

MAIN ACTION: Marisol lifts her gaze from her cup; her calm expression shifts into startled recognition as a small, involuntary smile forms — she realizes who she is looking at.

CAMERA: Vertical 9:16. Static medium shot with a very slow push-in toward Marisol's face; shallow depth of field keeps her sharp and the room soft.

LIGHTING & STYLE: Cinematic photorealistic, warm golden late-afternoon light through the window, soft filmic contrast, a gentle highlight on her face.

CONTINUITY: Keep Marisol's identity, glasses, cardigan, hairstyle, her cup, and the window light identical throughout. Do not change wardrobe, age, or setting.

AUDIO: Ambient coffee-shop only — quiet murmur of other patrons, clink of cups, low distant music. No spoken dialogue, no narration, no subtitles, captions, or text overlays.

ENDING CONDITION: End held on Marisol's face as the recognition settles into a soft smile, her gaze fixed across the room — hold this as the starting state for Clip 2.
```

**Clip 1 image** — `img1-1` (scene-only, one clean frame; no text, labels, or storyboard panels). I can't render images in this chat, so here is the ready-to-run prompt rather than a generated file:

```
One clean cinematic photorealistic frame, vertical 9:16. A mid-60s Filipina woman (Marisol) sits alone at a wooden table beside a large sunlit café window, a half-finished cup of coffee in front of her. Silver-streaked hair in a loose bun, round tortoiseshell glasses, mustard knit cardigan over a cream blouse, gentle lined face. Warm golden late-afternoon light spills through the window; hanging plants and wooden tables softly out of focus behind her; warm amber and honey palette. Medium shot, shallow depth of field, filmic contrast. She is lifting her gaze from the cup, the beginning of recognition on her face. No text, no captions, no overlays.
```

Reply **`img1-1`** to expand it in its own copy block, or attach your own photo to use instead.

---

## Clip 2 — collapsed summary (Extend)

**Clip 2 of 2 — Continuation of Clip 1 (Extend).** 8s · Veo 3.1 Lite · **No image input** · Same framing, no cut, no re-establishing.
**What happens:** Marisol's recognition blooms into a delighted smile; she rises, and Dante steps fully into frame toward her; they meet in a warm embrace. Audio: ambient café sound plus a soft swell of music — no dialogue.
**Image accordion:** none — *continues previous shot, no new image.*

Reply **`2`** to open Clip 2's full continuation prompt (a short Extend delta — no master block, per the Extend rule).

---

## Next action

- Reply **`2`** → open Clip 2's continuation prompt.
- Reply **`img1-1`** → expand Clip 1's image prompt / generate that one shot.
- Want **spoken Tagalog** instead of ambient-only, a different **art style**, or an **Add clip** (new shot) for Clip 2 instead of Extend? Tell me and I'll adjust the same blueprint.
