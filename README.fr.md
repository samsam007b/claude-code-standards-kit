# Claude Code Standards Kit : démarrer (édition française)

Miroir français de la section « Start here » de [README.md](README.md). Le palier avancé (contrats, audits, hooks) est décrit en anglais dans le README principal.

## Pour qui ?

Vous débutez avec Claude Code, après une explication ou une formation, et vous voulez comprendre ce que vous installez au lieu d'empiler des règles et des sécurités sans savoir à quoi elles servent.

Le kit a deux couches. La plupart des gens n'ont besoin que de la première.

| Palier | Pour qui | Ce que vous obtenez |
|---|---|---|
| **1. Démarrer** | Toute personne qui débute avec Claude Code | Une installation guidée, un court questionnaire, et un assistant qui explique chaque outil en mots simples avant de l'utiliser |
| **2. Outils** | Quand vous savez ce qu'il vous faut | Playwright (Claude pilote Chrome), Composio (relie Claude à vos applications), garde-fous, plus de skills |
| **Avancé** | Développeurs qui livrent de vrais produits | Le kit complet de standards (README anglais) : contrats, audits, 18 hooks globaux |

## Installer le démarrage

```bash
git clone https://github.com/samsam007b/claude-code-standards-kit ~/claude-starter
cd ~/claude-starter
./setup.sh --lang fr      # macOS ou Linux
```

Sous Windows, ouvrez PowerShell : `powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Lang fr`. Le palier avancé sous Windows demande WSL2 : voir [docs/WINDOWS.md](docs/WINDOWS.md).

Le script vérifie votre machine, explique chaque outil manquant (Homebrew ou winget, Git, Node.js, Python, Claude Code) et ne l'installe que si vous dites oui. Ensuite lancez `claude` et tapez **`/welcome`**.

## Et ensuite

1. `/welcome` pose 6 courtes questions et fixe votre niveau : **Découverte**, **Pratique** ou **Autonome**.
2. Il propose les outils selon vos besoins, un par un : ce que c'est, en quoi ça vous aide, comment le retirer. Rien ne s'installe sans votre oui.
3. À tout moment, tapez **`/explain <terme>`** (skill, hook, workflow, script, MCP, Composio...). Le [glossaire](docs/glossary/fr/README.md) contient 22 fiches.

Rien n'est envoyé nulle part. Votre profil est un fichier local : `~/.claude/kit/profile.json`.

## Premiers mots à connaître

| Mot | En une phrase |
|---|---|
| skill | une recette écrite que Claude suit à la demande |
| hook | un petit script qui se lance tout seul quand quelque chose arrive |
| workflow | une suite fixe d'étapes pour une tâche répétée |
| script | un fichier d'instructions que l'ordinateur exécute sans réfléchir |
| MCP | une prise standard entre Claude et un outil externe |

Pour tout le reste : `/explain <mot>`.
