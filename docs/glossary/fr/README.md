# Glossaire (français, miroir de l'anglais)

Une fiche par terme, lue par `/explain`. Format : En une phrase / Analogie / Exemple / Où ça vit / Voir aussi.
Les titres gardent le terme anglais, identique à l'édition source.

## skill

- **En une phrase** : une recette écrite que Claude suit quand vous demandez un type de tâche précis.
- **Analogie** : une fiche recette en cuisine. Le cuisinier (Claude) sait cuisiner, la fiche dit comment vous aimez ce plat.
- **Exemple** : `/explain hook` lance le skill `explain`.
- **Où ça vit** : `~/.claude/skills/<nom>/SKILL.md`.
- **Voir aussi** : command, workflow, agent.

## hook

- **En une phrase** : un petit script qui se lance tout seul quand quelque chose arrive, par exemple avant une commande.
- **Analogie** : un détecteur de fumée. On ne l'appelle pas, il réagit seul.
- **Exemple** : un hook qui bloque `rm -rf` avant que Claude l'exécute.
- **Où ça vit** : déclaré dans `~/.claude/settings.json`, script dans `~/.claude/hooks/`.
- **Voir aussi** : guardrail, script, permission.

## workflow

- **En une phrase** : une suite fixe d'étapes, parfois répartie entre plusieurs agents, pour une tâche que vous répétez.
- **Analogie** : une chaîne de montage : mêmes postes, même ordre, à chaque fois.
- **Exemple** : relire, corriger, tester, puis enregistrer.
- **Où ça vit** : dans un skill, ou dans un script qui enchaîne les étapes.
- **Voir aussi** : skill, agent, script.

## script

- **En une phrase** : un fichier texte d'instructions que l'ordinateur exécute pour vous, sans réfléchir.
- **Analogie** : un programme de machine à laver : le même cycle à chaque fois.
- **Exemple** : `setup.sh` installe les outils.
- **Où ça vit** : n'importe quel dossier, souvent `scripts/`.
- **Voir aussi** : hook, terminal.

## MCP

- **En une phrase** : une prise standard qui permet à Claude d'utiliser un outil ou une source de données externe.
- **Analogie** : un adaptateur secteur universel entre Claude et une application.
- **Exemple** : un serveur MCP qui permet à Claude de lire votre agenda.
- **Où ça vit** : déclaré dans `.mcp.json` ou `~/.claude.json`.
- **Voir aussi** : connector, Composio.

## connector

- **En une phrase** : un lien prêt à l'emploi entre Claude et une application (Gmail, Drive, Slack).
- **Analogie** : une clé taillée pour une seule porte.
- **Exemple** : le connecteur Gmail lit et rédige des mails.
- **Où ça vit** : fourni par un serveur MCP ou par Composio.
- **Voir aussi** : MCP, Composio.

## Composio

- **En une phrase** : un seul compte qui relie Claude à des centaines d'applications, sans configurer chacune soi-même.
- **Analogie** : un concierge d'hôtel qui détient les clés de nombreux bâtiments.
- **Exemple** : envoyer un mail, ajouter un événement, lire une feuille de calcul, depuis un seul endroit.
- **Où ça vit** : service externe (offre gratuite), clé rangée localement dans un fichier de secrets.
- **Voir aussi** : MCP, connector. Facultatif : vous pouvez refuser.

## Playwright

- **En une phrase** : un outil qui permet à Claude de piloter une vraie fenêtre Chrome : ouvrir des pages, cliquer, lire, faire des captures.
- **Analogie** : un assistant assis devant votre navigateur.
- **Exemple** : « ouvre cette page et dis-moi le prix ».
- **Où ça vit** : installé via Node.
- **Voir aussi** : MCP, Node.

## CLAUDE.md

- **En une phrase** : un fichier texte de consignes permanentes que Claude lit au début de chaque session.
- **Analogie** : la note de briefing laissée à un nouveau collègue.
- **Exemple** : « Réponds en français. Reste bref. »
- **Où ça vit** : dossier du projet, ou `~/.claude/CLAUDE.md` pour tous les projets.
- **Voir aussi** : memory, rule.

## agent and subagent

- **En une phrase** : une instance de Claude séparée, chargée d'une mission, avec sa propre mémoire de travail.
- **Analogie** : un spécialiste à qui l'on délègue et qui rapporte un résumé.
- **Exemple** : un agent de recherche lit 10 pages et rend 5 lignes.
- **Où ça vit** : `~/.claude/agents/<nom>.md`.
- **Voir aussi** : skill, context.

## context

