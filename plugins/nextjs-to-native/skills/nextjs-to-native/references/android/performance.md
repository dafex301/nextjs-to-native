# Android performance (Compose)

Referenced by [`nextjs-to-native`](../../SKILL.md) via `../shared/performance.md`. Check current APIs with `android docs search "compose performance"` and Google's `android-profiler` skill; for Compose-specific depth, `skydoves/compose-performance-skills` is a good companion.

## Build setup (phase 5)

- **R8 enabled** for release and for a `profile` build type (`isMinifyEnabled = true`, `isDebuggable = false`, `<profileable android:shell="true"/>` in the manifest for that build type). Judge performance only on this build.
- **Baseline Profiles**: add a `:baselineprofile` module (Baseline Profile Gradle plugin) generating a profile for startup and the critical journeys (open app → home → main list scroll → main detail). Regenerate when those flows change. This is the single biggest win for cold start and first-scroll jank.
- **Macrobenchmark** in the same module: `StartupTimingMetric` and `FrameTimingMetric` for the critical journeys, run on a physical device. Add to CI if a device farm is available; otherwise run before each release.
- **Compose compiler**: strong skipping is on by default in current Kotlin/Compose compilers (verify the version). Generate compiler metrics/reports only when investigating a recomposition problem.
- **Startup**: no work in `Application.onCreate` that the first frame does not need (use lazy Hilt injection / `Provider<T>`, App Startup for ordered init); keep the splash on screen with `setKeepOnScreenCondition` only until the first real frame is ready.

## High refresh rate

- Android negotiates the rate: touch, scrolling, and moving/resizing animations are boosted automatically on adaptive-refresh-rate displays (Android 15 QPR1+ with hardware support; `Display.hasArrSupport()`).
- For a custom animation that looks unsmooth at the default rate, request a higher rate on the animated composable with `Modifier.preferredFrameRate(FrameRateCategory.High)` (Compose 1.9+; confirm the current API name in the reference docs). Do not request high rates for small or slow animations (progress bars, visualizers): it costs battery for no visible gain.
- Video and slow ambient animation can request lower rates (24/30 Hz).

## Compose rules that matter

| Rule | Why |
|---|---|
| `LazyColumn`/`LazyRow`/grids for anything that can grow, with `key = { it.id }` and `contentType` for mixed rows | Reuse and correct item identity |
| Read fast-changing state as late as possible: lambda modifiers (`Modifier.offset { }`, `graphicsLayer { alpha = … }`, `drawBehind { }`) instead of value parameters | Moves the read from composition to layout/draw, so only that phase reruns |
| `derivedStateOf` for values derived from frequently changing state (scroll position → "show FAB") | Recomposes only when the derived value changes |
| Hoist expensive objects out of composition: formatters, regexes, parsed HTML, sorted lists → ViewModel or `remember(key)` | Composition can run every frame during animation |
| Split screen state so a ticking value (timer, progress, audio position) is observed only by the small composable that shows it | Avoids whole-screen recomposition |
| Immutable UI models (`data class` with `val`, `kotlinx.collections.immutable` lists when profiling shows instability) | Stable inputs enable skipping |
| `collectAsStateWithLifecycle()` | Stops collection when not visible |
| Coil with explicit size / `Size.ORIGINAL` only when needed; placeholders sized to the final layout | Prevents full-size decodes and layout jumps |
| Never nest a same-direction scrollable inside a lazy list; no `fillMaxHeight` items in a vertical lazy list | Prevents measuring everything |
| Animations via `animate*AsState`, `Animatable`, `updateTransition` applied in `graphicsLayer` | Keeps per-frame work in the draw phase |
| WebView: one instance per screen at most, created once, kept out of lazy lists; destroy on dispose | WebViews are heavy |

## Measuring

- **Layout Inspector** (recomposition counts) to find composables recomposing every frame.
- **Perfetto / Android Studio profiler** system traces for janky frames; enable Compose tracing (`runtime-tracing`) to see composable names in traces.
- **JankStats** in the app for field data; Play Console Android vitals (slow rendering, frozen frames, startup) after release.
- Low-end device check: Developer options → "Profile HWUI rendering" bars as a quick visual smoke test, then a real trace for anything over budget.
