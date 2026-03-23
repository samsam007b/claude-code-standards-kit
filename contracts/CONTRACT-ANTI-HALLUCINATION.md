# Contrat — Zéro Hallucination & Gouvernance IA

> Module de contrat SQWR Project Kit — enrichi avec recherche scientifique.
> Sources : Nature (2025), OpenAI Research (2025), PMC/NIH (2025), Springer Nature, Lakera.
> Inspiré du CLAUDE.md CozyGrowth (15 mars 2026).

---

## Fondements scientifiques

**Pourquoi les LLMs hallucinent** (OpenAI Research, 2025) : les modèles de langage sont entraînés à optimiser la plausibilité textuelle, pas la vérité factuelle. L'évaluation traditionnelle pénalise l'incertitude et récompense la confiance — même erronée. Résultat : le modèle préfère inventer une réponse confiante plutôt qu'admettre qu'il ne sait pas.

**Réduction mesurable :** les techniques RAG (Retrieval-Augmented Generation) réduisent les hallucinations de **15-82%** selon la combinaison de techniques (PMC/NIH, 2025).

> Source : *"AI hallucinations can't be stopped — but these techniques can limit their damage"* — Nature, 2025

---

## 1. Règle absolue — Zéro hallucination sur données réelles

**Une donnée incorrecte dans ce projet = problème réel pour un client ou un utilisateur réel.**

Ce contrat s'applique à tout projet contenant des données factuelles : prix, contacts, horaires, URLs, statistiques, noms propres, adresses.

---

## 2. Ce que l'IA ne doit JAMAIS faire

- **Inventer des chiffres** : prix, stats, capacités, années, horaires
- **Compléter des données manquantes** par "logique métier" ou approximation
- **Écrire des URLs, emails, numéros de téléphone** sans source vérifiée
- **Ajouter des informations "plausibles"** sans confirmation explicite
- **Inférer d'un contexte similaire** ("ce club ressemble à l'autre, donc...")
- **Réutiliser des données d'une session précédente** sans vérification fraîche

---

## 3. Ce que l'IA doit TOUJOURS faire

- Information manquante → écrire `[À CONFIRMER]` et signaler
- Chiffre d'origine inconnue → demander la source avant d'écrire
- Avant tout ajout de donnée → identifier la source explicitement
- Si <100% certain → poser la question, ne pas deviner
- **Confidence scoring** : ne pas traiter tous les outputs pareil — distinguer les affirmations vérifiées des hypothèses

---

## 4. Sources valides

1. **Screenshots ou texte fourni directement** dans la conversation
2. **Contenu scrappé en direct** depuis la source officielle (`WebFetch`)
3. **Confirmation orale explicite** de Samuel dans la conversation en cours

## Sources NON valides

- Ce qui "semble logique" pour ce type de projet
- Données vues dans une session précédente (hors mémoire persistante explicite)
- Chiffres interpolés ou extrapolés depuis des cas similaires
- Informations générées sans source identifiée

---

## 5. Format pour les données manquantes

```markdown
Tarif mensuel : [À CONFIRMER — source requise]
Email contact : [À CONFIRMER — non vérifié]
Capacité : [À CONFIRMER — donnée non disponible dans les sources fournies]
Statistique : [À CONFIRMER — aucune source trouvée pour ce chiffre]
```

---

## 6. Optimisation du context window (recherche LLM 2025)

> Source : LLM Context Management Guide — eval.16x.engineer, Redis Blog, GetMaxim

**Le remplissage maximal du contexte dégrade les performances.**

| Utilisation context window | Résultat |
|---------------------------|---------|
| 40-60% | Performance optimale |
| 60-80% | Début de dégradation |
| >80% | Dégradation significative prouvée |

**Règles d'optimisation :**

- **Nouvelles sessions pour nouvelles tâches** — ne pas contaminer le contexte avec des tâches précédentes
- **RAG plutôt que context exhaustif** — récupérer uniquement les sections pertinentes
- **Few-shot limité** : 2-5 exemples curatés (au-delà = diminishing returns prouvé)
- **Smart context selection** : charger uniquement les contrats pertinents au projet en cours

---

## 7. Techniques de réduction d'hallucinations recommandées

> Source : PMC/NIH (2025), Springer Nature — Hierarchical Semantic Piece method

