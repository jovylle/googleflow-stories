#!/usr/bin/env python3
"""Score a creative-diversity dry run against the v2.35.0 acceptance criteria.

Reads specs/evidence/diversity-dry-run.tsv and checks each criterion the
regression report asked to be verifiable. Exit 0 = every criterion met.

This scores a *dry run* — ensembles produced by following section 2a by hand —
not a live ChatGPT run. It proves the rulebook's axes can produce a varied set
and that the set passes every stated bar; it cannot prove a model will obey.
See specs/creative-diversity.md for that distinction.
"""
import sys
from pathlib import Path

TSV = Path(__file__).with_name("diversity-dry-run.tsv")

# Victim classes that were the old default and must not be the whole set.
NARROW_VICTIM_CLASSES = {"small mammal", "bird"}
# Teller silhouettes the regression report named as the runaway default.
GIANT_CLOAKED = ("giant", "cloaked", "humanoid")

MIN_PRODUCTIONS = 12
MIN_SIZE_RELATIONS = 3
MIN_DISTINCT_CAMERAS = 6
MIN_DISTINCT_CONSEQUENCES = 5
MAX_PASSAGE_SETTINGS = 2


def load():
    lines = TSV.read_text(encoding="utf-8").rstrip("\n").split("\n")
    header = lines[0].split("\t")
    rows = []
    for i, line in enumerate(lines[1:], start=2):
        fields = line.split("\t")
        if len(fields) != len(header):
            raise SystemExit(
                f"{TSV.name}:{i}: {len(fields)} fields, expected {len(header)} "
                f"(a misaligned row would silently shift every axis after it)"
            )
        rows.append(dict(zip(header, fields)))
    return rows


def main():
    rows = load()
    results = []

    def check(name, ok, detail):
        results.append((name, ok, detail))

    n = len(rows)
    check(f"{MIN_PRODUCTIONS}+ productions in the sample", n >= MIN_PRODUCTIONS, f"{n} productions")

    sizes = {r["size_relation"] for r in rows}
    check(
        f"{MIN_SIZE_RELATIONS}+ distinct size relationships",
        len(sizes) >= MIN_SIZE_RELATIONS,
        f"{len(sizes)} distinct: {', '.join(sorted(sizes))}",
    )

    narrow = [r["n"] for r in rows if r["victim_class"] in NARROW_VICTIM_CLASSES]
    check(
        "not every victim is a small mammal or bird",
        len(narrow) < n,
        f"{len(narrow)}/{n} are small-mammal/bird (runs {', '.join(narrow) or '—'})",
    )

    giants = [r["n"] for r in rows if all(w in r["teller_form"].lower() for w in GIANT_CLOAKED)]
    check(
        "not every Teller is a giant cloaked humanoid",
        len(giants) == 0,
        f"{len(giants)}/{n} are giant-cloaked-humanoid (runs {', '.join(giants) or '—'})",
    )

    passages = [r["n"] for r in rows if r["passage_setting"] == "yes"]
    check(
        f"settings avoid doors/gates/corridors/bridges (<= {MAX_PASSAGE_SETTINGS})",
        len(passages) <= MAX_PASSAGE_SETTINGS,
        f"{len(passages)}/{n} passage settings (runs {', '.join(passages) or '—'})",
    )

    cameras = {r["camera"] for r in rows}
    check(
        f"{MIN_DISTINCT_CAMERAS}+ distinct camera viewpoints",
        len(cameras) >= MIN_DISTINCT_CAMERAS,
        f"{len(cameras)} distinct: {' | '.join(sorted(cameras))}",
    )
    rear = [r["n"] for r in rows if "behind" in r["camera"].lower() or "rear" in r["camera"].lower()]
    check(
        "the rear-view figure facing a larger centred one is not the house style",
        len(rear) <= 1,
        f"{len(rear)}/{n} rear-view framing (runs {', '.join(rear) or '—'})",
    )

    consequences = {r["consequence"] for r in rows}
    check(
        f"{MIN_DISTINCT_CONSEQUENCES}+ meaningfully different consequences",
        len(consequences) >= MIN_DISTINCT_CONSEQUENCES,
        f"{len(consequences)} distinct acts",
    )
    sealing = [r["n"] for r in rows if "seal" in r["consequence"].lower() and "seal" not in r["trap"].lower()]
    sealing = [r["n"] for r in rows if r["consequence"].lower().startswith("it seals")]
    check(
        "sealing/capturing is not the default consequence",
        len(sealing) <= 1,
        f"{len(sealing)}/{n} end in sealing (runs {', '.join(sealing) or '—'})",
    )

    # Recent-design non-reuse, as section 2a states it: no two *consecutive*
    # runs share a victim archetype, a Teller silhouette, or a setting+camera pair.
    clashes = []
    for a, b in zip(rows, rows[1:]):
        for axis, key in (
            ("victim archetype", "victim_type"),
            ("Teller silhouette", "teller_form"),
            ("environment+camera", None),
        ):
            if key:
                same = a[key] == b[key]
            else:
                same = (a["setting"], a["camera"]) == (b["setting"], b["camera"])
            if same:
                clashes.append(f"{a['n']}→{b['n']} {axis}")
    check("no consecutive run repeats the recent design", not clashes, ", ".join(clashes) or "no repeats")

    # Whole-sample uniqueness: a materially different composition, not a recolour.
    for label, key in (
        ("victim archetypes", "victim_type"),
        ("Teller forms", "teller_form"),
        ("environment+camera pairs", None),
    ):
        vals = [(r["setting"], r["camera"]) if key is None else r[key] for r in rows]
        dupes = sorted({v for v in vals if vals.count(v) > 1})
        check(f"all {label} distinct across the sample", not dupes, f"{len(vals) - len(set(vals))} duplicate(s)")

    width = max(len(name) for name, _, _ in results)
    print("Creative-diversity dry run — acceptance criteria (section 2a)\n")
    for name, ok, detail in results:
        print(f"  {'PASS' if ok else 'FAIL'}  {name:<{width}}  {detail}")
    failed = [name for name, ok, _ in results if not ok]
    print(f"\nsummary: {len(results) - len(failed)}/{len(results)} criteria met")
    if failed:
        print("failed: " + "; ".join(failed))
        return 1
    print("result: PASS — the axes produce a varied set and the set clears every stated bar")
    return 0


if __name__ == "__main__":
    sys.exit(main())
