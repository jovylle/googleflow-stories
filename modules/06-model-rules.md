## 5. Google Flow model and feature rules

Verify before advising. Google Flow changes supported models, features, duration choices, regional availability, and costs. When web access is available and current capabilities affect the output, check the official compatibility documentation first, then use Reddit/community reports as anecdotal corroboration. Distinguish verified documentation from user opinion.

Official reference:

- Model and feature compatibility: https://support.google.com/flow/answer/16352836
- Create videos in Flow: https://support.google.com/flow/answer/16353334
- Flow help/FAQ: https://labs.google/fx/tools/flow/faq

At the research baseline date (2026-10-09), Google's compatibility page listed these capabilities:

### Veo 3.1 Lite

- Text-to-video: 4, 6, or 8 seconds; portrait and landscape.
- First-frame-to-video: 4, 6, or 8 seconds.
- First-and-last-frame video: 4, 6, or 8 seconds.
- Ingredients/references-to-video: 8 seconds only.
- Video extension: 8-second outputs; compatible Veo 3.1 video requirements apply.
- Video-to-video editing: unsupported.

### Gemini Omni Flash 1.1

- Text-to-video: 4, 6, 8, or 10 seconds; portrait and landscape.
- First-frame-to-video: 4, 6, 8, or 10 seconds.
- First-and-last-frame video: 4, 6, 8, or 10 seconds.
- Ingredients/references-to-video: 4, 6, 8, or 10 seconds.
- Video-to-video editing: supported up to 10 seconds.
- Video extension: listed as coming soon in the referenced compatibility document at the time checked.
- Omni 360p draft generation/editing: available at a lower credit cost than standard 720p, according to Google's model documentation.

These are a dated reference snapshot, not permanent guarantees. Always recheck the linked documentation and the user's actual Flow model selector. Do not invent features or assume a feature is available to every account or region.

### Reference-image handling

The user currently expects to work with roughly 1-3 images per clip. Treat this as a practical planning target and never exceed the limit shown in the user's active interface. If the official model or interface permits more references, do not assume more references automatically improve results. Choose only the images that provide distinct, relevant visual information.

Clearly identify the role of every image, for example:

- Character identity/reference
- Environment/location reference
- Product/prop reference
- Primary storyboard/keyframe image
- First frame
- Last frame
- Style reference, if supported and appropriate

Do not describe first/last-frame controls and ingredient/reference inputs as interchangeable. They serve different workflows and model support varies.
