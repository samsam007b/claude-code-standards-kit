# Contrat — Android (Jetpack Compose)

> Module de contrat SQWR Project Kit.
> Sources : Material Design 3 (m3.material.io), Android Developers docs (developer.android.com), Jetpack Compose docs (developer.android.com/jetpack/compose), Google Play Console — Android Vitals (developer.android.com/topic/performance/vitals), Google Play target API requirements (2024), Statcounter Global Stats (gs.statcounter.com).

---

## Fondements

**Android détient 72% du marché mobile mondial** (Statcounter, 2024). Jetpack Compose est le UI toolkit moderne officiel Android depuis Google I/O 2021. Material Design 3 (Material You) est le système de design officiel depuis Android 12.

Ce contrat est le pendant de `CONTRACT-IOS.md` pour Android. Les deux doivent coexister sur les projets cross-platform.

---

## 1. Setup — Jetpack Compose + Material 3

> Source : Android Developers — Compose setup (developer.android.com/jetpack/compose/setup)

```kotlin
// build.gradle.kts (app module)
android {
    compileSdk = 35
    defaultConfig {
        minSdk = 24        // couvre 97% des devices actifs (Android Developers dashboard)
        targetSdk = 35     // obligatoire depuis août 2024 (Play Store policy)
    }
    buildFeatures { compose = true }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.10"
    }
}

dependencies {
    // BOM — gère toutes les versions Compose de façon cohérente
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

## 2. Material Design 3 — Thème et Tokens

> Source : Material Design 3 — Color system (m3.material.io/styles/color/system/how-the-system-works)

**Règle absolue : jamais hardcoder les couleurs.** Toujours utiliser `MaterialTheme.colorScheme`.

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
        typography = AppTypography,  // définir dans Typography.kt
        content = content
    )
}
```

```kotlin
// Utilisation correcte des tokens
// ✅ Toujours via MaterialTheme
Text(text = "Titre", color = MaterialTheme.colorScheme.onBackground)
Surface(color = MaterialTheme.colorScheme.surface) { ... }

// ❌ Jamais hardcodé
Text(text = "Titre", color = Color(0xFF1C1B1F))
```

---

## 3. Navigation — Compose Navigation

> Source : Android Developers — Navigate with Compose (developer.android.com/jetpack/compose/navigation)

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

// Bottom Navigation — 3 à 5 items (Material Design 3 spec)
@Composable
fun AppBottomBar(navController: NavHostController) {
    NavigationBar {
        NavigationBarItem(
            icon = { Icon(Icons.Default.Home, contentDescription = "Accueil") },
            label = { Text("Accueil") },
            selected = /* currentRoute == HomeRoute */,
            onClick = { navController.navigate(HomeRoute) }
        )
        // 2-4 autres items max
    }
}
```

---

## 4. Touch Targets — Accessibilité

> Source : Material Design 3 — Accessibility (m3.material.io/foundations/accessible-design/accessibility-basics)
> **Threshold : 48×48dp minimum** pour tout élément interactif (Android — vs 44pt sur iOS)

```kotlin
// ✅ Minimum 48dp — Modifier.minimumInteractiveComponentSize() (Compose 1.3+)
IconButton(
    onClick = { /* action */ },
    modifier = Modifier.minimumInteractiveComponentSize()  // garantit 48×48dp
) {
    Icon(Icons.Default.Close, contentDescription = "Fermer")
}

// ✅ Agrandir la zone de tap sans agrandir l'icône
Box(
    modifier = Modifier
        .size(48.dp)
        .clickable { /* action */ },
    contentAlignment = Alignment.Center
) {
    Icon(Icons.Default.Add, contentDescription = "Ajouter", modifier = Modifier.size(24.dp))
}

// ❌ Icône sans padding — zone de tap = taille de l'icône
Icon(Icons.Default.Close, contentDescription = "Fermer")
```

---

## 5. Accessibilité — TalkBack

> Source : Android Accessibility (developer.android.com/guide/topics/ui/accessibility/principles)

```kotlin
// ✅ contentDescription obligatoire sur les éléments non-texte
Icon(
    imageVector = Icons.Default.Favorite,
    contentDescription = "Ajouter aux favoris",  // annoncé par TalkBack
    tint = MaterialTheme.colorScheme.primary
)

// ✅ Masquer les éléments décoratifs
Icon(
    imageVector = Icons.Default.CheckCircle,
    contentDescription = null,  // null = ignoré par TalkBack (décoratif)
)

// ✅ Grouper les éléments liés pour TalkBack
Column(modifier = Modifier.semantics(mergeDescendants = true) {}) {
    Text(text = "Samuel Baudon")
    Text(text = "Développeur", color = MaterialTheme.colorScheme.onSurfaceVariant)
}
// TalkBack lit "Samuel Baudon, Développeur" comme un seul élément

