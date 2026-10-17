#!/usr/bin/env python3
"""Executes the auto-riddle deck-draw snippet shipped in §2c of the pack.

Extracts the ```python block from modules/03b-auto-presets.md and asserts the
contract the pack states:
  1. it runs clean without modification (zero-indent top lines),
  2. across 60 runs both clip counts occur and every drawn value comes from its
     shipped list — a real draw, not a constant dressed as one,
  3. with PREVIOUS filled (one value per list), the excluded values never appear
     in their lines and the "excluding:" line names them — the no-repeat rule is
     code, not diligence. The clip count is exempt by design.
The guard in validate.sh (§47) runs this.
"""
import contextlib
import io
import pathlib
import re
import sys

MOD = pathlib.Path(__file__).resolve().parents[2] / "modules" / "03b-auto-presets.md"

code = MOD.read_text(encoding="utf-8").split("```python\n", 1)[1].split("```", 1)[0]
if code.splitlines()[0] != code.splitlines()[0].lstrip() or any(
    l[:1] in (" ", "\t") for l in code.splitlines()[:3]
):
    sys.exit("FAIL: snippet lines are indented — a uniform indent is a fatal IndentationError when pasted")

KEY_TO_LIST = {
    "preset": "PRESETS",
    "setting": "SETTINGS",
    "style": "STYLES",
    "consequence": "CONSEQUENCES",
    "victim": "VICTIMS",
    "teller": "TELLERS",
    "size": "SIZES",
}


def run(source):
    out = io.StringIO()
    with contextlib.redirect_stdout(out):
        exec(source, {})
    return out.getvalue()


# Phase 1 — fresh draw: both counts occur, every value comes from its shipped list.
counts, seen_bad = set(), []
for _ in range(60):
    text = run(code)
    m = re.search(r"^clips = ([23])$", text, re.M)
    if not m:
        sys.exit(f"FAIL: no 'clips = 2|3' line in output: {text!r}")
    counts.add(m.group(1))
    ns = {}
    with contextlib.redirect_stdout(io.StringIO()):
        exec(code, ns)
    for key, list_name in KEY_TO_LIST.items():
        mm = re.search(rf"^{key} = (.+)$", text, re.M)
        if not mm:
            sys.exit(f"FAIL: missing '{key} =' line in output: {text!r}")
        if mm.group(1) not in ns[list_name]:
            seen_bad.append(f"{key}={mm.group(1)!r} not in {list_name}")
if seen_bad:
    sys.exit("FAIL: drew values outside the shipped lists: " + "; ".join(seen_bad))
if counts != {"2", "3"}:
    sys.exit(f"FAIL: 60 runs drew only {sorted(counts)} — not a real 2/3 draw")

# Phase 2 — the no-repeat rule is code: fill PREVIOUS, excluded values cannot land.
ns = {}
with contextlib.redirect_stdout(io.StringIO()):
    exec(code, ns)
previous = [ns[name][0] for name in KEY_TO_LIST.values()]
excluded = dict(zip(KEY_TO_LIST.keys(), previous))
text = run(code.replace("PREVIOUS = []", f"PREVIOUS = {previous!r}", 1))
if not text.startswith("excluding: " + ", ".join(previous)):
    sys.exit(f"FAIL: 'excluding:' line does not name the pasted values: {text.splitlines()[0]!r}")
for key, banned in excluded.items():
    mm = re.search(rf"^{key} = (.+)$", text, re.M)
    if not mm:
        sys.exit(f"FAIL: missing '{key} =' line under exclusion: {text!r}")
    if mm.group(1) == banned:
        sys.exit(f"FAIL: PREVIOUS exclusion did not hold — {key} = {banned!r} was drawn again")
m = re.search(r"^clips = ([23])$", text, re.M)
if not m:
    sys.exit(f"FAIL: clips line missing under exclusion: {text!r}")

print("ok: snippet runs as written; 60 runs drew both counts inside the lists; "
      "PREVIOUS exclusions hold and the paste is visible")
