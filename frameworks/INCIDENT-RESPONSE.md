# Framework — Incident Response & Postmortem

> Framework SQWR Project Kit — inspiré du Google SRE Workbook et PagerDuty.
> Sources : Google SRE Workbook (response.pagerduty.com), PagerDuty Incident Response.
> À utiliser quand un service en production est dégradé ou indisponible.

---

## Principe : Culture Blameless

**Un incident n'est jamais la faute d'une personne. C'est un échec du système.**

Un postmortem qui cherche un coupable ne produit pas de systèmes plus fiables. Un postmortem qui cherche des causes systémiques et des actions concrètes, oui.

> *"The goal is not to find the bad apple. The goal is to find the rotten barrel."* — John Allspaw, Etsy

---

## Partie 1 — Réponse à l'incident (pendant)

### Rôles

Pour une équipe solo/très petite, une personne peut cumuler plusieurs rôles. L'important est de savoir qui fait quoi.

| Rôle | Responsabilité |
|------|---------------|
| **Incident Commander (IC)** | Coordonne la réponse, prend les décisions, déclare la résolution |
| **Ops Lead** | Effectue les actions techniques (rollback, hotfix, restart) |
| **Communications Lead** | Informe les parties prenantes (clients, équipe, uptime page) |

### Timeline de réponse

```
[0 min]   Détection (alerte Sentry, Vercel, signalement utilisateur)
           → Créer un canal/thread dédié à l'incident

[< 5 min] Acknowledgment
           → Quelqu'un a pris en charge l'incident
           → Communication initiale aux parties prenantes si impact utilisateurs

[< 15 min] Évaluation
           → Définir la sévérité (voir ci-dessous)
           → Identifier les systèmes affectés
           → Premier plan de mitigation

[< 30 min] Mitigation ou Escalade
           → Rollback si possible (voir CONTRACT-VERCEL.md)
           → Hotfix si identifiable rapidement
           → Escalade si bloqué

[Résolution] Déclaration de fin d'incident par l'IC
           → Communication finale aux parties prenantes
           → Planification du postmortem (< 48h)
```

### Niveaux de sévérité

| Niveau | Définition | Temps de réponse |
|--------|-----------|-----------------|
| **SEV-1** | Service totalement indisponible, données à risque | < 5 min |
| **SEV-2** | Feature critique dégradée (auth, paiement) | < 15 min |
| **SEV-3** | Feature non-critique dégradée | < 1h |
| **SEV-4** | Bug mineur, impact limité | Sprint suivant |

### Communication pendant l'incident

```markdown
<!-- Template message initial (< 5 min après détection) -->
🔴 INCIDENT EN COURS — [Date/Heure]

**Impact :** [ce que les utilisateurs voient]
**Systèmes affectés :** [Vercel / Supabase / LLM API / ...]
**Statut :** Investigation en cours
**Prochain update dans :** 15 minutes

<!-- Template update intermédiaire -->
🟡 UPDATE — [Date/Heure]

**Cause identifiée :** [description courte]
**Action en cours :** [rollback / hotfix / ...]
**ETA résolution :** [estimation ou "inconnu"]

<!-- Template résolution -->
✅ INCIDENT RÉSOLU — [Date/Heure]

**Durée :** [X minutes/heures]
**Cause :** [résumé en une phrase]
**Postmortem :** prévu le [date]
```

---

## Partie 2 — Postmortem (après)

### Quand faire un postmortem

- Tout incident SEV-1 ou SEV-2 : **obligatoire**
- Tout incident SEV-3 qui se répète : **recommandé**
- Tout incident qui a surpris l'équipe : **recommandé**

**Timing :** dans les 48h suivant la résolution. Passé 48h, les détails s'effacent.

### Template Postmortem Blameless

```markdown
# Postmortem — [Titre court de l'incident]

**Date :** [JJ/MM/AAAA]
**Durée :** [X minutes/heures]
**Sévérité :** SEV-[1/2/3]
**IC :** [nom]
**Auteur postmortem :** [nom]

---

## Résumé

[2-3 phrases max : que s'est-il passé, quel était l'impact, comment c'est résolu]

---

## Impact

- **Utilisateurs affectés :** [nombre ou estimation]
- **Fonctionnalités impactées :** [liste]
- **Durée d'impact :** [X min de dégradation totale]
- **Données perdues :** [oui/non — si oui, lesquelles]

---

## Timeline détaillée

| Heure | Événement |
|-------|-----------|
| HH:MM | [détection — par qui / comment] |
| HH:MM | [première action] |
| HH:MM | [cause identifiée] |
| HH:MM | [mitigation déployée] |
| HH:MM | [incident déclaré résolu] |

---

## Root Cause (5 Whys)

1. **Pourquoi** le service a-t-il échoué ?
   → [réponse]
2. **Pourquoi** [réponse 1] ?
   → [réponse]
3. **Pourquoi** [réponse 2] ?
   → [réponse]
4. **Pourquoi** [réponse 3] ?
   → [réponse]
5. **Pourquoi** [réponse 4] ?
   → **Root cause :** [cause racine systémique]

---

## Ce qui a bien fonctionné

- [élément 1 — ex: alerte Sentry a détecté en 2 min]
- [élément 2]

## Ce qui n'a pas fonctionné

- [élément 1 — ex: procédure de rollback inconnue, a pris 20 min de plus]
- [élément 2]

---

## Action Items (obligatoires — sans action = postmortem inutile)

| Action | Responsable | Deadline | Statut |
|--------|------------|---------|--------|
| [action préventive concrète] | [nom] | [date] | À faire |
| [amélioration monitoring] | [nom] | [date] | À faire |
| [documentation à créer] | [nom] | [date] | À faire |

---

## Lessons Learned

[Ce que ce postmortem apprend sur le système, pas sur les personnes]
```

---

## Partie 3 — Registre des incidents

Maintenir un registre dans le projet concerné pour tracker les incidents et leur résolution.

```markdown
<!-- docs/incidents/INCIDENT-LOG.md -->
# Registre des Incidents

| Date | Sévérité | Durée | Cause | Postmortem | Action Items |
|------|---------|-------|-------|-----------|-------------|
| [JJ/MM] | SEV-2 | 45 min | [cause] | [lien] | [X/Y complétés] |
```

---

## Checklist post-résolution

- [ ] Incident déclaré résolu par l'IC
- [ ] Communication finale envoyée aux parties prenantes
- [ ] Postmortem schedulé dans les 48h
- [ ] Incident loggé dans `docs/incidents/INCIDENT-LOG.md`
- [ ] Action items créés dans le tracker (Linear, GitHub Issues, etc.)
- [ ] ADR créé si la décision de l'incident change l'architecture

---

## Sources

| Référence | Source |
|-----------|--------|
| Google SRE Workbook — Incident Response | sre.google/workbook/incident-response |
| Google SRE Workbook — Postmortem Culture | sre.google/workbook/postmortem-culture |
| PagerDuty Incident Response Docs | response.pagerduty.com |
| Blameless Postmortems — Etsy | codeascraft.com/2012/05/22/blameless-postmortems |
