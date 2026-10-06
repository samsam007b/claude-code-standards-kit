---
description: Switch the whole session to the strongest model (only on explicit request). Not a native hybrid alias.
---

# /fableplan: one strong model for the whole session

**Never the default.** Run only when the user explicitly asks, never as a fallback.

**Scope warning**: unlike `/opusplan`, there is **no native hybrid alias** for this. `opusplan` switches Opus (Plan Mode) to Sonnet (execution) automatically inside one session, a behavior wired by Anthropic. Setting the model to a top-tier model name (or its alias) runs that model for the **entire session, Plan Mode and execution**, with no automatic downshift.

**Cost**: depending on your plan, the strongest model either bills at API rates or consumes your usage quota several times faster than Sonnet. Because nothing switches it down, even trivial execution burns quota at the high rate.

**Finer alternative**: from a session already in `/opusplan`, type `/model <strong-model>` for a one-off deep reflection, then `/model sonnet` or `/opusplan` to return. Instant, no reload, scope limited to what you need.

```bash
# Whole-session switch via user settings (replace with a model name from the models page)
python3 - <<'PY'
import json, pathlib
p = pathlib.Path.home() / ".claude" / "settings.json"
d = json.loads(p.read_text()) if p.exists() else {}
d["model"] = "<STRONGEST_MODEL_NAME>"
p.write_text(json.dumps(d, indent=2) + "\n")
PY
```

Subagents are unchanged (Sonnet for execution, Haiku for research). **Return to `/opusplan` at the end of the strategy session.**

Model names: https://docs.anthropic.com/en/docs/about-claude/models
