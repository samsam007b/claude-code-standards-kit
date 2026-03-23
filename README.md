<div align="center">

# Claude Code Standards Kit

**Standards professionnels pour Claude Code — ancrés dans la science, pas dans les opinions.**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![64 fichiers](https://img.shields.io/badge/64%20fichiers-organisés-green.svg)]()
[![Self-audit](https://img.shields.io/badge/self--audit-91%2F100-brightgreen.svg)]()
[![Made for Claude Code](https://img.shields.io/badge/made%20for-Claude%20Code-orange.svg)]()
[![By SQWR Studio](https://img.shields.io/badge/by-SQWR%20Studio-black.svg)](https://sqwr.be)

<sub>Conçu et maintenu par <a href="https://sqwr.be"><strong>SQWR Studio</strong></a> — Branding & Web · <a href="https://sqwr.be">sqwr.be</a> · <a href="mailto:studio@sqwr.be">studio@sqwr.be</a></sub>

</div>

---

Un développeur solo avec Claude Code peut écrire du code. Mais ce code respecte-t-il OWASP ? WCAG 2.1 ? Les Core Web Vitals ? Les standards AWS Well-Architected ?

**La plupart du temps : non.** Pas par manque de talent — par manque de méthode.

```
Sans ce kit   ████████████░░░░░░░░  ~51/100
Avec ce kit   █████████████████░░░  ≥85/100
```

> **La qualité professionnelle n'est pas dans le code — elle est dans la recherche qui précède le code.**

---

## Quick start

```bash
# 1. Cloner le kit
git clone https://github.com/sqwr/project-kit ~/Desktop/Project-Kit

# 2. Bootstrapper un nouveau projet
bash ~/Desktop/Project-Kit/scripts/init-project.sh \
  --name "mon-projet" --stack "nextjs-supabase" --path "~/Desktop/mon-projet"

# 3. Vérifier l'intégrité du kit
bash ~/Desktop/Project-Kit/scripts/verify-kit.sh --verbose
```

**Stacks disponibles :** `nextjs-supabase` · `nextjs` · `nextjs-supabase-ai` · `python`

---

## Comment ça marche

```
  RECHERCHE  →  CONTRAT  →  CODE  →  AUDIT

  "Quels sont    Règles +     Claude Code   Score /100
  les standards  thresholds   suit le       par domaine
  pro sur ce     + sources    contrat       (≥85 cible)
  sujet ?"       citées
```

Claude Code ne part pas d'opinions. Il cherche les standards existants, les synthétise en règles actionnables, puis les applique. Ce kit structure ce workflow sur 15 domaines.

Lire [`METHODOLOGY.md`](METHODOLOGY.md) pour la méthode complète.

---

## Ce qui est inclus

| Catégorie | Fichiers | Rôle |
|-----------|---------|------|
| **Contrats** | 24 | Règles métier avec thresholds chiffrés — à copier dans `CLAUDE.md` |
| **Frameworks** | 12 | Outils situationnels (branding, estimation, incident, campagne...) |
| **Audits** | 11 | Scoring /100 par domaine — à lancer avant chaque livraison |
| **Templates** | 5 | `CLAUDE.md`, `.env.example`, `.gitignore`, `CHANGELOG.md`, `CONTRIBUTING.md` |
| **Scripts** | 3 | `init-project.sh`, `verify-kit.sh`, `validate-claude-md.sh` |

---

## Les 15 contrats

> Chaque règle a un threshold chiffré. Chaque threshold a une source vérifiable.

| Contrat | Domaine | Standard |
|---------|---------|----------|
| [`CONTRACT-NEXTJS.md`](contracts/CONTRACT-NEXTJS.md) | App Router, SSR, CWV | Google Core Web Vitals |
| [`CONTRACT-SUPABASE.md`](contracts/CONTRACT-SUPABASE.md) | Base de données, RLS, auth | NIST SP 800-63B |
| [`CONTRACT-VERCEL.md`](contracts/CONTRACT-VERCEL.md) | Déploiement, rollback, canary | Vercel docs + Martin Fowler |
| [`CONTRACT-DESIGN.md`](contracts/CONTRACT-DESIGN.md) | Gestalt, typographie, couleur | Itten, Bringhurst, WCAG 2.1 |
| [`CONTRACT-TYPESCRIPT.md`](contracts/CONTRACT-TYPESCRIPT.md) | TypeScript strict, SOLID | Robert C. Martin |
| [`CONTRACT-TESTING.md`](contracts/CONTRACT-TESTING.md) | Pyramide de tests, coverage | Martin Fowler, Agile Alliance |
| [`CONTRACT-SECURITY.md`](contracts/CONTRACT-SECURITY.md) | OWASP Top 10, secrets, XSS | OWASP, NIST, CWE Top 25 |
| [`CONTRACT-PERFORMANCE.md`](contracts/CONTRACT-PERFORMANCE.md) | LCP, INP, CLS, Lighthouse | Google, DebugBear |
| [`CONTRACT-ACCESSIBILITY.md`](contracts/CONTRACT-ACCESSIBILITY.md) | WCAG 2.1 AA + EAA (loi EU) | W3C, Nielsen NN/G |
| [`CONTRACT-ANTI-HALLUCINATION.md`](contracts/CONTRACT-ANTI-HALLUCINATION.md) | Données réelles, RAG, context poisoning | Nature 2025, OpenAI |
| [`CONTRACT-AI-PROMPTING.md`](contracts/CONTRACT-AI-PROMPTING.md) | System prompts, few-shot, modèles | Anthropic, Lakera |
| [`CONTRACT-OBSERVABILITY.md`](contracts/CONTRACT-OBSERVABILITY.md) | Logging structuré, Sentry, RUM | Google SRE Book |
| [`CONTRACT-RESILIENCE.md`](contracts/CONTRACT-RESILIENCE.md) | Retry, circuit breaker, graceful degradation | AWS Well-Architected |
| [`CONTRACT-GREEN-SOFTWARE.md`](contracts/CONTRACT-GREEN-SOFTWARE.md) | Impact carbone, SCI | ISO/IEC 21031:2024 |
| [`CONTRACT-PYTHON.md`](contracts/CONTRACT-PYTHON.md) | PEP 8, mypy, FastAPI, packaging | PEP standards, Python.org |
| [`CONTRACT-IOS.md`](contracts/CONTRACT-IOS.md) | SwiftUI, touch targets, Dark Mode | Apple HIG, WCAG 2.5.5 |
| [`CONTRACT-PDF-GENERATION.md`](contracts/CONTRACT-PDF-GENERATION.md) | Puppeteer, react-pdf, CSS Paged Media | W3C CSS Paged Media, pptr.dev |
| [`CONTRACT-SEO.md`](contracts/CONTRACT-SEO.md) | SSR, metadata, JSON-LD, Core Web Vitals | Google Search Central, schema.org |
| [`CONTRACT-EMAIL.md`](contracts/CONTRACT-EMAIL.md) | SPF/DKIM/DMARC, React Email, deliverabilité | RFC 7489, Google Sender Guidelines 2024 |
| [`CONTRACT-CICD.md`](contracts/CONTRACT-CICD.md) | GitHub Actions, DORA, branches, Conventional Commits | DORA Research, semver.org |
| [`CONTRACT-ANALYTICS.md`](contracts/CONTRACT-ANALYTICS.md) | HEART, AARRR, GA4, PostHog, event taxonomy | Google CHI 2010, Dave McClure 2007 |
| [`CONTRACT-I18N.md`](contracts/CONTRACT-I18N.md) | next-intl, ICU, hreflang, RTL, Intl API | Unicode CLDR, W3C i18n |
| [`CONTRACT-PRICING.md`](contracts/CONTRACT-PRICING.md) | Van Westendorp, EVC, SaaS métriques, tiers | ESOMAR 1976, ProfitWell, SaaStr |
| [`CONTRACT-ANDROID.md`](contracts/CONTRACT-ANDROID.md) | Jetpack Compose, Material 3, TalkBack, Vitals | Android Developers, m3.material.io |

---

## Le système d'audit

Scorer /100 avant chaque livraison. **Seuil de livraison : ≥85/100 global.**

| Audit | Poids | Blocage |
|-------|-------|---------|
| [`AUDIT-SECURITY.md`](audits/AUDIT-SECURITY.md) | 22% | < 70 = bloquant |
| [`AUDIT-PERFORMANCE.md`](audits/AUDIT-PERFORMANCE.md) | 18% | < 70 recommandé |
| [`AUDIT-CODE-QUALITY.md`](audits/AUDIT-CODE-QUALITY.md) | 18% | < 75 recommandé |
| [`AUDIT-OBSERVABILITY.md`](audits/AUDIT-OBSERVABILITY.md) | 12% | < 70 recommandé |
| [`AUDIT-ACCESSIBILITY.md`](audits/AUDIT-ACCESSIBILITY.md) | 12% | < 80 + légal EU |
| [`AUDIT-DESIGN.md`](audits/AUDIT-DESIGN.md) | 8% | < 70 recommandé |
| [`AUDIT-AI-GOVERNANCE.md`](audits/AUDIT-AI-GOVERNANCE.md) | 5% | < 80 recommandé |
| [`AUDIT-DEPLOYMENT.md`](audits/AUDIT-DEPLOYMENT.md) | 5% | Gate pré-production |
| [`AUDIT-RGPD.md`](audits/AUDIT-RGPD.md) | — | ≥80/100 avant prod grand public |
| [`AUDIT-BRAND-STRATEGY.md`](audits/AUDIT-BRAND-STRATEGY.md) | — | Avant lancement ou repositionnement |

Voir [`audits/AUDIT-INDEX.md`](audits/AUDIT-INDEX.md) pour le séquençage.

---

## Pourquoi ce kit ?

**Ce qui le différencie de tous les autres starter kits :**

**1. Thresholds chiffrés, pas d'opinions**
`"LCP ≤2.5s (p75)"` — pas `"bonne performance"`. Chaque règle est mesurable.

**2. Sources Tier 1/2 obligatoires**
OWASP, WCAG, Google SRE, NIST, Nielsen NN/G, W3C. Pas de "il est recommandé de".

**3. Stratégie de marque incluse**
[`frameworks/BRAND-STRATEGY.md`](frameworks/BRAND-STRATEGY.md) couvre Sinek, Jung, StoryBrand, Blue Ocean. **Absent de 99% des starter kits techniques.**

**4. Conformité légale EU intégrée**
EAA (active depuis juin 2025), EU AI Act, RGPD. Voir [`frameworks/COMPLIANCE-EU.md`](frameworks/COMPLIANCE-EU.md).

**5. Le kit s'applique à lui-même**
Auto-audit : **91/100**. `bash scripts/verify-kit.sh --verbose` → 0 erreur.

---

## Frameworks situationnels

| Framework | Sortir quand |
|-----------|-------------|
| [`BRAND-STRATEGY.md`](frameworks/BRAND-STRATEGY.md) | **Avant tout design visuel** — Golden Circle, archétypes, narrative |
| [`PROJECT-SCOPING.md`](frameworks/PROJECT-SCOPING.md) | Avant de commencer — Shape Up Pitch + Pre-mortem |
| [`ESTIMATION.md`](frameworks/ESTIMATION.md) | Avant tout engagement de délai — PERT + règle ×1.5 |
| [`CLIENT-HANDOFF.md`](frameworks/CLIENT-HANDOFF.md) | Livraison finale — accès, docs, SLA |
| [`INCIDENT-RESPONSE.md`](frameworks/INCIDENT-RESPONSE.md) | Service en panne — postmortem blameless |
| [`ADR-TEMPLATE.md`](frameworks/ADR-TEMPLATE.md) | Nouvelle décision architecturale |
| [`SLO-TEMPLATE.md`](frameworks/SLO-TEMPLATE.md) | Définir les objectifs de fiabilité |
| [`COMPLIANCE-EU.md`](frameworks/COMPLIANCE-EU.md) | Projet livré à des clients européens |
| [`DEPENDENCY-MANAGEMENT.md`](frameworks/DEPENDENCY-MANAGEMENT.md) | Setup + maintenance mensuelle des dépendances |
| [`COMPETITIVE-AUDIT.md`](frameworks/COMPETITIVE-AUDIT.md) | **Avant tout lancement** — Blue Ocean, Nielsen Heuristics, Mystery Shopper |
| [`CAMPAIGN-STRATEGY.md`](frameworks/CAMPAIGN-STRATEGY.md) | Lancement campagne — SEE-THINK-DO-CARE, funnel, KPIs |
| [`UX-RESEARCH.md`](frameworks/UX-RESEARCH.md) | **Avant toute feature** — JTBD, entretiens, test utilisabilité (Nielsen, Fitzpatrick) |

---

## Sources intégrées (extrait)

| Domaine | Sources |
|---------|--------|
| Sécurité | OWASP Top 10, NIST SP 800-63B, CWE Top 25 |
| Performance | Google Core Web Vitals, DebugBear |
| Accessibilité | WCAG 2.1 W3C, EN 301 549, Nielsen Norman Group |
| Design | Gestalt (1920), Bringhurst (1992), Baymard Institute |
| Tests | Martin Fowler pyramid, Agile Alliance DoD |
| Fiabilité | Google SRE Book, AWS Well-Architected |
| Résilience | Michael Nygard (Release It! 2018) |
| Green IT | ISO/IEC 21031:2024 (SCI) |
| Brand | Sinek (2009), Jung/Mark & Pearson (2001), Donald Miller (2017) |
| Estimation | PERT (1957), Kahneman & Tversky (Nobel 2002) |
| AI / LLM | Anthropic docs, Lakera, Nature 2025 |
| Légal EU | Règlement UE 2024/1689, EAA, ENISA NIS2 |

---

## Structure complète

```
project-kit/
├── IDENTITY-TEMPLATE.md    → Fiche identité à personnaliser
├── METHODOLOGY.md          → Méthode complète (lire en premier)
├── GUIDE-DECOUVERTE.md     → Tour du kit en 10 min, PDF-ready
├── contracts/              → 24 contrats (thresholds + sources)
├── frameworks/             → 12 outils situationnels
├── audits/                 → 11 audits scoring /100
├── templates/              → CLAUDE.md, .env.example, .gitignore...
└── scripts/                → init-project.sh, verify-kit.sh, validate-claude-md.sh
```

---

## Contribuer

Voir [`CONTRIBUTING.md`](CONTRIBUTING.md).

**Règle d'or :** toute nouvelle règle = source Tier 1 (docs officielles) ou Tier 2 (académique/industriel). Pas d'opinions sans source. Threshold chiffré obligatoire.

---

## Vous voulez ce niveau de qualité sans vous en occuper ?

Ce kit est la méthode publique de **[SQWR Studio](https://sqwr.be)** — le studio qui l'a créé, affiné sur des dizaines de projets réels, et l'applique à chaque livraison.

**Ce que SQWR Studio propose :**
- **Audit de projet** — scorer votre codebase existant selon les standards du kit (/100 par domaine, rapport PDF)
- **Setup du kit** — intégrer le kit dans votre stack et former votre équipe
- **Livraison de projet** — développement Next.js / Supabase / iOS au niveau des standards décrits ici

> Un score ≥85/100 n'est pas un objectif — c'est notre baseline de livraison.

**Contact :** [studio@sqwr.be](mailto:studio@sqwr.be) · [sqwr.be](https://sqwr.be)

---

## Licence

MIT — libre d'utilisation, modification, distribution.

---

<div align="center">
<sub>
<a href="METHODOLOGY.md">Méthodologie</a> · <a href="GUIDE-DECOUVERTE.md">Tour en 10 min</a> · <a href="audits/AUDIT-INDEX.md">Lancer un audit</a> · <a href="https://sqwr.be">SQWR Studio</a> · <a href="mailto:studio@sqwr.be">studio@sqwr.be</a>
</sub>
</div>
