# SQWR Project Kit — Guide de Découverte

> **Pour qui ?** Les humains qui veulent comprendre ce qu'ils importent, pourquoi ça existe, et comment le développer.
> **Format :** Conçu pour être lu en markdown ou exporté en PDF (voir METHODOLOGY.md pour la commande de conversion).

---

## Ce qu'est ce kit — en une phrase

Un système de standards professionnels, ancré dans des recherches académiques et industrielles réelles, qui permet à une personne seule avec Claude Code de produire des livrables au niveau des équipes d'experts.

---

## Pourquoi ça existe

La réussite d'un projet digital — qu'il soit une app SaaS, un site web, ou une identité de marque — ne dépend pas seulement de l'exécution technique. Elle dépend de la connaissance de standards qui existent déjà dans chaque domaine.

Ces standards sont documentés. Ils sont publics. Ils sont accessibles.

**Le problème :** ils sont fragmentés sur des dizaines de sources, difficiles à synthétiser, et personne ne vous dit qu'ils existent ou qu'il faut les chercher.

**La solution :** un kit qui rassemble ces standards, les structure en règles actionnables, et les livre avec les sources pour que chaque règle soit vérifiable — pas une opinion de plus.

La méthode qui a produit ce kit est elle-même documentée dans `METHODOLOGY.md`. Elle tient en 5 mots : **chercher d'abord, implémenter ensuite.**

---

## Ce que vous trouverez dans ce kit

### 26 Contrats — Les règles à suivre pendant la construction

Les contrats sont des fichiers markdown que vous copiez dans votre projet (ou que vous référencez dans votre `CLAUDE.md`). Chaque contrat couvre un domaine et définit les règles avec thresholds mesurables et sources citées.

| Contrat | Domaine | Standard principal |
|---------|---------|-------------------|
| `CONTRACT-NEXTJS.md` | App Router, SSR, CWV | Google Core Web Vitals |
| `CONTRACT-SUPABASE.md` | Base de données, auth, RLS | NIST SP 800-63B |
| `CONTRACT-VERCEL.md` | Déploiement, rollback, canary | Vercel docs + Martin Fowler |
| `CONTRACT-DESIGN.md` | Gestalt, typographie, couleur | Itten, Bringhurst, WCAG 2.1 |
| `CONTRACT-TYPESCRIPT.md` | TypeScript strict, SOLID | Robert C. Martin |
| `CONTRACT-TESTING.md` | Pyramide de tests, coverage | Martin Fowler, Agile Alliance |
| `CONTRACT-SECURITY.md` | OWASP Top 10, RGPD, XSS | OWASP, NIST, CWE Top 25 |
| `CONTRACT-PERFORMANCE.md` | LCP, INP, CLS, Lighthouse | Google, DebugBear |
| `CONTRACT-ACCESSIBILITY.md` | WCAG 2.1 AA + ARIA patterns | W3C, Nielsen NN/G, WAI-ARIA APG |
| `CONTRACT-ANTI-HALLUCINATION.md` | Données réelles, RAG | Nature 2025, OpenAI |
| `CONTRACT-AI-PROMPTING.md` | System prompts, few-shot | Anthropic, Lakera |
| `CONTRACT-OBSERVABILITY.md` | Logging, Sentry, RUM | Google SRE Book |
| `CONTRACT-RESILIENCE.md` | Retry, circuit breaker | AWS Well-Architected |
| `CONTRACT-GREEN-SOFTWARE.md` | Impact carbone, SCI | ISO/IEC 21031:2024 |
| `CONTRACT-PYTHON.md` | PEP 8, mypy, FastAPI | PEP standards, Python.org |
| `CONTRACT-IOS.md` | SwiftUI, touch targets, Dark Mode | Apple HIG, WCAG 2.5.5 |
| `CONTRACT-PDF-GENERATION.md` | Puppeteer, react-pdf, CSS Paged Media | W3C CSS Paged Media, pptr.dev |
| `CONTRACT-SEO.md` | SSR, metadata, JSON-LD, Core Web Vitals | Google Search Central, schema.org |
| `CONTRACT-EMAIL.md` | SPF/DKIM/DMARC, React Email, deliverabilité | RFC 7489, Google Sender Guidelines 2024 |
| `CONTRACT-CICD.md` | GitHub Actions, DORA metrics, branches | DORA Research 2023, semver.org |
| `CONTRACT-ANALYTICS.md` | HEART, AARRR, GA4, PostHog, event taxonomy | Google CHI 2010, Dave McClure 2007 |
| `CONTRACT-I18N.md` | next-intl, ICU, hreflang, RTL, Intl API | Unicode CLDR, W3C i18n |
| `CONTRACT-PRICING.md` | Van Westendorp, EVC, SaaS métriques, tiers | ESOMAR 1976, ProfitWell, SaaStr |
| `CONTRACT-ANDROID.md` | Jetpack Compose, Material 3, TalkBack, Vitals | Android Developers, m3.material.io |
| `CONTRACT-MOTION-DESIGN.md` | Animation UI, Remotion, easing, prefers-reduced-motion | Material Design 3, Apple HIG, W3C WCAG 2.3 |
| `CONTRACT-VIDEO-PRODUCTION.md` | Pipeline vidéo, export plateforme, ElevenLabs, studio IA | Instagram/TikTok/YouTube specs, NN/G |

