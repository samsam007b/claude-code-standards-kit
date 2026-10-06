#!/usr/bin/env python3
"""Print `true` if MCP server slug argv[1] is marked trusted in the registry file argv[2].

Registry format: markdown tables. A row whose FIRST cell is the server slug (optionally in
backticks) and whose SECOND cell contains the check mark U+2705 marks that server trusted.
Any other row, a missing file or an unreadable file means "not trusted" (fail closed).
"""
import sys


def main() -> None:
    if len(sys.argv) < 3:
        print("false")
        return
    server, registry_path = sys.argv[1], sys.argv[2]
    try:
        with open(registry_path, encoding="utf-8") as fh:
            content = fh.read()
    except Exception:
        print("false")
        return

    trusted = set()
    for line in content.splitlines():
        line = line.strip()
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 2:
            continue
        slug, status = cells[0], cells[1]
        if slug.startswith("`") and slug.endswith("`"):
            slug = slug[1:-1]
        if "✅" in status:
            trusted.add(slug)
    print("true" if server in trusted else "false")


if __name__ == "__main__":
    main()
