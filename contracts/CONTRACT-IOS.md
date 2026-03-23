# Contract — iOS (SwiftUI)

> SQWR Project Kit contract module.
> Sources: Apple Human Interface Guidelines (developer.apple.com/design/human-interface-guidelines), Swift Documentation (swift.org/documentation), WCAG 2.1 W3C, Apple Accessibility (developer.apple.com/accessibility).

---

## Foundations

**The App Store is the most scrutinized distribution channel in the world.** Apple rejects apps that do not comply with the HIG (Human Interface Guidelines). The rules below are non-negotiable — they condition both App Store approval and perceived quality.

> Source: Apple Human Interface Guidelines — [developer.apple.com/design/human-interface-guidelines](https://developer.apple.com/design/human-interface-guidelines)

---

## 1. Navigation Architecture

> Source: Apple HIG — Navigation (developer.apple.com/design/human-interface-guidelines/navigation-bars)

### Patterns Approved by Apple

| Pattern | Use case | SwiftUI implementation |
|---------|----------|----------------------|
| **Tab Bar** | 3–5 core features, quick access | `TabView` with `.tabItem` |
| **Navigation Stack** | Linear hierarchy (drill-down) | `NavigationStack` + `NavigationLink` |
| **Sheet** | Quick actions < 2 min | `.sheet(isPresented:)` |
| **Drawer / Sidebar** | Secondary features | `NavigationSplitView` |

**Absolute Rules (HIG):**
- Tab Bar: **3–5 items maximum** — beyond this, items become visually inaccessible
- Sheets: **never contain deep navigation** — risk of confusion
- NavigationStack: **depth ≤ 3 levels** recommended (HIG)

```swift
// ✅ Correct Tab Bar structure (3-5 tabs max)
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

## 2. Design Tokens — Mandatory Token System

> Source: Apple HIG — Color (developer.apple.com/design/human-interface-guidelines/color), SwiftUI Documentation

**Fundamental rule: never use hardcoded values.** Always use tokens from the project's design system.

```swift
// ❌ Hardcoded values — FORBIDDEN
Text("Hello")
    .foregroundColor(Color(hex: "#9c5698"))
    .font(.system(size: 24, weight: .bold))

// ✅ Design system tokens
Text("Hello")
    .foregroundColor(IzzicoColors.ownerPrimary)
    .font(IzzicoTypography.heading2)
```

### Recommended Token Structure

```swift
// Colors.swift — All colors as tokens
enum AppColors {
    static let brandPrimary  = Color("BrandPrimary")   // Asset catalog
    static let brandSecondary = Color("BrandSecondary")
    static let textPrimary   = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let background    = Color("Background")
    static let surface       = Color("Surface")

    // Semantic colors (automatically Dark Mode-aware)
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

## 3. Touch Targets — Mandatory Thresholds

> Source: Apple HIG — Buttons (developer.apple.com/design/human-interface-guidelines/buttons)
> Secondary source: W3C WCAG 2.5.5 — Target Size (w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html)

**Absolute threshold: 44×44 pt minimum for any interactive element.**

```swift
// ✅ Touch target 44×44 pt minimum
Button(action: { /* action */ }) {
    Image(systemName: "xmark")
        .frame(width: 44, height: 44)  // HIG target size
        .contentShape(Rectangle())      // Extended tap area
}

// ✅ Enlarge tap area without enlarging the icon
Button(action: { close() }) {
    Image(systemName: "xmark")
        .font(.system(size: 16))
        .padding(12)                   // 16 + 12*2 = 40 ≈ 44pt
        .contentShape(Circle())
}

// ❌ 20×20 pt icon without padding — possible App Store rejection
Button(action: { close() }) {
    Image(systemName: "xmark")
        .font(.system(size: 16))
}
```

---

## 4. Performance — Measurable Thresholds

> Source: Apple HIG — Performance (developer.apple.com/design/human-interface-guidelines/performance)
> Source: WWDC 2023 — "Optimize app power and performance"

| Metric | Threshold | Measurement tool |
|--------|-----------|-----------------|
| **Cold launch time** | < 400ms (target: < 200ms) | Instruments → App Launch |
| **Tap response time** | < 100ms | Instruments → Time Profiler |
| **Frame rate (animations)** | ≥ 60 fps (120fps ProMotion) | Instruments → Core Animation |
| **Binary size** | < 50 MB (recommended) | Archive → App Store Connect |
| **Memory consumption** | < 200 MB (before iOS warning) | Instruments → Allocations |

```swift
// ✅ Lazy loading for long lists
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}

// ✅ Avoid unnecessary re-renders
struct ItemRow: View {
    let item: Item  // Struct (value type) = no unnecessary @ObservedObject

    var body: some View {
        Text(item.title)
    }
}

// ✅ Images — always use AsyncImage with placeholder
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

## 5. iOS Accessibility

> Source: Apple Accessibility — [developer.apple.com/accessibility/ios](https://developer.apple.com/accessibility/ios)
> Source: W3C WCAG 2.1 — SC 1.4.3, 2.5.5

### Dynamic Type — Mandatory

```swift
// ✅ Always use Apple Text Styles (adapt to Dynamic Type)
Text("Title")
    .font(.headline)  // Not .system(size: 18) — fixed and inaccessible

// ✅ If using custom font, use relativeTo for scaling
Text("Body")
    .font(.custom("YourFont", size: 16, relativeTo: .body))

// ❌ Fixed sizes — block accessibility
Text("Title")
    .font(.system(size: 18))  // Does NOT scale with user preferences
```

### VoiceOver

```swift
// ✅ Descriptive accessibility labels
Button(action: { dismiss() }) {
    Image(systemName: "xmark")
}
.accessibilityLabel("Fermer")

// ✅ Group related elements
VStack {
    Text("Samuel Baudon")
    Text("Fondateur")
}
.accessibilityElement(children: .combine)  // Announced as a single element

// ✅ Hide decorative elements
Image("decorative-pattern")
    .accessibilityHidden(true)

// ✅ Logical reading order
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

### Contrast — WCAG Thresholds

```swift
// Verify contrasts with the Xcode Accessibility Inspector tool
// Threshold: 4.5:1 (normal text) — WCAG 2.1 AA mandatory
// Threshold: 3:1 (large text ≥18pt or 14pt bold)

// ✅ Text color on background — always verify
// Example Izzico: Searcher-500 (#FFB10B) on white = insufficient contrast
// → Use Searcher-700 (#B37A07) for text
```

---

## 6. Dark Mode

> Source: Apple HIG — Dark Mode (developer.apple.com/design/human-interface-guidelines/dark-mode)

```swift
// ✅ Asset Catalog — define Light/Dark variants
// Colors.xcassets → Add "Dark" under "Appearances"

// ✅ Automatically adaptive colors
extension Color {
    static let background = Color("Background")
    // Background.light = #FFFFFF, Background.dark = #1C1C1E (iOS default)
}

// ✅ Test with the Environment
#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

// ❌ Fixed color ignoring dark mode
Text("Hello")
    .foregroundColor(.white)  // Invisible in light mode on white background
```

---

## 7. Internationalisation

> Source: Apple HIG — Internationalisation (developer.apple.com/design/human-interface-guidelines/right-to-left)

```swift
// ✅ Never hardcode strings in the UI
// ❌
Text("Bonjour Samuel")

// ✅ Localizable.strings
Text("greeting", tableName: "Localizable")

// Localizable.strings (fr)
"greeting" = "Bonjour %@";

// Localizable.strings (en)
"greeting" = "Hello %@";

// ✅ Dates and numbers with Locale
Text(date.formatted(.dateTime.locale(Locale.current)))

// ✅ RTL support (Arabic, Hebrew) — automatic with SwiftUI
// Never use .leading/.trailing explicitly if not necessary
```

---

## 8. Absolute Rules (Claude Code + iOS Workflow)

> Derived from field experience on SwiftUI + Claude Code projects

### Never do with Claude Code

- **Modify `.pbxproj`** — creates irreparable conflicts. Create Swift files, add them in Xcode manually.
- **Modify `.xcassets`** — provide specs, the human adds them in Xcode.
- **Create `*WebView.swift` files** — everything must be native SwiftUI, never a temporary WebView.
- **Use `SF Symbols` directly** if the project has a custom icon system — breaks visual consistency.

### Always do

```swift
// ✅ Mandatory header comment on every new view
// CONTRACT: v1 (2026-01-15) — synced from /app/dashboard/page.tsx

struct DashboardView: View {
    // ...
}
```

- **Always** use design system tokens, never hardcoded values
- **Always** handle loading / error / empty states in every view
- **Always** respect the Tab Bar 3-5 items (core features only)

---

## 9. Pre-TestFlight Checklist

- [ ] Touch targets ≥ 44×44 pt on all interactive elements
- [ ] Dynamic Type tested (accessibility settings → maximum size)
- [ ] VoiceOver: navigate through the main screens
- [ ] Dark Mode: test in dark on all screens
- [ ] Text contrast verified with Xcode Accessibility Inspector
- [ ] No hardcoded strings in the UI (Localizable.strings)
- [ ] Cold launch < 400ms (Instruments → App Launch)
- [ ] No `console.print(sensitive_data)` in production
- [ ] Binary size < 50 MB (Archive)
- [ ] All images have `.accessibilityHidden(true)` or a label

---

## 10. Sources

| Reference | Link |
|-----------|------|
| Apple Human Interface Guidelines | developer.apple.com/design/human-interface-guidelines |
| Apple Accessibility | developer.apple.com/accessibility/ios |
| SwiftUI Documentation | developer.apple.com/documentation/swiftui |
| W3C WCAG 2.5.5 — Target Size | w3.org/WAI/WCAG22/Understanding/target-size-enhanced |
| W3C WCAG 1.4.3 — Contrast Minimum | w3.org/WAI/WCAG21/Understanding/contrast-minimum |
| WWDC 2023 — App Performance | developer.apple.com/videos/play/wwdc2023 |
| App Store Review Guidelines | developer.apple.com/app-store/review/guidelines |
