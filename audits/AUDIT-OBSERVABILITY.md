# Observability & Reliability Audit

> Based on Google SRE Book, OpenTelemetry, Sentry Best Practices.
> Score: /100 | Recommended threshold: ≥70

---

## Section 1 — Structured Logging (10 points)

- [ ] Logs in structured JSON format (no raw `console.log` strings) .............. (4)
- [ ] Log levels used correctly (debug/info/warn/error/fatal) ..................... (3)
- [ ] No PII data in logs (email, password, tokens) ............................... (3)

**Quick check:**
```bash
# Find unstructured console.log calls
grep -r "console\.log\|print(" src/ --include="*.ts" --include="*.tsx" --include="*.py"
```

**Subtotal: /10**

---

## Section 2 — Error Tracking (20 points)

- [ ] Sentry (or equivalent) configured with DSN ................................. (8)
- [ ] Source maps uploaded (readable errors, not minified) ....................... (4)
- [ ] Environment tags configured (production/staging/development) ............... (4)
- [ ] Sentry alerts configured (error rate > threshold → notification) ........... (4)

**Verification:**
```bash
# Check for Sentry config presence
ls sentry.client.config.ts sentry.server.config.ts sentry.edge.config.ts 2>/dev/null
grep -r "NEXT_PUBLIC_SENTRY_DSN\|SENTRY_DSN" .env.example
```

**Subtotal: /20**

---

## Section 3 — Performance Monitoring / RUM (20 points)

- [ ] Real User Monitoring configured (Vercel Speed Insights or equivalent) ...... (8)
- [ ] LCP measured on critical pages (real value, not local Lighthouse) .......... (6)
- [ ] INP measured (real user interactivity) ..................................... (3)
- [ ] Alerts on CWV regressions (comparison with previous week) .................. (3)

**Measured values:**

| Metric | Current value | Target threshold | OK? |
|--------|---------------|------------------|-----|
| LCP (p75) | ___s | ≤2.5s | |
| INP (p75) | ___ms | ≤200ms | |
| CLS (p75) | ___ | <0.1 | |

**Subtotal: /20**

---

## Section 4 — Backup & Disaster Recovery (20 points)

- [ ] Supabase PITR enabled (or automated export configured) ..................... (8)
- [ ] Restore procedure documented (and tested at least once) .................... (8)
- [ ] Emergency contacts defined and accessible (Supabase support, Vercel support) (4)

**Verification:**
```bash
# Check for DR procedure presence
ls docs/disaster-recovery.md docs/runbook.md 2>/dev/null || echo "MISSING"
```

**Subtotal: /20**

---

## Section 5 — SLO & Monitoring (30 points)

- [ ] SLIs defined (uptime, latency, error rate) ................................. (10)
- [ ] SLOs documented with numerical targets ..................................... (8)
- [ ] Error budget calculated and tracked ........................................ (6)
- [ ] Monitoring dashboard accessible (Vercel, UptimeRobot, or equivalent) ....... (6)

**Current SLOs:**

| SLI | SLO Target | Current measurement | Remaining budget |
|-----|------------|---------------------|-----------------|
| Uptime | ___% | ___% | ___% |
| API latency p95 | ≤___ms | ___ms | N/A |
| Error rate | ≤___% | ___% | ___% |

**Subtotal: /30**

---

## Total Score: /100

| Section | Score | /Total |
|---------|-------|--------|
| Structured Logging | | /10 |
| Error Tracking | | /20 |
| Performance Monitoring | | /20 |
| Backup & DR | | /20 |
| SLO & Monitoring | | /30 |
| **TOTAL** | | **/100** |

---

## Recommended tools

| Need | Tool | Plan |
|------|------|------|
| Error tracking | Sentry | Free tier (10k errors/month) |
| RUM | Vercel Speed Insights | Included with Vercel |
| Uptime | UptimeRobot | Free (5 monitors) |
| Backup | Supabase PITR | Pro plan required |
| SLO dashboard | Grafana Cloud | Free tier |

---

## Reference sources

- Google SRE Book — Monitoring Distributed Systems: sre.google/sre-book/monitoring-distributed-systems
- OpenTelemetry: opentelemetry.io/docs
- Sentry Next.js: docs.sentry.io/platforms/javascript/guides/nextjs
- Vercel Speed Insights: vercel.com/docs/speed-insights
