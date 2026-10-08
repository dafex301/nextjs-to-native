# App patterns learned in real migrations

Referenced by [`nextjs-to-native`](../../SKILL.md) in phases 5–8. These are patterns that came up repeatedly when real web apps were rebuilt natively and that the platform skills do not cover, because they are about *migrating* behavior, not about the frameworks.

## 1. Audit interactive behavior from the web source, not from screenshots

Screenshots capture layout. They do not capture timing, thresholds, or transitions: a 450 ms eased scroll to the explanation, a snap that settles after 140 ms of idle, a pass mark of 85 vs a per-question mark of 70, a sound played once per question.

For any screen with non-trivial interaction (quizzes, feeds, players, multi-step flows, gesture-driven UI):

1. Read the web components that implement it (`file:line`), and list: states and transitions, timings and easings, thresholds and rounding, what is persisted, what triggers network calls, what happens on error/offline/back.
2. If possible, exercise the flow in a browser to confirm what the code says.
3. Write the audit as a dated note (`docs/notes/YYYY-MM-DD-<screen>-web-audit.md`) and fold the rules into the screen spec.
4. Implement from the spec; values from the server stay authoritative (never "tune" a threshold to make a screen look right).

## 2. Preview harness with shared fixtures

Emulators and simulators often cannot sign in (no Google account, no test identity), and many screens mutate real user data (grading, progress, purchases, credits). An agent still needs to render and verify those screens.

- Put sample API responses in **`shared/fixtures/<screen>/<state>.json`** (sanitized; no real user data). Both platforms read the same files, so both are verified against identical data.
- Add a **debug/staging-only harness**: a screen gallery or preview activity/scene that renders the *real* screen components with fixture data and a fake repository that never writes to the backend. Launchable by deep link with a fixture id (`<scheme>://harness/<screen>/<state>`), so the agent can open any state directly.
- Exclude it from production builds (build type/flavor on Android, configuration/`#if DEBUG` on iOS).
- Harness passes are **rendering evidence**, not completion: the screen is done only after a real authenticated pass on staging (or the user's device, see `verify.md` → Device acceptance).
- A UI-first batch (build all variants of a complex screen against fixtures, let the user curate visuals, then connect real data) works well for screens with many variants, such as question types.

## 3. Session and auth on the client

- **Single-flight refresh.** Many backends rotate refresh tokens and revoke the session if an old refresh token is reused. When several requests hit `401` at once, exactly one refresh may run; the others wait for its result. Android: an OkHttp `Authenticator` guarded by a mutex; iOS: an `actor` inside the API client middleware.
- Navigation switches between the signed-out and signed-in roots from a single observable session state. Screens never navigate to sign-in by hand.
- Endpoints that must not carry the token (sign-in, refresh) are marked explicitly, so the auth layer skips them.
- Session restore must not block the first frame (see `performance.md`).

## 4. Resumable flows

Long or high-stakes flows (quizzes, multi-step forms, uploads, recordings) must survive process death, app switching, and flaky networks without losing user input or double-submitting.

- Persist drafts, pending uploads, and the current step with **atomic writes** (write to temp, then rename), **bound to the account** (never restore one user's draft for another), and with an **expiry**.
- Server-confirmed actions (grading, payment, submission) stay server-confirmed: show progress, keep the draft on failure, retry idempotently. Do not fake success locally to look faster unless the error/retry path has been designed and audited.
- Clear persisted flow state on sign-out.
- Test: kill the app mid-flow (Android "Don't keep activities"/`adb shell am kill`; iOS: terminate from Xcode) and confirm the user lands on the same step with the same input.

## 5. Isolated web renderers: the only allowed WebViews

Full native is the rule. A WebView is allowed only for content that has no reasonable native renderer and comes from data: CMS rich HTML, math (KaTeX/MathJax), embedded third-party players that only offer an iframe (e.g. YouTube). Each use needs a decision record.

Rules for every isolated renderer:

- Sanitize the HTML (allowlist of tags/attributes) before loading. Remember that CMS content may be wrapped in semantic containers (`main`, `article`, `figure`) the sanitizer must allow.
- Bundle the renderer's assets (KaTeX CSS/JS/fonts) locally; no remote script loading except the third-party player itself.
- No JavaScript bridge to the app, no app cookies or tokens, non-persistent storage (Android: no `addJavascriptInterface`, cleared cookies; iOS: `WKWebsiteDataStore.nonPersistent()`, no script message handlers).
- Links open in Custom Tabs / `SFSafariViewController`, never inside the renderer.
- Native code owns everything around it: navigation, controls outside the embed, loading/error states. Plain text stays native.
- Performance limits in `performance.md` apply (one instance per screen, not inside lazy lists).

## 6. Generated clients are a starting point

OpenAPI generators sometimes mis-model polymorphic payloads (`oneOf`/unions of scalar and array, discriminated unions). Do not edit generated code: add a thin hand-written adapter or serializer next to it for the affected types, cover it with unit tests using `shared/fixtures/`, and note it in `shared/api/SOURCE.md`.

## 7. Production safety while migrating

Default guardrails, recorded as a decision in phase 2 unless the user chooses otherwise:

- The website repo is read-only for the migration.
- Backend changes are **additive** (new endpoints/fields, no behavior changes for existing clients), go through PRs, and are reviewed by the backend owner.
- Know which branch deploys where (e.g. `main` → staging, release workflow → production) and never trigger production deploys.
- Ask who owns backend work. If a backend engineer owns it, the agent writes a proposal and the mobile side codes against the proposed contract behind a placeholder, rather than implementing the backend itself.
