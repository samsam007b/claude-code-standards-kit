---
description: Prepare a clean commit by cleaning the code before committing (debug leftovers, unused imports, temp files), then confirm before staging.
---

# Clean commit

## Steps

### 1. Analyze modified files
Run `git status` and `git diff` (staged and unstaged).

### 2. Automatic cleanup
Remove:
- debug `console.log()`, `console.debug()`, `console.warn()` (keep intentional ones marked `// keep`)
- debug `print()` in Python
- `debugger;` statements
- temporary comments (`// TODO: remove`, `// FIXME`, `// DEBUG`, `// test`)
- `.DS_Store`, `*.log`, `*.tmp` files
- commented-out code blocks (more than 5 consecutive commented lines)

### 3. Imports
- Remove unused imports.
- Make sure there is no import from a test or debug path.

### 4. Documentation if needed
If a non-obvious technical solution was implemented in this session, create `docs/decisions/YYYY-MM-DD-description.md` explaining context and solution. Only when it is really needed for future understanding.

### 5. Summary
Show what was cleaned and ask for confirmation **before staging**. Then ask whether to show the diff, stage and commit directly, and which commit message to use (suggest one).

Never commit secrets: if a `.env` or key file shows up in the diff, stop and flag it.
