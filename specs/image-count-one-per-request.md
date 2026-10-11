# Spec — One image per request: no batches, no sheets, no panels (v2.20.0)

## Provenance

Reported live by the user mid-run, in two parts:

1. *"yow what is happeening, you are sending around 8 images right now in a rrow and all are in multipanel story of the thing. lets report this to my Coding Agent this is a bug"*
2. A 58-line written bug report that **did not survive ingestion** — it reached the assistant as a truncated placeholder and is stored that way, so the diagnosis below rests on the transcript symptom, the user's own pasted diagnosis, and the artifact itself. If the report carried anything beyond the symptom, it is not represented here.

The user's own pasted diagnosis, verbatim in substance: the image generation should happen **once**, after the three connected clip prompts are ready, and should produce **one standalone Clip 1 reference image**.

## Symptom

A Tagalog `.start riddle` run (eight generated candidates, the user picked Bugtong 4, answer *Salamin*, two-clip production with defaults) returned **about eight images in a row, all of them multi-panel storyboards** — not one standalone Clip 1 reference image.

## Why it was not a missing rule

The one-image rule was already in the artifact **five to six times**, including `10-clip1-final.md` almost verbatim ("Exactly one image this turn"). So the rule was being outvoted rather than absent. Six places said *more*:

| Pull upward | Where | Why it pulls |
|---|---|---|
| "work with roughly 1-3 images per clip… **Treat this as a practical planning target**" | `06:77` | Strongest single pull. Three clips × 1–3 ≈ the observed count. It is the only sentence in the file that frames a *quantity to plan for*. |
| "**Clearly identify the role of every image**" + a role list (Character identity / Environment / Prop…) | `06:81` | Reads as an inventory to produce one of each: character reference + environment reference + … |
| "produces a Veo-ready reference image **for each scene**" | `07:24` | Plural scenes → per-scene images. |
| "a single clip can carry **up to two shots** — when it does, **supply two images**" | `06:78`, `08a` | At face value, more shots means more images now. |
| The method's own name: "Generate reference image**s** with ChatGPT" | `07:27` | The label itself is plural. |
| A nested image **accordion** of `[imgN-M]` headers, one set per clip | `11:31` | A list of image headers per clip is very close to the shape of a **multi-panel storyboard** — which is what the run produced. |

Nothing in the file ever said "generate one image this turn and refuse to generate another". One line said one; six contexts implied more.

## The fix

- **`06:77` — the ceiling is a ceiling.** The 1–3 figure is how many references a clip may **attach at most**; it is not a quota and not a generation plan. Images are generated **one at a time, on demand**, and a delivery turn generates exactly one.
- **`06:81` — roles are labels.** Naming the image roles is a labeling rule, never a list of images to generate; each image is produced only when the user asks for it.
- **`07:10` — a batch is never a delivery.** Exactly one image per package turn, and it is a single frame of a single shot. Named bans: one per clip, one per subject, one per role, sets of variations, character sheet, model sheet, turnaround, contact sheet, panel set. If more than one image would help, say so in one line and let the user ask.
- **`07:12` — several subjects are still one frame.** When the subject field names the victims, the Teller, and the trap, that is **one composed scene in one frame** — never one image per subject, never a lineup or grid.
- **`07:15` — no reference lookups.** No web or image-library search for style references, and no page/source titles in the package. This is also the pathway by which Pinterest and Civitai page titles leaked into a real blueprint; describe a look in words instead.
- **`11:31` + `08a:24` — the plan is never an image.** Every `[imgN-M]` header, summary line, and accordion line is **text only**. Never render the blueprint, clip list, header list, accordion, storyboard, or section headings as a picture.
- **`10:49` — the count lives here.** Exactly one image this turn, **one image, of one composed scene**, every subject composed into that single frame.
- **`16:20` — the checklist verifies the count**, so a run checks its own delivery before sending.

## Guards

`validate.sh` **§22**, 11 checks: 10 `need` + 1 `need_not` on the old `Treat this as a practical planning target` wording — the batch-affording sentence is **deleted, not overridden**, and the guard stops it coming back.

Count **168 → 179**. Red first: 11/11 failed before the module edits.

## Residual risk — stated plainly

`validate.sh` proves a rule is **present**, not that a run **obeys** it. The deleted sentence is the real mechanical change, but the only proof is the next live run: if a package turn still returns a run of images, the next levers are (a) making the Clip 1 gate a hard stop in the command module rather than a rule in a later module, and (b) removing the per-clip image accordion from the default output format entirely, since it is the closest textual match to the "multipanel storyboard" shape.

## Not in this version

Three defects from an earlier live run remain **unactioned** pending the user's go-ahead:

1. The consequence rule names the actor (the Teller) but never the **victim** — a Tagalog phrasing read as *the Teller* being punished.
2. The Character field's options are pitched as victims, but a run **cast a victim option as the Teller**, leaving the victims without a locked design. Proposed fix: two explicit slots (victims + a separately-designed Teller) that must never silently merge.
3. A riddle at the ceiling of the duration budget (24 words ≈ 9.6 s) had its delivery **squeezed** rather than being offered a third clip or Veo 3.1 Quality.
