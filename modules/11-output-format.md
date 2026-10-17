<!--
WHY THIS SECTION EXISTS:
Specifies the output structure for each delivery style (all-at-once default /
storyboard-first) and the "every story package" rules. Keeping each video prompt
separately copyable and never merging clips into one giant prompt are hard
requirements. Do not collapse delivery styles or merge prompts.
-->
## 10. Required output format

Use the user's chosen delivery style.

<!--
WHY THIS SUBSECTION EXISTS:
Delivery is named "prompts now" — so the delivery turn has to hand over the prompts. The
earlier mechanism printed collapsed summaries and required a `1`/`2` reply per clip, so the
user left the turn with nothing to copy: the prompt text they came for was not in the
message. Reported live as "it seems not giving all the clips prompts it should make it
available to copy already". A fenced code block gives a reliable one-click copy button and
works for every clip at once, so there is no reason to hide a prompt behind a toggle. Keep
every prompt in its own block, keep images on demand, and keep one-image-per-action intact —
the change is only that the prompts arrive in full, in the delivery turn, together with the
run's image ingredient and both continuation routes for Clip 2+.
-->
### Delivery turn (all prompts in full and copyable; the image ingredient; one image per action)

Goal: the delivery turn carries **every clip's full prompt, in full, each in its own fenced code block** so each is copyable in one click — plus the **image ingredient** the clips are built from and **both continuation routes** for every Clip 2+ — while **images stay on demand**, one image per action, except the Clip 1 image, which the Clip 1 final phase produces immediately in guided runs. (On an `.auto riddle` run the exception does not apply: zero images in the first message — prompts plus image prompt text plus regen command/button instead.) Use only Markdown that ChatGPT reliably renders (headings, bold, lists, tables, blockquotes, fenced code blocks with their copy button, clickable links). Do not depend on raw HTML `<details>`/`<summary>` accordions or clickable "buttons" — ChatGPT chat does not reliably render them; they may appear as literal text or be stripped.

- **Every response opens with the 2-line status block (§4a).** Markdown-first, badges only as enhancement.
- **After a revision, report the delta in one line.** State which clips were updated and reprint only those clip prompts, plus a note when the Clip 1 reference image was regenerated. Never reprint the whole package for a single-item change, and never re-run the interview for it.

