# Framework — Conformité Légale EU 2026

> Framework SQWR Project Kit — obligations légales pour startups belges/européennes.
> Sources : Règlement UE 2024/1689 (EU AI Act), EN 301 549, RGPD, Directive NIS2.
> Dernière mise à jour : mars 2026

---

## ⚠️ Urgence — Deadlines imminentes

| Date | Obligation | Impact SQWR |
|------|-----------|------------|
| **28 juin 2025** | **EAA en vigueur** — accessibilité obligatoire pour produits numériques UE | Tous les sites livrés à des clients UE |
| **2 août 2025** | EU AI Act — obligations GPAI (General-Purpose AI) | Tout projet utilisant des APIs LLM |
| **2 août 2026** | EU AI Act — systèmes IA haut-risque (Annexe III) | izzico (matching), CozyGrowth (agents) |

---

## 1. EU AI Act — Classification des usages SQWR

### Classification obligatoire

Avant le 2 août 2026, chaque système IA de SQWR doit être classifié.

| Système | Usage | Classification | Action requise |
|---------|-------|---------------|---------------|
| **CozyGrowth agents** | Génération de contenu marketing pour clubs | Risque limité | Transparence (indiquer IA) |
| **izzico matching** | Matching co-living Seekers/Owners | À évaluer (Annexe III possible) | Évaluation conformité |
| **Claude Code (dev)** | Outil de développement interne | Hors périmètre (usage pro) | Aucune |
| **Chatbots clients** | Si SQWR développe pour clients | Risque limité | Indication IA obligatoire |

### Obligations selon le niveau de risque

**Risque limité (la plupart des usages SQWR) :**
- Informer les utilisateurs qu'ils interagissent avec une IA
- Exemple : "Ce contenu a été généré avec l'assistance de l'IA"

**Haut risque (si Annexe III applicable) :**
- Système de gestion des risques documenté
- Données d'entraînement gouvernées
- Transparence et documentation technique
- Supervision humaine obligatoire
- Exactitude, robustesse, cybersécurité démontrées
- Enregistrement auprès de l'EU AI Act database

**Pénalités :**
- Pratiques interdites : jusqu'à €35M ou 7% CA mondial
- Systèmes haut-risque non conformes : jusqu'à €15M ou 3% CA mondial
- Informations incorrectes : jusqu'à €7.5M ou 1.5% CA mondial

### Checklist EU AI Act (à compléter avant août 2026)

- [ ] Tous les systèmes IA SQWR classifiés
- [ ] Document de classification créé et archivé
- [ ] Mentions légales IA ajoutées dans les interfaces concernées
- [ ] Si haut-risque : évaluation conformité lancée

---

## 2. European Accessibility Act (EAA) — Déjà obligatoire

**Applicable depuis le 28 juin 2025.** Tout produit ou service numérique vendu dans l'UE doit respecter EN 301 549 (= WCAG 2.1 AA dans la pratique).

### Ce que ça signifie pour SQWR

**Chaque site web livré à un client belge/européen engage la responsabilité de SQWR Studio** si le site n'est pas accessible.

### Standards techniques

| Standard | Niveau | Obligation |
|---------|--------|-----------|
| WCAG 2.1 AA | Niveau A + AA | Minimum légal |
| EN 301 549 | v3.2.1 (2021) | Standard technique EU |
| WCAG 2.2 | Recommandé | Cible 2026-2027 |

### Checklist EAA par projet livré

- [ ] Audit AUDIT-ACCESSIBILITY.md réalisé
- [ ] Score ≥80/100 (WCAG 2.1 AA)
- [ ] Contrastes vérifiés (4.5:1 texte, 3:1 éléments UI)
- [ ] Navigation clavier complète
- [ ] Images avec alt text
- [ ] Formulaires avec labels explicites
- [ ] Déclaration d'accessibilité publiée sur le site

### Déclaration d'accessibilité (obligatoire)

Chaque site livré doit publier une déclaration d'accessibilité incluant :
- Le niveau de conformité atteint (AA)
- Les non-conformités connues et leurs solutions alternatives
- Un contact pour signaler des problèmes d'accessibilité
- La date de la dernière évaluation

---

## 3. RGPD — Data Processing Agreements avec fournisseurs IA

**Point critique souvent oublié :** quand SQWR envoie des données utilisateurs à des APIs LLM, ces fournisseurs deviennent des **sous-traitants** au sens du RGPD. Un DPA (Data Processing Agreement) est obligatoire.

