# Verify: baselines and parity checks

Phases 4–8 of [`nextjs-to-native`](../../SKILL.md). A screen passes when the running native screen matches the web baseline on content, behavior, and (in brand-first mode) visual fidelity. Builds, type checks, and unit tests are necessary but never sufficient.

## A. Capture web baselines (phase 4, once)

Run the website locally (`pnpm dev` / `npm run dev`) or use a staging URL, signed in as a test account. Capture at a phone viewport that matches the emulator/simulator you will compare against (e.g. 412×915 for a typical Android phone, 393×852 for a 6.1" iPhone; record the exact size in `PARITY_CHECKS.md`).

With `agent-browser` (preferred; run `agent-browser skills get core` for its current command reference):

```bash
agent-browser set viewport 412 915
agent-browser open "http://localhost:3000/orders"
agent-browser snapshot > migration/baselines/orders/loaded.a11y.txt
agent-browser screenshot migration/baselines/orders/loaded.png
agent-browser screenshot --full migration/baselines/orders/loaded-full.png
```

With Playwright, the equivalent is a script that sets `viewport` + `deviceScaleFactor`, navigates, and saves `page.screenshot()` and `page.accessibility.snapshot()`/ARIA snapshot.

Per screen, capture **every state** the spec lists: loaded, empty, loading (throttle the network or pause the request), error (block the endpoint), logged-out/forbidden, and long-content (to see truncation/wrapping). Also capture dark mode if the web supports it. For flows (forms, multi-step), capture each step and record the interaction sequence in the spec.

Store baselines under `migration/baselines/<screen>/<state>.png` and reference them from the screen spec. The folder is git-ignored by default (or tracked with Git LFS for teams; see `repo-layout.md`). Also capture each web component used by the design system under `migration/baselines/_components/` for the gallery comparison. Never re-capture a baseline to make a failing check pass; if the web changed, re-capture deliberately and note it.

Do not commit baselines that contain real user data or secrets; use seeded test accounts.

## B. Capture the native screen

Platform commands live in `../android/stack.md` and `../ios/stack.md`. In short:

- **Fast loop (no device):** Compose `@Preview` rendered via `android studio render-compose-preview`; SwiftUI `#Preview` rendered via Xcode's MCP preview tool, or a snapshot test. Use previews with fake data for every state.
- **Real loop (device image):** build and run on the emulator/simulator, navigate to the screen (deep link where possible), capture a screenshot and the UI hierarchy (`android layout` / XcodeBuildMCP UI automation describe).
- **Motion:** for screens with transitions, gestures, or animated states, record a short video (`adb shell screenrecord`, `xcrun simctl io booted recordVideo`) — a still frame cannot show jank or wrong easing.

## C. Compare

Compare the same screen and state, side by side. Check in this order and stop at the first failure class:

1. **Content** — the same data, fields, labels, counts, and ordering. Every element in the web a11y snapshot either exists natively or is intentionally dropped (note why: web-only chrome, hover-only affordance, SEO text).
2. **Behavior** — every action in the spec works: navigation targets, mutations reach the backend and the UI updates, validation messages match, error and empty states appear under the same conditions, auth gates redirect correctly.
3. **Visual fidelity (brand-first)** — layout structure, spacing, color, typography, radius, imagery, icon choice. Allowed differences: system chrome, font rasterization, native controls listed in `brand-vs-platform.md`, platform-correct touch target sizes (min 48dp / 44pt), single-column reflow of multi-column web layouts.
4. **Platform behavior** — back works and preserves state, keyboard never covers the focused field, insets/safe areas respected, rotation/process death (Android) and backgrounding restore the screen, screen reader reads it in a sensible order, large font sizes do not clip.

Record the result per screen and state in `PARITY_CHECKS.md`: `pass`, or `fail: <class> — <what differs>`. Fix failures caused by code in the same pass. If a failure comes from outside the code (missing endpoint, missing asset, unclear spec), mark the screen `blocked` in the worklist with what would unblock it.

## Faithful pass, then idiomatic pass

For the vertical slice (phase 6), do two passes on at least one flow:

1. **Faithful** — reproduce the web behavior and states exactly, even if the code looks web-shaped.
2. **Idiomatic** — restructure into proper platform architecture (state hoisting, ViewModel/observable state, navigation types, reusable primitives) and re-run every parity check.

The patterns that survive the idiomatic pass go into the app's `CLAUDE.md` and every later screen is written idiomatically from the start.

## UI tests

After a screen passes parity, add a UI test for its critical behavior (Compose UI test / XCUITest, or a Maestro flow if the team prefers cross-platform YAML flows). Screenshot tests (Compose Preview screenshot testing, Roborazzi/Paparazzi, swift-snapshot-testing) lock the visual result so later screens do not regress shared primitives.
