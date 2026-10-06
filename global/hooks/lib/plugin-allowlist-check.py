#!/usr/bin/env python3
"""Exit 0 if EVERY plugin path found in $CMD is listed in $ALLOWLIST_FILE.

Exit 1 if a single path is missing, or if no plugin path is detected at all (vacuity is
forbidden: the absence of a path never counts as an authorisation). Called by
plugin-script-exec-guard.sh before it shows the confirmation dialog.

Allowlist format: one literal script path per line, `$HOME` and `~` accepted, `#` comments.
"""
import os
import re
import sys

HOME = os.path.expanduser("~")
PLUGIN_PATH = re.compile(r"""[^\s;&|"']*\.claude/plugins/(?:marketplaces|cache)/[^\s;&|"']*""")


def norm(path: str) -> str:
    path = path.strip().strip('"').strip("'")
    path = path.replace("$HOME", HOME).replace("${HOME}", HOME)
    if path.startswith("~"):
        path = HOME + path[1:]
    return os.path.normpath(path)


def main() -> int:
    allowlist_file = os.environ.get("ALLOWLIST_FILE", "")
    if not allowlist_file or not os.path.isfile(allowlist_file):
        return 1

    with open(allowlist_file) as fh:
        allowed = {norm(l) for l in fh if l.strip() and not l.lstrip().startswith("#")}

    found = [norm(p) for p in PLUGIN_PATH.findall(os.environ.get("CMD", ""))]
    if not found:
        return 1
    return 0 if all(p in allowed for p in found) else 1


if __name__ == "__main__":
    sys.exit(main())