// ✅ Ajouter un contexte pour les actions
Button(
    onClick = { deleteItem(item.id) },
    modifier = Modifier.semantics {
        contentDescription = "Supprimer ${item.name}"  // contexte > "Supprimer"
    }
) {
    Text("Supprimer")
}
```

**Tester TalkBack :** Paramètres Android → Accessibilité → TalkBack. Naviguer dans l'app sans regarder l'écran.

---

## 6. Performance — Android Vitals

> Source : Android Vitals (developer.android.com/topic/performance/vitals)
> **Threshold Play Store : ANR rate <0.47%, crash rate <1.09%** (au-delà = badge "Mauvaise qualité")

```kotlin
// Cold start — cible <500ms (Android Vitals)
// Éviter les opérations bloquantes dans Application.onCreate()

// ✅ Opérations lourdes en arrière-plan
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Pas de I/O, pas de réseau ici
        // Initialiser les singletons légers uniquement
    }
}

// ✅ remember et derivedStateOf — éviter les recompositions inutiles
@Composable
fun ExpensiveList(items: List<Item>, filter: String) {
    // derivedStateOf : ne recalcule que si items ou filter change
    val filteredItems by remember(items, filter) {
        derivedStateOf { items.filter { it.name.contains(filter) } }
    }
    LazyColumn {
        items(filteredItems) { item -> ItemRow(item) }
    }
}

// ✅ LazyColumn obligatoire pour les listes (jamais Column pour > 20 items)
LazyColumn {
    items(longList) { item -> ItemCard(item) }
}
// ❌ Column pour une longue liste — tout est composé même hors écran
Column { longList.forEach { item -> ItemCard(item) } }
```

---

## 7. Dark Theme

```kotlin
// ✅ isSystemInDarkTheme() — respect du choix système
@Composable
fun StatusIndicator(isActive: Boolean) {
    val backgroundColor = if (isActive) {
        MaterialTheme.colorScheme.primaryContainer
    } else {
        MaterialTheme.colorScheme.surfaceVariant
    }
    // backgroundColor s'adapte automatiquement au dark theme via colorScheme
    Box(modifier = Modifier.background(backgroundColor, shape = CircleShape))
}
```

---

## 8. Règles absolues Android

```
❌ JAMAIS modifier les fichiers générés (R.java, fichiers dans build/)
❌ JAMAIS appeler le réseau ou I/O sur le Main Thread → StrictMode bloquera
❌ JAMAIS stocker l'état UI dans Activity (rotation = perte de données)
❌ JAMAIS hardcoder les dimensions en pixels — utiliser dp/sp
❌ JAMAIS ignorer les erreurs Lint liées à l'accessibilité

✅ TOUJOURS utiliser ViewModel + StateFlow pour l'état UI
✅ TOUJOURS tester en mode Dark Theme avant chaque PR
✅ TOUJOURS vérifier les touch targets (48dp minimum)
✅ TOUJOURS utiliser Coroutines/Flow pour les opérations async
```

---

## 9. Checklist Play Store

> Source : Google Play — Target API level requirements (support.google.com/googleplay/android-developer/answer/11926878)

### Bloquants

- [ ] `targetSdk` ≥ API 35 (Android 15) — obligatoire depuis août 2024
- [ ] Privacy Policy URL configurée dans Play Console
- [ ] App Bundle (`.aab`) — `.apk` n'est plus accepté depuis août 2021
- [ ] Déclaration des permissions dans le manifest (minimales)
- [ ] Data Safety form complété dans Play Console

### Importants

- [ ] TalkBack testé — navigation complète sans écran
- [ ] Dark Mode testé sur Android 10+ et Android 12+ (Dynamic Color)
- [ ] Touch targets ≥48dp sur tous les éléments interactifs
- [ ] ANR rate <0.47% et Crash rate <1.09% (Android Vitals)
- [ ] Cold start <500ms mesuré avec Android Studio Profiler

### Souhaitables

- [ ] Baseline Profile généré (améliore cold start de 30-40%)
- [ ] Adaptive icons (Android 8+)
- [ ] Support des tailles d'écran (WindowSizeClass — tablette)
- [ ] Play Asset Delivery pour les assets lourds

---

## Sources

| Référence | Lien |
|-----------|------|
| Material Design 3 | m3.material.io |
| Android Accessibility | developer.android.com/guide/topics/ui/accessibility |
| Jetpack Compose docs | developer.android.com/jetpack/compose |
| Android Vitals | developer.android.com/topic/performance/vitals |
| Play Store — Target API requirements | support.google.com/googleplay/android-developer/answer/11926878 |
| Compose Navigation type-safe | developer.android.com/jetpack/compose/navigation |
| Statcounter Mobile OS Market Share | gs.statcounter.com/os-market-share/mobile |
| Android Developers — Data Safety | support.google.com/googleplay/android-developer/answer/10787469 |
