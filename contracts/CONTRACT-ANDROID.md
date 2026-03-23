# Contract — Android (Jetpack Compose)

> SQWR Project Kit contract module.
> Sources: Material Design 3 (m3.material.io), Android Developers docs (developer.android.com), Jetpack Compose docs (developer.android.com/jetpack/compose), Google Play Console — Android Vitals (developer.android.com/topic/performance/vitals), Google Play target API requirements (2024), Statcounter Global Stats (gs.statcounter.com).

---

## Foundations

**Android holds 72% of the global mobile market** (Statcounter, 2024). Jetpack Compose is the official modern Android UI toolkit since Google I/O 2021. Material Design 3 (Material You) is the official design system since Android 12.

This contract is the Android counterpart of `CONTRACT-IOS.md`. Both must coexist on cross-platform projects.

---

## 1. Setup — Jetpack Compose + Material 3

> Source: Android Developers — Compose setup (developer.android.com/jetpack/compose/setup)

```kotlin
// build.gradle.kts (app module)
android {
    compileSdk = 35
    defaultConfig {
        minSdk = 24        // covers 97% of active devices (Android Developers dashboard)
        targetSdk = 35     // mandatory since August 2024 (Play Store policy)
    }
    buildFeatures { compose = true }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.10"
    }
}

dependencies {
    // BOM — manages all Compose versions consistently
    val composeBom = platform("androidx.compose:compose-bom:2024.05.00")
    implementation(composeBom)

    // Material Design 3
    implementation("androidx.compose.material3:material3")

    // Compose UI
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")

    // Navigation
    implementation("androidx.navigation:navigation-compose:2.8.0")

    // ViewModel
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.0")

    debugImplementation("androidx.compose.ui:ui-tooling")
}
```

---

## 2. Material Design 3 — Theme and Tokens

> Source: Material Design 3 — Color system (m3.material.io/styles/color/system/how-the-system-works)

**Absolute Rule: never hardcode colors.** Always use `MaterialTheme.colorScheme`.

```kotlin
// ui/theme/Theme.kt
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import android.os.Build

private val LightColorScheme = lightColorScheme(
    primary = Color(0xFF000000),
    onPrimary = Color(0xFFFFFFFF),
    secondary = Color(0xFF6650A4),
    background = Color(0xFFFFFBFE),
    surface = Color(0xFFFFFBFE),
)

private val DarkColorScheme = darkColorScheme(
    primary = Color(0xFFFFFFFF),
    onPrimary = Color(0xFF000000),
    secondary = Color(0xFFCCC2DC),
    background = Color(0xFF1C1B1F),
    surface = Color(0xFF1C1B1F),
)

@Composable
fun AppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,  // Material You — Android 12+
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context)
            else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = AppTypography,  // define in Typography.kt
        content = content
    )
}
```

```kotlin
// Correct token usage
// ✅ Always via MaterialTheme
Text(text = "Title", color = MaterialTheme.colorScheme.onBackground)
Surface(color = MaterialTheme.colorScheme.surface) { ... }

// ❌ Never hardcoded
Text(text = "Title", color = Color(0xFF1C1B1F))
```

---

## 3. Navigation — Compose Navigation

> Source: Android Developers — Navigate with Compose (developer.android.com/jetpack/compose/navigation)

```kotlin
// navigation/AppNavHost.kt
import androidx.navigation.compose.*
import kotlinx.serialization.Serializable

// Type-safe routes — Navigation 2.8+ (Kotlin Serialization)
@Serializable object HomeRoute
@Serializable object ProfileRoute
@Serializable data class DetailRoute(val id: String)

@Composable
fun AppNavHost(navController: NavHostController = rememberNavController()) {
    NavHost(navController = navController, startDestination = HomeRoute) {
        composable<HomeRoute> { HomeScreen(navController) }
        composable<ProfileRoute> { ProfileScreen() }
        composable<DetailRoute> { backStackEntry ->
            val route: DetailRoute = backStackEntry.toRoute()
            DetailScreen(id = route.id)
        }
    }
}

// Bottom Navigation — 3 to 5 items (Material Design 3 spec)
@Composable
fun AppBottomBar(navController: NavHostController) {
    NavigationBar {
        NavigationBarItem(
            icon = { Icon(Icons.Default.Home, contentDescription = "Home") },
            label = { Text("Home") },
            selected = /* currentRoute == HomeRoute */,
            onClick = { navController.navigate(HomeRoute) }
        )
        // 2-4 other items max
    }
}
```

---

## 4. Touch Targets — Accessibility

> Source: Material Design 3 — Accessibility (m3.material.io/foundations/accessible-design/accessibility-basics)
> **Threshold: 48×48dp minimum** for any interactive element (Android — vs 44pt on iOS)

```kotlin
// ✅ Minimum 48dp — Modifier.minimumInteractiveComponentSize() (Compose 1.3+)
IconButton(
    onClick = { /* action */ },
    modifier = Modifier.minimumInteractiveComponentSize()  // guarantees 48×48dp
) {
    Icon(Icons.Default.Close, contentDescription = "Close")
}

// ✅ Enlarge the tap zone without enlarging the icon
Box(
    modifier = Modifier
        .size(48.dp)
        .clickable { /* action */ },
    contentAlignment = Alignment.Center
) {
    Icon(Icons.Default.Add, contentDescription = "Add", modifier = Modifier.size(24.dp))
}

// ❌ Icon without padding — tap zone = icon size
Icon(Icons.Default.Close, contentDescription = "Close")
```

