---
description: Read-only drift audit between a design-token source of truth and its platform implementation, plus hardcoded values and mock data left in production code.
---

# /audit-drift: detect drift

Generic drift scan. Adapt the paths and patterns to your stack (the examples assume a tokens JSON file consumed by app code). **Read-only**: it reports, it never modifies anything.

## Checks

1. **Token drift**: compare the token source of truth (for example `design-tokens/tokens.json`) with the platform constants. Report CHANGED / NEW / REMOVED.
2. **Hardcoded colors**: search code for raw color literals (hex, rgb, named colors) outside the token files and outside previews/tests.
3. **Forbidden file or naming patterns**: for example a "WebView" screen in a native app that must be native.
4. **Missing contract headers**: for every view/component file, check the first line carries your contract marker (for example `// CONTRACT: v1`). Report NO_CONTRACT.
5. **Hardcoded identifiers**: literal user ids, `"current-user"`, fixed UUIDs outside preview/test data.
6. **Fake data in production**: artificial loading delays (`setTimeout`/`asyncAfter` over 1s), screens initialized with hardcoded lists, debug-only mock branches (acceptable if documented).
7. **Cross-reference a sync map** (optional): for each row of a status table (ID, implementation file, status): STALE if the file no longer exists but status is DONE/PARTIAL; DRIFT if a DONE row regressed to mocks; RE-CHECK if a PARTIAL row now uses a real service. Never edit the map automatically: a human decides, to avoid auto-committed false positives.

## Report format

```
=== DRIFT REPORT ===
Date: YYYY-MM-DD
TOKENS:           OK 45/45 aligned | WARN 2 changed
HARDCODED COLORS: FAIL 3 files outside tokens
FORBIDDEN FILES:  OK none
CONTRACT HEADERS: WARN 28/40 views without header
HARDCODED IDS:    OK none
FAKE DATA:        WARN 2 views
GLOBAL SCORE:     85/100
```

Run before each release and after any phase touching shared surfaces.
