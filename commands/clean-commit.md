# Clean Commit

Prepares a clean commit by cleaning up the code before committing.

## Steps

### 1. Analyze modified files
Look at staged and unstaged files with `git status` and `git diff`.

### 2. Automatic cleanup
Automatically remove:
- Debug `console.log()`, `console.debug()`, `console.warn()` (keep intentional ones marked with a `// keep` comment)
- Debug `print()` in Python
- `debugger;` statements
- Temporary comments (`// TODO: remove`, `// FIXME`, `// DEBUG`, `// test`)
- `.DS_Store`, `*.log`, `*.tmp` files
- Commented-out code blocks (more than 5 consecutive commented lines)

### 3. Import check
- Remove unused imports
- Check that there is no `import ... from './test'` or debug path

### 4. Documentation if needed
If a non-obvious technical solution was implemented during this session:
- Create a file `docs/decisions/YYYY-MM-DD-description.md` explaining the context and the solution
- Only add this doc if it is really needed for future understanding

### 5. Summary
Show a summary of what was cleaned up and ask for confirmation before staging the changes.

## User options
After the cleanup, ask:
- Do you want to see the diff of the changes?
- Do you want me to stage and commit directly?
- Suggested commit message?
