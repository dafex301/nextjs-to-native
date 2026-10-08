# <App name> — iOS

Lives in `ios/` of the mobile monorepo; cross-platform rules are in the root `CLAUDE.md`. Native iOS client for <product>, migrated from the Next.js website (<web repo>) with the `nextjs-to-native` skill. The website is the spec; `migration/` holds the worklist, screen specs, and baselines.

## Project

- Bundle id: `<com.example.app>` · deployment target iOS <n> · Swift <n> (strict concurrency)
- Ported from Android in lead-follow mode: names stay parallel (`XxxUiState` ↔ `XxxState`, same component, repository/service, and event names); procedure in the skill's `port/compose-swiftui.md`.
- ProMotion enabled (`CADisableMinimumFrameDurationOnPhone`); judge performance on Release builds on a device.
- Project generated from `project.yml` with XcodeGen — run `xcodegen generate` after adding files or targets. Never edit `.pbxproj`.
- Packages: `DesignSystem`, `Networking` (generated OpenAPI client + services), `Core`
- Configurations / base URLs: Dev `<url>`, Staging `<url>`, Prod `<url>` (in `.xcconfig`, never secrets)
- Visual mode: brand-first — tokens generated from `shared/tokens/tokens.json` into `DesignSystem`; components follow `shared/components/*.md`

## Commands

- Session defaults (once): `xcodebuildmcp setup`
- Build: `xcodebuildmcp simulator build`
- Build + run: `xcodebuildmcp simulator build-and-run`
- Tests: `xcodebuildmcp simulator test`
- Screenshot / hierarchy: `xcodebuildmcp simulator screenshot` · `xcodebuildmcp ui-automation snapshot-ui`
- Deep link to a screen: `xcrun simctl openurl booted "<scheme>://<path>"`
- Format/lint: `swiftformat .` · `swiftlint`

## Patterns (locked in the vertical slice — follow them)

- Screen = `XxxView` (thin) + `@MainActor @Observable final class XxxModel` owning a `state` enum with explicit loading/empty/error/content; `#Preview`s for every state in the spec using fake models.
- Data loads in `.task { await model.load() }`; mutations are `async` methods on the model.
- Services wrap the generated OpenAPI client; views never touch it directly.
- Navigation: one `NavigationStack` per tab with a typed route enum and a router object.
- Errors: <how API errors map to UI messages>.
- Strings in a String Catalog; no hardcoded user-facing text.
- Colors/fonts/spacing only from `DesignSystem`; no literal colors or font sizes in feature code.

## Rules

- Do not edit `.pbxproj`, `.xcodeproj/`, entitlements, generated sources, or web baselines (hooks enforce this).
- Signing, certificates, and App Store Connect are human-owned.
- One screen per change; update `migration/SCREENS.md` and `migration/PARITY_CHECKS.md` with the result.
- A change is done only after the screen passed parity on the simulator, not when it compiles.