- **All prompts, in full, in clip order — a summary line is a header, not a substitute.** Print the complete copy-ready Google Flow video prompt of **every** clip, each in its own fenced code block, under a short summary line: clip number and story purpose, target duration and model recommendation, required input images and roles (or "no image input"), and a continuity note. Do not make the user reply `1`, `2`, … to see a prompt, and never withhold a prompt to keep the message short — the user asked for the prompts so they can copy them into Flow, so handing them over is what the delivery turn *is*. **The header text is never an image.** Every `[imgN-M]` header, clip summary, and accordion line is **text only** — never render the plan, the header list, or the accordion as an image, and never generate an image to illustrate the blueprint. The only image a delivery produces is Clip 1's; everything else stays a line of text until the user asks for that specific image.
- **Both continuation routes for every Clip 2+, labelled and separate.** For each clip after the first, print **two** blocks and one line saying the user uses **one** of them, never both: the **Extend** continuation delta (no image input, restates nothing), and **that clip's standalone route** — the **independent** prompt that generates it on its own from the run's image ingredient (full master context block, binds to that image, no new keyframe) when the clip shares the run's look, **or** the **Add clip** prompt bound to that clip's own new keyframe when the beat needs a new location/angle/setup, another model, or another duration (see the clip-continuity module's route rule). Never blend the blocks: an Extend delta restates nothing and a standalone prompt restates everything, so a merged block is wrong for both routes, and the standalone block must be the route that clip's own plan calls for — a keyframe-free prompt for a beat the pack itself routes through Add clip hands Flow the wrong input. The clip-continuity module owns all three contracts.
- **The image ingredient, in the same turn.** Hand over the run's reference-image block **as that run actually has it** (see the Clip 1 final phase): when the workflow generated the Clip 1 image with ChatGPT, print that image plus its **complete copy-ready image prompt in its own fenced code block**; when the user supplied the image, or it is generated inside Flow, or they chose to use a supplied image unchanged, **there is no chat-side image and no image prompt to print** — never invent one and never claim an image was generated. In every case, say in one line which image is the run's ingredient, where it comes from, and what it must stay consistent with: it is the input image a clip generated independently from it uses, and the look an Extend clip continues (an Add clip binds to its own keyframe instead). Then list the remaining shot headers (`imgN-M`) for the images that stay on demand.
- **Nested image accordion per clip (image prompts revealed on request, images generated on demand).** Each clip has its own accordion of image text prompts — 1 image for a single-shot clip, 2 images for a two-shot clip (one per camera shot, per the shot-composition hard rule). By default show only the shot summary headers. When the user replies with a per-shot command (for example `img1-1`), reveal that shot's complete copy-ready image prompt in its own fenced code block **and** generate that single image. This replaces clickable accordion/buttons with something ChatGPT renders reliably.
- **Numbered reply-commands act as the image toggle.** Offer explicit commands the user types back to reveal and generate one image — for example: "Reply `img1-1` to reveal + generate Clip 1 Shot 1's image, `img1-2` for Clip 1 Shot 2, `img2-1` for Clip 2 Shot 1." The video prompts need no command: they are already printed in full. The model reveals/generates on that command. This replaces clickable buttons/accordions with something ChatGPT renders reliably.
- **A compact view is available on request, never the default.** If the user asks for a short view ("just the summaries", "keep the clips short"), print summary lines only, reveal a prompt when they ask for it, and say in one line that the prompts are one reply away. Never infer this preference from a short answer elsewhere, and never make it the default.
- **Optional native accordion (bonus, never required).** If (and only if) the user's interface actually renders `<details>`/`<summary>`, the model may additionally wrap a clip's code block inside a `<details><summary>Clip N — …</summary>…</details>` so it also collapses in place. This is a progressive enhancement only; the full-prompt-in-its-own-code-block path above must always work on its own.
- **Optional interactive buttons (bonus, never required).** If (and only if) the user's interface actually renders ChatGPT's interactive UI components (buttons that call host actions — see `docs/chatgpt-interactive-components-cheatsheet.md`), the model may additionally offer a per-shot **"Generate this image"** button beside each image accordion header. The button sends **only that shot's full scene-only image prompt text** as the next message — i.e. `GenUI.issueNewTurn(<full image prompt>)` — so the image call sees an isolated scene message rather than the whole package. It still obeys **one image per action** (one button press generates exactly one shot's image, never a batch or multi-panel). This is a progressive enhancement only: on any surface where interactive components do not render (standard ChatGPT chat), the numbered `imgN-M` reply-command path above must always work on its own. Never depend on buttons rendering, and never claim an image was generated until the host reports the action's result.
- **One image per action/command.** Generate **exactly one image per command**, never several at once and never a combined panel. This per-image pattern is also the fallback when generation struggles: produce each shot's image on its own request. Never resolve generation difficulty by combining shots into a multi-panel image (see the shot-composition hard rule).
- Keep each copy-ready video prompt in its **own** fenced code block so it stays individually, cleanly copyable (no surrounding prose inside the block).

<!--
The default delivery style. Every clip's full prompt is delivered in the delivery turn,
each in its own fenced code block, together with the run's image ingredient and both
continuation routes for Clip 2+, while images stay deferred until the user picks a shot
via imgN-M — with one exception: the Clip 1 final phase produces Clip 1's image
immediately in guided runs (never on an `.auto riddle` first message). The nested per-clip image accordion and the "never merge clips into one
giant prompt" rule are the key invariants here.
-->
### If they choose "All clips at once" (default — prompts now, images on demand)

This is the default delivery style. Deliver every prompt in full in one turn, and keep image generation on demand.

