---
name: ux-heuristic-audit
description: Audit an interface using Nielsen heuristics and Laws of UX. Prioritized report with issues and recommendations.
tags: [ux, audit, frontend, heuristics, nielsen]
model: sonnet
---

# UX Heuristic Audit Skill

## Description
Audits an interface or component according to scientific UX principles (Nielsen Heuristics + Laws of UX). Generates a report with identified issues and prioritized recommendations.

## Usage
```
/ux-heuristic-audit [file_path_or_component_name]
```

## Workflow

1. **Reading the Component/Page**
   - Reads the source code
   - Analyzes structure, props, states
   - Identifies UI elements (buttons, inputs, cards, etc.)

2. **Audit According to Nielsen's 10 Heuristics**
   - #1 Visibility of System Status
   - #2 Match Between System & Real World
   - #3 User Control & Freedom
   - #4 Consistency & Standards
   - #5 Error Prevention
   - #6 Recognition Rather Than Recall
   - #7 Flexibility & Efficiency
   - #8 Aesthetic & Minimalist Design
   - #9 Help Users Recognize, Diagnose & Recover from Errors
   - #10 Help & Documentation

3. **Audit According to Laws of UX**
   - Miller's Law (7±2 visible elements)
   - Hick's Law (number of choices)
   - Fitts's Law (size of interactive targets)
   - Tesler's Law (distribution of complexity)
   - Information Scent (descriptive labels)

4. **Report Generation**
   - Lists issues by severity (Critical, High, Medium, Low)
   - Specific recommendations
   - Before/after code examples
   - Overall UX score (0-100)

## Output Format

```markdown
# UX Audit Report - [Component Name]

**Date**: [Date]
**Auditor**: Claude (Scientific UX Framework)
**Overall UX Score**: [X]/100

---

## Executive Summary

[Summary of the main findings]

---

## Critical Issues (Severity 5/5)

### Issue #1: [Title]
- **Heuristic Violated**: Nielsen #X or Law of UX
- **Current State**: [Description of the problem]
- **User Impact**: [Impact on the user]
- **Recommendation**: [Proposed solution]
- **Code Example**:
  ```tsx
  // Before (problematic)
  [current code]

  // After (fixed)
  [corrected code]
  ```

---

## High Priority Issues (Severity 4/5)

[...]

---

## Medium Priority Issues (Severity 3/5)

[...]

---

## Low Priority Issues (Severity 2/5)

[...]

---

## Strengths (What works well)

- [Identified strengths]

---

## Recommendations Summary

| Priority | Issue | Estimated Effort | Impact |
|----------|-------|------------------|--------|
| P0 | [Issue] | [Effort] | [Impact] |

---

## Next Steps

1. [Priority action]
2. [Next action]
```

## Examples

### Example 1: Audit of a filter sidebar

```bash
/ux-heuristic-audit components/explore/FilterSidebar.tsx
```

**Findings**:
- ❌ Miller's Law violated: 25+ checkboxes visible (> 7±2)
- ❌ Information Scent weak: Label "Options" too vague
- ✅ Consistency good: Uniform icons

### Example 2: Audit of a full page

```bash
/ux-heuristic-audit app/seeker/explore/page.tsx
```

**Findings**:
- ❌ Visibility: No feedback on the number of results
- ❌ Hick's Law: Too many simultaneous choices (paralysis)
- ✅ Aesthetic & Minimalist: Clean design

## Configuration

The skill uses the references in `docs/ux-guidelines/`:
- `ux-checklist-before-feature.md`
- `ux-scientific-research-complex-interfaces.md`

## Output Location

Reports are saved in:
```
docs/ux-audits/[component-name]-audit-[date].md
```
