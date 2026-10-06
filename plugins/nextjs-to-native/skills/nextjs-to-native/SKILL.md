---
name: nextjs-to-native
description: Migrate an existing Next.js web app to fully native mobile apps — Kotlin + Jetpack Compose on Android and/or Swift + SwiftUI on iOS (not React Native, Expo, Capacitor, or a WebView wrapper). Use when the user wants to turn a Next.js site into a native Android or iOS app, audit a Next.js repo for a native rewrite, extract Server Actions / Server Components into an API a mobile client can call, carry a Tailwind/shadcn design system into Compose or SwiftUI themes, port screens one by one with visual parity checks against the running website, or port a finished native app from one platform to the other (Compose ↔ SwiftUI).
version: 0.1.0
license: MIT
---

# Next.js → Native (Compose / SwiftUI)

A Next.js app does not convert to native. There is no transpiler, and there is no shared runtime: the native app is a new client that talks to the same backend and carries the same brand. This skill is the spine that orders that rewrite so an agent can run it screen by screen, with evidence and verification at every step. It defers idiomatic Compose / SwiftUI detail to platform skills (see **Delegate, don't duplicate**) and keeps the migration-specific knowledge here.

```
0 Tooling ─▶ 1 Assess ─▶ 2 Decide ─▶ 3 Backend contract ─▶ 4 Baselines + screen specs
                                                                   │
        9 Ship ◀─ 8 Port 2nd platform ◀─ 7 Screen loop ◀─ 6 Vertical slice ◀─ 5 Foundation
```

## Principles

- **The website is the spec.** Behavior, content, states, and brand come from the running web app. Capture them once (phase 4) and verify every native screen against them.
- **Brand-first by default.** Custom components that the web designed on purpose stay custom: port them faithfully as themed composables / views built from the extracted tokens. Use stock Material 3 / SwiftUI controls only where the web itself used a generic control. Platform *behavior* is always native (see `references/shared/brand-vs-platform.md`). Platform-first is an opt-in decision in phase 2.
- **Backend before screens.** A mobile client cannot call Server Actions, receive RSC payloads, or share cookies with the browser. Until every screen's data has a callable endpoint with bearer auth, screen work only produces mocks.
- **Evidence, not vibes.** Every inventory claim cites `file:line` and carries a label: `observed`, `assumed`, or `unknown`. Unknowns that block a decision become questions.
- **Gates, not momentum.** Each phase ends with a gate. Do not start the next phase until the gate passes or the user explicitly waives it.
- **Verify by running.** A green build proves nothing about a blank or misaligned screen. Render it (preview, emulator, simulator) and compare against the web baseline.
- **Best-practice defaults, not dogma.** The stacks in `references/android/stack.md` and `references/ios/stack.md` are recommended defaults. If a native project or team convention already exists, follow it. Look up current versions and APIs live; never trust a version number written in this skill.
- **One screen per pass.** The app builds and runs after every pass. The worklist is the source of truth across sessions.

## Asking the user

Inspect the repository before asking anything. When a decision-changing fact cannot be found in code, ask **one** question per turn in this shape and stop:

```
**Question:** <one question>
**Why it matters:** <which decision or phase this changes>
```

## Phases

### 0 · Tooling

Check the verification tools for the target platform(s) exist; if one is missing, ask before installing it. Required: a web capture tool (`agent-browser`, or Playwright if already present), plus `android` (Android CLI) + `adb` for Android, or `xcodebuildmcp` + Xcode for iOS. Details per platform in each `stack.md`.

**Gate:** each required tool runs (`--version` / `--help`) and an emulator or simulator can boot.

### 1 · Assess → worklist

Read `references/shared/assess.md` and produce `migration/` in the native repo (or the web repo if the user prefers) using `templates/migration-progress.md`: route inventory, data dependencies, auth, storage, third-party services, Next.js-specific signals. Bucket every route: `nativize`, `drop` (SEO/marketing/admin pages that do not belong in an app), `webview-link` (rare: legal pages, help center opened in an in-app browser), or `later`.

**Gate:** every `page.tsx` / `pages/*` route is listed and bucketed; every data source for a `nativize` screen is traced to its origin with `file:line`.

### 2 · Decide

Record these decisions in `migration/DECISIONS.md` (ask for any the user has not stated):

1. **Platform mode** — `single` (one platform now), `lead-follow` (default when both: the second platform trails by 1–2 screens and uses the first as a reference), or `parallel` (only with a separate reviewer per platform; review, not code, is the bottleneck).
2. **Lead platform** — usually where most users are.
3. **Visual mode** — `brand-first` (default) or `platform-first`.
4. **Backend strategy** — extend the Next.js app with route handlers, or point at an existing separate API.
5. **Payments** — anything sold digitally inside the app must use store billing. Read `references/shared/services-and-sdks.md` *now*; it can change the business model.

**Gate:** all five recorded.

### 3 · Backend contract

Read `references/shared/backend-contract.md`. Expose every Server Action and server-side data read used by a `nativize` screen as an HTTP endpoint, move auth to bearer tokens, and publish an OpenAPI spec the native clients generate code from. This happens in the web/backend repo as its own PRs; do not mix it with native work.

**Gate:** every `nativize` screen's reads and writes have an endpoint; a token obtained via the auth flow works from `curl`; the OpenAPI spec validates.

### 4 · Baselines + screen specs

Read `references/shared/verify.md` (web side) and `references/shared/screen-spec.md`. For each `nativize` screen, capture the web baseline once — screenshots at a phone viewport for each state (loaded, empty, loading, error, logged-out), plus the accessibility snapshot — and write a platform-agnostic spec from `templates/screen-spec.md`.

**Gate:** every `nativize` screen has a spec and baselines for each of its states.

### 5 · Foundation (per platform)

Read the platform's `stack.md`, then `references/shared/design-tokens.md`. Scaffold the project, write the app's `CLAUDE.md` / `AGENTS.md` from `templates/`, install the guard hooks, generate the API client from OpenAPI, wire auth + secure token storage, convert the web tokens into the platform theme, and build the primitives the web actually uses. Put every primitive on one **gallery screen** with previews.

**Gate:** the gallery renders on an emulator/simulator and matches the web components at the token level (color, type scale, radius, spacing); the API client authenticates against the real backend.

### 6 · Vertical slice

Pick two or three flows that are *representative and hard*, not easy: sign-in + session restore, a list → detail with pagination, and the riskiest boundary (file upload, payments, push, realtime, maps, deep links). Build them end to end. Lock the patterns that emerge (screen structure, state, navigation, error/loading handling, testing) into the app's `CLAUDE.md`.

**Gate:** the slice runs on a device image, passes parity checks, and the patterns are written down.

### 7 · Screen loop

For each unchecked `nativize` screen, top-down: read its spec → implement (consult the platform false-friends and patterns files) → preview → run → parity check against baselines → write a UI test → check it off in the worklist with a one-line result, or mark it `blocked: <reason> — needs <unlock>` and move on. Never revisit a blocked item without new information. To run this unattended, use `references/shared/run-as-loop.md`.

**Gate:** no unchecked `nativize` items remain.

### 8 · Port to the second platform (lead-follow)

Repeat phase 5 for the second platform, then loop over screens using the web baseline as the spec of record and the lead platform's implementation as the reference for resolved decisions (API usage, edge cases, state shape). Read `references/port/compose-swiftui.md`. Re-run parity against the **web** baseline, not against the other native app.

**Gate:** same as phase 7.

### 9 · Ship

Store listings, privacy manifests / data-safety forms, signing, and release tracks need a human: prepare checklists and artifacts, but do not handle signing credentials. Platform notes are in each `stack.md`.

## Topic router

| Need | Read |
|---|---|
| Inventory a Next.js repo, bucket routes | `references/shared/assess.md` |
| Next.js / React concept with no native equivalent | `references/shared/nextjs-false-friends.md` |
| Server Actions / RSC → API, auth, OpenAPI | `references/shared/backend-contract.md` |
| Tailwind / shadcn / CSS variables → theme | `references/shared/design-tokens.md` |
| What stays brand vs what becomes platform-native | `references/shared/brand-vs-platform.md` |
| Payments, push, OAuth, analytics, maps, SDKs | `references/shared/services-and-sdks.md` |
| Writing a screen spec | `references/shared/screen-spec.md` |
| Capturing baselines, parity checks | `references/shared/verify.md` |
| Running the screen loop unattended | `references/shared/run-as-loop.md` |
| Android stack, tooling, hooks, verification | `references/android/stack.md` |
| React / Tailwind idiom → Compose | `references/android/react-to-compose.md` |
| Web UX pattern → Android | `references/android/patterns.md` |
| iOS stack, tooling, hooks, verification | `references/ios/stack.md` |
| React / Tailwind idiom → SwiftUI | `references/ios/react-to-swiftui.md` |
| Web UX pattern → iOS | `references/ios/patterns.md` |
| Compose ↔ SwiftUI translation | `references/port/compose-swiftui.md` |

## Delegate, don't duplicate

This skill owns the migration order, the Next.js mappings, and the parity loop. For deep platform idioms, use the platform skills when they are installed, and suggest installing them when they are not:

- **Android:** Google's official skills via Android CLI (`android skills list`, `android skills add <name>`): `navigation-3`, `adaptive`, `edge-to-edge`, `testing-setup`, plus `android-cli` for tooling.
- **iOS:** `swiftui-expert-skill` (AvdLee/SwiftUI-Agent-Skill) for SwiftUI correctness and current APIs; `xcodebuildmcp-cli` for builds; topic skills from `dpearson2699/swift-ios-skills` such as `swift-architecture`, `ios-networking`, `authentication`, `swiftui-navigation`, `storekit`, `push-notifications`.

When a delegated skill and this skill disagree on an idiom, the platform skill wins; on migration order and parity, this skill wins.