| Fournisseur | DPA disponible | Action |
|-------------|---------------|--------|
| **Anthropic** (Claude API) | Oui — anthropic.com/legal/dpa | Signer avant usage prod avec données perso |
| **Vercel** | Oui — vercel.com/legal/dpa | Déjà inclus dans les CGU Pro/Team |
| **Supabase** | Oui — supabase.com/privacy | Inclus dans les plans payants |
| **OpenRouter** | Vérifier — openrouter.ai | Vérifier avant usage avec données clients |
| **Resend** | Oui — resend.com/legal | À signer pour envoi emails utilisateurs |

### Règles de minimisation des données

- Ne pas envoyer d'informations personnelles identifiables (PII) à des LLMs sans nécessité
- Si nécessaire : anonymiser ou pseudonymiser avant l'envoi
- Documenter quelles données sont envoyées à quels fournisseurs

---

## 4. NIS2 — Sécurité Supply Chain

**Applicable depuis octobre 2024.** SQWR peut être soumis à NIS2 indirectement si un client opère dans un secteur critique.

### Secteurs clients NIS2 (nécessitent preuves sécurité)
- Santé (hôpitaux, médecins)
- Finance (banques, assurances)
- Énergie
- Transport
- Eau / infrastructures numériques

### Ce que NIS2 demande aux fournisseurs logiciels
- Politique de sécurité documentée (→ CONTRACT-SECURITY.md + AUDIT-SECURITY.md)
- Gestion des vulnérabilités (→ npm audit SLA, dependency scanning)
- Sécurité de la chaîne d'approvisionnement (→ SBOM, vérification packages)
- Notification d'incidents (< 24h pour incidents significatifs)

### Checklist NIS2 par projet pour client secteur régulé

- [ ] Politique de sécurité documentée (CLAUDE.md + CONTRACT-SECURITY.md)
- [ ] Audit sécurité AUDIT-SECURITY.md réalisé (score ≥70)
- [ ] Dependency scanning en CI (npm audit critical = blocant)
- [ ] Procédure de notification d'incident documentée (INCIDENT-RESPONSE.md)
- [ ] DPA signé avec tous les sous-traitants

---

## 5. ePrivacy — Cookies et Tracking

**Règle principale :** tout tracking analytique nécessite un consentement explicite, sauf si anonyme et sans cookie (= Plausible).

| Solution analytics | Cookie ? | Consentement requis ? | Recommandation SQWR |
|-------------------|---------|----------------------|---------------------|
| **Plausible** | Non | Non — RGPD-native | ✅ Recommandé (sqwr-site) |
| **Vercel Analytics** | Variable | Oui si données perso | ⚠️ Vérifier config |
| **Google Analytics** | Oui | Oui — CMP obligatoire | ❌ Éviter si possible |
| **PostHog** | Oui | Oui — CMP obligatoire | Uniquement si nécessaire |

---

## 6. Registre de conformité SQWR

Maintenir ce registre à jour pour chaque projet actif :

| Projet | EAA audit | EU AI Act classifié | RGPD DPAs signés | NIS2 si applicable |
|--------|-----------|--------------------|-----------------|--------------------|
| sqwr-site | [ ] | N/A | Vercel ✅ | N/A |
| izzico | [ ] | [ ] À évaluer | Vercel ✅ Supabase ✅ | N/A |
| cozygrowth | [ ] | [ ] Risque limité | Vercel ✅ Supabase ✅ Anthropic ☐ | N/A |
| [Projet client] | [ ] | N/A | [ ] | [ ] Si secteur régulé |

---

## Sources

| Référence | Source |
|-----------|--------|
| EU AI Act — Règlement UE 2024/1689 | eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX:32024R1689 |
| EU AI Act — Guide pratique | digital-strategy.ec.europa.eu/fr/policies/regulatory-framework-ai |
| European Accessibility Act | ec.europa.eu/social/main.jsp?catId=1202 |
| EN 301 549 v3.2.1 | etsi.org/deliver/etsi_en/301500_302000/301549 |
| RGPD — CNIL | cnil.fr/fr/rgpd-de-quoi-parle-t-on |
| NIS2 Directive | digital-strategy.ec.europa.eu/en/policies/nis2-directive |
| Anthropic DPA | anthropic.com/legal/data-processing-addendum |
