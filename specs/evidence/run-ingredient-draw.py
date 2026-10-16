#!/usr/bin/env python3
"""Executes the riddle-ingredient-draw snippet shipped in §2b of the pack.

Extracts the ```python block from modules/03-riddle-prephase.md, runs it with the
real secrets.Entropy (SystemRandom), and asserts the contract the pack states:
it runs clean without modification, produces N unique draws, and no two draws
share a category+subcategory combination. This proves the snippet ChatGPT is
told to paste is itself correct — the guard in validate.sh (§43) runs it.
"""
import contextlib
import io
import pathlib
import sys

MOD = pathlib.Path(__file__).resolve().parents[2] / "modules" / "03-riddle-prephase.md"

code = MOD.read_text(encoding="utf-8").split("```python\n", 1)[1].split("```", 1)[0]
if code.splitlines()[0] != code.splitlines()[0].lstrip() or any(
    l[:1] in (" ", "\t") for l in code.splitlines()[:3]
):
    sys.exit("FAIL: snippet lines are indented — a uniform indent is a fatal IndentationError when pasted")

out = io.StringIO()
try:
    with contextlib.redirect_stdout(out):
        exec(code, {})
except Exception as e:  # noqa: BLE001
    sys.exit(f"FAIL: shipped snippet does not run as written: {e}")

lines = out.getvalue().strip().splitlines()
n = len(lines)
if n != 10:
    sys.exit(f"FAIL: expected 10 draws, got {n}")
combos = {tuple(l.split(" | ")[:2]) for l in lines}
if len(combos) != n:
    sys.exit("FAIL: category+subcategory combinations are not unique across the batch")
print(f"ok: snippet runs as written; {n} draws, {len(combos)} unique combinations")
