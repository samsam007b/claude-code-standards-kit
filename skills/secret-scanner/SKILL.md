---
name: secret-scanner
description: Scanner les fichiers staged pour détecter des credentials, API keys, tokens et secrets avant tout commit git.
tags: [security, git, secrets, credentials]
model: sonnet
---

# Secret Scanner - Protection contre les fuites de credentials

## Description

Ce skill fournit une protection automatique contre la fuite de secrets (mots de passe, API keys, tokens) dans les commits Git. Il analyse automatiquement chaque `git commit` et `git push` avant exécution.

## Fonctionnement

Le hook `PreToolUse` intercepte les commandes Bash contenant :
- `git commit`
- `git push`
- `git commit --amend`

Il exécute ensuite le script `scan-secrets.sh` qui :
1. Récupère les changements staged (`git diff --cached`)
2. Analyse le contenu avec 30+ patterns regex
3. Bloque l'opération si des secrets sont détectés

## Patterns détectés

### Mots de passe
- `password = "..."`
- `pwd = "..."`
- `passwd = "..."`

### API Keys
- AWS: `AKIA...` (16 chars)
- Stripe: `sk_live_...`, `sk_test_...`, `whsec_...`
- Google: `AIza...` (35 chars)
- GitHub: `ghp_...`, `gho_...`
- Supabase JWT tokens
- SendGrid: `SG....`
- Slack: `xox[baprs]-...`

### Tokens génériques
- `api_key = "..."`
- `secret_key = "..."`
- `auth_token = "..."`
- `access_token = "..."`
- `bearer ...`

### Clés privées
- `-----BEGIN PRIVATE KEY-----`
- `-----BEGIN RSA PRIVATE KEY-----`
- `-----BEGIN PGP PRIVATE KEY BLOCK-----`

### Connection strings
- MongoDB: `mongodb://user:pass@...`
- PostgreSQL: `postgres://user:pass@...`
- MySQL: `mysql://user:pass@...`
- Redis: `redis://user:pass@...`

## Fichiers

- **Hook script**: `.claude/hooks/scan-secrets.sh`
- **Configuration**: `.claude/settings.json` (PreToolUse hook)

## Personnalisation

Pour ajouter de nouveaux patterns, éditez le tableau `PATTERNS` dans `scan-secrets.sh` :

```bash
PATTERNS=(
    # Ajouter votre pattern ici
    "mon_pattern_custom"
    ...
)
```

## Limitations

- Ne supprime PAS les secrets de l'historique Git
- Ne scanne pas les fichiers binaires
- Peut avoir des faux positifs sur certains patterns génériques

## Que faire si un secret est détecté ?

1. **Ne pas committer** - Le hook bloque automatiquement
2. **Retirer le secret du code** - Utiliser des variables d'environnement
3. **Si déjà committé** - Changer immédiatement le secret exposé
4. **Optionnel** - Nettoyer l'historique avec `git filter-branch` ou BFG

## Exemples de bonnes pratiques

```javascript
// ❌ MAUVAIS - Secret hardcodé
const apiKey = "sk_live_abc123xyz";

// ✅ BON - Variable d'environnement
const apiKey = process.env.STRIPE_SECRET_KEY;
```

```python
# ❌ MAUVAIS
password = "SuperSecret123"

# ✅ BON
import os
password = os.environ.get("DB_PASSWORD")
```
