# Contrat — Green Software & Impact Environnemental

> Module de contrat SQWR Project Kit.
> Sources : ISO/IEC 21031:2024 (SCI), Green Software Foundation, GHG Protocol.
> Principe : les logiciels représentent 4% des émissions mondiales — chaque décision technique a un coût carbone.

---

## Fondements

**Le Software Carbon Intensity (SCI)** est le standard mondial pour mesurer l'empreinte carbone des logiciels, ratifié par l'ISO en mars 2024.

**Formule SCI :**
```
SCI = (E × I) + M  par unité fonctionnelle

E = énergie consommée (kWh)
I = intensité carbone de l'électricité (gCO2e/kWh — variable par région)
M = carbone embarqué (fabrication des serveurs)
Unité fonctionnelle = par requête / par utilisateur / par transaction
```

> Source : *ISO/IEC 21031:2024 — Software Carbon Intensity Specification*
> Source : *Green Software Foundation — SCI Specification (sci.greensoftware.foundation)*

---

## 1. Pourquoi ça compte pour SQWR

- **4%** des émissions mondiales de GES proviennent des logiciels et data centers
- Les clients B2B européens commencent à exiger des preuves d'impact carbone
- La Commission Européenne travaille sur des obligations de reporting carbone pour les PME
- Les LLMs ont un coût carbone significatif — **SCI for AI** (Green Software Foundation, 2025)
- C'est un différenciateur compétitif pour SQWR en 2026-2027

---

## 2. Décisions d'architecture carbone-conscientes

### Sélection des régions — intensité carbone variable

L'intensité carbone de l'électricité varie considérablement selon les régions.

| Région | Intensité carbone | Source d'énergie dominante |
|--------|------------------|---------------------------|
| `eu-central-1` (Frankfurt) | ~300 gCO2e/kWh | Mix européen |
| `eu-west-1` (Ireland) | ~200 gCO2e/kWh | Éolien + mix UE |
| `us-east-1` (N. Virginia) | ~350 gCO2e/kWh | Charbon + gaz |
| `ap-southeast-1` (Singapore) | ~450 gCO2e/kWh | Gaz naturel |

**Outil temps réel :** electricitymap.org — intensité carbone par région/pays

**Recommandation SQWR :** Pour Vercel, choisir `eu-central-1` ou `eu-west-1` par défaut pour les projets européens — moins de latence ET moins d'émissions.

### Serverless > Always-on

Les fonctions serverless (Vercel Edge Functions, Vercel Serverless) ne consomment de l'énergie que pendant l'exécution. Un serveur always-on consomme en permanence.

```
// ✅ Serverless (Vercel) — consomme uniquement pendant les requêtes
// ❌ VPS always-on — consomme 24/7 même sans trafic
```

**Pour les projets SQWR :** Vercel + Supabase Edge Functions = architecture naturellement carbon-aware.

### Caching agressif — moins de compute

Chaque compute = énergie. Le caching évite de recalculer ce qui est déjà connu.

```typescript
// ✅ Données statiques — cache agressif
export const revalidate = 3600  // recalculer max 1 fois/heure

// ✅ Pages statiques — zéro compute par visite
export const dynamic = 'force-static'

// ⚠️ 'no-store' — compute à chaque requête — justifier si utilisé
export const dynamic = 'force-dynamic'  // seulement si données vraiment temps réel
```

---

## 3. LLM Carbon Cost

Le Green Software Foundation a publié en 2025 le **SCI for AI** — méthode standardisée pour mesurer l'impact carbone des appels LLM.

**Ordres de grandeur (estimation) :**

| Opération | Énergie estimée |
|-----------|----------------|
| 1 requête GPT-4 | ~0.001-0.01 kWh |
| 1 requête Claude Sonnet | ~0.0005-0.005 kWh |
| 1000 appels LLM/jour | ~0.5-10 kWh/jour |
| Fine-tuning d'un modèle | ~100-1000 kWh |

**Règles de sobriété LLM :**