| Technique | Réduction hallucination | Quand l'utiliser |
|-----------|------------------------|-----------------|
| **RAG** (Retrieval-Augmented Generation) | 15-50% | Toujours sur données externes |
| **Chain-of-thought prompting** | +25% accuracy | Tâches complexes multi-étapes |
| **Verification step** | Variable | Données critiques (prix, contacts) |
| **Confidence scoring** | 20-40% | Distinguer affirmations certaines/hypothèses |
| **HSP method** | 20-50% | Extraction multi-granularité (phrase + entité) |

---

## 8. Structure d'un system prompt fiable (Anthropic + Lakera)

```
[RÔLE] Tu es [rôle spécifique] pour [contexte précis].

[CONTRAINTES] Tu ne dois jamais :
- [liste explicite des interdictions]

[FORMAT] Tes réponses doivent :
- [format attendu]

[EXEMPLES] Voici 2-3 exemples de réponses attendues :
- [exemples curatés]

[DONNÉES DISPONIBLES]
{contexte_rag_injecté}
```

---

## 9. Risques IA avancés (2025-2026)

> Sources : Anthropic Research, CSA 2025, OWASP LLM03:2025, OpenAI pricing history.

### Context Poisoning / RAG Poisoning

**Anthropic Research et CSA 2025 : 5 documents soigneusement craftés suffisent à manipuler les outputs IA 90% du temps** dans un système RAG. Un attaquant ou même un contenu client mal formaté peut contaminer toutes les réponses du système.

**Pour CozyGrowth (KBs RAG avec données clients) :**
- Valider chaque document avant insertion en KB (voir CONTRACT-SECURITY.md section 10)
- Isoler les KBs par espace/client — jamais de contamination cross-client
- Auditer régulièrement les KBs avec `/verify-kb` pour détecter des patterns anormaux
- Les sources de données clients sont de confiance limitée — les traiter comme des inputs externes

### Provider Lock-In & Stratégie de Fallback

**OpenAI a déprécié GPT-3.5 sans préavis suffisant en 2024.** Anthropic peut modifier ses prix ou ses capacités. Tout projet qui dépend d'un seul fournisseur LLM sans fallback est fragile.

**Pattern d'abstraction recommandé :**

```typescript
// lib/ai/client.ts — abstraction layer multi-provider
const AI_PROVIDERS = {
  primary: 'anthropic',     // Claude (qualité)
  fallback: 'openrouter',   // OpenRouter (resilience)
} as const

async function callAI(prompt: string, options: AIOptions = {}): Promise<string> {
  try {
    return await callAnthropic(prompt, options)
  } catch (err) {
    // Fallback automatique si provider primaire indisponible
    console.warn('Anthropic unavailable, falling back to OpenRouter', err)
    return await callOpenRouter(prompt, options)
  }
}
```

**Via OpenRouter (recommandé pour les projets clients) :**
```typescript
// OpenRouter permet de changer de modèle sans changer de code
const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
  headers: { Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}` },
  body: JSON.stringify({
    model: process.env.AI_MODEL ?? 'anthropic/claude-sonnet-4-5',  // configurable via env
    messages: [{ role: 'user', content: prompt }],
  }),
})
```

### Denial of Wallet — Limits & Alertes Coût

**Un prompt malveillant ou une boucle infinie peut générer des milliers d'appels LLM en quelques minutes**, explosant les coûts. Sans hard limits, c'est un vecteur d'attaque financier.

```typescript
// Hard limits par appel LLM
const LLM_LIMITS = {
  maxInputTokens: 10_000,    // ~7500 mots input max
  maxOutputTokens: 4_000,    // ~3000 mots output max
  maxRequestsPerUser: 50,    // par heure
  maxRequestsPerSession: 20, // par session
} as const