### 13 Frameworks — Les outils situationnels

Les frameworks ne sont pas des règles permanentes — ce sont des outils à sortir au bon moment.

| Framework | Quand l'utiliser |
|-----------|----------------|
| `BRAND-STRATEGY.md` | **Avant tout design visuel** — positionnement, archétypes, narrative |
| `PROJECT-SCOPING.md` | Avant de commencer — Shape Up Pitch + Pre-mortem + Risk Register |
| `ESTIMATION.md` | Avant tout engagement de délai — PERT + règle ×1.5 solo+IA |
| `CLIENT-HANDOFF.md` | Livraison finale — accès, documentation, SLA |
| `INCIDENT-RESPONSE.md` | En cas d'incident de production |
| `ADR-TEMPLATE.md` | Pour toute décision architecturale importante |
| `SLO-TEMPLATE.md` | Pour définir les objectifs de fiabilité |
| `COMPLIANCE-EU.md` | Projets livrés à des clients européens |
| `DEPENDENCY-MANAGEMENT.md` | Setup + maintenance mensuelle des dépendances |
| `COMPETITIVE-AUDIT.md` | **Avant tout lancement** — Blue Ocean, Nielsen Heuristics, Mystery Shopper |
| `CAMPAIGN-STRATEGY.md` | Lancement campagne — SEE-THINK-DO-CARE, funnel, KPIs |
| `UX-RESEARCH.md` | **Avant toute feature** — JTBD, entretiens, test utilisabilité |
| `SOCIAL-CONTENT.md` | Lancement présence social — piliers, calendrier, tone, créateurs |

### 11 Audits — Les outils de mesure

Les audits permettent de scorer /100 chaque domaine à n'importe quel moment du projet.

| Audit | Poids | Seuil bloquant |
|-------|-------|---------------|
| Sécurité | 22% | < 70 = bloquant |
| Performance | 18% | < 70 recommandé |
| Qualité Code | 18% | < 75 recommandé |
| Observabilité | 12% | < 70 recommandé |
| Accessibilité | 12% | < 80 recommandé (+ légal EU) |
| Design | 8% | < 70 recommandé |
| Gouvernance IA | 5% | < 80 recommandé |
| Déploiement | 5% | Gate pré-production |
| RGPD | — | ≥80/100 avant prod grand public |
| Stratégie de Marque | — | Avant lancement ou repositionnement |

**Score moyen sans ce kit : ~51/100**
**Score cible avec ce kit : ≥85/100**

### 5 Templates — Les fichiers à copier dans chaque projet

```
CLAUDE.md          → Contrat IA universel (le plus important)
.env.example       → Variables d'environnement documentées
.gitignore         → Multi-stack (Node, Next, Python, macOS)
CHANGELOG.md       → Keep a Changelog 1.1.0 + SemVer 2.0.0
CONTRIBUTING.md    → Conventional Commits + règles IA
```

### 3 Scripts — L'automatisation

```bash
# Bootstrap complet d'un nouveau projet
bash scripts/init-project.sh --name "mon-projet" --stack "nextjs-supabase" --path "~/Desktop/mon-projet"

# Vérifier l'intégrité du kit lui-même
bash scripts/verify-kit.sh --verbose

# Valider qu'un CLAUDE.md de projet est complet
bash scripts/validate-claude-md.sh ~/mon-projet/CLAUDE.md
```

---

## Le tour en 10 minutes

### Minute 1-2 : Comprendre la philosophie

Lire `METHODOLOGY.md` — les 3 premières sections. C'est le "pourquoi" de tout le reste.

### Minute 3-4 : Bootstrapper un projet test

```bash
bash scripts/init-project.sh \
  --name "test-kit" \
  --stack "nextjs-supabase" \
  --path "/tmp/test-kit"
```

Observer ce qui est généré : CLAUDE.md pré-rempli, contrats copiés, CHANGELOG initialisé avec la date du jour, CONTRIBUTING.md avec le nom du projet.

### Minute 5-6 : Lire un contrat

Ouvrir `contracts/CONTRACT-SECURITY.md`. Observer la structure :
- Chaque règle a un threshold chiffré (pas "bon contraste" mais "≥4.5:1")
- Chaque section cite sa source (OWASP, NIST, W3C)
- Les commandes de vérification sont incluses

C'est ça la différence entre "avoir des bonnes pratiques" et "connaître les standards professionnels".

### Minute 7-8 : Lancer un audit

Ouvrir `audits/AUDIT-INDEX.md`. Suivre le séquençage. Lancer `AUDIT-SECURITY.md` sur n'importe quel projet existant.

### Minute 9-10 : Explorer les frameworks

Ouvrir `frameworks/BRAND-STRATEGY.md`. Même si vous ne faites que du code, comprendre la section sur le Cercle d'Or (Simon Sinek) change la façon dont vous écrivez les README, les landing pages, et les briefs clients.

