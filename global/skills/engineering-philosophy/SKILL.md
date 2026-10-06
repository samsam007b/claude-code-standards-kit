---
name: engineering-philosophy
description: Coding principles (think first, simplicity, surgical changes, verifiable goals), plan adherence, challenge-based prompting and TDD/debugging discipline. Load before any non-trivial code task, multi-file refactor, or execution of a PLAN.md.
---

## RULE: Four coding principles

1. **Think before coding.** List ambiguities and assumptions before the first line. If an interpretation is ambiguous, ask; never guess.
2. **Simplicity first.** The minimum code that solves the problem, no unrequested abstraction. Test: would a senior engineer call it over-engineered? Then simplify.
3. **Surgical changes.** Touch only what was asked. Do not refactor or "improve" adjacent code. Every changed line traces back to the request.
4. **Goal-driven execution.** Define verifiable success criteria before coding: a failing test, then it passes, then zero regressions.

Optional framing: when quality is critical, state in the system prompt that the output will be reviewed by senior experts.

Origin of the four principles: the public `andrej-karpathy-skills` collection (credit to its authors).

---

## RULE: Respect plans, no laziness

Bad habits that models show under implicit performance pressure. Never reproduce them:

1. Skipping a step of a PLAN.md, even a redundant one. Do it, note why afterwards.
2. `completed` means 100% delivered, tested and verified. Otherwise `in_progress`.
3. Research announced in the plan is actually done (sources verified), not skipped.
4. Delivering to a client without a nominal-path and edge-case audit is a failure. The client must never find the bug before you do.
5. "go" / "continue" means execute the whole agreed scope without re-validating halfway. If blocked: say so, propose, execute.
6. Speed never trades against correctness. Ten more minutes is cheaper than a wrong result.
7. Client documents (quotes, reports) are built from a full read, a visible extraction and a validation step, never from memory.

**Why**: models compress steps to look fast, which is the opposite of what most users value.

---

## RULE: Challenge-based prompting

- "Prove it works" means a concrete test or demo, not an assertion.
- "Scrap and redo" means restart from zero without defending the existing attempt.
- "Grill me" means run `/grill` to clarify scope before coding.
- Keep PRs small (around 140 lines or fewer is the community median) and commit at least hourly on long features.
- A skill description is a trigger (when to use it), not a summary of its content.

---

## RULE: TDD and debugging

- **Vertical TDD**: one test, one implementation, GREEN, refactor. Never write several tests ahead. Test public interfaces. Refactor only in GREEN, never in RED.
- **Debugging**: first build a fast, deterministic pass/fail signal (unit test, then CLI, HTTP, browser, logs), then look for the cause. Keep 3 to 5 falsifiable hypotheses at most.

Origin: the public `mattpocock/skills` collection (tdd and diagnose skills).
