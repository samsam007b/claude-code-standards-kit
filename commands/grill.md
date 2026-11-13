---
description: Interviews the user before coding a complex feature: clarify scope, ambiguities, shared language, success criteria. Matt Pocock /grill-with-docs pattern.
---

# /grill: Interview before implementation

Before coding, ask the following questions in order. Stop as soon as everything is clear.

## Phase 1: Scope & context

1. What is the expected **visible result** once the feature is done?
2. What is **explicitly out of scope**?
3. Does this feature already exist elsewhere in the codebase, or has it already been attempted?

## Phase 2: Users & edge cases

4. Who uses this feature, and in exactly what context?
5. What are the 2-3 edge cases that absolutely must be handled?
6. What should happen if it fails?

## Phase 3: Success criteria

7. How do we know it is **done**? Which test or observable behavior?
8. Are there non-negotiable technical constraints (performance, security, compatibility)?

## Phase 4: Shared language

9. Are there business terms specific to this project that I should know?
10. Is there an existing doc, ticket or example to follow?

---

## Usage rules

- Ask at most **3 questions per turn**, do not dump everything at once
- If the user says "go ahead" without clarifying everything, write down the assumptions explicitly before coding
- Summarize the plan in **5 bullets max** before writing the first line of code
- Define a verifiable success criterion before starting

## When to use it

| Situation | Grill? |
|-----------|---------|
| New feature, unclear scope | ✅ Mandatory |
| Isolated bug fix | ❌ No |
| Refactor >3 files | ✅ Recommended |
| "Quickly do X" with clear context | ❌ No |
| Cross-project feature or one with client impact | ✅ Mandatory |

---

*Inspired by mattpocock/skills, /grill-with-docs (56K stars)*
