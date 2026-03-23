# Contrat — iOS (SwiftUI)

> Module de contrat SQWR Project Kit.
> Sources : Apple Human Interface Guidelines (developer.apple.com/design/human-interface-guidelines), Swift Documentation (swift.org/documentation), WCAG 2.1 W3C, Apple Accessibility (developer.apple.com/accessibility).

---

## Fondements

**L'App Store est le canal de distribution le plus scruté au monde.** Apple rejette les apps ne respectant pas les HIG (Human Interface Guidelines). Les règles ci-dessous sont non-négociables — elles conditionnent à la fois l'approbation App Store et la qualité perçue.

> Source : Apple Human Interface Guidelines — [developer.apple.com/design/human-interface-guidelines](https://developer.apple.com/design/human-interface-guidelines)

---

## 1. Architecture de Navigation

> Source : Apple HIG — Navigation (developer.apple.com/design/human-interface-guidelines/navigation-bars)

### Patterns validés par Apple

| Pattern | Cas d'usage | Implémentation SwiftUI |
|---------|-------------|----------------------|
| **Tab Bar** | 3–5 features core, accès rapide | `TabView` avec `.tabItem` |
| **Navigation Stack** | Hiérarchie linéaire (drill-down) | `NavigationStack` + `NavigationLink` |
| **Sheet** | Actions rapides < 2 min | `.sheet(isPresented:)` |
| **Drawer / Sidebar** | Features secondaires | `NavigationSplitView` |

**Règles absolues (HIG) :**
- Tab Bar : **3–5 items maximum** — au-delà, les items sont inaccessibles visuellement
- Sheets : **ne jamais contenir de navigation profonde** — risque de confusion
- NavigationStack : **profondeur ≤ 3 niveaux** recommandée (HIG)

```swift
// ✅ Structure Tab Bar correcte (3-5 tabs max)
TabView(selection: $selectedTab) {
    HomeView()
        .tabItem {
            Label("Accueil", systemImage: "house.fill")
        }
        .tag(Tab.home)

    MessagesView()
        .tabItem {
            Label("Messages", systemImage: "message.fill")
        }
        .tag(Tab.messages)

    ProfileView()
        .tabItem {
            Label("Profil", systemImage: "person.fill")
        }
        .tag(Tab.profile)
}
```

---

## 2. Design Tokens — Système de Tokens Obligatoire

> Source : Apple HIG — Color (developer.apple.com/design/human-interface-guidelines/color), SwiftUI Documentation

**Règle fondamentale : jamais de valeurs hardcodées.** Toujours utiliser les tokens du design system du projet.

```swift
// ❌ Valeurs hardcodées — INTERDIT
Text("Hello")
    .foregroundColor(Color(hex: "#9c5698"))
    .font(.system(size: 24, weight: .bold))

// ✅ Tokens du design system
Text("Hello")
    .foregroundColor(IzzicoColors.ownerPrimary)
    .font(IzzicoTypography.heading2)
```

### Structure de tokens recommandée

```swift
// Colors.swift — Toutes les couleurs comme tokens
enum AppColors {
    static let brandPrimary  = Color("BrandPrimary")   // Asset catalog
    static let brandSecondary = Color("BrandSecondary")
    static let textPrimary   = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let background    = Color("Background")
    static let surface       = Color("Surface")

    // Semantic colors (automatiquement Dark Mode-aware)
    static let error   = Color.red
    static let success = Color.green
    static let warning = Color.orange
}

// Typography.swift
enum AppTypography {
    static let display = Font.custom("YourFont", size: 48).weight(.bold)
    static let heading1 = Font.custom("YourFont", size: 32).weight(.bold)
    static let heading2 = Font.custom("YourFont", size: 24).weight(.semibold)
    static let body     = Font.custom("YourFont", size: 16).weight(.regular)
    static let caption  = Font.custom("YourFont", size: 12).weight(.regular)
}

// Spacing.swift
enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

---

## 3. Touch Targets — Thresholds Obligatoires

> Source : Apple HIG — Buttons (developer.apple.com/design/human-interface-guidelines/buttons)
> Source secondaire : W3C WCAG 2.5.5 — Target Size (w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html)

**Threshold absolu : 44×44 pt minimum pour tout élément interactif.**

```swift
// ✅ Touch target 44×44 pt minimum
Button(action: { /* action */ }) {
    Image(systemName: "xmark")
        .frame(width: 44, height: 44)  // Target size HIG
        .contentShape(Rectangle())      // Zone de tap étendue
}

// ✅ Agrandir le tap area sans agrandir l'icône
Button(action: { close() }) {
    Image(systemName: "xmark")
        .font(.system(size: 16))
        .padding(12)                   // 16 + 12*2 = 40 ≈ 44pt
        .contentShape(Circle())
}

// ❌ Icône 20×20 pt sans padding — refus App Store possible
Button(action: { close() }) {
    Image(systemName: "xmark")
        .font(.system(size: 16))
}
```

---

## 4. Performance — Thresholds Mesurables

> Source : Apple HIG — Performance (developer.apple.com/design/human-interface-guidelines/performance)
> Source : WWDC 2023 — "Optimize app power and performance"

| Métrique | Threshold | Outil de mesure |
|----------|-----------|-----------------|
| **Temps de lancement à froid** | < 400ms (cible : < 200ms) | Instruments → App Launch |
| **Temps de réponse au tap** | < 100ms | Instruments → Time Profiler |
| **Frame rate (animations)** | ≥ 60 fps (120fps ProMotion) | Instruments → Core Animation |
| **Taille binaire** | < 50 MB (recommandé) | Archive → App Store Connect |
| **Consommation mémoire** | < 200 MB (avant warning iOS) | Instruments → Allocations |

```swift
// ✅ Chargement lazy pour listes longues
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}