- **En une phrase** : tout ce que Claude voit en ce moment dans la conversation ; c'est limité.
- **Analogie** : un bureau : quand il est plein, les vieux papiers tombent.
- **Exemple** : une très longue session est résumée pour faire de la place.
- **Où ça vit** : dans la session, pas sur le disque.
- **Voir aussi** : token, compact.

## token

- **En une phrase** : un petit morceau de texte, l'unité dans laquelle Claude lit, écrit et facture.
- **Analogie** : un morceau de mot, environ 4 caractères.
- **Exemple** : une page fait environ 500 tokens.
- **Où ça vit** : compté à chaque message.
- **Voir aussi** : context.

## permission

- **En une phrase** : la question que Claude pose avant une action qui modifie votre machine.
- **Analogie** : un collègue qui demande « je peux ? » avant de déplacer vos fichiers.
- **Exemple** : autoriser une fois, toujours, ou refuser.
- **Où ça vit** : `~/.claude/settings.json`.
- **Voir aussi** : hook, guardrail.

## guardrail

- **En une phrase** : un contrôle qui arrête une action risquée avant qu'elle ait lieu.
- **Analogie** : la rampe d'un escalier.
- **Exemple** : refuser de supprimer tout le dossier personnel.
- **Où ça vit** : réalisé avec des hooks.
- **Voir aussi** : hook, permission.

## plan mode

- **En une phrase** : Claude explore et propose un plan sans rien modifier tant que vous n'avez pas approuvé.
- **Analogie** : le plan de l'architecte avant l'arrivée des ouvriers.
- **Exemple** : Maj+Tab pour y entrer.
- **Où ça vit** : un mode de la session.
- **Voir aussi** : permission.

## terminal

- **En une phrase** : une fenêtre où l'on tape des commandes au lieu de cliquer.
- **Analogie** : envoyer des SMS à son ordinateur.
- **Exemple** : `claude` lance Claude Code.
- **Où ça vit** : Terminal (macOS), Windows Terminal ou PowerShell.
- **Voir aussi** : script, shell.

## Homebrew

- **En une phrase** : un installateur d'outils de développement sur macOS.
- **Analogie** : un app store que l'on pilote en tapant.
- **Exemple** : `brew install node`.
- **Où ça vit** : `/opt/homebrew`. Se retire avec son script de désinstallation.
- **Voir aussi** : winget, Node.

## winget

- **En une phrase** : l'installateur d'outils intégré à Windows.
- **Analogie** : le cousin Windows de Homebrew.
- **Exemple** : `winget install OpenJS.NodeJS`.
- **Où ça vit** : fourni avec Windows 10 et 11.
- **Voir aussi** : Homebrew.

## Node.js

- **En une phrase** : un programme qui exécute du JavaScript hors du navigateur ; Claude Code et Playwright en ont besoin.
- **Analogie** : le moteur sous plusieurs outils.
- **Exemple** : `node --version` montre qu'il est installé.
- **Où ça vit** : installé par Homebrew ou winget.
- **Voir aussi** : Playwright, npm.

## Python

- **En une phrase** : un langage de programmation généraliste que de nombreux scripts et outils utilisent.
- **Analogie** : un couteau suisse.
- **Exemple** : `python3 --version`.
- **Où ça vit** : installé par Homebrew ou winget.
- **Voir aussi** : script.

## Git

- **En une phrase** : un outil qui enregistre chaque version de vos fichiers pour pouvoir revenir en arrière.
- **Analogie** : un « annuler » illimité avec un livre d'histoire.
- **Exemple** : `git commit` enregistre un instantané.
- **Où ça vit** : un dossier caché `.git` dans le projet.
- **Voir aussi** : commit, branch.

## commit and branch

- **En une phrase** : un commit est un instantané enregistré ; une branche est une ligne de travail parallèle.
- **Analogie** : un point de sauvegarde dans un jeu, et une ligne temporelle alternative.
- **Exemple** : travailler sur `v5-starter` sans toucher à `main`.
- **Où ça vit** : à l'intérieur de `.git`.
- **Voir aussi** : Git.

## WSL2

- **En une phrase** : un système Linux qui tourne dans Windows, nécessaire pour les hooks avancés du kit.
- **Analogie** : une seconde pièce dans votre maison, avec un autre mobilier.
- **Exemple** : `wsl --install`.
- **Où ça vit** : fonctionnalité de Windows.
- **Voir aussi** : hook, terminal.

## memory

- **En une phrase** : des notes que Claude garde entre les sessions pour que vous n'ayez pas à vous répéter.
- **Analogie** : un carnet qui reste sur le bureau.
- **Exemple** : « je préfère les réponses courtes ».
- **Où ça vit** : `~/.claude/projects/<projet>/memory/`.
- **Voir aussi** : CLAUDE.md, context.
