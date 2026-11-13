#!/usr/bin/env python3
"""
usage-scan.py — mesure quels agents, skills et commandes servent reellement.

Pourquoi ce script existe
-------------------------
L'audit du 21/07 a compte a la main 28 agents sur 53 jamais invoques. Celui du
18/08 a constate que ce chiffre n'avait jamais ete remesure : on auditait tous
les six mois ce qu'il fallait mesurer en continu. Les setups publics de
reference, y compris ceux a 229 skills, ne mesurent rien du tout. C'est donc le
point ou ce setup peut passer devant, et il coute une centaine de lignes.

Pourquoi lire les transcripts plutot que poser un hook
-----------------------------------------------------
Un hook PostToolUse aurait demande d'editer settings.json, qui porte un
chflags uchg volontaire et exige une manipulation physique. Surtout, un hook ne
sait rien du passe : il faudrait attendre trois mois pour obtenir le premier
chiffre. Les transcripts de session contiennent deja tout l'historique, donc la
mesure est disponible retroactivement et sans toucher a la configuration.

Cout et incrementalite
----------------------
Le corpus fait 7 Gio. Deux precautions rendent le passage quotidien negligeable :
un cache (chemin, taille, mtime) qui saute tout fichier deja lu et inchange, et
un pre-filtre par sous-chaine avant tout json.loads, parce que decoder chaque
ligne de chaque session couterait des minutes pour quelques milliers de lignes
reellement utiles.
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

# Pre-filtre : une ligne qui ne contient aucun de ces marqueurs ne peut pas
# porter d'invocation, on evite de la decoder.
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

    print(f"fichiers lus {etat['fichiers_lus']}, deja connus {etat['fichiers_deja_connus']}")
    print(f"\nagents definis {len(definis)}, invoques au moins une fois {len(definis & utilises)}, "
          f"jamais invoques {len(jamais)}")
    print("\ntop agents :")
    for k, v in sorted(etat["agents"].items(), key=lambda x: -x[1]["n"])[:10]:
        marque = "" if k in definis else "   (non defini localement)"
        print(f"  {v['n']:5d}  {k:32s} dernier {v['dernier']}{marque}")
    print("\ntop skills :")
    for k, v in sorted(etat["skills"].items(), key=lambda x: -x[1]["n"])[:10]:
        print(f"  {v['n']:5d}  {k:32s} dernier {v['dernier']}")
    print(f"\njamais invoques ({len(jamais)}) :")
    print("  " + ", ".join(jamais) if jamais else "  aucun")


if __name__ == "__main__":
    t0 = time.time()
    e = scanner()
    rapport(e)
    print(f"\nduree {time.time() - t0:.1f}s")
