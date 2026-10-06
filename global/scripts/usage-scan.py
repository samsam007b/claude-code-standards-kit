#!/usr/bin/env python3
"""
usage-scan.py: measure which agents and skills are actually invoked.

Why this exists
---------------
A setup accumulates agents and skills nobody calls. Counting them by hand once or twice a
year finds the dead weight late; measuring continuously is cheap (about a hundred lines).
Most public setups measure nothing, so this is where a personal setup can pull ahead.

Why read transcripts instead of adding a hook
---------------------------------------------
A PostToolUse hook needs settings.json edits and knows nothing about the past: the first
figure would arrive months later. Session transcripts already contain the whole history,
so the measurement is available retroactively and without touching the configuration.

Cost and incrementality
-----------------------
The corpus can reach several GiB. Two precautions keep a daily pass negligible: a cache
keyed on (path, size, mtime) that skips any already-read unchanged file, and a substring
pre-filter before any json.loads (decoding every line of every session would cost minutes
for a few thousand useful lines).

Usage:  python3 usage-scan.py
Environment:
  USAGE_WINDOW_DAYS   only look at transcripts modified in the last N days (default 180)
  CLAUDE_DIR          default ~/.claude
Output: report on stdout, state in $CLAUDE_DIR/state/usage.json (+ usage-cache.json).
Never-invoked agents and skills are listed: candidates for archiving.
"""
import json
import os
import time
from pathlib import Path

CLAUDE = Path(os.environ.get("CLAUDE_DIR", str(Path.home() / ".claude")))
ROOT = CLAUDE / "projects"
STATE = CLAUDE / "state" / "usage.json"
CACHE = CLAUDE / "state" / "usage-cache.json"
WINDOW_DAYS = int(os.environ.get("USAGE_WINDOW_DAYS", "180"))

# Pre-filter: a line containing none of these markers cannot carry an invocation.
MARKERS = (b'"Agent"', b'"Skill"', b'"Task"')


def load(p, default):
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except Exception:
        return default


def scan():
    cache = load(CACHE, {})
    state = load(STATE, {"agents": {}, "skills": {}, "generated": None})
    agents = state.get("agents", {})
    skills = state.get("skills", {})

    cutoff = time.time() - WINDOW_DAYS * 86400
    read, skipped = 0, 0

    for f in ROOT.rglob("*.jsonl"):
        try:
            st = f.stat()
        except OSError:
            continue
        if st.st_mtime < cutoff:
            continue
        key = str(f)
        signature = [st.st_size, int(st.st_mtime)]
        if cache.get(key) == signature:
            skipped += 1
            continue

        day = time.strftime("%Y-%m-%d", time.localtime(st.st_mtime))
        try:
            with f.open("rb") as fh:
                for raw in fh:
                    if not any(m in raw for m in MARKERS):
                        continue
                    try:
                        d = json.loads(raw)
                    except Exception:
                        continue
                    content = (d.get("message") or {}).get("content")
                    if not isinstance(content, list):
                        continue
                    for block in content:
                        if not isinstance(block, dict) or block.get("type") != "tool_use":
                            continue
                        name = block.get("name")
                        args = block.get("input") or {}
                        if name in ("Agent", "Task"):
                            who, target = args.get("subagent_type"), agents
                        elif name == "Skill":
                            who, target = args.get("skill"), skills
                        else:
                            continue
                        if not who:
                            continue
                        e = target.setdefault(who, {"n": 0, "last": day})
                        e["n"] += 1
                        if day > e["last"]:
                            e["last"] = day
        except OSError:
            continue

        cache[key] = signature
        read += 1

    state = {
        "agents": agents,
        "skills": skills,
        "generated": time.strftime("%Y-%m-%d %H:%M"),
        "window_days": WINDOW_DAYS,
        "files_read": read,
        "files_already_known": skipped,
    }
    STATE.parent.mkdir(parents=True, exist_ok=True)
    STATE.write_text(json.dumps(state, ensure_ascii=False, indent=1), encoding="utf-8")
    CACHE.write_text(json.dumps(cache), encoding="utf-8")
    return state


def defined_skills():
    out = set()
    d = CLAUDE / "skills"
    if d.exists():
        for p in d.iterdir():
            if p.is_dir() and (p / "SKILL.md").exists():
                out.add(p.name)
            elif p.suffix == ".md" and p.name != "INDEX.md":
                out.add(p.stem)
    return out


def report(state):
    agents_dir = CLAUDE / "agents"
    defined = {p.stem for p in agents_dir.glob("*.md")} if agents_dir.exists() else set()
    used = set(state["agents"])
    never = sorted(defined - used)

    print("files read %d, already known %d (window %d days)"
          % (state["files_read"], state["files_already_known"], state["window_days"]))
    print("\nagents defined %d, invoked at least once %d, never invoked %d"
          % (len(defined), len(defined & used), len(never)))
    print("\ntop agents:")
    for k, v in sorted(state["agents"].items(), key=lambda x: -x[1]["n"])[:10]:
        mark = "" if k in defined else "   (not defined locally: built-in or plugin)"
        print("  %5d  %-32s last %s%s" % (v["n"], k, v["last"], mark))
    print("\ntop skills:")
    for k, v in sorted(state["skills"].items(), key=lambda x: -x[1]["n"])[:10]:
        print("  %5d  %-32s last %s" % (v["n"], k, v["last"]))
    skills_defined = defined_skills()
    # Skills may be invoked as plugin:name, compare on the bare name too.
    invoked_bare = {k.split(":")[-1] for k in state["skills"]}
    never_skills = sorted(skills_defined - invoked_bare)
    print("\nnever-invoked agents (%d):" % len(never))
    print("  " + ", ".join(never) if never else "  none")
    print("\nnever-invoked skills (%d of %d defined):" % (len(never_skills), len(skills_defined)))
    print("  " + ", ".join(never_skills) if never_skills else "  none")


if __name__ == "__main__":
    t0 = time.time()
    s = scan()
    report(s)
    print("\nduration %.1fs" % (time.time() - t0))
