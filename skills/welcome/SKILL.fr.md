---
name: "welcome"
description: "Premier lancement pour un débutant. Évalue le niveau et les besoins en 6 questions, explique chaque outil avant de l'installer, installe seulement après un oui, puis écrit le profil."
effort: medium
disable-model-invocation: true
argument-hint: "[--redo]"
---

# /welcome (édition française, miroir de SKILL.md)

Parcours didactique pour quelqu'un qui installe Claude Code seul (ou après une courte formation). Ignoré par `/pro-samuel`.

## Principes

- Mots simples. Définir tout terme technique à sa première apparition, ou renvoyer à `/explain <terme>`.
- Rien ne s'installe sans un « oui » clair. Avant chaque outil : ce que c'est, en quoi il aide cette personne, ce qu'il change sur la machine, comment le retirer.
- Une question à la fois. Jamais plus de 6 au total.
- Si la personne pose une question à côté, y répondre, puis reposer la question en attente une seule fois, simplement. Ne jamais s'excuser de la répéter ni promettre que c'est la dernière fois.
- Si une lecture demande une autorisation, dire « je demande votre autorisation avant de lire », jamais « bloqué ». Si le profil est illisible, répondre dans la langue du message de la personne.
- Ne jamais deviner le niveau : demander, puis confirmer en une phrase (« Donc vous êtes au niveau Pratique, correct ? »).

## Étape 1 : Détecter la configuration (sans question)

Lire `~/.claude/kit/profile.json`. S'il existe et que `--redo` est absent, saluer selon le niveau et demander ce qu'il y a à faire aujourd'hui au lieu de tout recommencer.
Sinon détecter : système, shell, présence de Homebrew ou winget, Git, Node, Python. Dire en mots simples ce qui est déjà là.

## Étape 2 : Six questions

1. Que voulez-vous faire avec Claude Code ? (écrire, coder, automatiser, analyser, autre)
2. Avez-vous déjà utilisé un terminal ? (jamais / un peu / souvent)
3. Avez-vous déjà utilisé Claude Code ? (jamais / quelques fois / tous les jours)
4. Travaillez-vous avec des mails, un agenda, des documents ou d'autres applications que Claude pourrait atteindre ?
5. Avez-vous besoin que Claude navigue ou teste des pages web pour vous ?
6. Comment préférez-vous apprendre : explications courtes, ou détail avec exemples ?

## Étape 3 : Niveau

| Niveau | Signal | Effet |
|---|---|---|
| Découverte | jamais de terminal ni de Claude Code | Tout expliquer, peu d'outils proposés, garde-fous renforcés |
| Pratique | un peu de terminal ou de Claude Code | Explications courtes, outils proposés selon les besoins |
| Autonome | usage quotidien | Style concis, listes d'options, palier avancé proposé |

## Étape 4 : Proposer les outils selon les besoins, un par un

| Besoin | Outil | Explication simple |
|---|---|---|
| Naviguer ou tester des pages | Playwright | Permet à Claude de piloter une fenêtre Chrome comme le ferait une personne |
| Mail, agenda, documents, nombreuses applications | Composio | Un seul compte qui relie Claude à des centaines d'applications sans configurer chacune |
| Toute personne, tout niveau | Composio, proposé à tous | Facultatif : l'intérêt est expliqué, un compte gratuit est nécessaire, refuser ne coûte rien |
| Routines réutilisables | Skills | Une recette écrite que Claude suit à la demande |
| Filet de sécurité | Garde-fous (2 hooks) | De petits contrôles qui arrêtent les commandes risquées avant leur exécution |

Pour chacun : expliquer, demander « l'installer ? », installer si oui, vérifier que ça marche, l'inscrire dans le profil.

Garde-fous : si oui, lancer `node ~/.claude/kit/hooks/register-hooks.mjs` (sauvegarde `settings.json`, fusionne, annulation avec `--remove`). Dire ce qu'ils bloquent : les commandes destructrices (guard-destructive) et les secrets d'apparence réelle écrits dans des fichiers (guard-secrets). Le mode pro les enregistre dans l'unique passe confirmée.

## Étape 5 : Écrire le profil

Écrire `~/.claude/kit/profile.json` avec `language`, `level`, `needs`, `tools_installed`, `mode: "learner"`, `date`. Fichier local, jamais envoyé nulle part.

## Étape 6 : Conclure

Un court résumé : ce qui est installé, à quoi sert chaque chose, comment demander de l'aide (`/explain <terme>`), comment changer de niveau (`/welcome --redo`). Proposer le palier avancé seulement au niveau Autonome, en disant comment : garder le dossier du kit téléchargé (le démarrage ne copie que 3 skills), puis lancer `bash global/install-global.sh --dry-run` pour prévisualiser, et sans `--dry-run` pour installer (sauvegarde, n'écrase jamais). Pour les autres : mentionner une fois que `/welcome --redo` le débloquera plus tard.

## Règles

- Windows : le palier 1 tourne en natif. Le palier avancé demande WSL2 ; l'expliquer et laisser la personne décider.
- La langue suit `language` dans le profil ; cette édition française reflète SKILL.md.
- Tout envoi externe ou création de compte demande une confirmation dans le même tour.
