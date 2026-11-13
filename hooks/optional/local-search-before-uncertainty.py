#!/usr/bin/env python3
"""Stop hook: local-search-before-uncertainty

Blocks the end of the turn if the last assistant message contains an uncertainty
marker ("[À CONFIRMER]", "je n'ai pas cette info", etc.) and no targeted local
search on the subject in question (Grep/Glob/find/grep on
~/Desktop, ~/Projects, ~/.claude, or Agent Explore/memory search_nodes)
was done in that same turn.

Triggering incident: Claude marked a client name as [À CONFIRMER] and
offered to ask the user, even though the information already existed in a local
project file. The CLAUDE.md rule "search before asking" already existed in prose
but was not guaranteed, so it was converted into a deterministic hook.

v2 (same day): v1 accepted any command mentioning
"grep"/"~/Desktop" as proof of a search, even when unrelated to the
uncertain subject (e.g. a `cat ~/Desktop/foo.md` already run for something else
was enough to unblock). v2 requires a keyword overlap between the
text around the uncertainty marker and the search query
(grep pattern, Glob name, memory query, Explore agent prompt).
Lenient fallback (any local search is enough) only if
no distinctive term could be extracted from the uncertain text.

v3 (same day, real false positive in prod): two bugs found by getting
blocked by our own hook. (1) Markdown table rows quoting the markers
as examples ("Élargie (à confirmer, pas certain...)") were matched
as if they were a real statement of uncertainty. Tables and code blocks
are now excluded from the scanned text. (2) extract_turn_entries
stopped at the first role=="user" block when walking backwards, but a tool_result
(response to a tool call) also has role=="user" in the API format,
so a turn with several tool round trips was truncated before
seeing all the searches made earlier in the same turn. It now
stops only on a real human message (block of type "text", not
"tool_result").

Non-blocking beyond 8 consecutive blocks (native Claude Code behavior,
see the official "Stop hook" doc).
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
    """A role=='user' message can be either the real human or a tool_result
    relayed by the API (same role in the Anthropic format). Only the first
    should mark the turn boundary."""
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
    """Return the assistant entries of the current turn (since the last real
    human message, not the intermediate tool_results, which also have
    role=='user' in the API format)."""
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
    """Remove markdown table rows and code blocks before
    looking for uncertainty markers, to avoid matching a line that
    *quotes* the phrasings as examples rather than actually asserting them."""
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
    """Return the text in a ~120-character window around each marker found."""
    windows = []
    for m in UNCERTAINTY_MARKERS.finditer(text):
        start = max(0, m.start() - 120)
        end = min(len(text), m.end() + 120)
        windows.append(text[start:end])
    return " ".join(windows)


def extract_search_query(name, inp):
    """Extract the query string from a search tool_use, for keyword comparison."""
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
            "BLOCKED (Stop hook local-search-before-uncertainty): your reply marks an "
            "uncertainty ([À CONFIRMER], 'je n'ai pas cette info'...) but no local search "
            "was done in this turn (Grep/Glob, grep/find on ~/Desktop or "
            "~/Projects, Agent Explore, or mcp__memory__search_nodes). Search locally "
            "first (MCP memory, hub, project folders) before marking the info as "
            "unknown or asking the user: the info is probably already somewhere "
            "on the machine.",
            file=sys.stderr,
        )
        sys.exit(2)

    # Local search(es) present: check that at least one properly targets the subject
    # mentioned around the uncertainty marker (prevents an unrelated search,
    # launched for something else earlier in the turn, from serving as a pass).
    subject_kw = keywords(context_around_markers(scan_text))

    if not subject_kw:
        # Cannot extract a distinctive term (text too generic):
        # lenient fallback, the presence of a local search is enough.
        sys.exit(0)

    for name, inp in search_calls:
        query = extract_search_query(name, inp)
        query_kw = keywords(query)
        if subject_kw & query_kw:
            sys.exit(0)

    print(
        "BLOCKED (Stop hook local-search-before-uncertainty): a local search did "
        "take place this turn, but none seems to target the subject marked uncertain "
        f"(expected keywords: {', '.join(sorted(subject_kw))[:200]}). "
        "Run a search that specifically targets this subject (name, project, term) "
        "before concluding the info is unavailable.",
        file=sys.stderr,
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
