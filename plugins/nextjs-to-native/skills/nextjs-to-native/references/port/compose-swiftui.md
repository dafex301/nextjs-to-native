# Compose ↔ SwiftUI port map

Phase 8 of [`nextjs-to-native`](../../SKILL.md) (lead-follow mode). The **web baseline stays the spec of record**; the lead platform's code is a reference for decisions already resolved (API usage, edge cases, state shape, copy fixes). Port behavior and structure, not syntax: write idiomatic code for the target platform, then verify against the web baseline, not against the other app.

## What transfers directly

- Screen specs, baselines, parity checklist, analytics events.
- `UiState` shape: the Kotlin `data class`/`sealed interface` maps to a Swift `struct`/`enum` with associated values almost 1:1.
- Repository/service boundaries and method names, error types, pagination logic, validation rules.
- Design tokens (both generated from the same `tokens.json`) and the primitive inventory (same names, same variants).

## Architecture

| Compose (Android) | SwiftUI (iOS) |
|---|---|
| `ViewModel` + `StateFlow<UiState>` | `@MainActor @Observable final class ScreenModel` with a `state` property |
| `viewModelScope.launch { }` | `Task { }` stored on the model, or `.task { }` in the view |
| `collectAsStateWithLifecycle()` | Direct property access (Observation tracks it) |
| `SavedStateHandle` | `@SceneStorage` / restoring from navigation path; process death is less common on iOS but backgrounding still matters |
| Hilt `@Inject` / `@HiltViewModel` | Initializer injection; services passed via `@Environment` or a composition root |
| Repository returning `Flow` | Service returning `AsyncStream`/`AsyncSequence`, or an `@Observable` store |
| `suspend fun` | `async throws func` |
| `Result`/sealed error | `throws` with typed errors, or `Result` |
| Room | SwiftData |
| DataStore | `UserDefaults` / `@AppStorage` |
| Keystore-encrypted DataStore | Keychain |
| Retrofit + OpenAPI generator | `swift-openapi-generator` + URLSession transport |
| Coil | `AsyncImage` / caching image library |
| WorkManager | `BGTaskScheduler` (more restrictive scheduling) |
| FCM | APNs (or FCM iOS SDK on top of APNs) |

## Navigation

| Compose | SwiftUI |
|---|---|
| Navigation 3 back stack of `NavKey`s | `NavigationStack(path:)` with `Hashable` route values |
| `NavDisplay` entry provider | `.navigationDestination(for:)` |
| Bottom navigation with per-tab back stacks | `TabView` with a `NavigationStack` per tab |
| Bottom sheet scene / `ModalBottomSheet` | `.sheet` + `.presentationDetents` |
| Dialog | `.alert` / `.confirmationDialog` / custom overlay |
| Deep links (App Links + intent filters) | Universal Links + `.onOpenURL` |
| Predictive back | Interactive edge-swipe pop |
| List-detail scene on large screens | `NavigationSplitView` |

## UI

| Compose | SwiftUI |
|---|---|
| `Column` / `Row` / `Box` | `VStack` / `HStack` / `ZStack` (or `.overlay`/`.background`) |
| `Arrangement.spacedBy(x)` | `spacing: x` |
| `Modifier.padding/background/clip/border` | `.padding/.background/.clipShape/.overlay(stroke)` — order matters on both |
| `Modifier.weight(1f)` | `.frame(maxWidth: .infinity)` / `Spacer()` |
| `LazyColumn` + `items(key=)` | `List` or `ScrollView { LazyVStack }` + `ForEach` with `Identifiable` |
| `LazyVerticalGrid` | `LazyVGrid` |
| `HorizontalPager` | Paging `ScrollView` / `TabView(.page)` |
| `Scaffold(topBar, bottomBar, snackbarHost)` | `NavigationStack` + `.toolbar` + `.safeAreaInset` + custom toast overlay |
| `TopAppBar` scroll behaviors | Navigation bar title display modes, toolbar background visibility |
| `TextField` + `KeyboardOptions` | `TextField` + `.keyboardType`/`.submitLabel`/`.textContentType` |
| `FocusRequester` | `@FocusState` |
| `remember { mutableStateOf() }` | `@State` |
| `rememberSaveable` | `@SceneStorage` / `@State` (view-scoped) |
| `LaunchedEffect(key)` | `.task(id: key)` |
| `DisposableEffect` | `.onAppear`/`.onDisappear` or `.task` cancellation |
| `derivedStateOf` | Computed property on the model |
| `AnimatedVisibility` / `animate*AsState` | `.transition` + `withAnimation` / `.animation(_:value:)` |
| `PullToRefreshBox` | `.refreshable` |
| `Modifier.semantics { }` | `.accessibilityLabel/.accessibilityAddTraits/.accessibilityElement(children:)` |
| `@Preview` with fake `UiState` | `#Preview` with a fake model |
| Compose UI test | XCUITest / ViewInspector-style unit tests |

## Platform differences that change behavior

- **Permissions:** iOS asks once; a denial requires sending the user to Settings. Android can re-ask with rationale. Port the *rationale UX*, not the prompt logic.
- **Back:** Android has a system back that can exit the app; iOS has no global back. Any Android flow that relies on system back to dismiss (e.g., a full-screen overlay) needs an explicit close control on iOS.
- **Background work:** iOS background execution is far more limited; anything relying on long-running background sync needs redesign (background refresh, push-triggered fetch).
- **Sign-in:** iOS requires Sign in with Apple when other social logins are offered.
- **Payments:** Play Billing vs StoreKit; entitlement checks go through the backend.
- **Typography:** Android `sp` respects font scale; iOS needs Dynamic Type-aware custom fonts (`relativeTo:`) to match.

The reverse direction (SwiftUI lead, Compose follow) uses the same tables read right-to-left.
