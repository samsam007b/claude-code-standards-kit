# Framework — Client Handoff

> Sources : Cloudways Web Agency Standards, Shopify Partner Program Documentation,
> Web Designer Depot Agency Best Practices 2024, frameworks/SLO-TEMPLATE.md.
> À utiliser : dans les 2 semaines précédant la livraison finale d'un projet client.

---

## Principe

**Un déploiement réussi ≠ une livraison client réussie.**

Le déploiement s'assure que le code fonctionne en production. La livraison s'assure que
le client *possède* ce qu'on lui a construit — les accès, la documentation, la formation,
et un plan de support clair. Un handoff bâclé génère du support client non facturé,
des malentendus sur les responsabilités, et des litiges potentiels.

**Règle SQWR :** Toute livraison client doit passer par les 5 catégories ci-dessous.
Aucune exception, même pour des projets "simples".

---

## Catégorie 1 — Accès & Credentials

**Règle absolue : ne jamais conserver les credentials d'un client livré.
Tout doit être entre ses mains. Documenter la date de transfert.**

| Accès | Méthode de transfert | Vérifié |
|-------|---------------------|---------|
| **GitHub repo** | Transférer l'ownership ou ajouter client comme Admin (Settings → Danger Zone → Transfer) | [ ] |
| **Vercel project** | Inviter email client comme Member ou Owner (Dashboard → Team → Members) | [ ] |
| **Supabase project** | Inviter via Dashboard → Settings → Team → Invite member | [ ] |
| **Figma files** | Partager via "Move to project" dans le workspace client OU exporter + transférer | [ ] |
| **DNS / Registrar** | Transfert de nom de domaine OU accès Admin au compte registrar du client | [ ] |
| **Google Search Console** | Ajouter l'email client comme Owner (pas seulement User) | [ ] |
| **Plausible Analytics** | Ajouter client via shared link OU transférer le site | [ ] |
| **Email/SMTP (Resend)** | Transférer l'accès à l'API key ou créer un compte client séparé | [ ] |
| **Variables d'environnement** | Fournir un `.env.production` documenté (sans secrets — les expliquer) | [ ] |

**Post-transfert :**
- [ ] Révoquer ou archiver les accès SQWR aux services du client (sauf si contrat maintenance actif)
- [ ] Noter la date de transfert dans le registre interne SQWR

---

## Catégorie 2 — Documentation Technique

Structure recommandée du dossier livré au client :

```
livrable-[nom-projet]-[date]/
├── README-CLIENT.md          → Guide de prise en main (non-technique, 1 page)
│
├── docs/
│   ├── ARCHITECTURE.md       → Stack technique, services utilisés, dépendances clés
│   ├── ENVIRONMENT.md        → Variables d'environnement requises (noms + rôles, pas les valeurs)
│   ├── DEPLOYMENT.md         → Comment re-déployer (commandes, étapes Vercel)
│   ├── CONTENT-UPDATE.md     → Comment modifier le contenu (CMS, code, ou Figma)
│   └── TROUBLESHOOTING.md    → Problèmes fréquents et solutions documentées
│
└── design/
    ├── brand-kit/            → Tous les assets de marque (voir Catégorie 3)
    └── components-export/    → Screenshots PNG des composants principaux
```

### README-CLIENT.md — Format cible

```markdown
# [Nom du projet] — Guide de démarrage

## Ce que vous avez reçu

- Site web déployé sur : [URL de production]
- Code source sur : [URL GitHub]
- Dashboard Vercel : [URL]
- Base de données : [URL Supabase Dashboard]

## Comment accéder à votre site

[Instructions simples, langage non-technique]

## Comment modifier le contenu

[Instructions pas-à-pas selon la stack]

## En cas de problème

Contacter SQWR Studio : studio@sqwr.be | +32 493 30 27 52
Support garanti jusqu'au : [date expiration SLA]
```

---

## Catégorie 3 — Brand Style Guide (si inclus dans la mission)

Contenu minimum d'un brand guide livrable :

**Fichiers obligatoires :**
- Logo principal — SVG vectoriel + PNG haute résolution (fond transparent + fond blanc)
- Logo noir (pour fonds colorés) + Logo blanc (pour fonds foncés)
- Favicon — 32×32px, 192×192px, 512×512px (ICO + PNG)

**Documentation :**
- Couleurs primaires et secondaires — HEX + RGB + CMJN (pour print)
- Zone d'exclusion (clear space) — règle de l'espace minimum autour du logo
- Typographies — nom de la police + licence + lien téléchargement + graisses utilisées
- Règles d'usage — ce qu'il ne faut pas faire (exemples visuels)
- Exemples d'application — carte de visite, header web, signature email, réseaux sociaux

**Format de livraison :**
- Dossier `/brand-kit/` zippé avec sous-dossiers par format
- PDF brand guidelines (1-4 pages selon le niveau de mission)
- Lien Figma permanent (si créé dans Figma) — transférer vers workspace client

---

## Catégorie 4 — Training Manual

Ce que le client doit pouvoir faire **seul** après livraison :

