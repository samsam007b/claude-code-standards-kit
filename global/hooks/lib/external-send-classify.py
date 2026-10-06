#!/usr/bin/env python3
"""Classify a PreToolUse payload (stdin JSON) as an outbound send or not.

Used by external-send-guard.sh. Prints one line:
    OK                      not an external send, let it through
    SEND<TAB>description    looks like an email / chat / social send
Exit code 3 (and prints nothing) when the payload cannot be parsed, so the caller can fail closed.
A payload that parses as JSON but is missing tool_name also exits 3: the hook only ever runs on
mcp__.*|Bash, so a legitimate call always carries one, and a missing field cannot be shown safe.

Provider-agnostic: matches tool slugs and tool names of any provider (Composio-style slugs such as
GMAIL_SEND_EMAIL, MCP tools such as mcp__slack__post_message), plus common Bash send vectors
(mail CLIs, osascript Mail, curl to chat/social APIs).

A Bash command made of several invocations chained with ";" or newline is judged invocation by
invocation when CLAUDE_SEND_GUARD_ALLOW_REGEX is set: one segment matching the allow-regex (e.g. a
--dry-run call of a trusted wrapper) never exempts a different segment in the same command that
performs a real send.

Environment:
  CLAUDE_SEND_GUARD_REGEX        replaces the default send regex for slugs/tool names (ERE-ish, Python re)
  CLAUDE_SEND_GUARD_EXTRA_REGEX  extra regex ORed with the defaults (applied to MCP text and Bash commands)
  CLAUDE_SEND_GUARD_ALLOW_REGEX  if it matches a command segment, that segment is never treated as a send
                                 (use it for an internal wrapper you trust)
"""
import json
import os
import re
import sys

PROVIDERS = (
    "GMAIL|OUTLOOK|MAIL|SLACK|DISCORD|TELEGRAM|WHATSAPP|TEAMS|TWITTER|LINKEDIN|FACEBOOK|"
    "INSTAGRAM|MASTODON|BLUESKY|THREADS|TIKTOK|REDDIT|SENDGRID|MAILCHIMP|TWILIO"
)

DEFAULT_SEND_RE = (
    r"(?:SEND|REPLY)_?(?:EMAIL|MAIL|MESSAGE|DM|TWEET|SMS)"
    r"|POST_(?:MESSAGE|TWEET|STATUS|COMMENT)"
    r"|CREATE_(?:TWEET|POST|STATUS)"
    r"|PUBLISH_(?:POST|TWEET|VIDEO)"
    r"|(?:^|[^A-Z])(?:" + PROVIDERS + r")_[A-Z_]*(?:SEND|REPLY|POST|PUBLISH|UPLOAD|TWEET)"
)

BASH_SEND_RE = (
    r"osascript[^\n]*[Mm]ail[^\n]*send"
    r"|(?:^|[;&|(]\s*|\bxargs\s+|\bsudo\s+)(?:sendmail|mailx?|msmtp|swaks)\s"
    r"|curl[^\n]*(?:hooks\.slack\.com|slack\.com/api/chat\.(?:postMessage|update)"
    r"|discord(?:app)?\.com/api/webhooks|api\.telegram\.org/bot[^\s/]*/send"
    r"|api\.(?:twitter|x)\.com/2/tweets|graph\.facebook\.com[^\s]*/(?:feed|messages)"
    r"|api\.sendgrid\.com/v3/mail/send|api\.mailgun\.net)"
    r"|composio\s+(?:proxy|run|execute)[^\n]*(?:SEND|REPLY|POST|PUBLISH)"
)


def slugs_of(tool_input):
    """Collect tool slugs from a (possibly multi-execute) tool_input."""
    out = []
    if not isinstance(tool_input, dict):
        return out
    for key in ("tool_slug", "tool", "action_name", "slug"):
        v = tool_input.get(key)
        if isinstance(v, str):
            out.append(v)
    for key in ("tools", "actions", "calls"):
        v = tool_input.get(key)
        if isinstance(v, list):
            for item in v:
                out.extend(slugs_of(item))
    return out


def main():
    try:
        data = json.load(sys.stdin)
        if not isinstance(data, dict):
            raise ValueError("payload is not an object")
    except Exception:
        sys.exit(3)

    name = data.get("tool_name", "") or ""
    if not isinstance(name, str) or not name:
        # The matcher for this hook is mcp__.*|Bash, so a legitimate payload always carries a
        # tool_name. A missing one cannot be shown safe: falling through to the default branch
        # below would have printed OK (incident class: an unparseable/incomplete field on a call
        # that already looked like a send must block, not silently pass).
        sys.exit(3)
    tool_input = data.get("tool_input", {}) or {}
    allow_re = os.environ.get("CLAUDE_SEND_GUARD_ALLOW_REGEX", "")
    extra_re = os.environ.get("CLAUDE_SEND_GUARD_EXTRA_REGEX", "")
    send_re = os.environ.get("CLAUDE_SEND_GUARD_REGEX", "") or DEFAULT_SEND_RE
    if extra_re:
        send_re = send_re + "|" + extra_re

    if name == "Bash":
        cmd = tool_input.get("command", "") if isinstance(tool_input, dict) else ""
        if not isinstance(cmd, str):
            cmd = ""

        # A composed Bash call (several invocations chained with ";" or "\n") is judged
        # invocation by invocation when an allow-regex is set, instead of once over the whole
        # string. Otherwise one segment matching CLAUDE_SEND_GUARD_ALLOW_REGEX (for example a
        # --dry-run smoke test of a trusted wrapper) would launder a different segment in the
        # same call that performs a real send (incident class: dry-run plus real send chained
        # in one composed command both passed as allowed).
        if allow_re:
            segments = re.split(r"[\n;]", cmd)
            live_segments = [s for s in segments if not re.search(allow_re, s)]
            live_cmd = "\n".join(live_segments)
            if not live_cmd.strip():
                print("OK")
                return
        else:
            live_cmd = cmd

        patterns = BASH_SEND_RE + ("|" + extra_re if extra_re else "")
        if re.search(patterns, live_cmd, re.MULTILINE):
            print("SEND\tBash: " + live_cmd.strip()[:200].replace("\n", " "))
            return
        # A runner invoked with a provider send slug as argument (composio-exec style wrappers)
        upper = live_cmd.upper()
        if re.search(r"\b(?:composio|rube|node|bun|python3?|npx)\b", live_cmd) and re.search(DEFAULT_SEND_RE, upper):
            m = re.search(DEFAULT_SEND_RE, upper)
            print("SEND\tBash runner with send action: " + m.group(0).strip("_ "))
            return
        print("OK")
        return

    if name.startswith("mcp__"):
        slugs = slugs_of(tool_input)
        text = " ".join([name] + slugs)
        if allow_re and re.search(allow_re, text):
            print("OK")
            return
        norm = text.upper().replace("-", "_")
        # tool name part only (server slug excluded) plus every slug
        tool_part = name.rsplit("__", 1)[-1] if "__" in name else name
        candidates = [tool_part.upper().replace("-", "_")] + [s.upper().replace("-", "_") for s in slugs]
        for c in candidates:
            if re.search(send_re, c):
                print("SEND\t%s: %s" % (name, c))
                return
        # extra regex may target the whole name (including the server slug)
        if extra_re and re.search(extra_re, norm):
            print("SEND\t%s" % name)
            return
    print("OK")


if __name__ == "__main__":
    main()
