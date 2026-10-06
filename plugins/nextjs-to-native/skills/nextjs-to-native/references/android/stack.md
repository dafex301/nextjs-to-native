# Android: stack, tooling, verification

Referenced by [`nextjs-to-native`](../../SKILL.md) for phases 0, 5–9 on Android.

## Recommended defaults

Best-practice defaults for a new app. If the repo or team already has conventions, follow those and note the deviation in the app's `CLAUDE.md`. Look up current versions with `android studio version-lookup` (Android Studio running) or the official release pages; look up current guidance with `android docs search "<keywords>"`. Do not copy version numbers from memory or from this file.

| Concern | Default | Why |
|---|---|---|
| Language/UI | Kotlin, Jetpack Compose, Material 3 (themed with brand tokens) | Current platform standard |
| Build | Gradle Kotlin DSL, version catalog (`gradle/libs.versions.toml`), Compose BOM | One place for versions; agents edit text, not IDE state |
| Architecture | Google's recommended app architecture: UI layer (screen composable + `ViewModel` exposing `StateFlow<UiState>`), data layer (repositories), optional domain layer for shared logic; unidirectional data flow | Well documented, most training data, testable |
| DI | Hilt | Standard with ViewModel and Navigation integration |
| Navigation | Navigation 3 (see the `navigation-3` skill) | Current recommendation for Compose; scenes cover sheets and list-detail |
| Networking | Retrofit + OkHttp + kotlinx.serialization; client generated from OpenAPI (`../shared/backend-contract.md`) | Most common stack, most examples |
| Auth tokens | DataStore with values encrypted via a Keystore-backed key (Tink), or the auth vendor SDK's storage | `EncryptedSharedPreferences` is deprecated |
| Images | Coil (Compose integration) | Compose-native, caching |
| Local data | Room for structured/offline data; DataStore for preferences | |
| Async | Coroutines + Flow; `viewModelScope`; `collectAsStateWithLifecycle()` in UI | Lifecycle-safe collection |
| Modules | Start with `:app` + `:core:designsystem` + `:core:network` + `:core:data`; feature modules when the app grows | Keeps the design system isolated and reusable |
| Testing | JUnit + Turbine for ViewModels/flows; Compose UI tests; screenshot tests (Compose Preview Screenshot Testing or Roborazzi); Maestro for cross-platform flows if both apps are built | |
| Quality | ktlint (or Spotless + ktlint), detekt, Android Lint | Formatting enforced by hook |
| minSdk | Ask; otherwise choose by the target market's device distribution (low-end Android is common in many markets) | |

Install Google's skills for depth instead of re-deriving idioms: `android skills add navigation-3`, `adaptive`, `edge-to-edge`, `testing-setup` (run `android skills list` to see what is current).

## Tooling (phase 0)

```bash
android --version && android info        # Android CLI + SDK location
adb version
android emulator list                    # an AVD with a recent Google Play image
android emulator start <avd-name>
```

Missing pieces: install Android CLI (`brew install --cask android-cli` on macOS, or the install script from the `android-cli` skill), then `android init` to install its agent skill; install SDK packages with `android sdk install platforms/android-<api> build-tools/<ver> system-images/android-<api>/google_apis_playstore/<abi>`; create a device with `android emulator create`. `android studio *` commands need a running Android Studio with the project open.

## Scaffold (phase 5)

Create the project with Android CLI. Its templates are the same ones the Android Studio "New Project" wizard uses, so the result is identical, but the agent can run it and the step is reproducible. (Creating it in the Studio wizard and handing it to the agent is equally valid.)

- `android create --list` to see templates; `android create <compose template> --name="<App>" --application-id=<id> --output=android`.
- Apply the defaults above (version catalog, Hilt, Navigation 3, modules), enable edge-to-edge (`enableEdgeToEdge()`), disable dynamic color in brand-first mode.
- Configure `buildConfigField`s / product flavors for `dev` / `staging` / `prod` base URLs. No secrets in the app.
- Generate the API client from `shared/api/openapi.yaml` as a Gradle task; wrap it in repositories.
- Add CI from `../../templates/ci/android.yml`.
- Write `android/CLAUDE.md` from `../../templates/CLAUDE.android.md` and install the hooks: copy `../../templates/hooks/*.sh` to `.claude/hooks/` (make them executable) and merge `../../templates/hooks.json` into `.claude/settings.json`.

## Verification loop

| Step | Command |
|---|---|
| Static check (fast) | `./gradlew :app:compileDebugKotlin` · `android studio analyze-file <path>` |
| Preview a composable | `android studio render-compose-preview <file> <PreviewFunction> --output-image-file=out.png --print-semantics` |
| Build + install + launch | `./gradlew :app:assembleDebug` then `android run --apks=<apk>` (`android describe` finds artifact paths), or `./gradlew :app:installDebug` |
| Open a screen directly | Deep link: `adb shell am start -a android.intent.action.VIEW -d "<scheme>://<path>" <package>` |
| Screenshot | `android screen capture --output=native.png` (add `--annotate` to get numbered element boxes for tapping) |
| UI hierarchy | `android layout --pretty` (`--full` includes non-interactive nodes) |
| Interact | Follow the `android-cli` skill's `interact.md` (`android screen resolve` turns `#N` labels into coordinates for `adb shell input tap`) |
| Motion | `adb shell screenrecord /sdcard/feel.mp4` then `adb pull` |
| Tests | `./gradlew testDebugUnitTest connectedDebugAndroidTest` |
| Journeys | Natural-language user journeys stored in the project, evaluated with the `android-cli` skill's `journeys.md` |

Every screen composable has `@Preview`s with fake `UiState` for each state in its spec (loaded, empty, loading, error), in light and dark, at phone size and at large font scale. Previews are the fastest parity check; the emulator run is the final one.

Gotchas: emulators reach the host's `localhost` at `10.0.2.2`; cleartext HTTP needs a debug-only network security config; process death (Developer options → "Don't keep activities") must restore screen state via `SavedStateHandle`.

## Ship (phase 9)

Human-owned: Play Console account, upload key / Play App Signing, store listing, Data safety form, content rating, target audience. Agent-preparable: release build with R8 (keep rules for serialization/Retrofit), `bundleRelease` AAB, mapping file upload for crash reporting, screenshots per form factor, in-app account deletion if accounts can be created, internal testing track first.
