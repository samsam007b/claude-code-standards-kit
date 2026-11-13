# Clean Commit

Prépare un commit propre en nettoyant le code avant de committer.

## Étapes

### 1. Analyse des fichiers modifiés
Regarde les fichiers staged et unstaged avec `git status` et `git diff`.

### 2. Nettoyage automatique
Retire automatiquement :
- `console.log()`, `console.debug()`, `console.warn()` de debug (garde ceux intentionnels avec commentaire `// keep`)
- `print()` de debug en Python
- `debugger;` statements
- Commentaires temporaires (`// TODO: remove`, `// FIXME`, `// DEBUG`, `// test`)
- Fichiers `.DS_Store`, `*.log`, `*.tmp`
- Code commenté en bloc (plus de 5 lignes consécutives commentées)

### 3. Vérification des imports
- Retire les imports non utilisés
- Vérifie qu'il n'y a pas de `import ... from './test'` ou chemins de debug

### 4. Documentation si nécessaire
Si une solution technique non-évidente a été implémentée durant cette session :
- Crée un fichier `docs/decisions/YYYY-MM-DD-description.md` expliquant le contexte et la solution
- N'ajoute cette doc que si c'est vraiment nécessaire pour la compréhension future

### 5. Résumé
Affiche un résumé de ce qui a été nettoyé et demande confirmation avant de stage les changements.

## Options utilisateur
Après le nettoyage, demande :
- Voulez-vous voir le diff des changements ?
- Voulez-vous que je stage et commit directement ?
- Message de commit suggéré ?
