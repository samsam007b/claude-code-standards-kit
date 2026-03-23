# Audit Déploiement — Gate Pré-Production

> Checklist exhaustive à compléter avant tout déploiement en production.
> Toutes les cases doivent être cochées avant de merger sur `main`.

---

## 🔴 Bloquants — zéro exception

- [ ] `npm run build` passe sans erreur
- [ ] `npm run lint` passe avec 0 erreur ESLint
- [ ] `npm audit --audit-level=critical` passe
- [ ] Aucun `console.log` de debug (`grep -r "console.log" src/`)
- [ ] Aucune clé secrète dans le diff (`git diff main...HEAD`)
- [ ] Variables d'environnement configurées dans Vercel dashboard
- [ ] `.env.local` NOT commité (vérifier `.gitignore`)

---

## 🟡 Qualité — fortement recommandé

**Performance :**
- [ ] LCP ≤2.5s sur les pages critiques (PageSpeed Insights)
- [ ] CLS <0.1 sur les pages critiques
- [ ] Lighthouse Performance ≥85
- [ ] Lighthouse SEO ≥90

**Code :**
- [ ] Tests passent (`npm run test`)
- [ ] Coverage ne régresse pas
- [ ] TypeScript strict — aucune erreur `any` introduite

**Accessibilité :**
- [ ] Lighthouse Accessibility ≥90
- [ ] Contrastes vérifiés sur les nouvelles UI

**SEO :**
- [ ] Metadata (title + description) sur toutes les nouvelles pages
- [ ] Aucun `ssr: false` ajouté sur pages indexées
- [ ] JSON-LD schema à jour si structure du site modifiée

**Release & Dépendances :**
- [ ] CHANGELOG.md mis à jour avec les changements de cette release
- [ ] `npm audit` complet — aucune vulnérabilité High ou Critical ouverte
- [ ] Dependabot PRs reviewées (aucune vulnérabilité P0/P1 en attente)

---

## 🟢 Vérifications post-déploiement (dans les 30 min)

- [ ] Page d'accueil charge correctement
- [ ] Formulaire de contact fonctionne (test réel)
- [ ] Auth flow fonctionne (connexion + déconnexion)
- [ ] Logs Vercel sans erreur 500
- [ ] Google Search Console : pas d'erreurs critiques nouvelles

---

## Commandes de vérification rapide

```bash
# Build
npm run build

# Lint + tests
npm run lint && npm run test

# Secrets dans diff
git diff main...HEAD | grep -E "(KEY|SECRET|PASSWORD|TOKEN)"

# console.log oubliés
grep -r "console\.log" src/ --include="*.ts" --include="*.tsx"

# Vérifier .env.local non commité
git status | grep ".env"
```

---

## Si un bloquant est levé sans résolution

Documenter ici avec date, raison, et plan de correction :

| Date | Bloquant levé | Raison | Plan |
|------|--------------|--------|------|
| [JJ/MM] | [item] | [raison] | [correction prévue pour] |
