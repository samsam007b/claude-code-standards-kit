# Contract — Feature Flags

> Sources: OpenFeature Specification v1.0 (openfeature.dev — CNCF, 2023), Martin Fowler — "Feature Toggles" (martinfowler.com, 2017), LaunchDarkly Best Practices (docs.launchdarkly.com, 2024)
> Score: /100 | Recommended threshold: ≥70
> Applies to: any project using feature flags, A/B testing, or gradual rollouts

---

## Section 1 — Flag Hygiene (30 points)

- [ ] Every flag has a documented owner and expiry date (prevents flag debt — Martin Fowler §Lifecycle) .............. (10)
- [ ] Maximum 50 active flags per codebase at any time (flag debt threshold — LaunchDarkly §Scale) .............. (8)
- [ ] Flags removed within 30 days of reaching 100% rollout (Martin Fowler §Removal) .............. (7)
- [ ] No feature flag logic in test files (tests run against stable, explicit config) .............. (5)

**Subtotal: /30**

---

## Section 2 — Implementation Standards (35 points)

- [ ] All flags are type-safe: boolean, string, or number — no untyped or `any` flags (OpenFeature §TypeSafety) .............. (10)
- [ ] Default value is always the "safe" state (feature OFF, old behaviour) — failsafe default (OpenFeature §2.2) .............. (12)
- [ ] Flag evaluation is synchronous in the render/request path (no async flag check blocking UI — LaunchDarkly §Performance) .............. (8)
- [ ] Flag SDK initialized once at application start, not per-request .............. (5)

**Subtotal: /35**

---

## Section 3 — Operations (35 points)

- [ ] Kill switch: any flag can be disabled within 60 seconds (OpenFeature §Operational, LaunchDarkly §KillSwitch) .............. (15)
- [ ] Targeting rules are auditable: changes logged with author, timestamp, reason .............. (12)
- [ ] Flag evaluation failures are caught and default value returned (never throw) .............. (8)

**Subtotal: /35**

---

## Sources

| Reference | Contribution |
|-----------|-------------|
| OpenFeature — *OpenFeature Specification v1.0* (openfeature.dev, CNCF, 2023) | Type safety, default value requirements, evaluation contract |
| Fowler, M. — *"Feature Toggles (aka Feature Flags)"* (martinfowler.com, 2017) | Lifecycle, hygiene, expiry requirements |
| LaunchDarkly — *Feature Flag Best Practices Guide* (docs.launchdarkly.com/guides/best-practices, 2024) | Scale thresholds (50 flags max), kill switch requirement |

> **Last validated:** 2026-03-31 — OpenFeature spec v1.0, Martin Fowler 2017, LaunchDarkly 2024
