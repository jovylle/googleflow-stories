#!/usr/bin/env python3
"""Executes the auto-riddle shape-draw snippet shipped in §2c of the pack.

Extracts the ```python block from modules/03b-auto-presets.md, runs it with the
real secrets entropy (SystemRandom), and asserts the contract the pack states:
it runs clean without modification, prints "clips = 2" or "clips = 3" every
time, and both values occur across repeated runs — so the shipped list is a real
two-value draw, not a constant dressed as one. This proves the snippet ChatGPT
is told to paste is itself correct — the guard in validate.sh (§45) runs it.
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

seen = set()
for _ in range(60):
    out = io.StringIO()
    try:
        with contextlib.redirect_stdout(out):
            exec(code, {})
    except Exception as e:  # noqa: BLE001
        sys.exit(f"FAIL: shipped snippet does not run as written: {e}")
    m = re.fullmatch(r"clips = ([23])\n?", out.getvalue())
    if not m:
        sys.exit(f"FAIL: snippet printed {out.getvalue()!r}, expected 'clips = 2' or 'clips = 3'")
    seen.add(m.group(1))

if seen != {"2", "3"}:
    sys.exit(f"FAIL: 60 runs drew only {sorted(seen)} — the shipped list is not a real 2/3 draw")

print("ok: snippet runs as written; 60 runs drew both 2 and 3, nothing else")
