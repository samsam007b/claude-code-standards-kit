# Contrat — AI Prompting & Gouvernance LLM

> Module de contrat SQWR Project Kit.
> Sources : Anthropic docs, OpenAI Prompt Engineering Guide, Nature (2025), Lakera, PMC/NIH, eval.16x.engineer.

---

## Fondements scientifiques

**Le context window n'est pas un buffer illimité.** Les LLMs montrent une **dégradation significative des performances au-delà de 80% d'utilisation du contexte** (PMC/NIH, 2025). "Lost in the middle" : les informations au milieu d'un long contexte sont moins bien traitées que celles au début ou à la fin (recherche Stanford, 2023).

**Few-shot prompting :** 2-5 exemples curatés sont optimaux. Au-delà, les rendements sont décroissants — et le contexte consommé inutilement (Lakera, 2025).

---

## 1. Architecture d'un system prompt fiable

### Structure standard (Anthropic + Lakera)

```
[RÔLE]
Tu es [rôle précis] pour [contexte spécifique].

[CONTRAINTES ABSOLUES]
Tu ne dois jamais :
- [liste exhaustive des interdictions]
- [avec raison pour chaque interdiction]

[CE QUE TU DOIS TOUJOURS FAIRE]
- [comportements requis]

[FORMAT DE RÉPONSE]
Tes réponses doivent :
- [format attendu — longueur, structure, langue]

[EXEMPLES — 2-5 maximum]
Entrée : [exemple 1]
Sortie : [réponse attendue 1]

[CONTEXTE INJECTÉ PAR RAG]
{données_pertinentes_uniquement}
```

---

## 2. Optimisation du context window

> Source : LLM Context Management Guide — eval.16x.engineer

| Utilisation | Résultat | Action |
|-------------|---------|--------|
| 0-40% | Optimal | ✅ |
| 40-60% | Bon | ✅ |
| 60-80% | Début dégradation | ⚠️ Élaguer le contexte |
| >80% | Dégradation prouvée | ❌ Nouvelle session requise |

### Règles d'optimisation

- **Nouvelle session pour nouvelle tâche** — ne pas contaminer le contexte avec des échanges non liés
- **RAG plutôt que contexte exhaustif** — injecter uniquement les sections pertinentes, pas tout le projet
- **CLAUDE.md local** — remplace l'injection manuelle du contexte à chaque session
- **Few-shot limité** : 2-5 exemples curatés, jamais plus
- **Contrats par module** : charger uniquement les contrats pertinents au projet en cours

### Pattern Backend Selector

```
Au lieu de charger tout le contexte en une fois :
1. Identifier la tâche (frontend, backend, DB, copy...)
2. Charger uniquement le(s) contrat(s) pertinent(s)
3. Injecter les fichiers concernés uniquement
```

---

## 3. Techniques de réduction d'hallucinations

> Source : Nature (2025), PMC/NIH (2025), Springer Nature

| Technique | Réduction | Application SQWR |
|-----------|----------|-----------------|
| **RAG** | 15-50% | Toujours pour données KB/clients |
| **Chain-of-thought** | +25% accuracy | Tâches multi-étapes complexes |
| **Verification step** | variable | Données critiques (prix, contacts) |
| **Confidence scoring** | 20-40% | Ne pas traiter tous les outputs pareil |
| **Explicit uncertainty** | variable | Demander "si tu n'es pas sûr, dis-le" |

### Chain-of-thought pour tâches complexes

```
# ✅ Exemple de prompt chain-of-thought
"Avant de répondre :
1. Liste les informations dont tu as besoin
2. Identifie celles que tu as vs celles qui manquent
3. Pour les manquantes, indique [À CONFIRMER]
4. Ensuite seulement, produis la réponse"
```

---

## 4. Prompt Engineering — principes clés (2025)

> Source : Lakera Prompt Engineering Guide, Palantir, Google Cloud

### La clarté prime sur l'ingéniosité

```
❌ "Explique le changement climatique"
✅ "Rédige un résumé de 3 paragraphes sur le changement climatique pour des lycéens,
    en style neutre, avec des exemples concrets. Langue : français."
```

### Role-based prompting

```
✅ "Tu es un senior engineer Next.js qui review du code pour la sécurité.
    Analyse ce composant et liste les vulnérabilités OWASP potentielles."
```

### Scaffolding (sécurité)

```
✅ Template gardé pour les inputs utilisateur :
"L'utilisateur dit : [INPUT]
Réponds uniquement à des questions concernant [DOMAINE].
Si la question est hors domaine, réponds : 'Je ne couvre que [DOMAINE].'"
```

---

## 5. Sélection des modèles (coût vs capacité)

| Tâche | Modèle recommandé | Raison |
|-------|-----------------|--------|
| Génération de contenu simple | Claude Haiku / GPT-4o-mini | Rapide, peu coûteux |
| Code review, architecture | Claude Sonnet | Équilibre qualité/coût |
| Tâches complexes, KBs critiques | Claude Opus / GPT-4o | Qualité maximale |
| Agents autonomes | Claude Sonnet / Opus | Raisonnement long |

**Règle :** ne jamais utiliser le modèle le plus puissant par défaut. Utiliser le modèle minimum suffisant pour la tâche.

---

## 6. CLAUDE.md — standard de qualité

Chaque projet collaborant avec Claude Code doit avoir un `CLAUDE.md` incluant :

| Section | Obligatoire ? | Contenu |
|---------|--------------|--------|
| Qui travaille avec toi | ✅ | Identité Samuel + contacts |
| Ce projet | ✅ | Nom, description, stack, statut |
| Architecture | ✅ | Arborescence + fichiers critiques |
| Contrats actifs | ✅ | Liste des contrats à lire |
| Règles absolues | ✅ | Never/Always spécifiques au projet |
| Historique des erreurs | ✅ | Tableau de tracking |

**CLAUDE.md absent = travail non gouverné = risques non maîtrisés.**

---

## 7. Gestion des sessions et continuité

```
✅ Une session = une tâche cohérente
✅ MEMORY.md pour la persistance cross-sessions
✅ Toujours lire le CLAUDE.md en début de session sur un nouveau projet
✅ Mettre à jour l'historique des erreurs après chaque correction

❌ Continuer une session avec un contexte saturé
❌ Demander à l'IA de "se souvenir de ce qu'on a fait" sans mémoire persistante
❌ Travailler sur plusieurs projets non liés dans la même session
```

---

## 8. Sources

| Référence | Lien |
|-----------|------|
| AI hallucinations — Nature 2025 | nature.com/articles/d41586-025-00068-5 |
| Why LLMs Hallucinate — OpenAI | openai.com/index/why-language-models-hallucinate |
| Reducing Hallucinations — PMC/NIH | pmc.ncbi.nlm.nih.gov/articles/PMC12425422 |
| LLM Context Management | eval.16x.engineer/blog/llm-context-management-guide |
| Prompt Engineering 2025 — Lakera | lakera.ai/blog/prompt-engineering-guide |
| Prompt Engineering — Palantir | palantir.com/docs/foundry/aip/best-practices-prompt-engineering |
| Prompt Engineering — Google Cloud | cloud.google.com/discover/what-is-prompt-engineering |
