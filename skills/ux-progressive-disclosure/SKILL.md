---
name: ux-progressive-disclosure
description: Apply the Progressive Disclosure pattern to a complex component, reorganizing it into 3 hierarchical levels (Essential / Advanced / Expert).
tags: [ux, frontend, progressive-disclosure, information-architecture]
model: sonnet
---

# UX Progressive Disclosure Skill

## Description
Applies the Progressive Disclosure pattern to a complex component. Reorganizes information into hierarchical levels (Level 1: Essential, Level 2: Advanced, Level 3: Expert) according to scientific principles.

## Usage
```
/ux-progressive-disclosure [file_path] [--levels=3] [--preview]
```

## Workflow

1. **Analysis of the Current Component**
   - Counts the number of visible elements
   - Identifies complexity (number of options, inputs, sections)
   - Detects Miller's Law violations (> 7±2)

2. **Categorization by Level**
   - **Level 1 (Always Visible)**: 5-7 essential elements
     - Criteria: Used by 80%+ of users, critical for the task
   - **Level 2 (On Demand)**: Advanced features
     - Criteria: Used by 20-50% of users, optional
   - **Level 3 (Expert)**: Fine-grained configuration
     - Criteria: Used by < 20% of users, power features

3. **Refactored Code Generation**
   - Creates collapsible sections (Accordion pattern)
   - Adds expand/collapse logic
   - Preserves all functionality (nothing removed)

4. **Adding UI Affordances**
   - "More options" indicators (+)
   - Explanatory tooltips
   - Smooth animations (Framer Motion)

## Examples

### Example 1: FilterSidebar with 30+ options

**Before**:
```tsx
<FilterSidebar>
  {/* 30 checkboxes visible at the same time */}
  <Checkbox label="WiFi" />
  <Checkbox label="Parking" />
  <Checkbox label="Elevator" />
  {/* ... 27 more */}
</FilterSidebar>
```

**After** (with `/ux-progressive-disclosure`):
```tsx
<FilterSidebar>
  {/* Level 1: Always visible (5 essentials) */}
  <FilterSection title="💰 Price" expanded={true}>
    <RangeSlider />
  </FilterSection>
  <FilterSection title="🏠 Type" expanded={true}>
    <ButtonGroup options={['Apartment', 'House']} />
  </FilterSection>

  {/* Level 2: Collapsed by default */}
  <FilterSection title="⚡ Amenities" expanded={false}>
    <CheckboxGroup
      visible={['WiFi', 'Parking', 'Furnished']} // 3 visible
      hidden={[...27 others]} // Revealed on "See more"
    />
  </FilterSection>

  {/* Level 3: Expert modal */}
  <FilterSection title="👥 Roommates" expanded={false}>
    <Button onClick={openModal}>+ Configure</Button>
  </FilterSection>
</FilterSidebar>
```

### Example 2: Complex Settings Page

**Command**:
```bash
/ux-progressive-disclosure app/seeker/settings/page.tsx --levels=3
```

**Output**:
- Reorganizes settings into 3 tabs (Account, Preferences, Advanced)
- Each tab with max 7 visible options
- Dangerous options (delete account) hidden in Advanced

## Output

The skill generates:
1. **Refactored code** (with progressive disclosure applied)
2. **Analysis report**:
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
- `--levels=N` : Number of levels (default: 3)
- `--preview` : Generates visual mockup (ASCII art) without modifying code
- `--preserve-state` : Keeps expand/collapse states in localStorage

## References

Based on:
- **Hick's Law**: Reduce visible choices → faster decision
- **Miller's Law**: Max 7±2 elements → manageable cognitive load
- **Progressive Disclosure Pattern**: [NN/g Research](https://www.nngroup.com/articles/progressive-disclosure/)
