<h1 align="center">nextjs-to-native</h1>

<p align="center">
  <strong>An agent skill for rewriting a Next.js web app as truly native mobile apps.</strong><br/>
  Kotlin + Jetpack Compose on Android · Swift + SwiftUI on iOS<br/>
  No React Native, no Expo, no WebView wrapper.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.1.0-blue" alt="version 0.1.0" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT license" />
  <img src="https://img.shields.io/badge/Agent%20Skills-compatible-8A2BE2" alt="Agent Skills compatible" />
  <img src="https://img.shields.io/badge/Android-Jetpack%20Compose-3DDC84?logo=android&logoColor=white" alt="Jetpack Compose" />
  <img src="https://img.shields.io/badge/iOS-SwiftUI-F05138?logo=swift&logoColor=white" alt="SwiftUI" />
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#how-it-works">How it works</a> ·
  <a href="#usage">Usage</a> ·
  <a href="#whats-inside">What's inside</a> ·
  <a href="#faq">FAQ</a>
</p>

---

> [!NOTE]
> **v0.1, still early.** Every phase is written up, but the skill hasn't been through a full real-world migration yet. Issues and PRs are welcome.

## Why

Coding agents write Compose and SwiftUI well. Converting a whole web app is a different job, and they get it wrong in predictable ways when nobody gives them a process:

- They port **web layouts** to mobile: hamburger menus, hover tooltips, data tables, footers.
- They start on screens **before the backend can serve a mobile client**. Server Actions, RSC data fetching, and cookie sessions don't work from a native app.
- They decide a screen is done **because it compiles**. A blank or misaligned screen compiles fine too.
- They **drift between platforms** and quietly drift from the brand.

This skill hands the agent an ordered process, a gate at the end of each phase, and a parity check against the **running website**, which acts as the spec.

## Install

**Claude Code (plugin marketplace)**

```text
/plugin marketplace add dafex301/nextjs-to-native
/plugin install nextjs-to-native@nextjs-to-native
```

