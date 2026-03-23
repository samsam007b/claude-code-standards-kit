# Méthodologie — SQWR Project Kit

> Ce document s'adresse simultanément à deux lecteurs :
> — **Claude Code** : qui l'intègre comme contexte comportemental ("comment je dois travailler")
> — **Les humains** : qui l'utilisent comme manifeste et guide d'apprentissage

---

## L'insight fondamental

**La qualité professionnelle n'est pas dans le code — elle est dans la recherche qui précède le code.**

Les professionnels (cabinets d'audit, grandes tech, agences de conseil) ne partent pas d'opinions. Ils partent de **standards documentés, de recherches publiées, de précédents vérifiables**. Claude Code permet d'accéder à cette base de connaissances et de l'appliquer à n'importe quel projet — y compris des projets solo ou étudiants.

Ce kit existe parce qu'une observation simple s'est avérée vraie sur des dizaines de projets :

> La différence entre un livrable "amateur" et un livrable "professionnel" n'est pas le talent — c'est la connaissance des standards qui existent déjà, et la discipline de les appliquer.

Claude Code sait chercher ces standards plus vite qu'un humain. L'humain sait quoi faire avec ce qu'il trouve. **L'association des deux dépasse ce que chacun peut faire seul.**

---

## Pour Claude Code — Règles de comportement

### Règle 1 : Recherche avant implémentation

Pour toute tâche non-triviale, et **avant d'écrire la première ligne de code**, poser la question :

> "Quel est l'état de l'art professionnel et académique sur ce sujet ?"

Exemple :
- Tâche : "Ajoute un système d'upload de fichiers"
- Recherche préalable : quelles sont les vulnérabilités connues (OWASP File Upload), les limites recommandées (NIST), les implémentations de référence (Vercel Blob docs, Supabase Storage docs)
- Implémentation : fondée sur des sources, pas sur des patterns mémorisés

### Règle 2 : Hiérarchie des sources

Respecter cet ordre de priorité :

```
TIER 1 — Documentation officielle (source de vérité technique)
  ├── Anthropic docs       → docs.anthropic.com
  ├── Vercel docs          → vercel.com/docs
  ├── GitHub / Actions     → docs.github.com
  ├── Apple Developer      → developer.apple.com
  ├── W3C / MDN            → w3.org, developer.mozilla.org
  └── Supabase docs        → supabase.com/docs

TIER 2 — Standards scientifiques et académiques (source de vérité métier)
  ├── OWASP, NIST, W3C     → Standards de sécurité, accessibilité
  ├── Nielsen Norman Group → UX research (nngroup.com)
  ├── Baymard Institute    → E-commerce UX (baymard.com)
  ├── Harvard Business Review → Management, stratégie (hbr.org)
  ├── Google SRE Book      → Fiabilité (sre.google)
  └── Publications académiques → Nature, arXiv, ACM, CHI, PMC/NIH

TIER 3 — Rapports professionnels d'industrie
  ├── Google Core Web Vitals research   → web.dev
  ├── Snyk State of Open Source Security → snyk.io/reports
  ├── Veracode GenAI Security Report    → veracode.com/state-of-software-security
  └── Publications d'écoles (ESADE, HBS, MIT Sloan)

TIER 4 — Communautés et praticiens (source de vérité pratique)
  ├── GitHub ★★★★★         → Issues, READMEs, discussions des projets les plus étoilés
  ├── Reddit                → r/webdev, r/ClaudeAI, r/entrepreneur (patterns réels)
  ├── Hacker News           → news.ycombinator.com (signal/bruit élevé)
  └── Dev.to, Engineering blogs (Stripe, Vercel, Shopify)
```

**Règle critique** : les thresholds numériques (ex : contraste 4.5:1, coverage ≥80%, LCP ≤2.5s) ne peuvent venir que de Tier 1 ou Tier 2. Les opinions de Tier 4 sont précieuses pour les patterns pratiques — pas pour les seuils mesurables.

### Règle 3 : Citer les sources dans les contrats

Chaque règle non-triviale ajoutée à un contrat doit avoir une source vérifiable. Format attendu :

```markdown
**Seuil : 16px minimum** (Rello & Pielot, CHI 2016 — étude sur la fatigue oculaire)
**Contraste : ≥4.5:1** (W3C WCAG 2.1 SC 1.4.3)
**Coverage : ≥80%** (Google Engineering Practices, eng-practices.github.io)
```

Pas de "il est recommandé de" sans source. Soit la source existe, soit c'est une opinion.

### Règle 4 : Ne jamais inventer des standards

Si un threshold ou une règle n'est pas dans un contrat du kit ou dans une source Tier 1-2 vérifiable : **le dire explicitement**.

> "Je n'ai pas de standard documenté pour ce cas précis. Voici ce que j'ai trouvé en Tier 4 (praticiens) — à vérifier avant d'en faire une règle."

L'anti-hallucination s'applique aux standards autant qu'aux données.

---

## Le workflow de recherche en 5 étapes

### Étape 1 — Identifier le domaine et les contrats applicables

Les contrats du kit définissent les règles pour les domaines couverts. **Vérifier d'abord si un contrat existe.**

```
Contrats applicables par type de tâche :
├── Sécurité / RGPD    → CONTRACT-SECURITY.md + DEPENDENCY-MANAGEMENT.md
├── Performance        → CONTRACT-PERFORMANCE.md
├── Accessibilité      → CONTRACT-ACCESSIBILITY.md
├── Design UI          → CONTRACT-DESIGN.md
├── TypeScript / Code  → CONTRACT-TYPESCRIPT.md
├── Tests              → CONTRACT-TESTING.md
├── Base de données    → CONTRACT-SUPABASE.md
├── Déploiement        → CONTRACT-VERCEL.md
├── Observabilité      → CONTRACT-OBSERVABILITY.md
├── Résilience         → CONTRACT-RESILIENCE.md
├── IA / LLM           → CONTRACT-AI-PROMPTING.md + CONTRACT-ANTI-HALLUCINATION.md
├── Mobile iOS         → CONTRACT-IOS.md
├── Python / FastAPI   → CONTRACT-PYTHON.md
├── Génération PDF     → CONTRACT-PDF-GENERATION.md
├── Green IT           → CONTRACT-GREEN-SOFTWARE.md
├── SEO technique      → CONTRACT-SEO.md
├── Email (SMTP/DKIM)  → CONTRACT-EMAIL.md
├── CI/CD              → CONTRACT-CICD.md
├── Analytics produit  → CONTRACT-ANALYTICS.md
├── Internationalisation → CONTRACT-I18N.md
├── Pricing / SaaS     → CONTRACT-PRICING.md
├── Android            → CONTRACT-ANDROID.md
├── Motion / Animation → CONTRACT-MOTION-DESIGN.md
├── Production vidéo   → CONTRACT-VIDEO-PRODUCTION.md
│
├── Recherche UX       → frameworks/UX-RESEARCH.md  (avant toute feature)
├── Stratégie contenu  → frameworks/SOCIAL-CONTENT.md  (avant tout lancement social)
│
├── Branding           → frameworks/BRAND-STRATEGY.md  (avant tout design)
├── Lancement produit  → frameworks/COMPETITIVE-AUDIT.md + frameworks/CAMPAIGN-STRATEGY.md
├── Conformité EU      → frameworks/COMPLIANCE-EU.md
├── Nouveau projet     → frameworks/PROJECT-SCOPING.md
├── Estimation délai   → frameworks/ESTIMATION.md
├── Livraison client   → frameworks/CLIENT-HANDOFF.md
├── Incident prod      → frameworks/INCIDENT-RESPONSE.md
├── Décision archi     → frameworks/ADR-TEMPLATE.md
└── Objectifs fiabilité→ frameworks/SLO-TEMPLATE.md
```

### Étape 2 — Recherche amont si le contrat ne couvre pas le cas

```
Prompt type :
"Avant d'implémenter [X], recherche :
1. Quelles sont les meilleures pratiques documentées par des sources Tier 1-2 ?
2. Quels standards reconnus s'appliquent (OWASP, WCAG, NIST, W3C) ?
3. Quels auteurs ou organisations font référence dans ce domaine ?"
```

### Étape 3 — Benchmarking communautaire (Tier 4)

```
Prompt type :
"Recherche sur GitHub les projets les plus étoilés qui implémentent [X].
Qu'est-ce qui revient dans les top issues et discussions ?
Quels patterns ont émergé comme standards de facto ?"
```

### Étape 4 — Ancrage dans la documentation officielle

```
Prompt type :
"Quelle est l'implémentation recommandée par [Vercel/Anthropic/Apple/W3C]
dans leur documentation officielle ?
Existe-t-il des patterns ou exemples officiels à suivre ?"
```

### Étape 5 — Synthèse → Contrat → Implémentation → Audit

La recherche devient un contrat (règles + sources + thresholds). L'implémentation suit le contrat. L'audit vérifie que les thresholds sont atteints.

---

## Ressources communautaires Claude Code de confiance

Ces projets GitHub sont des sources de confiance pour étendre les capacités de Claude Code. Critères de confiance : >500 étoiles, commits récents, maintenu activement.

| Ressource | Type | Pourquoi c'est utile |
|-----------|------|---------------------|
| **awesome-claude-code** | Curated list | Index des meilleurs skills, hooks, configs |
| **claude-code-hooks** | Exemples | Patterns avancés pour hooks personnalisés |
| **anthropics/anthropic-cookbook** | Officiel | Patterns officiels Claude API + Agent SDK |
| **r/ClaudeAI** (Reddit) | Communauté | Retours d'expérience réels, edge cases |
| **r/webdev** (Reddit) | Communauté | Tendances stack, pratiques actuelles |
| **Hacker News "Ask HN"** | Communauté | Signal élevé sur les meilleures pratiques |

**Règle de confiance GitHub :** un projet avec >1000 étoiles, des commits récents, et des issues résolues est généralement fiable. Toujours lire le code avant d'importer un skill externe.

---

## Pour les humains — Comment utiliser ce kit

### Si tu découvres Claude Code

**La question la plus importante à poser à Claude Code, en permanence :**

> "Avant de faire X, quelles sont les meilleures pratiques professionnelles et les standards reconnus dans ce domaine ? Va chercher sur internet."

Cette habitude seule fait passer les projets du niveau "personnel" au niveau "professionnel". Claude Code ne mémorise pas des opinions — il sait chercher les standards qui existent. L'enjeu est de lui donner ce réflexe systématiquement.

### Le démarrage en 3 commandes

```bash
# 1. Bootstrap un projet avec tout le kit
bash scripts/init-project.sh --name "mon-projet" --stack "nextjs-supabase" --path "~/Desktop/mon-projet"

# 2. Valider que le CLAUDE.md est complet
bash scripts/validate-claude-md.sh ~/Desktop/mon-projet/CLAUDE.md

# 3. Lancer l'audit initial (scorer l'état de départ)
# → Ouvrir audits/AUDIT-INDEX.md dans Claude Code et suivre les instructions
```

### Les 5 réflexes à développer avec Claude Code

| Situation | Réflexe |
|-----------|---------|
| Nouvelle fonctionnalité | "Cherche les standards et meilleures pratiques avant d'implémenter" |
| Décision d'architecture | "Crée un ADR (frameworks/ADR-TEMPLATE.md) pour documenter le choix" |
| Avant de livrer | "Lance l'audit AUDIT-INDEX.md et traite les points <70%" |
| Nouvelle marque/projet | "Commence par BRAND-STRATEGY.md avant tout design visuel" |
| Estimation délai | "Utilise frameworks/ESTIMATION.md — règle ×1.5 obligatoire" |

### Comment ce kit s'améliore

Ce kit est une base, pas une limite. Il est conçu pour grandir.

**Principe Open/Closed :** ouvert à l'extension, fermé à la modification non-sourcée.

Pour ajouter un contrat :
1. Identifier un domaine non couvert
2. Rechercher les standards Tier 1-2 du domaine
3. Créer `contracts/CONTRACT-[NOM].md` avec la structure standard
4. Ajouter à README.md + verify-kit.sh
5. Référencer dans AUDIT-INDEX.md si un audit est associé

Pour améliorer un contrat existant :
1. Identifier un threshold ou règle manquant
2. Trouver la source Tier 1-2 qui justifie le changement
3. Mettre à jour le contrat avec la source citée

---

## Pourquoi ce kit existe

Ce kit est né d'une observation faite sur plusieurs années de travail avec Claude Code : **les outils ne manquent pas — c'est la méthode qui manque**.

La plupart des tutoriels Claude Code montrent comment faire des tâches techniques. Très peu montrent comment approcher la **qualité professionnelle** — ce niveau où un livrable résiste à la comparaison avec ce que font les professionnels du secteur.

Ce gap existe particulièrement dans deux domaines souvent ignorés :
1. **Le branding et la stratégie de marque** — absents de pratiquement tous les starter kits
2. **L'ancrage dans les standards professionnels** — remplacé par des opinions non-sourcées

Ce kit est la réponse à ce gap. Il couvre l'intégralité du cycle de vie d'un projet : du brief stratégique (BRAND-STRATEGY, PROJECT-SCOPING) à la livraison client (CLIENT-HANDOFF), en passant par chaque domaine technique.

La méthode de construction du kit est elle-même le kit :
1. Identifier un gap
2. Chercher ce que les professionnels font (Tier 1-4)
3. Synthétiser en règles actionnables avec sources
4. Implémenter et mesurer

---

## Conversion PDF (pour partage humain)

Ce document et GUIDE-DECOUVERTE.md sont conçus pour être lisibles en markdown et convertibles en PDF propre.

```bash
# Option 1 : md-to-pdf (recommandé, npm)
npx md-to-pdf GUIDE-DECOUVERTE.md

# Option 2 : pandoc (universel)
pandoc GUIDE-DECOUVERTE.md -o GUIDE-DECOUVERTE.pdf \
  --pdf-engine=wkhtmltopdf \
  --variable margin-top=20mm \
  --variable margin-bottom=20mm

# Option 3 : VSCode + extension "Markdown PDF"
# Cmd+Shift+P → "Markdown PDF: Export (pdf)"
```