// ✅ Éviter les re-renders inutiles
struct ItemRow: View {
    let item: Item  // Struct (value type) = pas de @ObservedObject inutile

    var body: some View {
        Text(item.title)
    }
}

// ✅ Images — toujours utiliser AsyncImage avec placeholder
AsyncImage(url: URL(string: item.imageUrl)) { phase in
    switch phase {
    case .success(let image):
        image.resizable().scaledToFill()
    case .failure:
        Color.gray.opacity(0.2)
    case .empty:
        ProgressView()
    @unknown default:
        EmptyView()
    }
}
.frame(width: 60, height: 60)
.clipShape(Circle())
```

---

## 5. Accessibilité iOS

> Source : Apple Accessibility — [developer.apple.com/accessibility/ios](https://developer.apple.com/accessibility/ios)
> Source : W3C WCAG 2.1 — SC 1.4.3, 2.5.5

### Dynamic Type — Obligatoire

```swift
// ✅ Toujours utiliser les Text Styles Apple (s'adaptent au Dynamic Type)
Text("Titre")
    .font(.headline)  // Pas .system(size: 18) — fixe et inaccessible

// ✅ Si police custom, utiliser relativeTo pour scaling
Text("Corps")
    .font(.custom("YourFont", size: 16, relativeTo: .body))

// ❌ Tailles fixes — bloquent l'accessibilité
Text("Titre")
    .font(.system(size: 18))  // Ne scale PAS avec les prefs utilisateur
```

### VoiceOver

```swift
// ✅ Labels accessibilité descriptifs
Button(action: { dismiss() }) {
    Image(systemName: "xmark")
}
.accessibilityLabel("Fermer")

// ✅ Grouper les éléments liés
VStack {
    Text("Samuel Baudon")
    Text("Fondateur")
}
.accessibilityElement(children: .combine)  // Annoncé comme un seul élément

// ✅ Cacher les éléments décoratifs
Image("decorative-pattern")
    .accessibilityHidden(true)

