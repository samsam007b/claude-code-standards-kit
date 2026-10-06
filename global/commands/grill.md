---
description: Interview the user before coding a complex feature, to clarify scope, ambiguities, shared vocabulary and success criteria.
---

# /grill: interview before implementation

Before coding, ask the questions below in order. Stop as soon as everything is clear.

## Phase 1: scope and context
1. What is the **visible result** expected once the feature is done?
2. What is **explicitly out of scope**?
3. Does this feature already exist elsewhere in the codebase, or has it been attempted?

## Phase 2: users and edge cases
4. Who uses it, and in what exact context?
5. Which 2 or 3 edge cases must be handled?
6. What should happen on failure?

## Phase 3: success criteria
7. How do we know it is **done**? Which test or observable behavior?
8. Any non-negotiable technical constraints (performance, security, compatibility)?

## Phase 4: shared vocabulary
9. Any domain terms specific to this project I must know?
10. Any existing doc, ticket or example to follow?

## Rules
- Ask at most **3 questions per turn**, do not dump everything at once.
- If the user says "go" without clarifying everything, write down the assumptions explicitly before coding.
- Summarize the plan in **5 bullets max** before writing the first line of code.
- Define a verifiable success criterion before starting.

## When to use

| Situation | Grill? |
|---|---|
| New feature, fuzzy scope | Mandatory |
| Isolated bug fix | No |
| Refactor over 3 files | Recommended |
| "Do X quickly" with clear context | No |
| Cross-project feature or customer impact | Mandatory |

Inspired by the public `mattpocock/skills` grill-with-docs pattern.
