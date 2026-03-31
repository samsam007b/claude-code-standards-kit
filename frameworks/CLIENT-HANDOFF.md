# Framework — Client Handoff

> Sources: Cloudways Web Agency Standards, Shopify Partner Program Documentation,
> Web Designer Depot Agency Best Practices 2024, frameworks/SLO-TEMPLATE.md.
> When to use: in the 2 weeks before the final delivery of a client project.

---

## Principle

**A successful deployment ≠ a successful client delivery.**

Deployment ensures that the code works in production. Delivery ensures that
the client *owns* what was built for them — the access credentials, documentation, training,
and a clear support plan. A sloppy handoff generates unbilled client support,
misunderstandings about responsibilities, and potential disputes.

**SQWR Rule:** Every client delivery must go through the 5 categories below.
No exceptions, even for "simple" projects.

---

## Category 1 — Access & Credentials

**Absolute rule: never retain a delivered client's credentials.
Everything must be in their hands. Document the transfer date.**

| Access | Transfer Method | Verified |
|--------|----------------|---------|
| **GitHub repo** | Transfer ownership or add client as Admin (Settings → Danger Zone → Transfer) | [ ] |
| **Vercel project** | Invite client email as Member or Owner (Dashboard → Team → Members) | [ ] |
| **Supabase project** | Invite via Dashboard → Settings → Team → Invite member | [ ] |
| **Figma files** | Share via "Move to project" in client workspace OR export + transfer | [ ] |
| **DNS / Registrar** | Domain name transfer OR Admin access to client's registrar account | [ ] |
| **Google Search Console** | Add client email as Owner (not just User) | [ ] |
| **Plausible Analytics** | Add client via shared link OR transfer the site | [ ] |
| **Email/SMTP (Resend)** | Transfer API key access or create a separate client account | [ ] |
| **Environment variables** | Provide a documented `.env.production` (without secrets — explain them) | [ ] |

**Post-transfer:**
- [ ] Revoke or archive SQWR access to client services (unless an active maintenance contract is in place)
- [ ] Note the transfer date in the SQWR internal register

---

## Category 2 — Technical Documentation

Recommended structure of the deliverable folder handed to the client:

```
deliverable-[project-name]-[date]/
├── README-CLIENT.md          → Onboarding guide (non-technical, 1 page)
│
├── docs/
│   ├── ARCHITECTURE.md       → Tech stack, services used, key dependencies
│   ├── ENVIRONMENT.md        → Required environment variables (names + roles, not values)
│   ├── DEPLOYMENT.md         → How to redeploy (commands, Vercel steps)
│   ├── CONTENT-UPDATE.md     → How to update content (CMS, code, or Figma)
│   └── TROUBLESHOOTING.md    → Common issues and documented solutions
│
└── design/
    ├── brand-kit/            → All brand assets (see Category 3)
    └── components-export/    → PNG screenshots of main components
```

### README-CLIENT.md — Target Format

```markdown
# [Project Name] — Getting Started Guide

## What you received

- Website deployed at: [production URL]
- Source code at: [GitHub URL]
- Vercel Dashboard: [URL]
- Database: [Supabase Dashboard URL]

## How to access your website

[Simple instructions, non-technical language]

## How to update content

[Step-by-step instructions based on the stack]

## In case of an issue

Contact SQWR Studio: [your@email.com] | [YOUR PHONE]
Support guaranteed until: [SLA expiry date]
```

---

## Category 3 — Brand Style Guide (if included in the engagement)

Minimum content of a deliverable brand guide:

**Required files:**
- Primary logo — vector SVG + high-resolution PNG (transparent background + white background)
- Black logo (for colored backgrounds) + White logo (for dark backgrounds)
- Favicon — 32×32px, 192×192px, 512×512px (ICO + PNG)

**Documentation:**
- Primary and secondary colors — HEX + RGB + CMYK (for print)
- Exclusion zone (clear space) — minimum space rule around the logo
- Typefaces — font name + license + download link + weights used
- Usage rules — what not to do (visual examples)
- Application examples — business card, web header, email signature, social media

**Delivery format:**
- `/brand-kit/` folder zipped with subfolders by format
- PDF brand guidelines (1–4 pages depending on engagement level)
- Permanent Figma link (if created in Figma) — transfer to client workspace

---

## Category 4 — Training Manual

What the client must be able to do **independently** after delivery:

