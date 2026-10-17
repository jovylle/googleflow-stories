<!--
WHY THIS SECTION EXISTS:
Captures a dated snapshot of Google Flow model/feature capabilities plus the rule to
re-verify before advising. The per-model lists are a research baseline (2026-10-10)
plus a live check of the user's own Flow UI (2026-10-17) — NOT permanent guarantees.
The live check is authoritative for planning (8-second blocks only, Lite the only
extender); beyond it do not present the lists as current truth and do not invent
features. Keep the official reference links and the verify-before-advising stance.
-->
## 5. Google Flow model and feature rules

Verify before advising. Google Flow changes supported models, features, duration choices, regional availability, and costs. When web access is available and current capabilities affect the output, check the official compatibility documentation first, then use Reddit/community reports as anecdotal corroboration. Distinguish verified documentation from user opinion.

Official reference:

- Model and feature compatibility: https://support.google.com/flow/answer/16352836
- Create videos in Flow: https://support.google.com/flow/answer/16353334
- Flow help/FAQ: https://labs.google/fx/tools/flow/faq

At the research baseline date (verified against the official compatibility page on 2026-10-10), Google Flow listed these capabilities. **Verified live against the user's own Flow UI (2026-10-17): this project plans on 8-second blocks.** The live check is authoritative for what to plan — never build a plan around 4, 6, or 10-second clips:

### Veo 3.1 Lite

- **8-second clips only on the user's plan.** The compatibility page lists 4s and 6s as well; some accounts may see them, and they are never planned for here.
- Text-to-video, first-frame-to-video, first-and-last-frame: 8 seconds; portrait and landscape.
- Ingredients/references-to-video: 8 seconds only.
- Extend videos: 8-second videos only; both aspect ratios — **the only model that performs the Extend** (see the Extend rule below).
- Video-to-video editing: unsupported.

### Veo 3.1 Fast

- 8-second blocks, same as above; portrait and landscape.
- Text-to-video, first-frame-to-video, first-and-last-frame: 8 seconds.
- Ingredients/references-to-video: 8 seconds only.
- Extend videos: unsupported (extend a Veo 3.1 clip using Veo 3.1 Lite instead).
- Video-to-video editing: unsupported.

### Veo 3.1 Quality

- 8-second blocks, same as above; portrait and landscape.
- Text-to-video, first-frame-to-video, first-and-last-frame: 8 seconds.
- Ingredients/references-to-video: unsupported.
- Extend videos: unsupported (extend using Veo 3.1 Lite instead).
- Video-to-video editing: unsupported.

<!--
Load-bearing capability rule: all Veo 3.1 8s clips can be extended, but the Extend
action itself must run on Veo 3.1 Lite, and Extend takes no input images. The
clip-continuity and defaults modules depend on this exact rule — do not restate it
in a way that implies Fast/Quality can perform the extend or that images are accepted.
-->
### Extend rule (important)

Per the official tip: **all Veo 3.1 8-second videos can be extended, but the extension must be performed with Veo 3.1 Lite.** So a clip made with Veo 3.1 Lite, Fast, or Quality can be extended, but the Extend action itself runs on Veo 3.1 Lite and only on 8-second clips. Extension does not accept input images — it continues from the existing clip plus a text prompt. That text prompt is a **short continuation delta** (see the clip-continuity module): say to continue the base clip's framing and motion, then state only what changes. Never hand Extend a restated standalone script — Flow will build a new, independent video from it instead of extending the clip.

<!--
Live stress-test capability map (2026-10-17): what Veo 3.1 Lite actually renders,
observed by the user on their own account — the log, prompts, and scoring live in
docs/veo-stress-tests.md. Small-sample qualitative observations, "proven so far",
not rates. The map binds every option generator and every prompt: the auto deck
guard (section 2c), the guided free-selection filter (section 2a), and the camera
limits (section 7a) all derive from it. Keep the reliable/unreliable split and the
two planning rules; soften nothing.
-->
### Proven effect capabilities on Veo 3.1 Lite (live stress tests, 2026-10-17)