---

## 5. Accessibility — TalkBack

> Source: Android Accessibility (developer.android.com/guide/topics/ui/accessibility/principles)

```kotlin
// ✅ contentDescription mandatory on non-text elements
Icon(
    imageVector = Icons.Default.Favorite,
    contentDescription = "Add to favorites",  // announced by TalkBack
    tint = MaterialTheme.colorScheme.primary
)

// ✅ Hide decorative elements
Icon(
    imageVector = Icons.Default.CheckCircle,
    contentDescription = null,  // null = ignored by TalkBack (decorative)
)

// ✅ Group related elements for TalkBack
Column(modifier = Modifier.semantics(mergeDescendants = true) {}) {
    Text(text = "Samuel Baudon")
    Text(text = "Developer", color = MaterialTheme.colorScheme.onSurfaceVariant)
}
// TalkBack reads "Samuel Baudon, Developer" as a single element

// ✅ Add context for actions
Button(
    onClick = { deleteItem(item.id) },
    modifier = Modifier.semantics {
        contentDescription = "Delete ${item.name}"  // context > "Delete"
    }
) {
    Text("Delete")
}
```

**Testing TalkBack:** Android Settings → Accessibility → TalkBack. Navigate the app without looking at the screen.

---

## 6. Performance — Android Vitals

> Source: Android Vitals (developer.android.com/topic/performance/vitals)
> **Play Store Threshold: ANR rate <0.47%, crash rate <1.09%** (beyond = "Poor quality" badge)

```kotlin
// Cold start — target <500ms (Android Vitals)
// Avoid blocking operations in Application.onCreate()

// ✅ Heavy operations in the background
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // No I/O, no network here
        // Initialize lightweight singletons only
    }
}

// ✅ remember and derivedStateOf — avoid unnecessary recompositions
@Composable
fun ExpensiveList(items: List<Item>, filter: String) {
    // derivedStateOf: only recalculates if items or filter changes
    val filteredItems by remember(items, filter) {
        derivedStateOf { items.filter { it.name.contains(filter) } }
    }
    LazyColumn {
        items(filteredItems) { item -> ItemRow(item) }
    }
}

// ✅ LazyColumn mandatory for lists (never Column for > 20 items)
LazyColumn {
    items(longList) { item -> ItemCard(item) }
}
// ❌ Column for a long list — everything is composed even off-screen
Column { longList.forEach { item -> ItemCard(item) } }
```

---

## 7. Dark Theme

```kotlin
// ✅ isSystemInDarkTheme() — respects system preference
@Composable
fun StatusIndicator(isActive: Boolean) {
    val backgroundColor = if (isActive) {
        MaterialTheme.colorScheme.primaryContainer
    } else {
        MaterialTheme.colorScheme.surfaceVariant
    }
    // backgroundColor adapts automatically to dark theme via colorScheme
    Box(modifier = Modifier.background(backgroundColor, shape = CircleShape))
}
```

---

## 8. Absolute Rules — Android

```
❌ NEVER modify generated files (R.java, files in build/)
❌ NEVER call network or I/O on the Main Thread → StrictMode will block
❌ NEVER store UI state in Activity (rotation = data loss)
❌ NEVER hardcode dimensions in pixels — use dp/sp
❌ NEVER ignore Lint errors related to accessibility

✅ ALWAYS use ViewModel + StateFlow for UI state
✅ ALWAYS test in Dark Theme mode before each PR
✅ ALWAYS verify touch targets (48dp minimum)
✅ ALWAYS use Coroutines/Flow for async operations
```

---

## 9. Play Store Checklist

> Source: Google Play — Target API level requirements (support.google.com/googleplay/android-developer/answer/11926878)

### Blockers

- [ ] `targetSdk` ≥ API 35 (Android 15) — mandatory since August 2024
- [ ] Privacy Policy URL configured in Play Console
- [ ] App Bundle (`.aab`) — `.apk` is no longer accepted since August 2021
- [ ] Permissions declared in the manifest (minimal)
- [ ] Data Safety form completed in Play Console

### Important

- [ ] TalkBack tested — complete navigation without screen
- [ ] Dark Mode tested on Android 10+ and Android 12+ (Dynamic Color)
- [ ] Touch targets ≥48dp on all interactive elements
- [ ] ANR rate <0.47% and Crash rate <1.09% (Android Vitals)
- [ ] Cold start <500ms measured with Android Studio Profiler

### Desirable

- [ ] Baseline Profile generated (improves cold start by 30-40%)
- [ ] Adaptive icons (Android 8+)
- [ ] Screen size support (WindowSizeClass — tablet)
- [ ] Play Asset Delivery for heavy assets

---

## Sources

| Reference | Link |
|-----------|------|
| Material Design 3 | m3.material.io |
| Android Accessibility | developer.android.com/guide/topics/ui/accessibility |
| Jetpack Compose docs | developer.android.com/jetpack/compose |
| Android Vitals | developer.android.com/topic/performance/vitals |
| Play Store — Target API requirements | support.google.com/googleplay/android-developer/answer/11926878 |
| Compose Navigation type-safe | developer.android.com/jetpack/compose/navigation |
| Statcounter Mobile OS Market Share | gs.statcounter.com/os-market-share/mobile |
| Android Developers — Data Safety | support.google.com/googleplay/android-developer/answer/10787469 |
