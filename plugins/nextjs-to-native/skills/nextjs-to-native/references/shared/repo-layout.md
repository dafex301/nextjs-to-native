# Repo layout and docs

Phase 2 decision 6 of [`nextjs-to-native`](../../SKILL.md). Decide where the native code, shared artifacts, migration state, and decision records live before scaffolding anything.

## Topology

The website and backend keep their repos. The native apps get one **mobile monorepo** by default:

```
<backend repo>        owns the API contract (OpenAPI)
<web repo>            the spec: behavior, content, brand
<app>-mobile          android/ + ios/ + shared artifacts   ← created by this skill
```

| Option | Choose when |
|---|---|
| **Mobile monorepo** (default) | Solo developer or one small team; lead-follow mode; no shared Kotlin/Swift code needed |
| **One repo per platform** | Separate Android and iOS teams with their own release cadence and CI budget |
| **Add mobile to an existing web/backend monorepo** | The web and backend already live in one monorepo owned by the same team |

Native Kotlin and Swift share no code. What the monorepo shares is **artifacts**: screen specs, component specs, design tokens, assets, the pinned API contract, and migration state. That is what makes lead-follow cheap. If the repo must be split later, `android/` and `ios/` never import each other, so `git filter-repo --path android/` (and the same for `ios/`) splits it with history. Starting together and splitting later is easy; merging later is not.

## Mobile monorepo layout

```
<app>-mobile/
├── CLAUDE.md                  cross-platform rules (from templates/CLAUDE.root.md)
├── README.md
├── android/                   Gradle project; android/CLAUDE.md (templates/CLAUDE.android.md)
├── ios/                       project.yml (XcodeGen), local packages; ios/CLAUDE.md (templates/CLAUDE.ios.md)
├── shared/
│   ├── tokens/                tokens.json + generator script → Compose theme + SwiftUI theme
│   ├── components/            one spec per design-system component (templates/component-spec.md)
│   ├── assets/                icons, illustrations, fonts — single source, converted per platform
│   └── api/                   pinned snapshot of the backend's OpenAPI spec + sync script
├── migration/                 living migration state (SCREENS.md, DATA.md, screens/, PARITY_CHECKS.md, ...)
│   └── baselines/             web screenshots — git-ignored by default (see below)
├── docs/
│   ├── decisions/             dated decision records (ADRs)
│   └── notes/                 dated notes: research, findings, retros
└── .github/workflows/         android.yml, ios.yml with path filters (templates/ci/)
```

Claude Code loads nested `CLAUDE.md` files when it works inside that folder, so platform rules only enter context when relevant; keep the root `CLAUDE.md` to cross-platform rules.

## Rules that keep it scalable

- **CI path filters.** Android changes never start a macOS runner; iOS changes never run Gradle. Changes under `shared/` run both.
- **Independent releases.** Tag per platform: `android/v1.4.0`, `ios/v1.3.2`. Store review cycles differ.
- **The backend owns the API contract.** `shared/api/openapi.yaml` is a pinned copy fetched from the backend (by URL or from the backend repo at a commit), recorded in `shared/api/SOURCE.md`. Codegen in both apps reads that copy. Update it deliberately, in its own commit, and regenerate both clients.
- **Generated code is not committed by hand.** Theme code generated from tokens and API clients generated from OpenAPI are rebuilt by scripts/build steps.
- **CODEOWNERS** per folder once more than one person works in the repo.

## Baselines: git-ignored or Git LFS

Git keeps every version of every file forever. Screenshots are large binaries that cannot be delta-compressed, so re-captured baselines bloat the repository quickly.

- **Default (solo / small team): git-ignore `migration/baselines/`.** Baselines are reproducible from the website; re-capture them when needed. Record the capture viewport and date in `PARITY_CHECKS.md`.
- **Team with separate reviewers: Git LFS.** `git lfs track "migration/baselines/**/*.png"` stores the images outside the normal history and keeps small pointers in git. Check the hosting provider's LFS quota.

## Living docs vs records

| Kind | Examples | Naming |
|---|---|---|
| **Living docs** — always describe the current state; edited in place, history in git | Screen specs, component specs, tokens, `SCREENS.md`, `DATA.md`, `CLAUDE.md` | No date: `migration/screens/orders.md` |
| **Records** — written once, not rewritten | Decisions, discussion outcomes, research notes, findings, retros | ISO date prefix: `docs/decisions/2026-10-06-repo-layout.md` |

- Use ISO dates (`YYYY-MM-DD`): sortable and unambiguous.
- One file per record. Use a folder (`2026-10-06-repo-layout/README.md`) only when the record has attachments.
- Never edit a decision to change it. Write a new one and mark the old one `Status: superseded by <file>`.
- Decisions use `templates/adr.md`; notes use `templates/note.md`.
- `migration/DECISIONS.md` is the index: one line per decision linking to its record.
- A new agent session should read `docs/decisions/` before acting: it is how context survives between sessions.