**Any agent: Codex, Cursor, Gemini CLI, Copilot, OpenCode, … ([skills CLI](https://skills.sh))**

```bash
npx skills add dafex301/nextjs-to-native --skill nextjs-to-native
```

## How it works

```
0 Tooling ─▶ 1 Assess ─▶ 2 Decide ─▶ 3 Backend contract ─▶ 4 Baselines + screen specs
                                                                   │
        9 Ship ◀─ 8 Port 2nd platform ◀─ 7 Screen loop ◀─ 6 Vertical slice ◀─ 5 Foundation
```

| # | Phase | What happens | Gate |
|---|-------|--------------|------|
| 0 | **Tooling** | Check the verification tools; ask before installing anything | Emulator/simulator boots |
| 1 | **Assess** | Read the Next.js repo; bucket every route as `nativize`, `drop`, `webview-link`, or `later`; cite every claim with `file:line` | Every route bucketed |
| 2 | **Decide** | Platform mode, lead platform, visual mode, backend strategy, payments | All decisions recorded |
| 3 | **Backend contract** | Turn Server Actions and RSC reads into versioned endpoints with bearer auth and an OpenAPI spec | A real token works from `curl` |
| 4 | **Baselines + specs** | Screenshot every screen in every state at phone size; write one platform-agnostic spec per screen | Every screen has a spec and baselines |
| 5 | **Foundation** | Scaffold the app, turn tokens into a native theme, build primitives and a gallery screen, generate the API client, install guard hooks | Gallery matches the web components |
| 6 | **Vertical slice** | Build the *hardest* representative flows end to end, then lock the patterns into `CLAUDE.md` | Slice passes parity |
| 7 | **Screen loop** | One screen per pass: spec → implement → preview → run → parity → test → check off. Can run unattended | Worklist empty |
| 8 | **Second platform** | Port with the web as the spec of record and the first app as the reference | Same as phase 7 |
| 9 | **Ship** | Store, privacy, and release checklists. Signing stays with a human | — |

### Principles

- **The website is the spec.** Every native screen is checked against web baselines: content first, then behavior, visual fidelity, and platform behavior.
- **Brand-first by default.** Components the web designed on purpose stay custom and are rebuilt from your design tokens. Platform *behavior* is always native: back gestures, safe areas, keyboard, system pickers, accessibility. Platform-first is available as an opt-in.
- **Backend before screens.** Until each screen's data has an endpoint, screen work only produces mocks.
- **Evidence, not vibes.** Claims are labeled `observed`, `assumed`, or `unknown`. When something is unknown, the agent asks one question at a time.
- **Best-practice defaults, not dogma.** If a project or team already has conventions, the skill follows them. Versions are looked up live, never hardcoded.
- **Delegate, don't duplicate.** Deep Compose and SwiftUI idioms come from dedicated platform skills. This skill owns the migration order, the Next.js mappings, and the parity loop.

### Platform modes

| Mode | When |
|---|---|
| `single` | One platform now, the other later |
| `lead-follow` *(default for both)* | The second platform trails by 1–2 screens and reuses decisions already settled on the first |
| `parallel` | Only when each platform has its own reviewer. With agents doing the coding, human review becomes the bottleneck |

## Usage

Open your agent in the Next.js repo, or in a new folder for the native app with the web repo next to it, and ask:

```text
Migrate this Next.js app to a native Android app with Jetpack Compose.
```

The agent starts with a read-only assessment and keeps the migration state in a `migration/` folder, so the work can carry on across sessions and agents:

```
migration/
├── SCREENS.md          worklist: every route, bucket, priority, per-platform status
├── DATA.md             every data source → endpoint, auth, cache rule
├── DEPENDENCIES.md     third-party services → native replacement
├── STATE_AND_STORAGE.md
├── DECISIONS.md        platform mode, visual mode, backend, payments
├── PARITY_CHECKS.md    per screen × state: content / behavior / visual / platform
├── tokens.json         design tokens extracted from Tailwind / shadcn / CSS
├── screens/<id>.md     platform-agnostic screen specs
└── baselines/<id>/     web screenshots + accessibility snapshots per state
```

After the vertical slice is done, the screen loop can run unattended with Claude Code's `/loop`, using the ready-made objective in [`run-as-loop.md`](plugins/nextjs-to-native/skills/nextjs-to-native/references/shared/run-as-loop.md).

## What's inside

```
plugins/nextjs-to-native/skills/nextjs-to-native/
├── SKILL.md                         phases, gates, topic router
├── references/
│   ├── shared/
│   │   ├── assess.md                Next.js signals, inventory, bucketing
│   │   ├── backend-contract.md      Server Actions/RSC → API, cookie → bearer, OpenAPI codegen
│   │   ├── design-tokens.md         Tailwind v3/v4, shadcn, CSS vars → Compose & SwiftUI themes
│   │   ├── brand-vs-platform.md     what stays custom, what is always native
│   │   ├── nextjs-false-friends.md  Next.js concepts with no native equivalent
│   │   ├── services-and-sdks.md     payments (store billing rules), auth, push, analytics, maps
│   │   ├── screen-spec.md           the platform-agnostic spec format
│   │   ├── verify.md                baselines and the 4-level parity check
│   │   └── run-as-loop.md           unattended screen loop objective
│   ├── android/                     stack + Android CLI loop · React → Compose · UX patterns
│   ├── ios/                         stack + XcodeBuildMCP loop · React → SwiftUI · UX patterns
│   └── port/compose-swiftui.md      two-way Compose ↔ SwiftUI map
└── templates/
    ├── migration-progress.md        the migration/ files
    ├── screen-spec.md
    ├── CLAUDE.android.md / CLAUDE.ios.md
    └── hooks.json + hooks/          block .pbxproj / entitlements / baselines edits; auto-format
```

## Recommended companions

The skill checks for these during phase 0 and asks before installing anything.

| For | Tool / skill | Install |
|---|---|---|
| Web baselines | [agent-browser](https://github.com/vercel-labs/agent-browser) | `npm i -g agent-browser && agent-browser install` |
| Android | [Android CLI](https://developer.android.com/tools/agents/android-cli) + [Google's Android skills](https://github.com/android/skills) | `brew install --cask android-cli && android init` |
| iOS | [XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP) | `npm i -g xcodebuildmcp && xcodebuildmcp init` |
| iOS | [SwiftUI Agent Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) | `npx skills add AvdLee/SwiftUI-Agent-Skill` |
| iOS | XcodeGen | `brew install xcodegen` |
| Hooks | ktlint, SwiftFormat, SwiftLint | `brew install ktlint swiftformat swiftlint` |
| E2E *(optional)* | [Maestro](https://maestro.dev) | `brew install mobile-dev-inc/tap/maestro` |

## Default stacks

These are recommendations only, and the skill follows existing conventions where a project has them.

| | Android | iOS |
|---|---|---|
| UI | Jetpack Compose + Material 3, themed from your tokens | SwiftUI |
| State | `ViewModel` + `StateFlow<UiState>` | `@Observable` models |
| Navigation | Navigation 3 | `NavigationStack` |
| DI | Hilt | Initializer / `@Environment` injection |
| Networking | Retrofit + OkHttp + kotlinx.serialization, generated from OpenAPI | URLSession + `swift-openapi-generator` |
| Secure storage | Keystore-encrypted DataStore | Keychain |
| Project | Gradle KTS + version catalog | XcodeGen or Tuist (agents never edit `.pbxproj`) |

## FAQ

**Why not React Native or Expo?**
If either fits your team, use it. Expo already ships an excellent [`expo-web-to-native`](https://github.com/expo/skills/tree/main/plugins/expo/skills/expo-web-to-native) skill. This skill is for teams that have chosen fully native apps.

**Why not wrap the site in a WebView first?**
That's the "strangler fig" approach. Apps that are mostly web wrappers tend to get rejected under App Store guideline 4.2, cookie sessions have to be bridged to native auth, and all of that work is thrown away later. The website stays live during the migration anyway, so there's no pressure to ship a half-native app.

**Does it work for Pages Router apps?**
Yes. The assessment covers the App Router, the Pages Router, and repos that mix the two.

**Does it change my Next.js repo?**
Only in phase 3, where it extracts Server Actions and server-side reads into endpoints. That happens as separate PRs, and the website keeps working throughout.

## Contributing

Issues and PRs are welcome, especially reports from real migrations: what the skill missed, where the agent went wrong, and which mappings are outdated.

## Acknowledgements

The ideas build on work by Expo, Callstack, Google's Android team, Antoine van der Lee, and others. See [ACKNOWLEDGEMENTS.md](ACKNOWLEDGEMENTS.md).

## License

[MIT](LICENSE)