| Skill | Target Level | Available Support |
|-------|-------------|------------------|
| Access the Vercel dashboard | Independent | Documentation provided |
| Verify that the site is working | Independent | Checklist provided |
| Edit text or images | Independent | Video or step-by-step guide |
| Understand a Sentry alert | Basic awareness | Contact SQWR if > P1 |
| Redeploy after a commit | Basic awareness (if applicable) | DEPLOYMENT.md provided |

**Recommended format:**
- Printable PDF for non-technical users
- Screen recording video (≤ 5 min) for frequent operations
- Onboarding call at delivery (30 min — included in every delivery)

---

## Category 5 — Post-Delivery SLA

### SLA Template to hand to the client at delivery

```markdown
# Post-Delivery Support SLA — [Project Name]

**Client:** [Client Name]
**Delivery date:** [DD/MM/YYYY]
**Included support period:** [30 / 60 / 90 days] from the delivery date
**Expiry date:** [DD/MM/YYYY]

---

## Guaranteed response times

| Request type | Response time | Resolution time |
|-------------|--------------|-----------------|
| Critical (site inaccessible, data lost) | < 4 business hours | < 24h |
| Functional (broken feature, visible bug) | < 1 business day | < 3 business days |
| Usage question | < 2 business days | Response = resolution |

*Business hours: Monday–Friday, 9am–6pm (CET/CEST)*

---

## What is covered

- Bug fixes introduced during SQWR development
- Usage questions about delivered features
- Minor content adjustments (< 30 min per request)

## What is NOT covered

- New features (separate quote required)
- Design changes requested after final sign-off
- Issues caused by client modifications to code or configuration
- Dependency updates outside of critical security patches
- Issues related to third-party services (Vercel, Supabase, Resend) outside our control

---

## Contact

- Email: [your@email.com]
- Phone: [YOUR PHONE]
- Monday–Friday, 9am–6pm (critical emergencies: 7 days/7)

## After the support period

Monthly maintenance contract available on request.
Includes: dependency updates, monitoring, 2h of changes/month.
```

---

## Complete Handoff Checklist

### Before the delivery meeting

**Technical:**
- [ ] `AUDIT-DEPLOYMENT.md` completed (final score documented)
- [ ] `AUDIT-ACCESSIBILITY.md` ≥ 80/100 (legal obligation EAA since June 2025)
- [ ] `AUDIT-SECURITY.md` ≥ 70/100 (blocking threshold)
- [ ] `npm audit --audit-level=critical` passes (zero critical vulnerabilities)
- [ ] Lighthouse Performance ≥ 85 in production

**Access:**
- [ ] All Category 1 accesses transferred or scheduled for transfer
- [ ] Documented `.env.production` environment handed to client

**Documentation:**
- [ ] `/deliverable-[project]/` folder created and complete (README-CLIENT + docs/ + design/)
- [ ] Brand Style Guide exported (if applicable to the engagement)
- [ ] Training Manual ready (PDF or video)
- [ ] Post-delivery SLA prepared and dated

### During the delivery meeting (30–60 min)

- [ ] Full demonstration of the site/app to the client
- [ ] Walkthrough of main access points (Vercel, Supabase if applicable)
- [ ] Delivery of the deliverable folder (Google Drive link or download link)
- [ ] Explanation of the SLA (support period, what is included/excluded)
- [ ] Q&A
- [ ] Confirmation email scheduled (or sent in real time)

### After the delivery meeting

- [ ] Summary email sent to client (access + SLA + contacts + docs link)
- [ ] Project archived in the internal SQWR Studio folder
- [ ] Client credentials removed from SQWR local tools (1Password, etc.)
- [ ] Internal satisfaction note created (what went well / what to improve)
- [ ] Final invoice issued if applicable

---

## SQWR Delivery Register

Keep up to date in the internal SQWR Studio folder:

| Project | Client | Delivery date | SLA expires | Maintenance contract | Notes |
|---------|--------|--------------|------------|---------------------|-------|
| La Villa | [client] | 2024 | Expired | No | |
| Nanou Mendels | [client] | 2025 | Expired | No | |
| Villa Coladeira | [client] | 2025 | [verify] | [verify] | |

---

## Sources

| Reference | Link |
|-----------|------|
| Cloudways — Agency Website Handoff | cloudways.com/blog/web-design-project-handoff |
| Shopify Partner Program — Delivery Standards | shopify.com/partners/blog/project-handoff |
| Web Designer Depot — Client Handoff | webdesignerdepot.com/2024/client-website-handoff |
| SQWR SLO Template | frameworks/SLO-TEMPLATE.md |
| European Accessibility Act (EAA) | frameworks/COMPLIANCE-EU.md |
