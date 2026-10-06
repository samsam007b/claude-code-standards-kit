---
description: Restore the default mode: Opus in Plan Mode, Sonnet at execution (native hybrid alias), Haiku for research subagents.
---

# /opusplan: default mode

Run it when a session drifted (for example after `/fableplan`) to return to the baseline.

What it sets, on the real levers:

1. **Main session**: the native `opusplan` alias (not plain `opus`, which would run Opus continuously even at execution). `opusplan` is a hybrid alias documented by Anthropic: Opus in Plan Mode, automatic switch to Sonnet when you leave Plan Mode for execution, within the SAME session.
   - CLI: `/model opusplan`, or `"model": "opusplan"` in `~/.claude/settings.json`.
   - VS Code extension: the `claudeCode.selectedModel` setting in your user settings. Reload the window afterwards.
2. **Execution subagents**: Sonnet, via `CLAUDE_CODE_SUBAGENT_MODEL` in the `env` block of `~/.claude/settings.json`.
3. **Research subagents**: Haiku, set in the frontmatter of the `researcher` and `doc-reader` agents themselves, independent of the default above.

```bash
# CLI example: set the main session alias in user settings
python3 - <<'PY'
import json, pathlib
p = pathlib.Path.home() / ".claude" / "settings.json"
d = json.loads(p.read_text()) if p.exists() else {}
d["model"] = "opusplan"
p.write_text(json.dumps(d, indent=2) + "\n")
PY
```

Verify the active model in the status line. Current model names and IDs: https://docs.anthropic.com/en/docs/about-claude/models