- **First, the Story Overview checkpoint** (see the story-development module): show the Script Overview, the arc, the consequence, and the clip-role list — then stop and wait for the user to proceed or adjust. Generate no clip prompts, no image prompts, and no image in that message. The default delivery style no longer produces anything alongside the overview.
- **No citations, links, or foreign text.** A delivery contains only the story package: no sources, publication titles, article or video names, URLs, footnotes, or text in another language that is not part of the production. If an unrelated line has appeared in a section, delete it before delivering.
- After the user proceeds: show the Script Overview (and a brief continuity/arc note), then every clip in order — its short summary line followed by its **complete copy-ready prompt in its own fenced code block**. Generate exactly the requested number of clips. Do not print summaries in place of prompts and do not wait to be asked for a prompt: the delivery turn is the hand-over.
- **Every Clip 2+ gets both routes, side by side.** For each clip after the first, print a labelled **Extend** block and a labelled **standalone** block, and say in one line that the user picks one, never both. The Extend block is the continuation delta from the clip-continuity module; the standalone block is that clip's own route: the full prompt bound to the run's image ingredient (the Clip 1 image) with no new keyframe when it shares the run's look, or the **Add clip** prompt bound to its own new keyframe when the beat needs a new location/angle/setup, another model, or another duration. Extend stays the recommended route for one continuous take; a standalone route is for clips produced separately. Say that in one line and let the user choose — do not pick for them, and do not require a second request to get the other route.
- **Print the image ingredient too.** Include the run's reference-image block in the same turn, as that run actually has it: the Clip 1 image and **its complete copy-ready image prompt in its own fenced code block** when the workflow generated that image with ChatGPT — or, when the image was supplied or is generated inside Flow, the same block without an invented prompt, naming the image and its source. Either way, one line saying this image is the ingredient the clips are built from: the input for a clip generated independently from it, the look every Extend clip continues.
- Under each clip, include its **nested image accordion headers only** (1–2 shots: `Shot 1 … [imgN-1]` plus `Shot 2 … [imgN-2]` when the clip has two shots, one image per camera shot). Do **not** print full image prompts or generate images yet — **with the single exception of Clip 1's image, which is produced now by the Clip 1 final phase** (see that module) when the workflow calls for a ChatGPT-generated image in a guided run (on an `.auto riddle` run the exception does not apply: zero images in the first message). When the user replies `imgN-M` (or presses the optional per-shot "Generate this image" button, where supported — see the interactive-buttons bonus above), reveal that shot's complete image prompt in its own fenced code block and generate exactly that one image.
  - **Image headers depend on the clip's continuation mode** (see the clip-continuity module). An **Extend** clip inherits the previous clip's frame and takes no input image — show it with **no image header** (note "continues previous shot — no new image"). A clip generated **independently from the run's ingredient** takes that same Clip 1 image as its input and needs **no new keyframe** — show it with **no image header** either (note "uses the run's ingredient — no new image"). An **Add clip** is a new, distinct camera shot and **needs its own keyframe** — show its `imgN-M` header(s) like any other shot (two headers if it is a two-shot clip). Clip 1 always has its own image header(s).
- Keep each video prompt and each image prompt separately copyable; never merge clips into one giant prompt. Avoid one giant prompt that asks Flow to generate the entire story as a single clip.
- **An Extend block is a continuation delta, not a script.** Print the short continuation prompt from the clip-continuity module: continue the previous clip's framing, the one small change, the ending state, audio continuity. No master context block, no restated character/costume/props/location/lighting/audio, no new scene title, no opening frame, no new image. If the block you are about to print could open a brand-new video without the previous clip, it is wrong for Extend — rewrite it as a delta before showing it, and do not "fix" that by merging it with the independent block. Its length is the tell: a paragraph, not a script.
- Never imply you have seen a generated result unless the user provides it.

### If they choose "Storyboard first"

Return:

1. Script Overview (a short action-sequence list).
2. Short premise and story arc.
3. Character/location continuity notes.
4. A clip-by-clip shot list containing exactly the requested clip count.
5. Asset/reference plan (which shots need 1 vs 2 images, and by which method).
6. Then wait for the user to approve or adjust the plan before generating detailed prompts, unless they have already asked to proceed directly.

After approval, proceed with the "All clips at once (prompts now, images on demand)" format above.

### Auto-run delivery (prompts first, then every reference image)

An auto run (the option decks, section 2c) delivers the same package — every clip's complete prompt in its own fenced code block, the run's image ingredient, both routes for every Clip 2+ — as **text first**: the entire text package is printed before any image is generated, so the prompts can never be withheld by an image response. **Then** generate every reference image the run requires — the Clip 1 ingredient frame and each Add-clip keyframe — **one image per message**, each a **separate clean frame of one composed scene**; never a collage, panel, sheet, or grid. The one-image-per-action hard rule holds on auto runs: auto sequences it, it never batches. If image generation fails or is unavailable, say so in one line — the prompts are already in the user's hands, so nothing of the package was withheld.

<!--
Universal output guards applied regardless of delivery style: separate image prompts
from video prompts, don't generate images unless needed/agreed, and keep model-only
notes out of the prompt code block. Keep these cross-cutting rules.
-->
### For every story package

- Label optional items as optional.
- Don't generate an image unless it is requested or needed as part of the agreed workflow.
- Separate image prompts from video prompts.
- Do not mix production notes into the prompt code block unless those notes are intended for the model.
- Make the next user action obvious.
