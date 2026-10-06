# iOS: stack, tooling, verification

Referenced by [`nextjs-to-native`](../../SKILL.md) for phases 0, 5–9 on iOS.

## Recommended defaults

Best-practice defaults for a new app. If the repo or team already has conventions, follow those and note the deviation in the app's `CLAUDE.md`. Check current APIs with `swiftui-expert-skill` (its `latest-apis` reference) and Apple's documentation (Xcode's MCP documentation search when available). Do not copy version numbers or deployment targets from memory.

| Concern | Default | Why |
|---|---|---|
| Language/UI | Swift (current major, strict concurrency), SwiftUI | Current platform standard |
| Project file | **XcodeGen** (`project.yml`) or Tuist generating the `.xcodeproj`; or Xcode's synchronized folder groups | Agents must not hand-edit `.pbxproj`; a generator or folder sync makes file additions safe |
| Packages | Swift Package Manager; local packages for `DesignSystem`, `Networking`, `Core` | Isolates the design system and API client, faster builds and previews |
| State | `@Observable` models (Observation framework), `@State` for view-local state, `@Environment` for injection, `@Bindable` for bindings | Replaces `ObservableObject`/`@Published`/`@StateObject` |
| Architecture | Views stay thin; a per-screen `@Observable` model (or feature store) owns state and calls services; services wrap the generated API client | Same shape as the Android ViewModel layer, which keeps lead-follow porting mechanical |
| Navigation | `NavigationStack` with a typed path / value-based `navigationDestination`; a router object per tab | `NavigationView` is deprecated |
| Networking | `URLSession` async/await; client generated with `swift-openapi-generator` + `swift-openapi-urlsession` (`../shared/backend-contract.md`) | No third-party HTTP dependency needed |
| Auth tokens | Keychain (Security framework or a thin wrapper), or the auth vendor SDK | Never `UserDefaults` |
| Images | `AsyncImage` for simple cases; a caching image library (e.g. Nuke or Kingfisher) for feeds | `AsyncImage` does not cache across launches |
| Local data | SwiftData for structured/offline data; `UserDefaults`/`@AppStorage` for preferences | |
| Concurrency | `async`/`await`, `Task` tied to view lifetime via `.task {}`, `@MainActor` for UI models | `.task` cancels automatically when the view disappears |
| Testing | Swift Testing for logic; XCUITest for flows; snapshot tests (e.g. swift-snapshot-testing) for visual regressions; Maestro for cross-platform flows if both apps are built | |
| Quality | SwiftFormat + SwiftLint | Formatting enforced by hook |
| Deployment target | Ask; otherwise the current iOS major minus one is a common floor | Newer targets mean simpler, more modern APIs |

Install for depth: `swiftui-expert-skill` (AvdLee/SwiftUI-Agent-Skill), `xcodebuildmcp-cli` (`xcodebuildmcp init`), and topic skills from `dpearson2699/swift-ios-skills` as needed (`swift-architecture`, `ios-networking`, `authentication`, `swiftui-navigation`, `storekit`, `push-notifications`).

## Tooling (phase 0)

```bash
xcodebuild -version                      # Xcode installed, license accepted
xcrun simctl list runtimes               # a simulator runtime for the target iOS version
xcodebuildmcp --help                     # XcodeBuildMCP CLI (or registered as an MCP server)
xcodegen --version                       # if using XcodeGen
```

Missing pieces: `xcodebuild -downloadPlatform iOS` for a simulator runtime; `brew install xcodegen swiftformat swiftlint`; `npm i -g xcodebuildmcp` (or `brew install xcodebuildmcp`) then `xcodebuildmcp init --client claude --skill cli`. Optionally register Apple's Xcode MCP bridge for previews and documentation (`claude mcp add --transport stdio xcode -- xcrun mcpbridge`; requires Xcode running with the project open). Accepting the Xcode license needs the user's password — ask them to run `sudo xcodebuild -license accept`.

## Scaffold (phase 5)

Create the project as code, **never with the Xcode "New Project" wizard**: the wizard produces a `.pbxproj`, which agents cannot edit safely, so every later target, package, capability, or build-setting change would get stuck.

- Copy `../../templates/ios/project.yml` to `ios/project.yml`, fill the slots, create the folders it references (`App/`, `Resources/`, `Tests/`, `UITests/`, `Config/`, `Packages/DesignSystem`, `Packages/Networking`, `Packages/Core`), and run `xcodegen generate`. The `.xcodeproj` is generated and git-ignored; regenerate after adding files or changing `project.yml`. (Tuist is an equivalent alternative for larger projects; `xcodebuildmcp project-scaffolding scaffold-ios` is fine for throwaway prototypes.)
- Configurations `Debug` / `Staging` / `Release` with base URLs in `.xcconfig` files. No secrets in the app.
- Add the `swift-openapi-generator` build plugin to the `Networking` package, reading `shared/api/openapi.yaml`; wrap generated code in services.
- Add CI from `../../templates/ci/ios.yml` (macOS runners are expensive; the path filter keeps it to iOS/shared changes).
- Write `ios/CLAUDE.md` from `../../templates/CLAUDE.ios.md` and install the hooks: copy `../../templates/hooks/*.sh` to `.claude/hooks/` (make them executable) and merge `../../templates/hooks.json` into `.claude/settings.json` (they block edits to `.pbxproj`, `.xcodeproj/`, entitlements, and signing settings).

## Verification loop

Run `xcodebuildmcp <workflow> --help` for exact arguments; set session defaults (project, scheme, simulator) once with `xcodebuildmcp setup`.

| Step | Command |
|---|---|
| Build (structured errors) | `xcodebuildmcp simulator build` |
| Preview a view | `xcodebuildmcp xcode-ide list-tools` → call the preview-capture tool (needs Xcode open); or render through a snapshot test |
| Build + install + launch | `xcodebuildmcp simulator build-and-run` |
| Open a screen directly | `xcrun simctl openurl booted "<scheme>://<path>"` (custom URL scheme or universal link) |
| Screenshot | `xcodebuildmcp simulator screenshot` (or `xcrun simctl io booted screenshot native.png`) |
| UI hierarchy | `xcodebuildmcp ui-automation snapshot-ui` |
| Interact | `xcodebuildmcp ui-automation tap` / `type-text` / `swipe` using element refs from the latest snapshot |
| Motion | `xcodebuildmcp simulator record-video` (or `xcrun simctl io booted recordVideo feel.mov`) |
| Tests | `xcodebuildmcp simulator test` |

Every screen view has `#Preview`s with fake model state for each state in its spec (loaded, empty, loading, error), in light and dark, and at a large Dynamic Type size. Previews are the fastest parity check; the simulator run is the final one.

Gotchas: the simulator shares the host network (`localhost` works), but ATS blocks plain HTTP unless a debug-only exception is configured; test on the smallest supported screen size; keyboard avoidance is automatic in SwiftUI but scroll-to-focused-field often needs `ScrollViewReader`/`scrollPosition`.

## Ship (phase 9)

Human-owned: Apple Developer account, certificates/provisioning (or automatic signing), App Store Connect record, privacy nutrition labels, age rating, review notes and a demo account. Agent-preparable: privacy manifest (`PrivacyInfo.xcprivacy`) covering required-reason APIs and SDKs, purpose strings for every permission, Sign in with Apple if other social logins exist, in-app account deletion, App Store screenshots per device size, TestFlight build via `xcodebuild archive` / CI.
