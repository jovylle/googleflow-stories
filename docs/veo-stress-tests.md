<!--
WHAT THIS FILE IS:
The user's live stress-test log for Veo 3.1 Lite on the Riddle Horror Action
production context (8-second clips, one continuous shot, English prompts, the
user's own Flow account). It records what the model renders reliably and what it
does not, and turns that into selection guidance for scenes and consequences.
The results are QUALITATIVE observations from a small number of generations, not
measured reliability rates — a single failure does not prove a permanent defect
(test 4 failed orientation in 1 of 2 clips) and a pass does not prove a guarantee.
Keep the evidence sections factual; add new tests with the template in §2.
Status: wired into the pack in v2.43.0 — module 5 (the capability map), 2c (the deck
guard), 2a (the guided filter), 7a (the camera limits), and 15 (the final gate). This
log stays the evidence source; the pack carries the rules.
-->

# Veo 3.1 Lite stress tests — the Riddle Horror Action benchmark

**Created:** 2026-10-17 · **Status:** living log — tests 1–5 recorded, camera suite queued (§8), map wired into the pack in v2.43.0
**Scope:** the user's Flow account, Veo 3.1 Lite, 8-second clips, one continuous shot per clip,
photorealistic/3D-CGI horror-action prompts, no dialogue or subtitles.
**Purpose:** know what to *lean on* and what to *avoid* when choosing scenes and consequences —
spectacle the model renders reliably gets planned; physics it cannot simulate does not.

---

## 1. How to read this

- Each test stresses one thing. The value is comparative: tests 1–5 now separate
  **environmental spectacle** (strong) from **physical simulation** (weak).
- Results are recorded as verdict words (`PASS` / `PASS + caveat` / `MIXED` / `FAIL`) plus,
  where given, 1–5 scores on six axes (see the scorecard).
- A stochastic failure is recorded as such: Test 4's orientation defect appeared in **one of
  two** generations, so it is a risk to plan around, not a certainty.
- Test 6 (§8) isolates camera control and continuity — the two issues that recurred in tests 3
  and 4.

## 2. The benchmark template (reuse for every new test)

```
Test ID / Name
Purpose:            what capability is being tested
What stays simple:  1 main character, 1 main location, 1 continuous shot, limited actions
What is stressed:   weather / lighting / debris physics / camera stability / environment response
Prompt:             the exact prompt used (verbatim, so re-runs are comparable)
What to watch for:  2–4 yes/no checkpoints, written before the run
Result:             per-checkpoint observation + notes
Verdict:            Bad / Okay / Good / Very good — or 1–5 on the scorecard
```

**Scorecard (1–5, optional but useful for comparing tests):**

| Test | Visual quality | Consistency | Motion realism | Environmental response | Camera coherence | Overall |
|---|---|---|---|---|---|---|

**Methodology rules:**

1. One capability per test — do not bundle action choreography into a weather test.
2. Same prompt + same starting image across generations; change only the seed when Flow
   exposes it. This separates *Veo weakness* from *one bad roll*.
3. Record clip-by-clip when a test needed more than one generation (Test 4's Clip A/B is the
   model for this).
4. Write the "what to watch for" checkpoints **before** watching, so the observation is not
   fitted to the outcome.

## 3. Results at a glance

| Test | Verdict | Primary finding |
|---|---|---|
| 1 — Action / monster attack / environment breakage | **MIXED** | Effects (lightning, breakage, face reveal, stumble) work; complex choreography does not |
| 2 — Weather change | **PASS (strong)** | Weather transitions, rain, wind, lightning all reliable in one shot |
| 3 — Heavy lightning | **PASS + caveat** | Frequent lightning and exposure changes hold; the camera introduced unrequested angle changes |
| 4 — Heavy wind + debris | **PASS + caveat** | Cloth, dust, and debris all good; character orientation flipped impossibly in 1 of 2 clips |
| 5 — Earthquake | **FAIL** | Destruction appearances render, but earthquake physics does not: zero camera shake, unreliable cracking, local-only debris |
| 4-add — Orientation (2 clips) | **Stochastic** | Clip A: impossible instant 180° turn while walking away. Clip B: correct. 1 of 2 failed |

**Headline conclusion:** Veo 3.1 Lite is much stronger at generating **the appearance of
dramatic environmental events** than at reproducing **their underlying physical motion**.

## 4. Test log

### Test 1 — Action / monster attack / environment breakage

**Purpose:** fast action movement, monster transformation/extreme form, camera motion,
environmental destruction, lighting change, close-up horror reveal.
**Prompt:** not retained from the first pass (recorded results only).
**Observed results:**

| Checkpoint | Result | Notes |
|---|---|---|
| Lightning effects | Good / reliable | Looked strong and cinematic |
| Breaking / destruction effects | Good | Environment breakage worked fairly well |
| Full face close-up reveal | Good enough / reliable | Monster face reveal worked |
| Stumble / simple body reaction | Worked | Believable enough |
| Complex action choreography | Bad | Multi-step movement was weak |
| Extreme coordinated motion | Bad | Hard to maintain all actions together |
| Overall consistency during heavy action | Weak | Good pieces, not strong across the full sequence |

**Verdict: MIXED.** Reliable at effects-heavy spectacle; struggles with sustained complex
movement, multiple coordinated actions at once, and staying clean through extreme sequence
changes.

### Test 2 — Weather change stress test

**Purpose:** whether Veo can smoothly transform weather conditions in one continuous shot
(calm air → darkening skies → rain → increasing wind → frequent lightning).
**Prompt (verbatim):**

```
Create an 8-second AAA-quality photorealistic 3D CGI horror scene in one continuous cinematic shot.

A hooded figure stands in an abandoned ruined church courtyard at night. The sequence begins with still air and faint moonlight.

0–2 seconds: The environment is calm, with only subtle fog and gentle candle flicker. The camera slowly pushes toward the hooded figure.

2–4 seconds: Dark storm clouds rapidly gather overhead. Strong wind begins to move the figure’s cloak and nearby dead branches. Rain begins lightly.

4–6 seconds: The storm intensifies. Heavy rain pours down, repeated lightning flashes illuminate the courtyard, and the wind becomes violent. Dust, leaves, and loose debris swirl through the scene.

6–8 seconds: The weather reaches full intensity. Lightning strikes nearby, the camera shakes slightly from the impact, and the hooded figure looks up as the entire environment is engulfed in a raging storm.

Prioritize realistic weather transition, cloth movement, believable wind interaction, cinematic lightning, volumetric rain, and strong atmosphere. Maintain spatial consistency and one continuous shot. No subtitles, no dialogue.
```

**Observed results:**

| Checkpoint | Result | Notes |
|---|---|---|
| Weather transition feels smooth | Very good | Reliable enough |
| Rain appears correctly | Very good | Reliable enough |
| Wind affects clothing | Good / very good | Reliable enough |
| Wind affects debris | Good / very good | Reliable enough |
| Lightning cinematic without breaking the scene | Very good | Cinematic; scene held |

**Scores:** visual quality 5 · consistency 4.5 · motion realism 4 · environmental response 5 ·
camera coherence 4 · **overall 4.5**.
*(Note: the prompt text includes "the camera shakes slightly from the impact" — camera shake
was later isolated and failed outright in Test 5; do not read Test 2's pass as shake working.)*

**Verdict: PASS (strong).**

### Test 3 — Heavy lightning stress test

**Purpose:** many lightning events without ruining the scene — repeated flashes, brightness
changes, atmosphere changes, shadow shifts, shockwave feel.
**Prompt (verbatim):**

```
Create an 8-second photorealistic 3D CGI horror-action scene in one continuous shot.

A hooded character stands inside a ruined Gothic cathedral at night during a supernatural storm. The camera slowly circles the character.

0–2 seconds: The cathedral is dark with cold blue moonlight through broken stained-glass windows. Dust floats in the air.

2–4 seconds: Lightning begins flashing outside the windows, briefly flooding the cathedral with intense white-blue light. Each flash changes the shadows dramatically.

4–6 seconds: The lightning becomes rapid and frequent, illuminating the cathedral from different angles. Thunder shakes the room and loose fragments begin falling from the ceiling.

6–8 seconds: A powerful red lightning strike transforms the mood of the entire cathedral. The room glows crimson, dust and debris surge outward, and the hooded character’s face is revealed in an intense close-up.

Prioritize repeated lightning flashes, realistic exposure changes, shadow behavior, cinematic atmosphere, and environmental reaction to thunder. One continuous shot. No subtitles or dialogue.
```

**Observed results:**

| Checkpoint | Result | Notes |
|---|---|---|
| Frequent lightning stays clean | Yes | Reliable enough |
| Scene stays visually coherent | Mostly yes | **Camera angle changes appeared** — to be tested separately (§8) |
| Shadows and exposure update believably | Yes | Reliable enough |
| Goes ugly under frequent flashes | No | Holds up well |

**Scores:** visual quality 4.5 · consistency 4 · motion realism 4 · environmental response 5 ·
camera coherence 3.5 · **overall 4.25**.
Weather effects and environment rendering were both noted as genuinely good.

**Verdict: PASS + caveat.** The weakness observed is **camera angle instability**, not the
lightning: unrequested re-framing appeared inside a "one continuous shot".

### Test 4 — Heavy wind + debris stress test (2 clips generated)

**Purpose:** violent wind and airborne debris while keeping the character readable — cloak
movement, fabric motion, dust swirl, flying leaves/paper/rubble, camera stability during chaos.
**Prompt (verbatim):**

```
Create an 8-second AAA-quality photorealistic 3D CGI horror scene in one continuous cinematic shot.

A hooded figure walks through an abandoned street filled with rubble, broken wood, paper scraps, and dust. The environment is dark and stormy.

0–2 seconds: The air is tense but mostly still. The camera tracks backward in front of the hooded figure as they walk forward.

2–4 seconds: A sudden gust of wind erupts through the street. The figure’s cloak whips violently, dust rises from the ground, and paper scraps begin spinning around them.

4–6 seconds: The wind becomes extremely strong. Wood splinters, leaves, dust, and debris spiral chaotically through the air. The character struggles to maintain footing and stumbles slightly.

6–8 seconds: The storm reaches maximum intensity. Larger debris flies past the camera, the hooded figure braces against the wind, and the scene is filled with swirling particles while remaining visually clear.

Prioritize realistic wind force, cloth simulation, particle movement, environmental interaction, and clear subject readability. Keep the sequence coherent and cinematic. One continuous shot. No dialogue or subtitles.
```

**Observed results — environmental effects:**

| Checkpoint | Result | Notes |
|---|---|---|
| Cloak movement | Good | Reliable |
| Hair / fabric motion | Good | Reliable |
| Dust swirl | Good | Reliable |
| Flying leaves / paper / rubble | Good | Reliable |
| Camera stability during chaos | — | Needs separate testing (§8) |
| Character orientation continuity | **Inconsistent** | Failed in 1 of 2 clips — see below |

**Clip-by-clip (orientation):**

| Clip | Observation | Result |
|---|---|---|
| A | Character walked away, then suddenly faced the camera without physically turning — an impossible instantaneous reversal | **FAILED** |
| B | Character continued walking normally; no impossible turn | **PASSED** |

**Verdict: PASS + caveat.** Environmental motion is strong; orientation is a **stochastic
failure** (1 of 2), not a guaranteed one — plan around it, and isolate it (Test 6, §8).

### Test 5 — Earthquake stress test

**Purpose:** ground shaking and structural collapse — camera shake, floor cracking, falling
debris, stumble/balance correction, environmental destruction.
**Prompt (verbatim):**

```
Create an 8-second photorealistic 3D CGI horror-action sequence in one continuous cinematic shot.

A hooded protagonist stands inside a large abandoned cathedral with cracked stone flooring and broken pillars. The camera is positioned at medium distance, slowly moving toward the character.

0–2 seconds: The cathedral is still and quiet. Dust drifts in the air. The figure stands alert.

2–4 seconds: A low rumble begins. Small vibrations shake the floor, dust falls from the ceiling, and the character reacts with uncertainty.

4–6 seconds: A violent earthquake erupts. The floor cracks open, stones break apart, pillars collapse, and the character stumbles and struggles to stay upright while the camera shakes with the impact.

6–8 seconds: The earthquake intensifies. Massive debris crashes around the room, large fractures spread across the floor, and the character falls to one knee as the cathedral partially collapses around them.

Prioritize believable earthquake motion, structural damage, falling debris, realistic body balance reactions, and cinematic destruction. Keep the character visible and the camera coherent. One continuous shot. No subtitles or dialogue.
```

**Observed results:**

| Checkpoint | Result | Notes |
|---|---|---|
| Camera shaking | **FAILED** | "Zero camera shake. No shaking at all." |
| Floor cracking | Unreliable | Cracking effects did not behave consistently |
| Falling debris | Unreliable | Debris fell in one spot rather than responding to shaking |
| Stumbling / balance correction | Limited pass | The character bent her knees to rebalance — believable partial reaction |
| Environmental destruction | Good | Destruction effects appeared reliably |

**Verdict: FAIL — earthquake simulation.** Four technical reads:

1. **Destruction ≠ earthquake physics** — the appearance of damage renders without the forces
   that cause it.
2. **Falling debris ≠ dynamic debris simulation** — debris falls locally, not in response to
   widespread shaking.
3. **Knee bending ≠ full-body balance recovery** — a partial reaction, not a reliable one.
4. **Requested camera shake = entirely absent** — a stronger finding than Test 3's drift,
   because here the requested motion did not happen at all.

## 5. Test 4 addendum — orientation continuity (2 clips)

Recorded inside Test 4: one clip flipped the walking character to face the camera with no
physical turn (fail), the other kept orientation correctly (pass). Treat as:
**stochastic** — repeat the same prompt + same starting image across several generations
before concluding anything about frequency.

## 6. Cumulative capability tracker

**Strong / reliable (lean on these):**

- lightning — single, repeated, and frequent; exposure and shadow updates believable
- weather transitions (calm → storm in one shot)
- rain
- wind on clothing and on loose debris; dust and particle swirl
- environmental breakage / destruction *appearance*
- dramatic close-up reveal
- simple single physical reactions (stumble, knee bend)

**Weak / unreliable / needs isolation (do not plan as the visible beat):**

- complex multi-step action choreography; several coordinated actions at once
- extreme combined action with many moving parts
- character orientation continuity (stochastic — 1 of 2 clips failed)
- camera angle / shot continuity (unrequested angle changes appeared in Test 3)
- camera shake (entirely absent when requested — Test 5)
- earthquake physics: sustained ground motion, consistent cracking, dynamic debris

## 7. Selection guidance — choosing scenes and consequences from these results

For this project's horror-riddle production, when picking the Teller's act, the consequence,
or the scene's spectacle:

**Prefer (proven to render):**

- **Destruction appearances** as the visible result of the Teller's act — breakage,
  collapse, debris settling; Test 1 and Test 5 both showed destruction renders well even
  when the *physics* behind it does not.
- **Weather spectacle** as consequence backing or scene pressure — storm building, rain,
  frequent lightning, violent wind, drifting dust. All passed; lightning is a headline
  strength.
- **A dramatic close-up** as a reveal beat (Teller's face, the moment something is taken).
- **One simple physical reaction** for a victim (a stumble, sinking to a knee).

**Avoid planning as the visible beat:**

- **Earthquake-style ideas** — "the ground shakes", "everything trembles": the shake will not
  be there (Test 5), and neither will debris that reacts to it.
- **Camera shake requests** — absent, not weak (Test 5). Do not write "the camera shakes".
- **Complex choreography** — multi-step actions, several characters acting at once, "and then
  they also…" beats (Test 1).
- **Mid-clip orientation reversals** — a clip that walks *or* faces away should not also be
  asked to turn and reveal the face; the reversal risks the impossible instant turn (Test 4A).

**Rules of thumb:**

1. **One dominant motion per clip, with at most one strong effect layered on it** — the
   stress tests independently confirm the pack's low-motion, clean-render preset rationale.
2. **Effects-heavy ≠ action-heavy.** Spectacle is safe; movement is not. Pair a big effect with
   a *simple* body action.
3. **If a beat truly needs a turn or a re-framing, make that the clip's one dominant action** —
   not a secondary instruction inside a shot already doing something else.
4. Keep the camera request minimal and explicit (`locked-off`, `one slow push-in`); anything
   more elaborate drifts (Test 3) until Test 6 says otherwise.

> **Wired into the pack in v2.43.0** — the capability map (module 5), the deck guard
> (§2c), the guided filter (§2a), the camera limits (§7a), and the final gate all derive
> from this section. This log stays the evidence source; the camera suite (§8) may refine
> the map.

## 8. Next tests queued — Test 6: camera control & continuity

Motivated by Test 3 (unrequested angle changes) and Test 4 (stochastic orientation flip).
**Methodology:** run each prompt 2–3 generations with the same starting image; log clip-by-clip.

**(a) Orientation hold — rear tracking (the user's controlled prompt, verbatim):**

```
8-second photorealistic 3D CGI cinematic horror sequence.

A hooded man walks steadily away from the camera through a long abandoned Gothic corridor. His back remains visible for the entire duration. The camera follows directly behind him at a constant distance and height.

Wind blows his cloak, fog moves around his feet, and lightning flashes through broken windows. Debris drifts across the corridor.

The man keeps walking forward in the same direction throughout the entire clip. He does not turn his head, rotate his body, reverse direction, or face the camera.

Use exactly one continuous rear-tracking shot. No cuts, no camera orbit, no reverse-angle shots, no scene transitions.

Maintain consistent character anatomy, walking direction, environment layout, and camera position throughout all eight seconds. Realistic horror CGI with cinematic environmental lighting.
```

**(b) Fixed camera (control):** the same scene, but `The camera is locked off on a tripod and
does not move at all` and a still character; watch for any drift, zoom, or re-framing in an
8-second static shot. If even this drifts, camera coherence is a planning constraint, not a
prompt-wording problem.

**(c) Deliberate camera shake:** a still character; "the camera shakes violently as the ground
shakes" — the Test 5 ask, isolated. Pass = visible shake; the point is to separate *not
requested well* from *not possible*.

**(d) Tracking → orbit:** start walking behind the character, then request a deliberate slow
orbit to the front. Pass = one smooth intended arc; fail = jumps, cuts, or instant angle
changes.

**(e) Deliberate 180° turn:** the character walks away, then turns to face the camera as the
clip's **one dominant action** (not a secondary instruction). Compare against Test 4A — this
distinguishes "turns can't render" from "turns fail when layered onto another action".

---

## Related

- `modules/06-model-rules.md` — the model/feature capability table this log feeds.
- `modules/03b-auto-presets.md` — Deck R's low-motion, clean-render presets, independently
  validated by tests 1, 5 and 4's caveat.
- `specs/pacing-and-consequence.md` — v2.42.0's beat rules; this log's §7 is where a future
  version would plug scene/consequence capability limits in.
