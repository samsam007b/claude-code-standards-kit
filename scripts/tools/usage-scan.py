#!/usr/bin/env python3
"""
usage-scan.py: measures which agents, skills and commands are actually used.

Why this script exists
----------------------
The 07/21 audit counted by hand 28 agents out of 53 never invoked. The
08/18 one found that this figure had never been re-measured: we audited every
six months what should have been measured continuously. Public reference
setups, including those with 229 skills, measure nothing at all. This is
therefore the point where this setup can pull ahead, and it costs about a hundred lines.

Why read transcripts rather than add a hook
-------------------------------------------
A PostToolUse hook would have required editing settings.json, which carries a
deliberate chflags uchg and requires a physical manipulation. Above all, a hook
knows nothing about the past: we would have to wait three months to get the first
number. Session transcripts already contain the whole history, so the
measurement is available retroactively and without touching the configuration.

Cost and incrementality
-----------------------
The corpus is 7 GiB. Two precautions make the daily pass negligible:
a cache (path, size, mtime) that skips any file already read and unchanged, and
a substring pre-filter before any json.loads, because decoding every
line of every session would cost minutes for a few thousand really useful
lines.
"""
import json
import os
import sys
import time
from pathlib import Path

RACINE = Path.home() / ".claude" / "projects"
ETAT = Path.home() / ".claude" / "state" / "usage.json"
CACHE = Path.home() / ".claude" / "state" / "usage-cache.json"
FENETRE_JOURS = int(os.environ.get("USAGE_FENETRE", "180"))

# Pre-filter: a line containing none of these markers cannot
# carry an invocation, so we avoid decoding it.
MARQUEURS = (b'"Agent"', b'"Skill"', b'"Task"')


def charger(p, defaut):
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except Exception:
        return defaut


def scanner():
    cache = charger(CACHE, {})
    etat = charger(ETAT, {"agents": {}, "skills": {}, "genere": None})
    agents = etat.get("agents", {})
    skills = etat.get("skills", {})

    limite = time.time() - FENETRE_JOURS * 86400
    lus, sautes = 0, 0

    for f in RACINE.rglob("*.jsonl"):
        try:
            st = f.stat()
        except OSError:
            continue
        if st.st_mtime < limite:
            continue
        cle = str(f)
        signature = [st.st_size, int(st.st_mtime)]
        if cache.get(cle) == signature:
            sautes += 1
            continue

        jour = time.strftime("%Y-%m-%d", time.localtime(st.st_mtime))
        try:
            with f.open("rb") as fh:
                for brut in fh:
                    if not any(m in brut for m in MARQUEURS):
                        continue
                    try:
                        d = json.loads(brut)
                    except Exception:
                        continue
                    msg = d.get("message") or {}
                    contenu = msg.get("content")
                    if not isinstance(contenu, list):
                        continue
                    for bloc in contenu:
                        if not isinstance(bloc, dict) or bloc.get("type") != "tool_use":
                            continue
                        nom = bloc.get("name")
                        entree = bloc.get("input") or {}
                        if nom in ("Agent", "Task"):
                            qui = entree.get("subagent_type")
                            cible = agents
                        elif nom == "Skill":
                            qui = entree.get("skill")
                            cible = skills
                        else:
                            continue
                        if not qui:
                            continue
                        e = cible.setdefault(qui, {"n": 0, "dernier": jour})
                        e["n"] += 1
                        if jour > e["dernier"]:
                            e["dernier"] = jour
        except OSError:
            continue

        cache[cle] = signature
        lus += 1

    etat = {
        "agents": agents,
        "skills": skills,
        "genere": time.strftime("%Y-%m-%d %H:%M"),
        "fenetre_jours": FENETRE_JOURS,
        "fichiers_lus": lus,
        "fichiers_deja_connus": sautes,
    }
    ETAT.parent.mkdir(parents=True, exist_ok=True)
    ETAT.write_text(json.dumps(etat, ensure_ascii=False, indent=1), encoding="utf-8")
    CACHE.write_text(json.dumps(cache), encoding="utf-8")
    return etat


def rapport(etat):
    definis = {p.stem for p in (Path.home() / ".claude" / "agents").glob("*.md")}
    utilises = set(etat["agents"])
    jamais = sorted(definis - utilises)

    print(f"files read {etat['fichiers_lus']}, already known {etat['fichiers_deja_connus']}")
    print(f"\nagents defined {len(definis)}, invoked at least once {len(definis & utilises)}, "
          f"never invoked {len(jamais)}")
    print("\ntop agents:")
    for k, v in sorted(etat["agents"].items(), key=lambda x: -x[1]["n"])[:10]:
        marque = "" if k in definis else "   (not defined locally)"
        print(f"  {v['n']:5d}  {k:32s} last {v['dernier']}{marque}")
    print("\ntop skills:")
    for k, v in sorted(etat["skills"].items(), key=lambda x: -x[1]["n"])[:10]:
        print(f"  {v['n']:5d}  {k:32s} last {v['dernier']}")
    print(f"\nnever invoked ({len(jamais)}):")
    print("  " + ", ".join(jamais) if jamais else "  none")


if __name__ == "__main__":
    t0 = time.time()
    e = scanner()
    rapport(e)
    print(f"\nduration {time.time() - t0:.1f}s")
