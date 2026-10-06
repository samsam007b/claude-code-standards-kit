#!/usr/bin/env python3
"""Stop hook: local-search-before-uncertainty   (BLOCKING, fail-open on any error)

Blocks the end of a turn when the last assistant message states uncertainty ("[TO CONFIRM]",
"I don't have this information", "I'm not sure"...) without a targeted local search on that
subject having been done in the same turn (Grep/Glob, grep/find/rg in Bash, an Explore-type
subagent, or an MCP memory search). Rule behind it: search locally before telling the user
"I don't know" or asking them something that already exists on their machine.

Event / matcher : Stop (no matcher)                   (timeout 10)
Exit codes      : 0 allow, 2 block (stderr is fed back to the model). Claude Code itself stops
                  re-blocking after a number of consecutive Stop blocks.

How it decides
  1. Collect the assistant entries since the last REAL human message (a tool_result also has
     role "user" in the API format and must not end the turn scan).
  2. Strip markdown table rows and fenced code blocks from the text, so a line that merely QUOTES
     the uncertainty phrases as examples does not trigger the hook.
  3. If a marker is found and no local search was made: block.
  4. If searches exist, require a keyword overlap between the text around the marker and at
     least one search query, so an unrelated earlier search cannot serve as an alibi.
     Fallback when no distinctive keyword can be extracted: any local search is enough.

Environment:
  CLAUDE_UNCERTAINTY_LANG    comma-separated marker languages (default "en"). Add "fr" for the
                             French markers: CLAUDE_UNCERTAINTY_LANG=en,fr
  CLAUDE_LOCAL_SEARCH_PATHS  extra regex that counts as local-search evidence inside Bash
                             commands (default already covers grep, find, rg, ~/Projects,
                             ~/Desktop, ~/Documents, ~/.claude, memory MCP tools)
  CLAUDE_UNCERTAINTY_GUARD=off   disable the hook.
"""
import json
import os
import re
import sys

LANGS = {x.strip().lower() for x in os.environ.get("CLAUDE_UNCERTAINTY_LANG", "en").split(",") if x.strip()}

MARKERS_EN = [
    r"\[TO CONFIRM\]",
    r"\[TO VERIFY\]",
    r"\[UNVERIFIED\]",
    r"I (?:don['’]t|do not) have (?:this|that|the) (?:info|information|data)",
    r"I (?:don['’]t|do not) have (?:any )?(?:data|information|source)",
    r"no (?:external )?source (?:confirms|allows)",
    r"I (?:don['’]t|do not) know",
    r"I['’]m not (?:sure|certain)",
    r"I am not (?:sure|certain)",
    r"no information (?:on|about|available)",
    r"lack(?:s|ing)? context (?:on|about)",
    r"I (?:couldn['’]t|could not|didn['’]t|did not) find (?:any )?info",
    r"(?:needs?|has) to be (?:confirmed|validated|verified)",
    r"can you (?:please )?confirm",
    r"could you (?:please )?confirm",
    r"we should (?:verify|validate)",
]
MARKERS_FR = [
    r"\[À CONFIRMER\]",
    r"je n['’]ai pas (?:cette info|de données|d['’]information|de source)",
    r"je n['’]ai aucune (?:donnée|info|source)",
    r"aucune source (?:externe )?ne (?:permet|confirme)",
    r"je ne (?:sais|connais) pas",
    r"je ne suis pas (?:sûr|certain)",
    r"pas d['’]information (?:sur|disponible)",
    r"manque de contexte sur",
    r"je n['’]ai pas trouvé d['’]info",
    r"à (?:confirmer|valider)\b",
    r"il faudrait (?:vérifier|que tu (?:me )?confirmes|valider)",
    r"peux-tu (?:me )?confirmer",
    r"pas certain(?:e)?",
]

_markers = list(MARKERS_EN) if "en" in LANGS or not LANGS else []
if "fr" in LANGS:
    _markers += MARKERS_FR
UNCERTAINTY_MARKERS = re.compile("|".join(_markers) if _markers else r"(?!x)x", re.IGNORECASE)

_evidence = (
    r"grep|find |ripgrep|\brg\b"
    r"|~/Desktop|~/Projects|~/Documents|~/\.claude|\$HOME/"
    r"|search_nodes|read_graph|open_nodes"
)
_extra = os.environ.get("CLAUDE_LOCAL_SEARCH_PATHS", "")
if _extra:
    _evidence += "|" + _extra
LOCAL_SEARCH_EVIDENCE = re.compile(_evidence, re.IGNORECASE)

SEARCH_TOOL_NAMES = {"Grep", "Glob"}
SEARCH_SUBAGENTS = {"Explore", "researcher", "doc-reader", "general-purpose", "claude"}

