# Changelog

> Format : [Keep a Changelog 1.1.0](https://keepachangelog.com/fr/1.1.0/)
> Versioning : [Semantic Versioning 2.0.0](https://semver.org/lang/fr/)
>
> **Règles SemVer :**
> - `MAJOR` (x.0.0) : changements incompatibles avec les versions précédentes
> - `MINOR` (0.x.0) : nouvelles fonctionnalités rétro-compatibles
> - `PATCH` (0.0.x) : corrections de bugs rétro-compatibles
>
> **Mapping Conventional Commits → SemVer :**
> - `feat:` → MINOR increment
> - `fix:` → PATCH increment
> - `BREAKING CHANGE:` dans le footer → MAJOR increment
> - `chore:`, `docs:`, `style:`, `refactor:`, `test:` → pas de release automatique

---

## [Unreleased]

### Added
-

### Changed
-

### Fixed
-

---

## [1.0.0] — YYYY-MM-DD

### Added
- Lancement initial du projet
- [Décrire les fonctionnalités majeures du premier release]

---

<!-- ═══════════════════════════════════════════════════════════════════
INSTRUCTIONS POUR MAINTENIR CE FICHIER
═══════════════════════════════════════════════════════════════════

AVANT CHAQUE RELEASE :
1. Renommer "[Unreleased]" en "[X.Y.Z] — YYYY-MM-DD" (date ISO 8601)
2. Créer un nouveau "[Unreleased]" vide au-dessus
3. Tagger le commit : git tag -a vX.Y.Z -m "Release X.Y.Z"
4. Pousser le tag : git push origin vX.Y.Z

CATÉGORIES DISPONIBLES (n'utiliser que celles avec du contenu) :
- Added      : nouvelles fonctionnalités
- Changed    : changements dans des fonctionnalités existantes
- Deprecated : fonctionnalités qui seront supprimées dans une future version
- Removed    : fonctionnalités supprimées (attention : peut être BREAKING CHANGE)
- Fixed      : corrections de bugs
- Security   : corrections de vulnérabilités (toujours inclure si applicable)

FORMAT DATE : toujours ISO 8601 (YYYY-MM-DD) — pas de 18/03/2026 ou March 18, 2026

EXEMPLE D'ENTRÉE BIEN FORMATÉE :
## [1.2.0] — 2026-03-18

### Added
- Tableau de bord propriétaires avec compteur de vues des annonces (#45)
- Notifications email pour les nouveaux messages (#52)

### Fixed
- Correction de l'affichage des images sur mobile Safari (#61)
- Résolution du bug de session qui déconnectait après 15 min (#58)

### Security
- Mise à jour next-auth 4.24.5 → 4.24.7 (CVE-2026-XXXX)

RÈGLE D'OR : ce fichier est pour les humains, pas les machines.
Écrire des descriptions que quelqu'un peut comprendre sans regarder le code.

SOURCES :
- Keep a Changelog : keepachangelog.com/fr/1.1.0
- Semantic Versioning : semver.org
- Conventional Commits : conventionalcommits.org
═══════════════════════════════════════════════════════════════════ -->