// Vérification avant chaque appel
function validateLLMRequest(input: string, userId: string) {
  const tokenEstimate = Math.ceil(input.length / 4)  // approximation
  if (tokenEstimate > LLM_LIMITS.maxInputTokens) {
    throw new Error(`Input trop long : ${tokenEstimate} tokens estimés (max ${LLM_LIMITS.maxInputTokens})`)
  }
  // Rate limiting par userId...
}
```

**Alertes coût à configurer :**
- Anthropic Console : budget alert à 80% du budget mensuel
- OpenRouter : hard limit en dollars/mois
- Vercel : alerte si edge function calls explosent (peut indiquer une boucle)

### Model Drift — Monitoring comportemental

Les modèles fine-tunés ou les prompts qui fonctionnaient en janvier peuvent produire des outputs différents 6 mois plus tard, sans changement de code visible.

**Mitigation :**
```typescript
// tests/ai-baseline.test.ts — test de régression comportementale
describe('AI Baseline Tests', () => {
  const BASELINE_PROMPTS = [
    {
      input: 'Résume cet espace co-living en 2 phrases.',
      mustContain: ['chambres', 'espace'],    // mots attendus
      mustNotContain: ['À CONFIRMER', '['],   // signes de hallucination
    },
  ]

  // Lancer en CI mensuel ou après changement de modèle
  BASELINE_PROMPTS.forEach(({ input, mustContain, mustNotContain }) => {
    it(`Baseline: "${input.slice(0, 30)}..."`, async () => {
      const output = await callAI(input)
      mustContain.forEach(word => expect(output).toContain(word))
      mustNotContain.forEach(word => expect(output).not.toContain(word))
    })
  })
})
```

**Règle :** après tout changement de modèle (montée de version, changement de provider), re-tester les baseline prompts avant de déployer en prod.

---

## 10. Cas réel — Hallucinations CozyGrowth (15 mars 2026)

> Exemple documenté d'un projet SQWR réel. Source : CLAUDE.md CozyGrowth.
> Ces 3 erreurs ont été détectées et corrigées le même jour.

**Contexte** : CozyGrowth est une plateforme de génération de contenus marketing pour des espaces co-living. Les KBs (Knowledge Bases) contiennent les données réelles de chaque espace — tarifs, capacités, contacts, certifications.

| Date | Donnée inventée | Source de l'erreur | Impact | Statut |
|------|----------------|-------------------|--------|--------|
| 15/03/2026 | Smash Academy : "3,000 jeunes/an" | Inférence à partir du contexte "réseau national" — jamais mentionné dans la KB | Chiffre faux dans contenu marketing client | Corrigé — `[À CONFIRMER]` ajouté |
| 15/03/2026 | Label "AFT 14/15" | Interprétation d'un label interne non défini dans la KB | Information non vérifiable publiée | Corrigé — label retiré du contenu |
| 15/03/2026 | Numéro de téléphone LEGIO | Réutilisation du numéro d'un autre espace similaire dans la session | Contact erroné diffusé | Corrigé — `[À CONFIRMER]` + vérification directe |

**Leçons tirées :**
- Les chiffres ronds ("3,000") doivent systématiquement déclencher une vérification — ils sont souvent inventés
- Les labels/certifications non définis explicitement dans la KB ne doivent jamais être émis
- En session multi-espaces, les contacts ne sont jamais transférables d'un espace à l'autre

**Pattern RAG appliqué depuis** : chaque espace a une KB dédiée chargée isolément. Les sessions ne mélangent pas les données de plusieurs espaces.

---

## 10. Historique des hallucinations (à maintenir par projet)

> Tracker les erreurs détectées pour éviter leur répétition. Modèle CozyGrowth.

| Date | Donnée inventée | Source de l'erreur | Statut |
|------|----------------|-------------------|--------|
| [JJ/MM/AAAA] | [description] | [ce qui a causé l'erreur] | Corrigé / Signalé |

---

## 11. Sources

| Référence | Lien |
|-----------|------|
| AI hallucinations can't be stopped | nature.com/articles/d41586-025-00068-5 |
| Why Language Models Hallucinate — OpenAI | openai.com/index/why-language-models-hallucinate |
| Reducing Hallucinations in LLMs — PMC/NIH | pmc.ncbi.nlm.nih.gov/articles/PMC12425422 |
| HSP Method — Springer Nature | link.springer.com/article/10.1007/s40747-025-01833-9 |
| LLM Context Management | eval.16x.engineer/blog/llm-context-management-guide |
| Context Windows Explained — Redis | redis.io/blog/llm-context-windows |
| Prompt Engineering 2025 — Lakera | lakera.ai/blog/prompt-engineering-guide |
