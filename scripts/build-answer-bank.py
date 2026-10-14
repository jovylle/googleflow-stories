#!/usr/bin/env python3
"""build-answer-bank.py — emit modules/03a-answer-bank.md from the answer-bank JSON.

WHY THIS SCRIPT EXISTS
The riddle generator collapsed onto a handful of answers because it had no source
of answers at all: every run invented them, and the illustrations in the riddle
module (salamin, kandila, anino, orasan) read as the menu. The user's answer bank
(capital 1,000 Tagalog answers) existed but nothing in the pack referenced it.

This script is the bridge: data/riddle-answer-bank.json -> modules/03a-answer-bank.md,
so the pack carries the pool itself and the generator has a real, addressable
source. It is a build step, not an authored file: never hand-edit the module.

Generated per line:
    NNNN <answer>                     family == the answer itself
    NNNN <answer> [<family>]          a variant; the head noun is a different entry
    NNNN <answer> [<family>] [not-an-answer]   a description, not a thing to guess

Section 2c, referenced by the protocol in section 2b — the numbering follows the riddle
module's own series (2, 2a, 2b, 2c) rather than the build order, because the interview
module owns section 3.
The 4-digit prefix is the bank's own id (0001 == BUG-0001), so a used-answer
record written against this module stays valid if the bank is later extended.

The family is derived, never hand-listed: the first token that is itself a bare
answer in the bank, accounting for the Tagalog -ng/-g ligature, else the first
token. That is what lets the rule "no two picks in a batch share a family" be
checked by eye — variants of one thing carry the same bracket.

Usage:
    python3 scripts/build-answer-bank.py            # write the module
    python3 scripts/build-answer-bank.py --check    # verify it is up to date
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
JSON_PATH = ROOT / "data" / "riddle-answer-bank.json"
OUT_PATH = ROOT / "modules" / "03a-answer-bank.md"

# A bank entry that describes a thing ("kandilang walang apoy") is a riddle already,
# not an answer to guess. The bank's own notes flag that these need review; this is
# the narrow, mechanical version of that note so the generator can skip them.
DESCRIPTION_RE = re.compile(r"\b(na\s+)?walang\b", re.IGNORECASE)


def load_bank() -> dict:
    data = json.loads(JSON_PATH.read_text(encoding="utf-8"))
    answers = data.get("answers")
    if not isinstance(answers, list) or not answers:
        raise SystemExit(f"{JSON_PATH}: no 'answers' list")
    return data


def bare_answers(answers: list[dict]) -> set[str]:
    """Answers that are a single token — the vocabulary the family rule matches against."""
    return {e["answer"].strip().lower() for e in answers if len(e["answer"].split()) == 1}


def family_of(answer: str, bare: set[str]) -> str:
    """The answer's head noun, as a bank token.

    Scans the entry's tokens for one that is itself a bare answer, accepting the
    Tagalog ligature forms (`salaming` -> `salamin`, `kandilang` -> `kandila`).
    Falls back to the first token, so every entry has exactly one family.
    """
    tokens = [t for t in re.split(r"\s+", answer.strip().lower()) if t]
    if not tokens:
        return answer.strip().lower()
    for token in tokens:
        if token in bare:
            return token
        for stripped in _ligature_forms(token):
            if stripped in bare:
                return stripped
    return tokens[0]


def _ligature_forms(token: str) -> list[str]:
    forms = []
    if token.endswith("ng"):
        forms.append(token[:-2])
    if token.endswith("g"):
        forms.append(token[:-1])
    return forms


def render(data: dict, answers: list[dict]) -> str:
    bare = bare_answers(answers)
    rows: list[str] = []
    tagged = desc = 0
    for entry in answers:
        eid = str(entry["id"]).split("-")[-1]  # BUG-0001 -> 0001
        answer = entry["answer"].strip()
        if "\n" in answer or "\t" in answer:
            raise SystemExit(f"{entry['id']}: answer contains a line break or tab")
        family = family_of(answer, bare)
        suffix = ""
        if family != answer.strip().lower():
            suffix += f" [{family}]"
            tagged += 1
        if DESCRIPTION_RE.search(answer):
            suffix += " [not-an-answer]"
            desc += 1
        rows.append(f"{eid} {answer}{suffix}")

    families = {family_of(e["answer"], bare) for e in answers}
    multi = len({family_of(e["answer"], bare) for e in answers if len(e["answer"].split()) > 1})

    head = f'''<!--
WHY THIS MODULE EXISTS:
The riddle generator used to invent its own answers. With no source, every run
converged on the same few objects and the riddle module's own illustrations
(salamin, kandila, anino, orasan) read as the menu — so unrelated sessions kept
producing the same riddles. This module is the generator's answer source: the
user's 1,000-answer bank, embedded so the pack needs no upload and no retrieval.

HOW TO READ IT:
Every line is one answer: a 4-digit index, then the answer.
  0001 salamin                  the family is the answer itself
  0037 kandila sa mesa [kandila]   a variant — its family is `kandila`
  0104 salaming walang repleksiyon [salamin] [not-an-answer]
The bracketed family is the entry\'s head noun: two entries that share a bracket
are two versions of one thing, and picking both in one batch is a visible repeat.
`[not-an-answer]` marks an entry that is already a description ("a mirror without
a reflection") rather than a guessable thing, so it must not be chosen as an answer.

The index is the bank\'s own id (0001 == BUG-0001). A used-answer record written
against this list stays valid if the bank is later extended.
The selection protocol that consumes this list is in the riddle module, section 2b.
Do not hand-edit this module — it is generated by scripts/build-answer-bank.py.
-->
## 2c. Riddle answer bank ({len(answers)} answers)

The answer bank. It is the **source of answers** for every generated riddle: the
generator picks an entry here and writes a riddle whose answer is that entry. The
illustrations in the riddle module are illustrations; **this list is the source.**

- Source: {data.get("name")} {data.get("version")} (`data/riddle-answer-bank.json`).
- Language: {data.get("language")}. When the production language is another one, the
  chosen answer is translated into that language and the riddle is written there.
- {len(answers)} entries · {len(families)} families · {tagged} variant entries share a family with another
  entry · {desc} entries are descriptions rather than answers.
- The list is in the bank\'s own order. **The order is not a selection order** — see
  section 2b, which spreads a batch across the whole bank instead of taking the head.

'''
    body = "\n".join(rows)
    tail = """

---

"""
    return head + body + tail


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="verify the module is current")
    args = ap.parse_args()

    data = load_bank()
    rendered = render(data, data["answers"])

    if args.check:
        current = OUT_PATH.read_text(encoding="utf-8") if OUT_PATH.exists() else ""
        if current != rendered:
            print(f"STALE: {OUT_PATH.relative_to(ROOT)} — run scripts/build-answer-bank.py", file=sys.stderr)
            return 1
        print(f"ok: {OUT_PATH.relative_to(ROOT)} is current")
        return 0

    OUT_PATH.write_text(rendered, encoding="utf-8")
    print(f"wrote {OUT_PATH.relative_to(ROOT)}")
    print(f"  answers: {len(data['answers'])}")
    print(f"  chars:   {len(rendered)}")
    print(f"  lines:   {rendered.count(chr(10)) + 1}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