| Compétence | Niveau cible | Support disponible |
|-----------|-------------|-------------------|
| Accéder au dashboard Vercel | Autonome | Documentation fournie |
| Vérifier que le site fonctionne | Autonome | Checklist fournie |
| Modifier du texte ou des images | Autonome | Vidéo ou guide pas-à-pas |
| Comprendre une alerte Sentry | Notion de base | Contacter SQWR si > P1 |
| Re-déployer après un commit | Notion de base (si applicable) | DEPLOYMENT.md fourni |

**Format recommandé :**
- PDF imprimable pour les non-techniques
- Vidéo screen recording (≤ 5 min) pour les opérations fréquentes
- Chat de prise en main à la livraison (30 min — inclus dans toute livraison)

---

## Catégorie 5 — SLA Post-Livraison SQWR

### Template SLA à remettre au client à la livraison

```markdown
# SLA Support Post-Livraison — [Nom du projet]

**Client :** [Nom du client]
**Date de livraison :** [JJ/MM/AAAA]
**Période de support incluse :** [30 / 60 / 90 jours] à compter de la date de livraison
**Date d'expiration :** [JJ/MM/AAAA]

---

## Délais de réponse garantis

| Type de demande | Délai de réponse | Délai de résolution |
|----------------|-----------------|---------------------|
| Critique (site inaccessible, données perdues) | < 4h ouvrables | < 24h |
| Fonctionnel (feature cassée, bug visible) | < 1 jour ouvrable | < 3 jours ouvrables |
| Question d'utilisation | < 2 jours ouvrables | Réponse = résolution |

*Heures ouvrables : lundi-vendredi, 9h-18h (CET/CEST)*

---

## Ce qui est couvert

- Correction de bugs introduits lors du développement SQWR
- Questions d'utilisation sur les fonctionnalités livrées
- Ajustements mineurs de contenu (< 30 min par demande)

## Ce qui n'est PAS couvert

- Nouvelles fonctionnalités (devis séparé requis)
- Modifications de design demandées après validation finale
- Problèmes causés par des modifications du client sur le code ou la config
- Mises à jour de dépendances hors correctifs de sécurité critiques
- Problèmes liés à des services tiers (Vercel, Supabase, Resend) hors de notre contrôle

---

## Contact

- Email : studio@sqwr.be
- Téléphone : +32 493 30 27 52
- Lundi–Vendredi, 9h–18h (urgences critiques : 7j/7)

## Après la période de support

Contrat de maintenance mensuel disponible sur devis.
Inclut : mises à jour de dépendances, monitoring, 2h de modifications/mois.
```

---

## Checklist Handoff Complète

### Avant la réunion de livraison

**Technique :**
- [ ] `AUDIT-DEPLOYMENT.md` complété (score final documenté)
- [ ] `AUDIT-ACCESSIBILITY.md` ≥ 80/100 (obligation légale EAA depuis juin 2025)
- [ ] `AUDIT-SECURITY.md` ≥ 70/100 (seuil blocant)
- [ ] `npm audit --audit-level=critical` passe (zéro vulnérabilité critique)
- [ ] Performance Lighthouse ≥ 85 en production

**Accès :**
- [ ] Tous les accès de la Catégorie 1 transférés ou programmés pour transfert
- [ ] Environnement `.env.production` documenté remis au client

**Documentation :**
- [ ] Dossier `/livrable-[projet]/` créé et complet (README-CLIENT + docs/ + design/)
- [ ] Brand Style Guide exporté (si applicable à la mission)
- [ ] Training Manual prêt (PDF ou vidéo)
- [ ] SLA post-livraison préparé et daté

### Pendant la réunion de livraison (30-60 min)

- [ ] Démonstration complète du site/app au client
- [ ] Walkthrough des accès principaux (Vercel, Supabase si applicable)
- [ ] Remise du dossier livrable (lien Google Drive ou lien de téléchargement)
- [ ] Explication du SLA (période de support, ce qui est inclus/exclu)
- [ ] Questions/réponses
- [ ] Email de confirmation planifié (ou envoyé en direct)

### Après la réunion de livraison

- [ ] Email récapitulatif envoyé au client (accès + SLA + contacts + lien docs)
- [ ] Projet archivé dans le dossier interne SQWR Studio
- [ ] Credentials clients supprimés des outils SQWR locaux (1Password, etc.)
- [ ] Note de satisfaction interne créée (ce qui a bien marché / à améliorer)
- [ ] Facture finale émise si applicable

---

## Registre des livraisons SQWR

Tenir à jour dans le dossier interne SQWR Studio :

| Projet | Client | Date livraison | SLA expire | Contrat maint. | Notes |
|--------|--------|---------------|-----------|----------------|-------|
| La Villa | [client] | 2024 | Expiré | Non | |
| Nanou Mendels | [client] | 2025 | Expiré | Non | |
| Villa Coladeira | [client] | 2025 | [vérifier] | [vérifier] | |

---

## Sources

| Référence | Lien |
|-----------|------|
| Cloudways — Agency Website Handoff | cloudways.com/blog/web-design-project-handoff |
| Shopify Partner Program — Delivery Standards | shopify.com/partners/blog/project-handoff |
| Web Designer Depot — Client Handoff | webdesignerdepot.com/2024/client-website-handoff |
| SQWR SLO Template | frameworks/SLO-TEMPLATE.md |
| European Accessibility Act (EAA) | frameworks/COMPLIANCE-EU.md |
