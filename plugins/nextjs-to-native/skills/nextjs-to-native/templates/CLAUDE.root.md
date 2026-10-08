# <App name> — mobile

Native mobile clients for <product>: Android (Kotlin + Jetpack Compose) in `android/`, iOS (Swift + SwiftUI) in `ios/`. Migrated from the Next.js website with the `nextjs-to-native` skill. Platform rules live in `android/CLAUDE.md` and `ios/CLAUDE.md`.

## Related repos

- Web (the spec): `<path or URL>`
- Backend (owns the API contract): `<path or URL>`

## Start here

1. Read `docs/decisions/` — every accepted decision, newest last. Do not re-decide something recorded there; propose a new record instead.
2. Read `migration/SCREENS.md` for current progress.
3. For any screen, its spec is `migration/screens/<id>.md`; for any component, `shared/components/<name>.md`.

## Shared artifacts (single source for both platforms)

- `shared/tokens/tokens.json` → generated themes. Never hand-edit generated theme code; change the tokens and regenerate.
- `shared/components/*.md` → component contracts. Both platforms use the same component names, parameters, variants, and states.
- `shared/assets/` → icons, illustrations, fonts.
- `shared/fixtures/` → sanitized sample responses per screen/state, used by both preview harnesses and tests.
- `shared/api/openapi.yaml` → pinned copy of the backend contract (source recorded in `shared/api/SOURCE.md`). Update deliberately, then regenerate both clients.

## Conventions

- Mode: <single | lead-follow (lead: android) | parallel>. Visual mode: <brand-first | platform-first>.
- Records are dated (`docs/decisions/YYYY-MM-DD-slug.md`, `docs/notes/YYYY-MM-DD-slug.md`); living docs are not.
- Commits: `feat(android): …`, `feat(ios): …`, `chore(shared): …`, `docs: …`.
- Release tags per platform: `android/vX.Y.Z`, `ios/vX.Y.Z`.
- `migration/baselines/` is git-ignored; re-capture from the website when needed.
- A screen is done when it passes parity against the web baseline on a device image (and a physical device where behavior is device-dependent), not when it compiles.
- Performance budgets: `<cold start ≤ 1.5 s on <low-end device>, no visible hitches at 60/120 Hz>`; measured on release-like builds only.
