# nextjs-to-native

An agent skill for migrating a **Next.js web app to fully native mobile apps**: Kotlin + Jetpack Compose on Android, Swift + SwiftUI on iOS. Not React Native, not Expo, not a WebView wrapper.

It works with Claude Code, Codex, Cursor, and other agents that support the [Agent Skills](https://skills.sh) format.

> **Status: v0.1, not battle-tested yet.** The structure is complete, but the skill hasn't been run end to end on a real migration. Feedback and issues are welcome.

## What it does

There is no transpiler from React to Compose or SwiftUI. A native app is a new client for the same backend, carrying the same brand. This skill gives the agent an ordered path through that rewrite, with a gate at the end of every phase:

| # | Phase | Output |
|---|-------|--------|
| 0 | Tooling | Verification tools for each platform installed and working |
| 1 | Assess | Every route inventoried and bucketed (`nativize` / `drop` / `webview-link` / `later`), with `file:line` evidence |
| 2 | Decide | Platform mode (single / lead-follow / parallel), visual mode (brand-first / platform-first), backend strategy, payments |
| 3 | Backend contract | Server Actions and RSC data exposed as versioned HTTP endpoints, bearer auth, OpenAPI spec |
| 4 | Baselines + specs | Web screenshots for every state at a phone viewport, plus a platform-agnostic spec per screen |
| 5 | Foundation | Scaffold, design tokens turned into a native theme, primitives, a gallery screen, generated API client, guard hooks |
| 6 | Vertical slice | Two or three representative, *hard* flows built end to end; patterns written into the app's `CLAUDE.md` |
| 7 | Screen loop | One screen per pass: implement → preview → run → parity check → test → check off (can run unattended) |
| 8 | Second platform | Port using the web as the spec of record and the first app as the reference |
| 9 | Ship | Store and privacy checklists (signing stays with a human) |

Principles:

- **The website is the spec.** Every native screen gets checked against web baselines for content, behavior, and visual fidelity.
- **Brand-first by default.** Custom components the web designed on purpose stay custom. Platform behavior (back navigation, insets, keyboard, pickers, accessibility) is always native.
- **Backend before screens.** A mobile client can't call Server Actions or share browser cookies.
- **Verify by running.** A green build tells you nothing about a blank screen.
- **Delegate, don't duplicate.** Deep Compose and SwiftUI idioms come from platform skills (Google's Android skills, `swiftui-expert-skill`). This skill owns the migration order, the Next.js mappings, and the parity loop.

## Install

**Claude Code (plugin):**

```
/plugin marketplace add dapex301/nextjs-to-native
/plugin install nextjs-to-native@nextjs-to-native
```

**Any agent (skills CLI):**

```bash
npx skills add dapex301/nextjs-to-native --skill nextjs-to-native
```

## Recommended companions

| Platform | Tool / skill | Install |
|---|---|---|
| Web baselines | `agent-browser` | `npm i -g agent-browser && agent-browser install` |
| Android | Android CLI + Google's skills | `brew install --cask android-cli`, then `android init` and `android skills add navigation-3` (plus `adaptive`, `edge-to-edge`, `testing-setup`) |
| iOS | XcodeBuildMCP | `npm i -g xcodebuildmcp && xcodebuildmcp init` |
| iOS | SwiftUI expert skill | `npx skills add AvdLee/SwiftUI-Agent-Skill` |
| Both | Formatters for hooks | `brew install ktlint swiftformat swiftlint` |
| Both (optional) | Maestro for cross-platform E2E flows | `brew install mobile-dev-inc/tap/maestro` |

## Usage

Open the agent in your Next.js repo (or in a new folder for the native app, with the web repo next to it) and ask:

> Migrate this Next.js app to a native Android app with Compose.

The skill starts with the read-only assessment and asks one question at a time about anything it can't find in the code. Migration state lives in a `migration/` folder (worklist, decisions, screen specs, baselines, parity results), so the work can carry on across sessions and agents.

## Layout

```
plugins/nextjs-to-native/skills/nextjs-to-native/
├── SKILL.md                     phases, gates, topic router
├── references/
│   ├── shared/                  assess, backend contract, design tokens, brand vs platform,
│   │                            Next.js false friends, services & SDKs, screen specs, verify, loop
│   ├── android/                 stack + verification, React→Compose, UX patterns
│   ├── ios/                     stack + verification, React→SwiftUI, UX patterns
│   └── port/                    Compose ↔ SwiftUI
└── templates/                   migration files, screen spec, CLAUDE.md per platform, hooks
```

## License

MIT. See [ACKNOWLEDGEMENTS.md](ACKNOWLEDGEMENTS.md) for the skills that inspired this one.
