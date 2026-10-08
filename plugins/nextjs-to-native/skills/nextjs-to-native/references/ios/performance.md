# iOS performance (SwiftUI)

Referenced by [`nextjs-to-native`](../../SKILL.md) via `../shared/performance.md`. `swiftui-expert-skill` covers performance patterns and Instruments trace capture/analysis in depth; use it.

## Build setup (phase 5)

- **ProMotion opt-in (do this first).** On iPhone, an app's own animations are capped at 60 Hz unless the Info.plist contains `CADisableMinimumFrameDurationOnPhone` = `YES` (Boolean). System scrolling may already run at 120 Hz, but springs, transitions, and custom animations will not. Put the key in the Info.plist itself (in XcodeGen: `info.properties` in `project.yml`); confirm it is present in the built `.app`'s Info.plist, since some build-setting routes drop it. Verify on a ProMotion device.
- Judge performance only on a **Release** build on a physical device. The simulator cannot show 120 Hz and has different performance characteristics.
- **Startup**: keep `App.init` and the root view's first body cheap; restore the Keychain session asynchronously behind the launch screen/skeleton; initialize analytics/crash SDKs after the first frame where their docs allow it.

## SwiftUI rules that matter

| Rule | Why |
|---|---|
| `@Observable` models, and pass each child only the properties it reads | Observation tracks property reads per view, so unrelated changes do not invalidate it |
| Split a ticking value (timer, progress, audio position) into its own small view or model | Prevents whole-screen body re-evaluation every tick |
| Nothing expensive in `body`: no formatter creation, parsing, sorting, filtering, or regexes. Hoist to the model or static constants | `body` can run every frame during animation |
| `List` or `LazyVStack`/`LazyVGrid` for long content, with stable `Identifiable` ids; avoid `.id(UUID())` and conditional views that change identity | Lazy loading and correct reuse |
| Avoid `AnyView` in lists and hot paths; prefer `@ViewBuilder` and concrete types | Type erasure defeats diffing |
| Make leaf views `Equatable` only when profiling shows redundant updates | Targeted, not blanket |
| Downsample images to the displayed size before showing them; use a caching loader for feeds | Full-size decodes cost memory and frames |
| Animate with `withAnimation`/`.animation(_:value:)`, `PhaseAnimator`, `KeyframeAnimator`; avoid writing model state every frame from a timer | Keeps work in the render server |
| `TimelineView(.animation)` and per-frame timers can be capped at ~60 fps even with ProMotion enabled; for truly continuous 120 Hz drawing use `CADisplayLink`/Metal | Known limitation reported by developers; verify on device |
| `WKWebView`: one per screen, created once, sized once; never inside a lazy list | Each instance is a separate process-backed view |
| `drawingGroup()` only for complex vector/shape compositions that profiling shows are slow | It rasterizes offscreen and can cost more than it saves |

## Measuring

- **Instruments → SwiftUI template** (Xcode 26+): view body update lanes flag long updates and the cause graph shows which state change invalidated them. Pair with **Time Profiler** and **Hangs**.
- **Animation Hitches** template for scrolling and transitions on a ProMotion device.
- **App Launch** template for cold start.
- `Self._printChanges()` inside a `body` (debug only, remove afterwards) to see why a view re-evaluated.
- **MetricKit** / Xcode Organizer (hitch rate, launch time, hangs) for field data after TestFlight/App Store release.
