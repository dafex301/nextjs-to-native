# Compose ↔ SwiftUI port guide

Phase 8 of [`nextjs-to-native`](../../SKILL.md) (lead-follow mode). The **web baseline stays the spec of record**; the lead platform's code is a reference for decisions already resolved (API usage, edge cases, state shape, copy fixes). Written for Compose → SwiftUI; read the tables right-to-left for the reverse.

## Principle: extract, don't transliterate

Do not translate Kotlin line by line. Extract what the Android screen *decided* — data, state shape, rules, edge cases, flows — and write idiomatic Swift for it. ViewModels and data logic port almost mechanically (Kotlin and Swift collections, strings, nullability, and control flow are close); views and lifecycle do not.

## Procedure per screen

1. **Read three sources**: the screen spec (spec of record), its web baselines, and the Android implementation (reference).
2. **List the decisions already resolved on Android** before writing code: edge cases handled, error mapping, thresholds and rounding, persistence, analytics events, workarounds and why they exist. Note anything platform-specific that should *not* be copied.
3. **Keep names parallel**: same screen, state, event, repository/service, and component names (`OrdersUiState` ↔ `OrdersState`, `BrandButton` ↔ `BrandButton`). Record the naming convention in `ios/CLAUDE.md` so reviews and diffs line up.
4. **Port the tests**: Android ViewModel/repository unit tests → Swift Testing with the same cases and the same `shared/fixtures/` data. Matching tests are the proof that logic is equivalent.
5. **Write the view idiomatically** using `../ios/react-to-swiftui.md`, `../ios/patterns.md`, and the tables below.
6. **Verify the triangle**: iOS screenshot vs web baseline (pass/fail), and vs the Android screenshot (consistency check). Differences from Android are fine where platform behavior requires them; differences from the web baseline need a reason.

## Pitfalls that trip agents

| Pitfall | Why | Rule |
|---|---|---|
| `Task { }` started in a button action outlives the view | Unlike `rememberCoroutineScope`, it is a top-level task | Lifecycle-bound work goes in `.task { }`. Store callback-started tasks on the model and cancel them |
| The model is created repeatedly | The `@State var model = Model()` initializer expression runs every time the view struct is re-created (only the first instance is kept) | No side effects or fetches in model `init`. Load in `.task`, guarded against duplicates |
| `.task` re-runs when a view reappears (pop back, tab switch) | Android's ViewModel `init` ran once per screen instance | Track "loaded" on the model, or use `.task(id:)` with a meaningful key; refresh deliberately |
| State resets unexpectedly | SwiftUI identity is structural: `if/else` branches and `.id()` create new views | Prefer modifiers (opacity, disabled, overlay) over swapping views; stable ids in `ForEach` |
| Avoiding bindings | In Compose, passing `MutableState` down is an anti-pattern; in SwiftUI `Binding`/`@Bindable` is idiomatic | Use bindings for child edits; keep ownership in one place |
| Old observation patterns | Many articles still use `ObservableObject`/`@Published`/`@StateObject` | iOS 17+: `@Observable` models owned with `@State`, `@Bindable` for bindings, `@Environment` for injection |
| Swift 6 `Sendable`/actor errors | Strict concurrency is the main friction for agents | UI models `@MainActor`; DTOs are `Sendable` structs; shared mutable state in an `actor` |
| Kotlin-isms | Literal translation | Sealed hierarchy → `enum` with associated values; `copy()` → mutate a `var` struct; `?.let` chains → `if let`/`guard let`; `object` → `enum` namespace/static |
| Porting `SavedStateHandle` / configuration-change handling | iOS has no configuration change recreation | Not needed. Handle backgrounding; use `@SceneStorage` only for small UI state worth restoring |
| Looking for `BackHandler` | iOS has no global back button | Give flows an explicit close/cancel; leave edge-swipe back native; `interactiveDismissDisabled` for sheets that must confirm |
| One-off event streams (`SharedFlow`/`Channel`) | No direct equivalent; easy to drop events | Model events as state (e.g. `pendingToast`) consumed by the view, or `AsyncStream` owned by the model |
| Assuming Material components exist | No ripple, snackbar, or Material theme | Brand components from `shared/components/`; press states via `ButtonStyle`; custom toast |

## Architecture and data

| Compose (Android) | SwiftUI (iOS) |
|---|---|
| `ViewModel` + `StateFlow<UiState>` | `@MainActor @Observable final class ScreenModel` with a `state` property (or several granular properties) |
| `viewModelScope.launch { }` | `Task { }` stored on the model and cancelled, or `.task { }` in the view |
| `collectAsStateWithLifecycle()` | Direct property access (Observation tracks it) |
| `Flow` from a repository | `AsyncStream`/`AsyncSequence`, or an `@Observable` store |
| `suspend fun` | `async throws func` |
| `Result` / sealed error | `throws` with typed errors, or `Result` |
| Hilt `@Inject` / `@HiltViewModel` | Initializer injection from a composition root; services via `@Environment` where convenient |
| Retrofit + OpenAPI generator | `swift-openapi-generator` + `swift-openapi-urlsession` |
| OkHttp `Interceptor` (auth header, device headers) | `ClientMiddleware` |
| OkHttp `Authenticator` single-flight refresh | `actor` guarding refresh inside the auth middleware |
| kotlinx.serialization | Generated types / `Codable`; give unknown enum values a fallback case |
| Hand-written adapter for a mis-modeled union | Same adapter idea in Swift; check the generator's current `oneOf` support first |
| Room | SwiftData |
| DataStore (preferences) | `UserDefaults` / `@AppStorage` |
| DataStore + Tink (tokens) | Keychain |
| WorkManager | `BGTaskScheduler` (much more restricted) or push-triggered fetch |
| FCM | APNs (or the FCM iOS SDK on top of APNs) |