// ✅ Ordre de lecture logique
HStack {
    Image("avatar")
    VStack {
        Text(user.name)
        Text(user.role)
    }
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(user.name), \(user.role)")
```

### Contraste — Thresholds WCAG

```swift
// Vérifier les contrastes avec l'outil Xcode Accessibility Inspector
// Threshold : 4.5:1 (texte normal) — WCAG 2.1 AA obligatoire
// Threshold : 3:1 (grand texte ≥18pt ou 14pt bold)

// ✅ Couleur texte sur fond — toujours vérifier
// Exemple Izzico : Searcher-500 (#FFB10B) sur blanc = contraste insuffisant
// → Utiliser Searcher-700 (#B37A07) pour le texte
```

---

## 6. Dark Mode

> Source : Apple HIG — Dark Mode (developer.apple.com/design/human-interface-guidelines/dark-mode)

```swift
// ✅ Asset Catalog — définir les variantes Light/Dark
// Colors.xcassets → Ajouter "Dark" dans "Appearances"

// ✅ Couleurs adaptatives automatiques
extension Color {
    static let background = Color("Background")
    // Background.light = #FFFFFF, Background.dark = #1C1C1E (iOS default)
}

// ✅ Tester avec l'Environment
#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

// ❌ Couleur fixe ignorant le dark mode
Text("Hello")
    .foregroundColor(.white)  // Invisible en light mode sur fond blanc
```

---

## 7. Internationalisation

> Source : Apple HIG — Internationalisation (developer.apple.com/design/human-interface-guidelines/right-to-left)

```swift
// ✅ Jamais de strings hardcodées dans l'UI
// ❌
Text("Bonjour Samuel")

// ✅ Localizable.strings
Text("greeting", tableName: "Localizable")

// Localizable.strings (fr)
"greeting" = "Bonjour %@";

// Localizable.strings (en)
"greeting" = "Hello %@";

// ✅ Dates et nombres avec Locale
Text(date.formatted(.dateTime.locale(Locale.current)))

// ✅ Support RTL (arabe, hébreu) — automatique avec SwiftUI
// Ne jamais utiliser .leading/.trailing explicitement si pas nécessaire
```

---

## 8. Règles Absolues (Workflow Claude Code + iOS)

> Issu de l'expérience terrain sur projets SwiftUI + Claude Code

### Ne jamais faire avec Claude Code

- **Modifier `.pbxproj`** — crée des conflits irréparables. Créer les fichiers Swift, les ajouter dans Xcode manuellement.
- **Modifier `.xcassets`** — fournir les specs, l'humain ajoute dans Xcode.
- **Créer des fichiers `*WebView.swift`** — tout doit être SwiftUI natif, jamais de WebView temporaire.
- **Utiliser `SF Symbols` directement** si le projet a un icon system custom — cohérence visuelle brisée.

### Toujours faire

```swift
// ✅ Header comment obligatoire sur chaque nouvelle vue
// CONTRACT: v1 (2026-01-15) — synced from /app/dashboard/page.tsx

struct DashboardView: View {
    // ...
}
```

- **Toujours** utiliser les tokens du design system, jamais de valeurs hardcodées
- **Toujours** gérer les états loading / error / empty dans chaque vue
- **Toujours** respecter le Tab Bar 3-5 items (features core uniquement)

---

## 9. Checklist pré-TestFlight

- [ ] Touch targets ≥ 44×44 pt sur tous les éléments interactifs
- [ ] Dynamic Type testé (accessibility settings → taille max)
- [ ] VoiceOver : parcourir les écrans principaux
- [ ] Dark Mode : tester en dark sur tous les écrans
- [ ] Contraste texte vérifié avec Xcode Accessibility Inspector
- [ ] Pas de strings hardcodées dans l'UI (Localizable.strings)
- [ ] Lancement à froid < 400ms (Instruments → App Launch)
- [ ] Pas de `console.print(sensitive_data)` en production
- [ ] Taille binaire < 50 MB (Archive)
- [ ] Toutes les images ont `.accessibilityHidden(true)` ou un label

---

## 10. Sources

| Référence | Lien |
|-----------|------|
| Apple Human Interface Guidelines | developer.apple.com/design/human-interface-guidelines |
| Apple Accessibility | developer.apple.com/accessibility/ios |
| SwiftUI Documentation | developer.apple.com/documentation/swiftui |
| W3C WCAG 2.5.5 — Target Size | w3.org/WAI/WCAG22/Understanding/target-size-enhanced |
| W3C WCAG 1.4.3 — Contrast Minimum | w3.org/WAI/WCAG21/Understanding/contrast-minimum |
| WWDC 2023 — App Performance | developer.apple.com/videos/play/wwdc2023 |
| App Store Review Guidelines | developer.apple.com/app-store/review/guidelines |
