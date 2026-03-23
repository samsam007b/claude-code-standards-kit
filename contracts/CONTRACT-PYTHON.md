# Contrat — Python

> Module de contrat SQWR Project Kit.
> Sources : PEP 8, PEP 20 (Zen of Python), FastAPI docs, PyObjC docs, mypy docs.
> Applicable : sqwr-dictate (PyObjC), scripts utilitaires, agents IA Python.

---

## 1. Style & Qualité — PEP 8 + PEP 20

**The Zen of Python (PEP 20) — les 3 règles les plus importantes :**
```
Explicit is better than implicit.
Simple is better than complex.
Errors should never pass silently.
```

### Formatage obligatoire

```python
# Outil de formatage : black (non-configurable = cohérence forcée)
pip install black
black src/          # formater tout le code source

# Linting : ruff (remplace flake8 + isort, 10-100x plus rapide)
pip install ruff
ruff check src/

# Type checking : mypy (équivalent TypeScript strict pour Python)
pip install mypy
mypy src/ --strict
```

### Nommage (PEP 8)

```python
# Variables et fonctions : snake_case
user_name = "samuel"
def get_user_profile(): ...

# Classes : PascalCase
class AudioTranscriber: ...

# Constantes : SCREAMING_SNAKE_CASE
MAX_RECORDING_DURATION = 30  # secondes

# Modules/fichiers : snake_case
# transcriber.py, paster.py, audio_utils.py

# Éviter les noms génériques
# ❌ data, info, temp, x, res, val
# ✅ audio_buffer, transcription_result, retry_count
```

---

## 2. Typage statique — mypy strict

**Règle : tout code Python SQWR utilise le typage statique.**

```python
# ✅ Toujours annoter les fonctions
from typing import Optional, list, dict

def transcribe_audio(
    audio_path: str,
    language: str = "fr",
    model: str = "base"
) -> Optional[str]:
    """Transcrit un fichier audio et retourne le texte, ou None si erreur."""
    ...

# ✅ Dataclasses pour les structures de données
from dataclasses import dataclass

@dataclass
class TranscriptionResult:
    text: str
    language: str
    confidence: float
    duration_seconds: float

# ❌ Éviter any et les fonctions sans annotations
def process(data):  # ❌ pas de types
    ...
```

### Configuration mypy

```ini
# mypy.ini
[mypy]
strict = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_generics = true
```

---

## 3. Gestion des erreurs

**Règle PEP 20 : "Errors should never pass silently."**

```python
# ❌ Exception silencieuse — bug invisible
try:
    result = transcribe(audio)
except:
    pass  # JAMAIS

# ❌ Exception trop large
try:
    result = transcribe(audio)
except Exception:
    print("Something went wrong")

# ✅ Exceptions spécifiques avec logging
import logging

logger = logging.getLogger(__name__)

try:
    result = transcribe(audio)
except FileNotFoundError as e:
    logger.error("Audio file not found: %s", e)
    raise  # Re-raise si on ne peut pas récupérer
except TranscriptionError as e:
    logger.warning("Transcription failed, retrying: %s", e)
    return fallback_transcription(audio)
```

### Exceptions personnalisées

```python
# exceptions.py — hiérarchie claire
class SQWRError(Exception):
    """Base exception pour tous les projets SQWR Python."""

class TranscriptionError(SQWRError):
    """Erreur lors de la transcription audio."""

class APIError(SQWRError):
    """Erreur d'API externe."""
    def __init__(self, message: str, status_code: int):
        super().__init__(message)
        self.status_code = status_code
```

---

## 4. PyObjC — Règles spécifiques sqwr-dictate

> Source : PyObjC documentation + architecture sqwr-dictate (CLAUDE.md)

```python
# ✅ Vérifier les valeurs de retour des fonctions Core Graphics
import Quartz

event = Quartz.CGEventCreateKeyboardEvent(None, key_code, key_down)
if event is None:
    logger.error("Failed to create keyboard event for key_code=%d", key_code)
    return  # ← Évite l'Abort trap 6 (crash documenté)

# ✅ Utiliser arch -arm64 pour les binaires macOS Silicon
# Voir build_app.sh — le launcher doit être compilé en arm64 Mach-O
# clang -arch arm64 -o launcher launcher.c

# ✅ Droits Accessibilité — 3 entrées dans System Settings
# "Python", "python3.13", "sqwr-dictate" doivent TOUTES être activées
```

---

## 5. Packaging & Distribution

### Structure de projet

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
└── .python-version    # version Python exacte (ex: 3.13.2)
```

### pyproject.toml (standard moderne)

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

### Environnements virtuels

```bash
# Toujours utiliser un venv isolé
python3.13 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"

# .python-version pour pyenv
echo "3.13.2" > .python-version
```

---

## 6. Tests Python

```python
# tests/test_transcriber.py
import pytest
from sqwr_dictate.transcriber import transcribe_audio, TranscriptionResult

def test_transcribe_valid_audio(tmp_path):
    # Arrangement
    audio_file = tmp_path / "test.wav"
    audio_file.write_bytes(generate_test_wav())

    # Action
    result = transcribe_audio(str(audio_file))

    # Assertion
    assert result is not None
    assert isinstance(result, TranscriptionResult)
    assert len(result.text) > 0
    assert result.confidence > 0.5

def test_transcribe_missing_file():
    with pytest.raises(FileNotFoundError):
        transcribe_audio("/nonexistent/audio.wav")
```

```bash
# Lancer les tests
pytest tests/ -v --tb=short

# Avec coverage
pytest tests/ --cov=src/sqwr_dictate --cov-report=term-missing
```

---

## 7. Règles absolues

### Ne jamais faire
- Bare `except:` sans logger et sans re-raise (erreurs silencieuses)
- Code sans annotations de type (mypy doit passer en strict mode)
- `print()` pour le debug en production (utiliser `logging`)
- Dépendances globales (toujours utiliser un venv)
- Retourner `None` sans l'annoter `Optional[T]`

### Toujours faire
- `black` + `ruff` + `mypy --strict` avant tout commit
- Type hints sur toutes les fonctions
- Logging structuré avec niveaux appropriés
- Tests pour chaque fonction publique
- Vérifier les valeurs de retour des fonctions système (PyObjC notamment)

---

## 8. Sources

| Référence | Source |
|-----------|--------|
| PEP 8 — Style Guide | peps.python.org/pep-0008 |
| PEP 20 — Zen of Python | peps.python.org/pep-0020 |
| mypy — static typing | mypy-lang.org |
| black — formatter | black.readthedocs.io |
| ruff — linter | docs.astral.sh/ruff |
| PyObjC — macOS binding | pyobjc.readthedocs.io |
| FastAPI — API REST Python | fastapi.tiangolo.com |