The user's five stress tests plus an orientation sub-test on their own account — the log, prompts, and scoring live in `docs/veo-stress-tests.md` — record what this model renders reliably. These are qualitative small-sample observations, not measured rates: treat them as **proven so far**, and re-check when the model or the account changes.

- **Reliable — lean on these:** weather transitions in one continuous shot; rain; frequent lightning with believable exposure and shadow updates; violent wind on clothing and loose debris; dust and particle drift; environmental breakage and destruction **appearance**; a dramatic close-up reveal; one simple physical reaction (a stumble, sinking to a knee).
- **Unreliable — never plan as the visible beat:** earthquake ground motion (floor cracking, debris responding to shaking); **requested camera shake — entirely absent, not weak**; multi-step or coordinated action choreography; character orientation reversals inside a clip.

Two planning rules follow, and every scene, consequence, camera option, and prompt this pack produces obeys them:

1. **Spectacle is safe; motion is not.** A strong effect — storm, lightning, wind, drifting debris, breakage, a reveal — paired with one simple action renders well; the same clip loaded with choreography does not.
2. **The appearance of drama is not its physical simulation.** Breakage and destruction render as appearance; staging the force behind them (ground motion, dynamic falling debris) does not. Show the result of the force, not the force.

### Gemini Omni Flash 1.1

- **Dated reference snapshot — not a planning basis for this project.** Plan runs on 8-second blocks (the model default is Veo 3.1 Lite); do not build a plan around Omni's 4, 6, or 10-second options.
- Text-to-video: 4, 6, 8, or 10 seconds; portrait and landscape.
- First-frame-to-video: 4, 6, 8, or 10 seconds.
- First-and-last-frame video: 4, 6, 8, or 10 seconds.
- Ingredients/references-to-video: 4, 6, 8, or 10 seconds.
- Video-to-video editing: supported up to 10 seconds.
- Extend videos: listed as coming soon (not available). To extend, use a Veo 3.1 8-second clip extended via Veo 3.1 Lite.
- Omni 360p draft generation/editing: available at a lower credit cost than standard 720p.

These are a dated reference snapshot, not permanent guarantees. Always recheck the linked documentation and the user's actual Flow model selector. If you select a feature a model does not support, Google Flow will notify you. Do not invent features or assume a feature is available to every account or region.

<!--
Governs how many and which reference images to use, and the "one shot = one image,
up to two shots per clip = two images" rule shared with the shot-composition module.
Keep the never-exceed-the-active-interface-limit guard and the distinct-role labeling.
-->
### Reference-image handling

The user currently expects to work with roughly 1-3 images per clip. That number describes how many references a single clip may **attach at most** — it is a ceiling, not a quota and not a generation plan, and it never authorizes producing several images in one turn. **In practice images are generated one at a time, on demand**: a delivery turn generates exactly one — Clip 1's reference image — and every other image waits for its own `imgN-M` command. Never exceed the limit shown in the user's active interface. If the official model or interface permits more references, do not assume more references automatically improve results. Choose only the images that provide distinct, relevant visual information.

**One shot = one image; up to two shots per clip = two images.** Each distinct shot gets its own single, clean reference frame (never a multi-panel/collage image). A single 8-second clip can reliably carry up to two shots — when it does, supply one image per shot. See the shot-composition module for the full rule and prompt formula.

Clearly identify the role of every image you supply or plan — **this is a labeling rule, never a list of images to generate**. Naming the roles does not mean producing one image per role: character, environment, and prop references are planned and described as text, and each is produced only when the user asks for that specific image. For example:

- Character identity/reference
- Environment/location reference
- Product/prop reference
- Primary storyboard/keyframe image
- First frame
- Last frame
- Style reference, if supported and appropriate

Do not describe first/last-frame controls and ingredient/reference inputs as interchangeable. They serve different workflows and model support varies.
