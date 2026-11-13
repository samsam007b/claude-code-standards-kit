---
name: ux-progressive-disclosure
description: Appliquer le pattern Progressive Disclosure à un composant complexe — réorganise en 3 niveaux hiérarchiques (Essentiel / Avancé / Expert).
tags: [ux, frontend, progressive-disclosure, information-architecture]
model: sonnet
---

# UX Progressive Disclosure Skill

## Description
Applique le pattern Progressive Disclosure à un composant complexe. Réorganise l'information en niveaux hiérarchiques (Niveau 1: Essentiel, Niveau 2: Avancé, Niveau 3: Expert) selon principes scientifiques.

## Usage
```
/ux-progressive-disclosure [file_path] [--levels=3] [--preview]
```

## Workflow

1. **Analyse du Composant Actuel**
   - Compte le nombre d'éléments visibles
   - Identifie la complexité (nombre d'options, inputs, sections)
   - Détecte violations Miller's Law (> 7±2)

2. **Catégorisation par Niveau**
   - **Niveau 1 (Always Visible)**: 5-7 éléments essentiels
     - Critères: Utilisés par 80%+ des users, critiques pour tâche
   - **Niveau 2 (On Demand)**: Fonctionnalités avancées
     - Critères: Utilisés par 20-50% des users, optionnels
   - **Niveau 3 (Expert)**: Configurations fines
     - Critères: Utilisés par < 20% des users, power features

3. **Génération du Code Refactoré**
   - Crée sections collapsibles (Accordion pattern)
   - Ajoute expand/collapse logic
   - Préserve toutes les fonctionnalités (rien supprimé)

4. **Ajout des Affordances UI**
   - Indicateurs "Plus d'options" (+)
   - Tooltips explicatifs
   - Animations smooth (Framer Motion)

## Exemples

### Exemple 1: FilterSidebar avec 30+ options

**Before**:
```tsx
<FilterSidebar>
  {/* 30 checkboxes visibles en même temps */}
  <Checkbox label="WiFi" />
  <Checkbox label="Parking" />
  <Checkbox label="Elevator" />
  {/* ... 27 more */}
</FilterSidebar>
```

**After** (avec `/ux-progressive-disclosure`):
```tsx
<FilterSidebar>
  {/* Niveau 1: Toujours visible (5 essentiels) */}
  <FilterSection title="💰 Prix" expanded={true}>
    <RangeSlider />
  </FilterSection>
  <FilterSection title="🏠 Type" expanded={true}>
    <ButtonGroup options={['Apartment', 'House']} />
  </FilterSection>

  {/* Niveau 2: Collapsed par défaut */}
  <FilterSection title="⚡ Équipements" expanded={false}>
    <CheckboxGroup
      visible={['WiFi', 'Parking', 'Meublé']} // 3 visibles
      hidden={[...27 autres]} // Révélés sur "Voir plus"
    />
  </FilterSection>

  {/* Niveau 3: Modal expert */}
  <FilterSection title="👥 Colocataires" expanded={false}>
    <Button onClick={openModal}>+ Configurer</Button>
  </FilterSection>
</FilterSidebar>
```

### Exemple 2: Complex Settings Page

**Command**:
```bash
/ux-progressive-disclosure app/seeker/settings/page.tsx --levels=3
```

**Output**:
- Réorganise settings en 3 tabs (Account, Preferences, Advanced)
- Chaque tab avec max 7 options visibles
- Options dangereuses (delete account) cachées dans Advanced

## Output

Le skill génère :
1. **Code refactoré** (avec progressive disclosure appliqué)
2. **Rapport d'analyse** :
   ```markdown
   # Progressive Disclosure Analysis

   ## Before
   - Total elements visible: 32
   - Cognitive load: HIGH (violates Miller's Law)

   ## After
   - Level 1: 5 elements (essential)
   - Level 2: 15 elements (advanced, collapsed)
   - Level 3: 12 elements (expert, modal)
   - Cognitive load: LOW ✅

   ## User Impact
   - Novice users: See only 5 options → No overwhelm
   - Advanced users: Can expand → Full control
   - Experts: Modal for fine-tuning → Power features
   ```

## Configuration

Options:
- `--levels=N` : Nombre de niveaux (default: 3)
- `--preview` : Génère mockup visuel (ASCII art) sans modifier code
- `--preserve-state` : Garde les expand/collapse states en localStorage

## Références

Basé sur:
- **Hick's Law**: Réduire choix visibles → décision plus rapide
- **Miller's Law**: Max 7±2 éléments → charge cognitive gérable
- **Progressive Disclosure Pattern**: [NN/g Research](https://www.nngroup.com/articles/progressive-disclosure/)
