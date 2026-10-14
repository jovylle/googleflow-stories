#!/usr/bin/env python3
"""score-answer-pool-dry-run.py — score the answer-pool dry run against the bank.

WHAT THIS SCORES, AND WHAT IT DOES NOT
This scores a **dry run of the selection protocol** in `modules/03-riddle-prephase.md`
section 2b: the picks in `answer-pool-dry-run.tsv` were produced by applying that
protocol to the real bank, so this checks that the protocol *as written* yields a
spread batch with no repeated families — and, independently, that every pick is a
genuine bank entry.

It is not evidence that a live ChatGPT run follows 2b. Only a live run shows that.
Do not report this as a live result.

Every criterion is re-derived from `data/riddle-answer-bank.json`, so the sample
cannot certify itself: the answers, families, and exclusions are recomputed here
rather than read from the TSV.

Exit code 0 = every criterion met.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
BANK = ROOT / "data" / "riddle-answer-bank.json"
TSV = Path(__file__).resolve().parent / "answer-pool-dry-run.tsv"

DESCRIPTION_RE = re.compile(r"\b(na\s+)?walang\b", re.IGNORECASE)
# The illustrations in Step 0a, as families. If picks drift back onto these, the
# generator is reading the examples as a menu again — the defect this fixes.
ILLUSTRATIONS = {
    "shadow", "anino", "echo", "alingawngaw", "mirror", "salamin", "clock", "orasan",
    "candle", "kandila", "wind", "hangin", "footprint", "footprints", "yapak", "book",
    "aklat", "rain", "ulan", "smoke", "usok", "key", "susi", "broom", "walis", "needle",
    "karayom", "river", "ilog", "salt", "asin", "bell", "kampana", "rope", "lubid",
    "window", "bintana", "well", "balon", "spoon", "kutsara",
}


def load_bank() -> list[dict]:
    return json.loads(BANK.read_text(encoding="utf-8"))["answers"]


def family_of(answer: str, bare: set[str]) -> str:
    """Same derivation as scripts/build-answer-bank.py — recomputed, not trusted."""
    tokens = [t for t in re.split(r"\s+", answer.strip().lower()) if t]
    for token in tokens:
        if token in bare:
            return token
        for stripped in ((token[:-2] if token.endswith("ng") else None),
                         (token[:-1] if token.endswith("g") else None)):
            if stripped and stripped in bare:
                return stripped
    return tokens[0] if tokens else answer.strip().lower()


def load_sample() -> list[dict]:
    lines = [l for l in TSV.read_text(encoding="utf-8").splitlines() if l.strip()]
    header = lines[0].split("\t")
    out = []
    for n, line in enumerate(lines[1:], start=2):
        f = line.split("\t")
        if len(f) != len(header):
            raise SystemExit(f"{TSV.name}:{n}: {len(f)} fields, expected {len(header)} "
                             "(a misaligned row would silently shift every column after it)")
        out.append(dict(zip(header, f)))
    return out


def main() -> int:
    bank = load_bank()
    by_idx = {str(e["id"]).split("-")[-1]: e for e in bank}
    bare = {e["answer"].strip().lower() for e in bank if len(e["answer"].split()) == 1}
    row_by_idx = {i: (e["answer"].strip(), family_of(e["answer"], bare),
                      bool(DESCRIPTION_RE.search(e["answer"])))
                  for i, e in by_idx.items()}
    sample = load_sample()
    failures: list[str] = []
    checks = 0

    def check(ok: bool, label: str, detail: str = "") -> None:
        nonlocal checks
        checks += 1
        print(f"  {'PASS' if ok else 'FAIL'}  {label}{'  — ' + detail if detail else ''}")
        if not ok:
            failures.append(label)

    total = len(sample)
    batches: dict[str, list[dict]] = {}
    for r in sample:
        batches.setdefault(r["batch"], []).append(r)

    print(f"Scoring {total} picks across {len(batches)} batches (dry run of section 2b)\n")

    # 1. provenance — every pick is a real bank entry, answer and family recomputed
    bad = [r["index"] for r in sample
           if r["index"] not in row_by_idx
           or r["answer"] != row_by_idx[r["index"]][0]
           or r["family"] != row_by_idx[r["index"]][1]]
    check(not bad, "every pick is a real bank entry (index, answer, family recomputed)",
          f"{len(bad)} mismatched: {bad[:5]}" if bad else f"{total}/{total} verified")

    # 2. no entry that is a description rather than an answer
    desc = [r["index"] for r in sample if row_by_idx[r["index"]][2]]
    check(not desc, "no [not-an-answer] entry was picked as an answer", f"picked {desc}")

    # 3. the rule: no two candidates in one batch share a family
    within = [(b, r["family"]) for b, rs in batches.items()
              for r in rs if [x["family"] for x in rs].count(r["family"]) > 1]
    check(not within, "no two candidates in one batch share a family",
          f"{len(within)} collisions" if within else "0 collisions in 6 batches")

    # 4. across the whole sample — no family (and so no answer) offered twice
    fams = [r["family"] for r in sample]
    dupes = sorted({f for f in fams if fams.count(f) > 1})
    check(not dupes, "no family repeats anywhere in the sample", f"repeated: {dupes}")

    # 5. spread — each batch steps evenly through the bank, not clustered
    jagged = []
    for b, rs in batches.items():
        idx = sorted(int(r["index"]) for r in rs)
        gaps = [b - a for a, b in zip(idx, idx[1:])] + [idx[0] + 1000 - idx[-1]]
        if any(not (80 <= g <= 320) for g in gaps):
            jagged.append((b, gaps))
    check(not jagged, "each batch is evenly spread across the bank (gaps 80-320)",
          f"uneven: {jagged}" if jagged else "5 picks per batch, stride ~200")

    # 6. the head of the list is not the default
    firsts = [int(rs[0]["index"]) for rs in batches.values()]
    check(all(v >= 41 for v in firsts), "no batch started at the head of the list",
          "starting indexes: " + ", ".join(f"{v:04d}" for v in firsts))
    head = [r["index"] for r in sample if int(r["index"]) <= 100]
    expected = total / 10  # the head decile's fair share of the picks
    check(len(head) <= expected + 2,
          "the head decile is not over-represented",
          f"{len(head)}/{total} picks in the first 100 indexes (fair share {expected:.0f})")
    starts = [rs[0]["index"] for rs in batches.values()]
    check(len(set(starts)) == len(starts), "no two batches started at the same index",
          "starts: " + ", ".join(starts))

    # 7. coverage — the sample spans the bank rather than one region
    deciles = {int(r["index"]) // 100 for r in sample}
    check(len(deciles) >= 8, "the picks span at least 8 of the bank's 10 deciles",
          f"{len(deciles)}/10 deciles covered (span "
          f"{min(int(r['index']) for r in sample):04d}-{max(int(r['index']) for r in sample):04d})")

    # 8. the illustration list is not the menu it used to be
    ill = [r for r in sample if r["family"] in ILLUSTRATIONS]
    check(len(ill) <= total * 0.1,
          "picks do not drift back onto the illustration answers",
          f"{len(ill)}/{total} are illustration families ({', '.join(r['answer'] for r in ill) or 'none'})")

    print()
    if failures:
        print(f"answer-pool dry run: {len(failures)} criteria FAILED — {failures}")
        return 1
    print(f"answer-pool dry run: {total} picks, all {checks} criteria met")
    return 0


if __name__ == "__main__":
    sys.exit(main())
