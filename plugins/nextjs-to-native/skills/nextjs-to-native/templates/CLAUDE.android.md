# <App name> — Android

Lives in `android/` of the mobile monorepo; cross-platform rules are in the root `CLAUDE.md`. Native Android client for <product>, migrated from the Next.js website (<web repo>) with the `nextjs-to-native` skill. The website is the spec; `migration/` holds the worklist, screen specs, and baselines.

## Project

- Application id: `<com.example.app>` · minSdk <n> · targetSdk <n>
- Modules: `:app`, `:core:designsystem`, `:core:network`, `:core:data`, `:feature:*`
- Flavors / base URLs: dev `<url>`, staging `<url>`, prod `<url>` (in `buildConfigField`, never secrets)
- Visual mode: brand-first — tokens generated from `shared/tokens/tokens.json` into `:core:designsystem`; components follow `shared/components/*.md`

## Commands

- Build: `./gradlew :app:assembleDevDebug`
- Install + launch: `./gradlew :app:installDevDebug` then `adb shell am start -n <id>/.MainActivity`
- Unit tests: `./gradlew testDevDebugUnitTest` · UI tests: `./gradlew connectedDevDebugAndroidTest`
- Lint/format: `./gradlew lint` · `ktlint --format`
- Preview: `android studio render-compose-preview <file> <Preview> --output-image-file=<png>`
- Screenshot / hierarchy: `android screen capture --output=<png>` · `android layout --pretty`
- Deep link to a screen: `adb shell am start -a android.intent.action.VIEW -d "<scheme>://<path>"`
- Regenerate API client (from `shared/api/openapi.yaml`): `./gradlew :core:network:openApiGenerate`

## Patterns (locked in the vertical slice — follow them)

- Screen = `XxxRoute` (gets ViewModel, collects state) + stateless `XxxScreen(uiState, onEvent...)` + `@Preview`s for every state in the spec.
- `XxxViewModel` (`@HiltViewModel`) exposes `StateFlow<XxxUiState>`; `UiState` is a sealed interface or data class with explicit loading/empty/error/content.
- Repositories wrap the generated API client; screens never call Retrofit directly.
- Navigation: <Navigation 3 keys / graph location>.
- Errors: <how API errors map to UI messages>.
- Strings in `strings.xml`; no hardcoded user-facing text.
- Colors/typography/spacing only from the design system; no literal `Color(0x...)` or `dp` values in feature code except layout-specific sizes.

## Rules

- Do not edit generated code under `build/generated/` or web baselines under `migration/baselines/` (hooks enforce this).
- Never commit secrets, keystores, or `google-services.json` with production keys.
- One screen per change; update `migration/SCREENS.md` and `migration/PARITY_CHECKS.md` with the result.
- A change is done only after the screen passed parity on the emulator, not when it compiles.
