# Performance: smooth on every device

Referenced by [`nextjs-to-native`](../../SKILL.md) in phases 5–9. A native rewrite is only worth it if it feels native: instant launch, no dropped frames while scrolling or animating, and the highest refresh rate the display offers when motion is on screen. Platform techniques: `../android/performance.md`, `../ios/performance.md`.

## Rules

- **Measure before optimizing, and only on release-like builds.** Debug builds on both platforms are much slower: Compose debug runs without R8 or baseline profiles, and Swift debug builds are unoptimized. Use a `profile`/release-like build (Android: R8 on, debuggable off, `profileable`; iOS: Release configuration) for every performance judgement.
- **Measure on the devices that matter.** A low-end Android phone from the target market (a 60 Hz budget device exposes CPU problems), a high-refresh device (90/120 Hz exposes frame-pacing problems), and an iPhone with ProMotion. Emulators and simulators are not performance evidence.
- **Fix what the tools flag.** Profile, find the specific slow frame or composable/view, fix it, re-measure. Do not sprinkle `@Stable`, `remember`, `Equatable`, or `drawingGroup` by instinct; they cost readability and can make things worse.
- **High refresh rate is opt-in on iOS and negotiated on Android.** Without configuration, an iPhone app's own animations are capped at 60 Hz; see the platform files.

## Budgets (agree in phase 2, check in phases 6, 7, 9)

| Metric | Default budget | How to measure |
|---|---|---|
| Cold start to first meaningful frame | ≤ 1.5 s on the low-end target device (release-like build) | Android: Macrobenchmark `StartupTimingMetric` or `adb shell am start -W`; iOS: Instruments App Launch, or MetricKit in the field |
| Frame time while scrolling the heaviest list and running the main transitions | No visible hitches; Android jank ≤ 1% of frames; iOS hitch ratio ≤ 5 ms/s | Android: Macrobenchmark `FrameTimingMetric`, JankStats, Perfetto; iOS: Instruments SwiftUI + Animation Hitches templates |
| Main-thread work per frame at 120 Hz | < 8.3 ms (60 Hz: < 16.7 ms) | Same tools |
| Memory on the heaviest screen | No growth across repeated navigation; images downsampled | Android Studio Memory profiler; Instruments Allocations/Leaks |
| App size | Track per release; investigate jumps | Play Console / App Store Connect size reports |

Record the measured numbers per release in `docs/notes/YYYY-MM-DD-performance-<release>.md`.

## Where web-ported apps lose frames

These are the recurring causes when screens come from a web app:

1. **Startup work on the main thread**: decrypting the session store, reading large JSON, initializing SDKs eagerly. Defer everything the first screen does not need, and restore the session asynchronously behind the splash/skeleton.
2. **Lists built like web lists**: non-lazy stacks over long data, missing stable keys, heavy rows, images decoded at full size.
3. **State that updates too broadly**: one big screen state object observed by every child, so a timer or progress tick re-renders the whole screen.
4. **Work inside composition/body**: formatting dates and numbers, parsing HTML/Markdown, sorting, building regexes on every render.
5. **Embedded web renderers** (HTML, KaTeX, video embeds): each WebView costs memory and startup time. Reuse or pool them, size them once, and never put several in a scrolling list.
6. **Per-frame animations driven from state**: animated values written to observable state each frame re-render whole subtrees. Animate in the draw/graphics layer instead.
7. **Unoptimized assets**: oversized bitmaps, unconverted GIFs (see `assets.md`).

## Gates

- **Phase 6 (vertical slice):** the slice flows meet the budgets on the low-end device and a high-refresh device. Startup tracing set up (baseline profile on Android).
- **Phase 7:** every screen with a long list, heavy media, or continuous animation gets a frame-time check before it is marked done.
- **Phase 9:** full budget table measured on release builds and recorded.
