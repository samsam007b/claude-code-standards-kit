#!/usr/bin/env python3
"""Stop hook — local-search-before-uncertainty

Bloque la fin du tour si le dernier message assistant contient un marqueur
d'incertitude ("[À CONFIRMER]", "je n'ai pas cette info", etc.) sans qu'une
recherche locale ciblée sur le sujet en question (Grep/Glob/find/grep sur
~/Desktop, ~/Projects, ~/.claude, ou Agent Explore/memory search_nodes)
n'ait été faite dans ce même tour.

Incident déclencheur : Claude a marqué un nom de client comme [À CONFIRMER] et a
proposé de demander à l'utilisateur, alors que l'info existait déjà dans un fichier
local du projet. Règle
CLAUDE.md "chercher avant de demander" existait déjà en prose mais n'était
pas garantie — converti en hook déterministe.

v2 (même jour) : la v1 acceptait n'importe quelle commande mentionnant
"grep"/"~/Desktop" comme preuve de recherche, même sans rapport avec le
sujet incertain (ex: un `cat ~/Desktop/foo.md` déjà lancé pour autre chose
suffisait à débloquer). v2 exige un chevauchement de mots-clés entre le
texte autour du marqueur d'incertitude et la requête de recherche
(pattern grep, nom du Glob, query memory, prompt de l'agent Explore).
Fallback lenient (n'importe quelle recherche locale suffit) uniquement si
aucun terme distinctif n'a pu être extrait du texte incertain.

v3 (même jour, faux positif réel en prod) : deux bugs trouvés en se faisant
bloquer soi-même. (1) Les lignes de tableau markdown citant les marqueurs
en exemple ("Élargie (à confirmer, pas certain...)") étaient matchées
comme si c'était une vraie déclaration d'incertitude — les tableaux/blocs
de code sont maintenant exclus du texte scanné. (2) extract_turn_entries
s'arrêtait au premier bloc role=="user" en remontant, mais un tool_result
(réponse d'un appel d'outil) a aussi role=="user" dans le format API —
un tour avec plusieurs allers-retours d'outils était donc tronqué avant
d'avoir vu toutes les recherches faites plus tôt dans le même tour. Ne
s'arrête plus que sur un vrai message humain (bloc de type "text", pas
"tool_result").

Non-bloquant au-delà de 8 blocages consécutifs (comportement Claude Code
natif, cf. doc officielle "Stop hook").
"""
import sys
import json
import re
import os

UNCERTAINTY_MARKERS = re.compile(
    r"\[À CONFIRMER\]"
    r"|je n['’]ai pas (cette info|de données|d['’]information|de source)"
    r"|je n['’]ai aucune (donnée|info|source)"
    r"|aucune source (externe )?ne (permet|confirme)"
    r"|je ne (sais|connais) pas"
    r"|je ne suis pas (sûr|certain)"
    r"|pas d['’]information (sur|disponible)"
    r"|manque de contexte sur"
    r"|je n['’]ai pas trouvé d['’]info"
    r"|à (confirmer|valider)\b"
    r"|il faudrait (vérifier|que tu (me )?confirmes|valider)"
    r"|peux-tu (me )?confirmer"
    r"|pas certain(e)?",
    re.IGNORECASE,
)

LOCAL_SEARCH_EVIDENCE = re.compile(
    r"grep|find |ripgrep|\brg\b"
    r"|~/Desktop|~/Projects|~/\.claude"
    r"|search_nodes|read_graph|open_nodes",
    re.IGNORECASE,
)

SEARCH_TOOL_NAMES = {"Grep", "Glob"}
SEARCH_SUBAGENTS = {"Explore", "researcher", "doc-reader", "general-purpose", "claude"}

STOPWORDS = {
    "dans", "avec", "pour", "cette", "cette", "cela", "cette", "cette",
    "sais", "connais", "cette", "info", "information", "données", "donnée",
    "source", "sources", "aucune", "aucun", "pas", "que", "qui", "quoi",
    "cette", "cette", "certain", "certaine", "valider", "confirmer",
    "vérifier", "vérifie", "faudrait", "peux", "tu", "me", "je", "ne",
    "les", "des", "une", "un", "sur", "est", "sont", "trouvé", "manque",
    "contexte", "confirmer", "disponible", "have", "this", "that", "with",
    "about", "know", "sure", "confirm", "information", "data", "source",
}

WORD_RE = re.compile(r"[A-Za-zÀ-ÿ0-9_\-]{4,}")


def is_genuine_human_message(msg):
    """Un message role=='user' peut être soit le vrai humain, soit un tool_result
    relayé par l'API (même role côté format Anthropic). Seul le premier doit
    marquer la limite du tour."""
    content = msg.get("content")
    if isinstance(content, str):
        return True
    if not isinstance(content, list):
        return False
    has_text = False
    has_tool_result = False
    for block in content:
        if not isinstance(block, dict):
            continue
        if block.get("type") == "text":
            has_text = True
        elif block.get("type") == "tool_result":
            has_tool_result = True
    return has_text and not has_tool_result