```typescript
// ✅ Utiliser le modèle adapté à la complexité de la tâche
const MODEL_BY_TASK = {
  'classification-simple': 'claude-haiku-4-5',    // tâche simple → modèle léger
  'generation-contenu': 'claude-sonnet-4-5',       // tâche moyenne → modèle moyen
  'analyse-complexe': 'claude-opus-4-5',           // tâche complexe → modèle puissant
} as const

// ❌ Ne jamais utiliser claude-opus pour des tâches simples
// ❌ Ne pas appeler le LLM si le résultat peut être mis en cache
```

**Cache LLM pour réduire les appels :**

```typescript
// lib/ai/cached-call.ts
import { createClient } from '@supabase/ssr'

async function cachedAICall(prompt: string, ttl = 3600): Promise<string> {
  const cacheKey = `ai:${hash(prompt)}`

  // Vérifier le cache d'abord
  const cached = await supabase
    .from('ai_cache')
    .select('response, created_at')
    .eq('key', cacheKey)
    .gt('created_at', new Date(Date.now() - ttl * 1000).toISOString())
    .single()

  if (cached.data) return cached.data.response

  // Appeler le LLM uniquement si pas en cache
  const response = await callAI(prompt)

  // Stocker en cache
  await supabase.from('ai_cache').upsert({ key: cacheKey, response })

  return response
}
```

---

## 4. Mesurer son SCI

**Pour un projet SQWR typique (Next.js + Supabase) :**

```
SCI = (E_vercel × I_region + E_supabase × I_region + E_llm × I_llm_datacenter) + M
    / nombre de transactions par mois

// En pratique, les estimations sont approximatives sans outils spécialisés
// L'important : suivre la tendance, pas la valeur absolue
```

**Outils de mesure :**

| Outil | Mesure | Usage |
|-------|--------|-------|
| Vercel Carbon | Émissions infrastructure Vercel | Tableau de bord Vercel |
| electricitymap.org | Intensité carbone temps réel par région | Choix de région |
| Green Software Foundation SCI Guide | Méthodologie SCI complète | Rapport carbone |
| Cloud Carbon Footprint | AWS/GCP/Azure émissions | Si multi-cloud |

---

## 5. Green Software Checklist

### Architecture
- [ ] Régions Vercel/Supabase sélectionnées sur critère carbone + latence (pas seulement latence)
- [ ] Caching configuré sur toutes les données semi-statiques
- [ ] `force-dynamic` justifié (pas utilisé par défaut)
- [ ] Serverless ou Edge Functions plutôt qu'always-on

### LLM & IA
- [ ] Modèle adapté à la complexité de la tâche (Haiku/mini pour tâches simples)
- [ ] Cache LLM implémenté pour les prompts répétitifs
- [ ] Hard limit tokens configuré (éviter les appels abusifs)
- [ ] `revalidate` configuré sur les composants avec appels LLM

### Assets & Frontend
- [ ] Images optimisées (WebP, next/image)
- [ ] Fonts subsettées (next/font, éviter de charger tous les glyphes)
- [ ] Bundle JS minimal (<200KB First Load)
- [ ] CSS non utilisé purgé (Tailwind fait ça automatiquement en prod)

---

## 6. Règles absolues

### Ne jamais faire
- Utiliser `force-dynamic` par défaut (recalcul à chaque requête = gaspillage)
- Utiliser claude-opus ou gpt-4 pour des tâches qui peuvent être faites par un modèle léger
- Appeler le LLM sans cache si la même question peut être posée plusieurs fois
- Choisir une région serveur uniquement sur la latence sans considérer l'intensité carbone

### Toujours faire
- Préférer le caching à la génération dynamique quand possible
- Utiliser le modèle IA le plus léger capable d'accomplir la tâche
- Vérifier electricitymap.org avant de choisir une région pour un nouveau projet

---

## 7. Sources

| Référence | Source |
|-----------|--------|
| SCI Specification | sci.greensoftware.foundation |
| ISO/IEC 21031:2024 | iso.org/standard/86612.html |
| SCI for AI (2025) | greensoftware.foundation/articles/sci-ai-specification-ratified |
| Electricity Maps | electricitymap.org |
| Cloud Carbon Footprint | cloudcarbonfootprint.org |
| Green Software Principles | principles.green |
