# Effect capabilities — the stress-test map wired into both modes (v2.43.0)

**Status:** built, `./build.sh && ./validate.sh` → **635 checks / 0 failed** (was 612 at
v2.42.0; +23, all in the new §46, written red-first) · in the working tree on `dev`, on
top of `a41f243` (the stress-test log this version consumes)
**Date:** 2026-10-17 · **Failure class:** options and prompts chosen without a renderable
basis. The pack could propose — and a prompt could ask for — effects the model does not
actually render (camera shake, earthquake ground motion, multi-step choreography,
mid-clip orientation reversals). The model then produced something else, and the plan
looked wrong for a reason that was never the model's.

---

## 1. What was reported

The user ran five live stress tests plus a two-clip orientation sub-test on their own
Flow account and pasted the transcript; the full log, with verbatim prompts and their
verdicts, is `docs/veo-stress-tests.md` (shipped in `a41f243`). The load-bearing
verdicts:

> "it seems good on giving the breaking effects"

> "Does it 'go ugly' when flashes get frequent? no"

> "camera shaking = there is 0 shaking, nothing shaking at all. no camera shaking"

> "Character suddenlyy facing us when he was walking away, so its Veo weakness"

And the user's framing of what to do with the results:

> "we can now properly have good options on the AI generated options we have here for
> Auto and for Guided modes"

> "we can decide what consequence or scenes to choose or pick based on this stress test
> result"

## 2. The defect

### 2a. Nothing in the pack knew what the model renders

The pack's scene presets were low-motion by design (R1–R3: locked-off camera or one slow
push-in, one dominant gesture per clip, no complex physics), and §08a's camera vocabulary
was a menu of on-screen terms. But no rule anywhere said which **effects** render on the
user's plan — so nothing stopped a future deck edit, a guided suggestion, or a written
prompt from asking for an earthquake, a camera shake, or a choreographed multi-step
action. The stress tests are the first evidence that these asks fail in a specific,
recorded way.

### 2b. The failure was the model's, but the friction was the plan's

Test 3 showed unrequested camera-angle changes; Test 4 showed a stochastic 180° flip
inside a clip; Test 5 showed zero camera shake and local-only debris. A plan that asks
for those things hands the user a prompt whose result cannot match it. The fix is not
"prompt harder" — it is to keep options and prompts inside what is proven to render.

## 3. What v2.43.0 ships

Five sites, one map (the evidence stays in `docs/veo-stress-tests.md`; the pack carries
the rules):

1. **Module 5 — the capability map.** New subsection "Proven effect capabilities on
   Veo 3.1 Lite (live stress tests, 2026-10-17)": the reliable list (weather transitions,
   rain, frequent lightning, violent wind, dust/debris drift, breakage/destruction
   *appearance*, close-up reveal, one simple reaction), the unreliable list (earthquake
   ground motion; requested camera shake — entirely absent, not weak; multi-step
   choreography; mid-clip orientation reversals), and two planning rules: **spectacle is
   safe; motion is not**, and **the appearance of drama is not its physical simulation**.
   Stance: small-sample, "proven so far", source log named.
2. **2c — the deck guard.** Every auto preset and list entry stays inside the map; the
   proven spectacle forms are named for when an entry wants one. (R1–R3 already complied
   — the guard keeps future edits honest.)
3. **2a — the guided filter.** Guided free selection is capability-bounded by the same
   map: axis picks, suggested sets, and staged effects.
4. **7a — the camera limits.** Never write that the camera shakes (show the impact's
   visible effects in frame instead); one camera movement per shot; hold the orientation
   within a clip — a turnaround is its own dominant action, never a secondary
   instruction.
5. **15 — the gate.** Three checklist items: no shake/ground-motion asks; orientation
   held; effects inside the map.

## 4. The option the user did not take (for the record)

The tabled plan offered a second option — enriching the user-vetted deck lists with new
proven-spectacle entries (a storm setting, a breakage consequence act). The user's go
answered with option A (guard only), so **no deck list entry changed**; the lists remain
the user's to edit in place.

## 5. Evidence

- **Red-first:** §46 written and run against the untouched pack → **635 checks, 21
  failed** — every new rule missing, both traps passing trivially.
- **Green:** five module edits + version bump + rebuild → `./validate.sh` → **635 / 0**.
- **Traps:** the build must never contain "the camera shakes slightly" or "the ground
  shakes" — the positive phrasings the stress-test findings forbid.
- The capability map's stance is pinned ("proven so far") so it cannot be presented as
  measured rates.

## 6. What only a live run can show

- An `auto riddle` run drawing inside the deck, with every proposed option inside the
  map (no shake, no ground motion, no choreography asks in any prompt).
- A prompt whose scene needs impact: the impact rendered **without** a camera-shake
  instruction, through visible effects in frame.
- A walking-away shot holding its orientation for the full clip.
- The camera suite (**Test 6**, `docs/veo-stress-tests.md` §8) is queued and unrun; its
  results go into that log, and into §46 only if they change a rule.
