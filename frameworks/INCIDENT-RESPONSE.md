# Framework — Incident Response & Postmortem

> SQWR Project Kit Framework — inspired by the Google SRE Workbook and PagerDuty.
> Sources: Google SRE Workbook (response.pagerduty.com), PagerDuty Incident Response.
> When to use: when a production service is degraded or unavailable.

---

## Principle: Blameless Culture

**An incident is never the fault of a person. It is a system failure.**

A postmortem that looks for someone to blame does not produce more reliable systems. A postmortem that looks for systemic causes and concrete actions does.

> *"The goal is not to find the bad apple. The goal is to find the rotten barrel."* — John Allspaw, Etsy

---

## Part 1 — Incident Response (during)

### Roles

For a solo/very small team, one person can hold multiple roles. What matters is knowing who does what.

| Role | Responsibility |
|------|---------------|
| **Incident Commander (IC)** | Coordinates the response, makes decisions, declares resolution |
| **Ops Lead** | Performs technical actions (rollback, hotfix, restart) |
| **Communications Lead** | Informs stakeholders (clients, team, uptime page) |

### Response Timeline

```
[0 min]   Detection (Sentry alert, Vercel, user report)
           → Create a dedicated channel/thread for the incident

[< 5 min] Acknowledgment
           → Someone has taken ownership of the incident
           → Initial communication to stakeholders if user impact

[< 15 min] Assessment
           → Define severity (see below)
           → Identify affected systems
           → First mitigation plan

[< 30 min] Mitigation or Escalation
           → Rollback if possible (see CONTRACT-VERCEL.md)
           → Hotfix if quickly identifiable
           → Escalate if blocked

[Resolution] Incident declared resolved by the IC
           → Final communication to stakeholders
           → Postmortem scheduled (< 48h)
```

### Severity Levels

| Level | Definition | Response Time |
|-------|-----------|--------------|
| **SEV-1** | Service fully unavailable, data at risk | < 5 min |
| **SEV-2** | Critical feature degraded (auth, payment) | < 15 min |
| **SEV-3** | Non-critical feature degraded | < 1h |
| **SEV-4** | Minor bug, limited impact | Next sprint |

### Communication during the incident

```markdown
<!-- Initial message template (< 5 min after detection) -->
🔴 INCIDENT IN PROGRESS — [Date/Time]

**Impact:** [what users are experiencing]
**Affected systems:** [Vercel / Supabase / LLM API / ...]
**Status:** Investigation in progress
**Next update in:** 15 minutes

<!-- Interim update template -->
🟡 UPDATE — [Date/Time]

**Identified cause:** [short description]
**Action in progress:** [rollback / hotfix / ...]
**ETA to resolution:** [estimate or "unknown"]

<!-- Resolution template -->
✅ INCIDENT RESOLVED — [Date/Time]

**Duration:** [X minutes/hours]
**Cause:** [one-sentence summary]
**Postmortem:** scheduled for [date]
```

---

## Part 2 — Postmortem (after)

### When to conduct a postmortem

- Every SEV-1 or SEV-2 incident: **mandatory**
- Every SEV-3 incident that recurs: **recommended**
- Any incident that surprised the team: **recommended**

**Timing:** within 48h of resolution. Past 48h, details fade.

### Blameless Postmortem Template

```markdown
# Postmortem — [Short Incident Title]

**Date:** [DD/MM/YYYY]
**Duration:** [X minutes/hours]
**Severity:** SEV-[1/2/3]
**IC:** [name]
**Postmortem author:** [name]

---

## Summary

[2–3 sentences max: what happened, what the impact was, how it was resolved]

---

## Impact

- **Users affected:** [number or estimate]
- **Affected features:** [list]
- **Impact duration:** [X min of total degradation]
- **Data lost:** [yes/no — if yes, which data]

---

## Detailed Timeline

| Time | Event |
|------|-------|
| HH:MM | [detection — by whom / how] |
| HH:MM | [first action] |
| HH:MM | [cause identified] |
| HH:MM | [mitigation deployed] |
| HH:MM | [incident declared resolved] |

---

## Root Cause (5 Whys)

1. **Why** did the service fail?
   → [answer]
2. **Why** [answer 1]?
   → [answer]
3. **Why** [answer 2]?
   → [answer]
4. **Why** [answer 3]?
   → [answer]
5. **Why** [answer 4]?
   → **Root cause:** [systemic root cause]

---

## What worked well

- [item 1 — e.g., Sentry alert detected in 2 min]
- [item 2]

## What did not work

- [item 1 — e.g., rollback procedure unknown, took 20 extra minutes]
- [item 2]

---

## Action Items (mandatory — no action = useless postmortem)

| Action | Owner | Deadline | Status |
|--------|-------|---------|--------|
| [concrete preventive action] | [name] | [date] | To do |
| [monitoring improvement] | [name] | [date] | To do |
| [documentation to create] | [name] | [date] | To do |

---

## Lessons Learned

[What this postmortem teaches about the system, not about individuals]
```

---

## Part 3 — Incident Register

Maintain a register in the relevant project to track incidents and their resolution.

```markdown
<!-- docs/incidents/INCIDENT-LOG.md -->
# Incident Register

| Date | Severity | Duration | Cause | Postmortem | Action Items |
|------|---------|---------|-------|-----------|-------------|
| [DD/MM] | SEV-2 | 45 min | [cause] | [link] | [X/Y completed] |
```

---

## Post-resolution Checklist

- [ ] Incident declared resolved by the IC
- [ ] Final communication sent to stakeholders
- [ ] Postmortem scheduled within 48h
- [ ] Incident logged in `docs/incidents/INCIDENT-LOG.md`
- [ ] Action items created in the tracker (Linear, GitHub Issues, etc.)
- [ ] ADR created if the incident decision changes the architecture

---

## Sources

| Reference | Source |
|-----------|--------|
| Google SRE Workbook — Incident Response | sre.google/workbook/incident-response |
| Google SRE Workbook — Postmortem Culture | sre.google/workbook/postmortem-culture |
| PagerDuty Incident Response Docs | response.pagerduty.com |
| Blameless Postmortems — Etsy | codeascraft.com/2012/05/22/blameless-postmortems |
