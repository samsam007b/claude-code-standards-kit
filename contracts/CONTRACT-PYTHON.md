# Contract — Python

> SQWR Project Kit contract module.
> Sources: PEP 8, PEP 20 (Zen of Python), FastAPI docs, PyObjC docs, mypy docs.
> Applicable to: sqwr-dictate (PyObjC), utility scripts, Python AI agents.

---

## 1. Style & Quality — PEP 8 + PEP 20

**The Zen of Python (PEP 20) — the 3 most important rules:**
```
Explicit is better than implicit.
Simple is better than complex.
Errors should never pass silently.
```

### Mandatory Formatting

```python
# Formatting tool: black (non-configurable = enforced consistency)
pip install black
black src/          # format all source code

# Linting: ruff (replaces flake8 + isort, 10-100x faster)
pip install ruff
ruff check src/

# Type checking: mypy (Python equivalent of TypeScript strict mode)
pip install mypy
mypy src/ --strict
```

### Naming Conventions (PEP 8)

```python
# Variables and functions: snake_case
user_name = "samuel"
def get_user_profile(): ...

# Classes: PascalCase
class AudioTranscriber: ...

# Constants: SCREAMING_SNAKE_CASE
MAX_RECORDING_DURATION = 30  # seconds

# Modules/files: snake_case
# transcriber.py, paster.py, audio_utils.py

# Avoid generic names
# ❌ data, info, temp, x, res, val
# ✅ audio_buffer, transcription_result, retry_count
```

---

## 2. Static Typing — mypy strict

**Rule: all SQWR Python code uses static typing.**

```python
# ✅ Always annotate functions
from typing import Optional, list, dict

def transcribe_audio(
    audio_path: str,
    language: str = "fr",
    model: str = "base"
) -> Optional[str]:
    """Transcribes an audio file and returns the text, or None on error."""
    ...

# ✅ Dataclasses for data structures
from dataclasses import dataclass

@dataclass
class TranscriptionResult:
    text: str
    language: str
    confidence: float
    duration_seconds: float

# ❌ Avoid any and functions without annotations
def process(data):  # ❌ no types
    ...
```

### mypy Configuration

```ini
# mypy.ini
[mypy]
strict = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_generics = true
```

---

## 3. Error Handling

**PEP 20 rule: "Errors should never pass silently."**

```python
# ❌ Silent exception — invisible bug
try:
    result = transcribe(audio)
except:
    pass  # NEVER

# ❌ Overly broad exception
try:
    result = transcribe(audio)
except Exception:
    print("Something went wrong")

# ✅ Specific exceptions with logging
import logging

logger = logging.getLogger(__name__)

try:
    result = transcribe(audio)
except FileNotFoundError as e:
    logger.error("Audio file not found: %s", e)
    raise  # Re-raise if we cannot recover
except TranscriptionError as e:
    logger.warning("Transcription failed, retrying: %s", e)
    return fallback_transcription(audio)
```

### Custom Exceptions

```python
# exceptions.py — clear hierarchy
class SQWRError(Exception):
    """Base exception for all SQWR Python projects."""

class TranscriptionError(SQWRError):
    """Error during audio transcription."""

class APIError(SQWRError):
    """External API error."""
    def __init__(self, message: str, status_code: int):
        super().__init__(message)
        self.status_code = status_code
```

---

## 4. PyObjC — Specific Rules for sqwr-dictate

> Source: PyObjC documentation + sqwr-dictate architecture (CLAUDE.md)

```python
# ✅ Check return values of Core Graphics functions
import Quartz

event = Quartz.CGEventCreateKeyboardEvent(None, key_code, key_down)
if event is None:
    logger.error("Failed to create keyboard event for key_code=%d", key_code)
    return  # ← Prevents Abort trap 6 (documented crash)

# ✅ Use arch -arm64 for macOS Silicon binaries
# See build_app.sh — the launcher must be compiled as arm64 Mach-O
# clang -arch arm64 -o launcher launcher.c

# ✅ Accessibility permissions — 3 entries in System Settings
# "Python", "python3.13", "sqwr-dictate" must ALL be enabled
```

---

## 5. Packaging & Distribution

### Project Structure

```
sqwr-dictate/
├── src/
│   └── sqwr_dictate/
│       ├── __init__.py
│       ├── main.py
│       ├── transcriber.py
│       ├── paster.py
│       └── exceptions.py
├── tests/
│   ├── test_transcriber.py
│   └── test_paster.py
├── pyproject.toml
├── mypy.ini
└── .python-version    # exact Python version (e.g. 3.13.2)
```

### pyproject.toml (modern standard)

```toml
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.backends.legacy:build"

[project]
name = "sqwr-dictate"
version = "1.0.0"
requires-python = ">=3.13"
dependencies = [
    "pyobjc>=10.0",
    "pyobjc-framework-Quartz>=10.0",
]

[project.optional-dependencies]
dev = ["black", "ruff", "mypy", "pytest", "pytest-asyncio"]

[tool.black]
line-length = 88
target-version = ["py313"]

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "W"]  # PEP 8 + imports + naming
```

### Virtual Environments

```bash
# Always use an isolated venv
python3.13 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"

# .python-version for pyenv
echo "3.13.2" > .python-version
```

---

## 6. Python Tests

```python
# tests/test_transcriber.py
import pytest
from sqwr_dictate.transcriber import transcribe_audio, TranscriptionResult

def test_transcribe_valid_audio(tmp_path):
    # Arrange
    audio_file = tmp_path / "test.wav"
    audio_file.write_bytes(generate_test_wav())

    # Act
    result = transcribe_audio(str(audio_file))

    # Assert
    assert result is not None
    assert isinstance(result, TranscriptionResult)
    assert len(result.text) > 0
    assert result.confidence > 0.5

def test_transcribe_missing_file():
    with pytest.raises(FileNotFoundError):
        transcribe_audio("/nonexistent/audio.wav")
```

```bash
# Run tests
pytest tests/ -v --tb=short

# With coverage
pytest tests/ --cov=src/sqwr_dictate --cov-report=term-missing
```

---

## 7. Absolute Rules

### Never do
- Bare `except:` without logging and without re-raise (silent errors)
- Code without type annotations (mypy must pass in strict mode)
- `print()` for debug in production (use `logging`)
- Global dependencies (always use a venv)
- Return `None` without annotating it as `Optional[T]`

### Always do
- `black` + `ruff` + `mypy --strict` before every commit
- Type hints on all functions
- Structured logging with appropriate levels
- Tests for every public function
- Check return values of system functions (especially PyObjC)

---

## 8. Sources

| Reference | Source |
|-----------|--------|
| PEP 8 — Style Guide | peps.python.org/pep-0008 |
| PEP 20 — Zen of Python | peps.python.org/pep-0020 |
| mypy — static typing | mypy-lang.org |
| black — formatter | black.readthedocs.io |
| ruff — linter | docs.astral.sh/ruff |
| PyObjC — macOS binding | pyobjc.readthedocs.io |
| FastAPI — REST API Python | fastapi.tiangolo.com |