## Navigation

| Compose | SwiftUI |
|---|---|
| Navigation 3 back stack of `NavKey`s | `NavigationStack(path:)` with `Hashable` route values |
| `NavDisplay` entry provider | `.navigationDestination(for:)` |
| Bottom navigation with per-tab back stacks | `TabView` with a `NavigationStack` per tab |
| Signed-in / signed-out roots switched on session state | Root view switching on the session model |
| Bottom sheet scene / `ModalBottomSheet` | `.sheet` + `.presentationDetents` |
| Dialog | `.alert` / `.confirmationDialog` / custom overlay |
| Deep links (App Links + intent filters) | Universal Links + `.onOpenURL` |
| Predictive back | Interactive edge-swipe pop |
| List-detail scene on large screens | `NavigationSplitView` |

## UI

| Compose | SwiftUI |
|---|---|
| `Column` / `Row` / `Box` | `VStack` / `HStack` / `ZStack` (or `.overlay`/`.background`) |
| `Arrangement.spacedBy(x)` | `spacing: x` (always pass it; default spacing is not zero) |
| `Modifier.padding/background/clip/border` | `.padding/.background/.clipShape/.overlay(stroke)`; order matters on both |
| `Modifier.weight(1f)` | `.frame(maxWidth: .infinity)` / `Spacer()` |
| `LazyColumn` + `items(key=)` | `List` or `ScrollView { LazyVStack }` + `ForEach` with `Identifiable` |
| `LazyVerticalGrid` | `LazyVGrid` |
| `HorizontalPager` | Paging `ScrollView` (`.scrollTargetBehavior(.paging)`) / `TabView(.page)` |
| Custom snapping (`SnapFlingBehavior`, settle logic) | Custom `ScrollTargetBehavior` + `scrollPosition` |
| `Scaffold(topBar, bottomBar, snackbarHost)` | `NavigationStack` + `.toolbar` + `.safeAreaInset` + custom toast overlay |
| `TextField` + `KeyboardOptions` | `TextField` + `.keyboardType`/`.submitLabel`/`.textContentType` |
| `FocusRequester` | `@FocusState` |
| `remember { mutableStateOf() }` | `@State` |
| `rememberSaveable` | `@State` (no recreation on iOS); `@SceneStorage` only when restoration matters |
| `LaunchedEffect(key)` | `.task(id: key)` |
| `DisposableEffect` | `.onAppear`/`.onDisappear`, or `.task` cancellation |
| `derivedStateOf` | Computed property on the model |
| `AnimatedVisibility` / `animate*AsState` | `.transition` + `withAnimation` / `.animation(_:value:)` |
| `graphicsLayer { }` animations | `.scaleEffect`/`.opacity`/`.offset` with animation; `.visualEffect` for geometry-based effects |
| `PullToRefreshBox` | `.refreshable` |
| `Snackbar` | Custom toast (overlay + transition + auto-dismiss) |
| Ripple / `indication` | `ButtonStyle` using `configuration.isPressed` |
| `sp` + font scale | Dynamic Type (`Font.custom(_:size:relativeTo:)`) |
| `Modifier.semantics { }` | `.accessibilityLabel/.accessibilityAddTraits/.accessibilityElement(children:)` |
| `@Preview` with fake `UiState` | `#Preview` with a fake model, same fixtures |
| Compose UI test / screenshot test | XCUITest / snapshot test |

## Media, device, and web content

| Android (common choice) | iOS |
|---|---|
| Media3 ExoPlayer (MP4/HLS) | `AVPlayer` / `VideoPlayer` (AVKit) |
| `SoundPool` (short SFX) | Preloaded `AVAudioPlayer`s (or `AVAudioEngine` for low latency) |
| `AudioRecord` → WAV PCM | `AVAudioEngine` tap or `AVAudioRecorder` with linear PCM settings; configure `AVAudioSession` category/mode |
| `SpeechRecognizer` | `SFSpeechRecognizer`, or `SpeechAnalyzer` on iOS 26+; check per-locale availability |
| Runtime permission + rationale | Info.plist purpose strings (`NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`, …); one prompt, then Settings |
| Credential Manager (Google) | Google Sign-In iOS SDK; plus Sign in with Apple (required when other social logins exist) |
| Isolated `WebView` (HTML, KaTeX, YouTube iframe) | `WKWebView` with `WKWebsiteDataStore.nonPersistent()`, no message handlers (rules in `../shared/app-patterns.md`) |
| Custom Tabs | `SFSafariViewController` |
| Share intent | `ShareLink` |

## Platform differences that change behavior

- **Permissions:** iOS asks once; a denial requires sending the user to Settings. Port the rationale UX, not the prompt logic.
- **Back:** Android can exit the app with system back; iOS has no global back.
- **Background work:** much more limited on iOS; long background sync needs redesign (background refresh, push-triggered fetch).
- **Sign-in:** Sign in with Apple is mandatory alongside other social logins.
- **Payments:** Play Billing vs StoreKit; entitlements are checked through the backend.
- **Refresh rate:** iPhone apps must opt into ProMotion (`../ios/performance.md`); Android negotiates automatically.
- **Typography:** Android `sp` follows font scale; iOS needs Dynamic Type-aware custom fonts.