---

## La discipline de la marque

> Cette section est la contribution la plus rare du kit — absente de pratiquement tous les starter kits techniques.

**La réussite d'une app ou d'une agence ne dépend pas seulement de l'infrastructure.** Elle dépend de la réponse à des questions que la plupart des développeurs ne se posent pas :

- **Pourquoi** est-ce que ce produit existe, au-delà de la fonctionnalité ?
- **Pour qui** exactement — et quel désir profond adressons-nous ?
- **Comment** se différencie-t-il de façon crédible et mémorable ?
- **Quelle histoire** faisons-nous vivre à l'utilisateur ?

Ces questions ont des réponses scientifiques. Simon Sinek a formalisé le WHY (60M+ vues TED). Carl Jung a fourni les archétypes psychologiques universels. Donald Miller a structuré la narrative. Al Ries et Jack Trout ont théorisé le positionnement mental.

**La marque la plus solide n'est pas la plus belle — c'est celle qui répond le mieux à ces questions.**

`frameworks/BRAND-STRATEGY.md` contient les outils pour répondre à ces questions avant de commencer le design visuel.

---

## Comment développer ce kit

Ce kit est une base, pas un produit fini. Il est fait pour grandir avec chaque projet.

### Principes de contribution

**1. Ancrage obligatoire**
Toute nouvelle règle doit avoir une source vérifiable (Tier 1 = officielle, Tier 2 = académique). "C'est une bonne pratique" sans source n'a pas sa place.

**2. Threshold chiffré**
"Performance correcte" n'est pas une règle. "LCP ≤2.5s (75e percentile, Google CWV)" est une règle.

**3. Structure cohérente**
Suivre le format des contrats existants : introduction → sections numérotées → sous-total → score → sources.

**4. Open/Closed**
Ouvert à l'extension (nouveaux contrats), fermé à la modification non-sourcée (pas de suppression de sources sans remplacement).

### Domaines non couverts — opportunités d'extension

| Domaine | Priorité | Sources à explorer |
|---------|---------|-------------------|
| Android | P2 | Material Design 3, Android Accessibility avancée (Compose) |
| Internationalisation (i18n) | P2 | Next.js i18n docs, Unicode CLDR, ICU Message Format |
| Pricing & monétisation | P2 | Van Westendorp, Price Intelligently, value-based pricing |
| Recherche utilisateur (UX) | P2 | JTBD (Christensen), Nielsen usability testing, Baymard Institute |
| Android | P3 | Material Design 3, Android Accessibility (WCAG) |

---

## À propos du kit

Ce kit a été développé par **[Samuel Baudon](https://sqwr.be)** ([SQWR Studio](https://sqwr.be), Bruxelles) à partir de 2024, et affiné sur des dizaines de projets réels — sites web, applications SaaS, projets académiques, identités de marque.

Il est la méthode publique de SQWR Studio — le studio qui l'a créé, le maintient, et l'applique comme baseline de livraison sur chaque projet.

Il reflète une conviction : **les outils d'IA comme Claude Code ne sont pas des raccourcis vers la médiocrité — ils sont des amplificateurs de rigueur pour ceux qui ont la méthode.**

La méthode, c'est ce kit.

---

## Vous voulez ce niveau de qualité sans vous en occuper ?

**Ce que SQWR Studio propose :**
- **Audit de projet** — scorer votre codebase existant selon les standards du kit (/100 par domaine, rapport PDF)
- **Setup du kit** — intégrer le kit dans votre stack et former votre équipe
- **Livraison de projet** — développement Next.js / Supabase / iOS au niveau des standards décrits ici

> Un score ≥85/100 n'est pas un objectif — c'est notre baseline de livraison.

**Contact :** [studio@sqwr.be](mailto:studio@sqwr.be) · [sqwr.be](https://sqwr.be)

---

## Licence & Partage

Ce kit est libre d'utilisation, de modification et de distribution.
Si vous l'améliorez, le partage des améliorations fait avancer tout le monde.

**Attribution appréciée mais non requise :**
> Basé sur [Claude Code Standards Kit](https://github.com/samsam007b/claude-code-standards-kit) — [SQWR Studio](https://sqwr.be)

---

## Ressources pour aller plus loin

**Sur Claude Code :**
- `METHODOLOGY.md` — La méthode de travail complète
- Anthropic docs : docs.anthropic.com
- Claude Code changelog : github.com/anthropics/claude-code

**Sur les standards :**
- OWASP : owasp.org
- WCAG 2.1 : w3.org/WAI/WCAG21
- Google SRE Book : sre.google/sre-book
- Nielsen Norman Group : nngroup.com

**Sur la stratégie de marque :**
- Simon Sinek, *Start With Why* (2009)
- Donald Miller, *Building a StoryBrand* (2017)
- Marty Neumeier, *The Brand Gap* (2005)

**Sur l'estimation & la gestion de projet :**
- Ryan Singer, *Shape Up* (basecamp.com/shapeup) — gratuit en ligne
- Daniel Kahneman, *Thinking, Fast and Slow* (2011) — biais de planification