STOPWORDS = {
    # english
    "have", "this", "that", "with", "about", "know", "sure", "confirm", "information", "info",
    "data", "source", "sources", "certain", "validate", "verify", "verified", "validated",
    "could", "please", "context", "available", "found", "find", "should", "need", "needs",
    "there", "their", "which", "what", "from", "into", "than", "then", "does", "dont", "don",
    "external", "confirmed", "lack", "lacks", "lacking", "any", "the", "and", "for", "not",
    # french (harmless when unused)
    "dans", "avec", "pour", "cette", "cela", "sais", "connais", "donnees", "données", "donnée",
    "aucune", "aucun", "quoi", "certaine", "valider", "confirmer", "vérifier", "vérifie",
    "faudrait", "peux", "trouvé", "manque", "contexte", "disponible", "sont", "les", "des",
}

WORD_RE = re.compile(r"[A-Za-zÀ-ÿ0-9_\-]{4,}")


def is_genuine_human_message(msg):
    """A role=='user' entry is either the real human or a tool_result relayed by the API.
    Only the former marks the start of the turn."""
    content = msg.get("content")
    if isinstance(content, str):
        return True
    if not isinstance(content, list):
        return False
    has_text = has_tool_result = False
    for block in content:
        if not isinstance(block, dict):
            continue
        if block.get("type") == "text":
            has_text = True
        elif block.get("type") == "tool_result":
            has_tool_result = True
    return has_text and not has_tool_result


def extract_turn_entries(lines):
    """Assistant entries of the current turn (since the last real human message)."""
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
    """Drop markdown table rows and fenced code blocks before looking for markers, so a line
    that CITES the phrases as examples is not mistaken for a real statement of uncertainty."""
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
    return {w.lower() for w in WORD_RE.findall(text) if w.lower() not in STOPWORDS}


def context_around_markers(text):
    windows = []
    for m in UNCERTAINTY_MARKERS.finditer(text):
        start = max(0, m.start() - 120)
        end = min(len(text), m.end() + 120)
        windows.append(text[start:end])
    return " ".join(windows)


def extract_search_query(name, inp):
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
    if os.environ.get("CLAUDE_UNCERTAINTY_GUARD", "on").lower() == "off":
        sys.exit(0)
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    transcript_path = data.get("transcript_path")
    if not transcript_path or not os.path.exists(transcript_path):
        sys.exit(0)

    try:
        with open(transcript_path, encoding="utf-8") as f:
            lines = f.readlines()
    except Exception:
        sys.exit(0)

    turn = extract_turn_entries(lines)
    if not turn:
        sys.exit(0)

    last_text = ""
    search_calls = []
    for msg in turn:
        content = msg.get("content", [])
        if isinstance(content, str):
            last_text += content + "\n"
            continue
        for block in content:
            if not isinstance(block, dict):
                continue
            btype = block.get("type")
            if btype == "text":
                last_text += block.get("text", "") + "\n"
            elif btype == "tool_use":
                name = block.get("name", "")
                inp = block.get("input", {}) or {}
                inp_str = json.dumps(inp)
                is_search = False
                if name in SEARCH_TOOL_NAMES:
                    is_search = True
                elif name == "Bash" and LOCAL_SEARCH_EVIDENCE.search(inp_str):
                    is_search = True
                elif name == "Agent" and inp.get("subagent_type") in SEARCH_SUBAGENTS:
                    is_search = True
                elif name in ("mcp__memory__search_nodes", "mcp__memory__read_graph", "mcp__memory__open_nodes"):
                    is_search = True
                if is_search:
                    search_calls.append((name, inp))

    scan_text = strip_meta_text(last_text)
    if not UNCERTAINTY_MARKERS.search(scan_text):
        sys.exit(0)

    if not search_calls:
        print(
            "BLOCKED (Stop hook local-search-before-uncertainty): your reply states an uncertainty "
            "([TO CONFIRM], 'I don't have this information'...) but no local search was made in this "
            "turn (Grep/Glob, grep/find/rg in Bash, an Explore subagent, or a memory search). Search "
            "locally first (memory, project folders, notes) before declaring the information unknown "
            "or asking the user: it is probably already somewhere on the machine.",
            file=sys.stderr,
        )
        sys.exit(2)

    subject_kw = keywords(context_around_markers(scan_text))
    if not subject_kw:
        sys.exit(0)  # text too generic to extract a subject: any local search is enough

    for name, inp in search_calls:
        if subject_kw & keywords(extract_search_query(name, inp)):
            sys.exit(0)

    print(
        "BLOCKED (Stop hook local-search-before-uncertainty): a local search was made this turn, but "
        "none seems to target the subject marked as uncertain "
        f"(expected keywords: {', '.join(sorted(subject_kw))[:200]}). "
        "Run a search that targets this specific subject (name, project, term) before concluding "
        "that the information is unavailable.",
        file=sys.stderr,
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
