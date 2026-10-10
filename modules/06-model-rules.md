## 5. Google Flow model and feature rules

Verify before advising. Google Flow changes supported models, features, duration choices, regional availability, and costs. When web access is available and current capabilities affect the output, check the official compatibility documentation first, then use Reddit/community reports as anecdotal corroboration. Distinguish verified documentation from user opinion.

Official reference:

- Model and feature compatibility: https://support.google.com/flow/answer/16352836
- Create videos in Flow: https://support.google.com/flow/answer/16353334
- Flow help/FAQ: https://labs.google/fx/tools/flow/faq

At the research baseline date (verified against the official compatibility page on 2026-10-10), Google Flow listed these capabilities:

### Veo 3.1 Lite

- Text-to-video: 4, 6, or 8 seconds; portrait and landscape.
- First-frame-to-video: 4, 6, or 8 seconds.
- First-and-last-frame video: 4, 6, or 8 seconds.
- Ingredients/references-to-video: 8 seconds only.
- Extend videos: 8-second videos only; both aspect ratios.
- Video-to-video editing: unsupported.

### Veo 3.1 Fast

- Text-to-video: 4, 6, or 8 seconds; portrait and landscape.
- First-frame-to-video: 4, 6, or 8 seconds.
- First-and-last-frame video: 4, 6, or 8 seconds.
- Ingredients/references-to-video: 8 seconds only.
- Extend videos: unsupported (extend a Veo 3.1 clip using Veo 3.1 Lite instead).
- Video-to-video editing: unsupported.

### Veo 3.1 Quality

- Text-to-video: 4, 6, or 8 seconds; portrait and landscape.
- First-frame-to-video: 4, 6, or 8 seconds.
- First-and-last-frame video: 4, 6, or 8 seconds.
- Ingredients/references-to-video: unsupported.
- Extend videos: unsupported (extend using Veo 3.1 Lite instead).
- Video-to-video editing: unsupported.

### Extend rule (important)

Per the official tip: **all Veo 3.1 8-second videos can be extended, but the extension must be performed with Veo 3.1 Lite.** So a clip made with Veo 3.1 Lite, Fast, or Quality can be extended, but the Extend action itself runs on Veo 3.1 Lite and only on 8-second clips. Extension does not accept input images — it continues from the existing clip plus a text prompt.

### Gemini Omni Flash 1.1

- Text-to-video: 4, 6, 8, or 10 seconds; portrait and landscape.
- First-frame-to-video: 4, 6, 8, or 10 seconds.
- First-and-last-frame video: 4, 6, 8, or 10 seconds.
- Ingredients/references-to-video: 4, 6, 8, or 10 seconds.
- Video-to-video editing: supported up to 10 seconds.
- Extend videos: listed as coming soon (not available). To extend, use a Veo 3.1 8-second clip extended via Veo 3.1 Lite.
- Omni 360p draft generation/editing: available at a lower credit cost than standard 720p.

These are a dated reference snapshot, not permanent guarantees. Always recheck the linked documentation and the user's actual Flow model selector. If you select a feature a model does not support, Google Flow will notify you. Do not invent features or assume a feature is available to every account or region.

### Reference-image handling

The user currently expects to work with roughly 1-3 images per clip. Treat this as a practical planning target and never exceed the limit shown in the user's active interface. If the official model or interface permits more references, do not assume more references automatically improve results. Choose only the images that provide distinct, relevant visual information.

**One shot = one image; up to two shots per clip = two images.** Each distinct shot gets its own single, clean reference frame (never a multi-panel/collage image). A single 8-second clip can reliably carry up to two shots — when it does, supply one image per shot. See the shot-composition module for the full rule and prompt formula.

Clearly identify the role of every image, for example:

- Character identity/reference
- Environment/location reference
- Product/prop reference
- Primary storyboard/keyframe image
- First frame
- Last frame
- Style reference, if supported and appropriate

Do not describe first/last-frame controls and ingredient/reference inputs as interchangeable. They serve different workflows and model support varies.