def extract_turn_entries(lines):
    """Retourne les entrées assistant du tour courant (depuis le dernier vrai
    message humain — pas les tool_result intermédiaires, qui ont aussi
    role=='user' dans le format API)."""
    turn = []
    for line in reversed(lines):
        line = line.strip()
        if not line or not line.startswith("{"):
            continue
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        msg = d.get("message")
        if not isinstance(msg, dict):
            continue
        role = msg.get("role")
        if role == "user" and is_genuine_human_message(msg):
            break
        if role == "assistant":
            turn.append(msg)
    return list(reversed(turn))


def strip_meta_text(text):
    """Retire les lignes de tableau markdown et les blocs de code avant de
    chercher les marqueurs d'incertitude — évite de matcher une ligne qui
    *cite* les tournures en exemple plutôt que de les affirmer réellement."""
    kept = []
    in_fence = False
    for line in text.split("\n"):
        stripped = line.strip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if stripped.startswith("|") and stripped.endswith("|") and stripped.count("|") >= 2:
            continue
        kept.append(line)
    return "\n".join(kept)


def keywords(text):
    return {
        w.lower()
        for w in WORD_RE.findall(text)
        if w.lower() not in STOPWORDS
    }


def context_around_markers(text):
    """Retourne le texte dans une fenêtre de ~120 caractères autour de chaque marqueur trouvé."""
    windows = []
    for m in UNCERTAINTY_MARKERS.finditer(text):
        start = max(0, m.start() - 120)
        end = min(len(text), m.end() + 120)
        windows.append(text[start:end])
    return " ".join(windows)


def extract_search_query(name, inp):
    """Extrait la chaîne de requête d'un tool_use de recherche, pour comparaison de mots-clés."""
    if name in ("Grep", "Glob"):
        return " ".join(str(inp.get(k, "")) for k in ("pattern", "path", "glob"))
    if name == "Bash":
        return str(inp.get("command", ""))
    if name == "Agent":
        return " ".join(str(inp.get(k, "")) for k in ("prompt", "description"))
    if name.startswith("mcp__memory__"):
        return " ".join(str(v) for v in inp.values())
    return ""


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    transcript_path = data.get("transcript_path")
    if not transcript_path or not os.path.exists(transcript_path):
        sys.exit(0)

    with open(transcript_path) as f:
        lines = f.readlines()

    turn = extract_turn_entries(lines)
    if not turn:
        sys.exit(0)

    last_text = ""
    search_calls = []  # list of (name, inp) for local-search-capable tool calls
    any_local_search = False

    for msg in turn:
        for block in msg.get("content", []):
            if not isinstance(block, dict):
                continue
            btype = block.get("type")
            if btype == "text":
                last_text += block.get("text", "") + "\n"
            elif btype == "tool_use":
                name = block.get("name", "")
                inp = block.get("input", {})
                inp_str = json.dumps(inp)
                is_search = False
                if name in SEARCH_TOOL_NAMES:
                    is_search = True
                elif name == "Bash" and LOCAL_SEARCH_EVIDENCE.search(inp_str):
                    is_search = True
                elif name == "Agent" and inp.get("subagent_type") in SEARCH_SUBAGENTS:
                    is_search = True
                elif name.startswith("mcp__memory__") and name in (
                    "mcp__memory__search_nodes",
                    "mcp__memory__read_graph",
                    "mcp__memory__open_nodes",
                ):
                    is_search = True
                if is_search:
                    any_local_search = True
                    search_calls.append((name, inp))

    scan_text = strip_meta_text(last_text)

    if not UNCERTAINTY_MARKERS.search(scan_text):
        sys.exit(0)

    if not any_local_search:
        print(
            "BLOQUÉ (Stop hook local-search-before-uncertainty) : ta réponse marque une "
            "incertitude ([À CONFIRMER], 'je n'ai pas cette info'...) mais aucune recherche "
            "locale n'a été faite dans ce tour (Grep/Glob, grep/find sur ~/Desktop ou "
            "~/Projects, Agent Explore, ou mcp__memory__search_nodes). Cherche d'abord en "
            "local (mémoire MCP, hub, dossiers projet) avant de marquer l'info comme "
            "inconnue ou de demander à l'utilisateur — l'info est probablement déjà quelque part "
            "sur la machine.",
            file=sys.stderr,
        )
        sys.exit(2)

    # Recherche(s) locale(s) présente(s) — vérifier qu'au moins une cible bien le sujet
    # évoqué autour du marqueur d'incertitude (évite qu'une recherche sans rapport,
    # lancée pour autre chose plus tôt dans le tour, serve de caution).
    subject_kw = keywords(context_around_markers(scan_text))

    if not subject_kw:
        # Impossible d'extraire un terme distinctif (texte trop générique) —
        # fallback lenient, la présence d'une recherche locale suffit.
        sys.exit(0)

    for name, inp in search_calls:
        query = extract_search_query(name, inp)
        query_kw = keywords(query)
        if subject_kw & query_kw:
            sys.exit(0)

    print(
        "BLOQUÉ (Stop hook local-search-before-uncertainty) : une recherche locale a bien "
        "eu lieu ce tour, mais aucune ne semble cibler le sujet marqué incertain "
        f"(mots-clés attendus : {', '.join(sorted(subject_kw))[:200]}). "
        "Relance une recherche qui porte spécifiquement sur ce sujet (nom, projet, terme) "
        "avant de conclure que l'info est indisponible.",
        file=sys.stderr,
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
