# Migration workspace templates

Create these files under `migration/` in phase 1. Keep them in git; they are the durable state of the migration across sessions and agents.

---

## `migration/SCREENS.md`

```markdown
# Screens

Web repo: <path or URL> @ <commit>
Lead platform: <android|ios>   Mode: <single|lead-follow|parallel>   Visual: <brand-first|platform-first>

## nativize (priority order)

| # | id | route | source | auth | complexity | android | ios |
|---|----|-------|--------|------|------------|---------|-----|
| 1 | sign-in | /login | app/(auth)/login/page.tsx:1 | no | stateful | [ ] | [ ] |
| 2 | orders | /orders | app/orders/page.tsx:12 | yes | stateful | [ ] | [ ] |

Results (one line per completed or blocked item):
- android/sign-in — done (credential manager + email/password)
- android/orders — blocked: no pagination endpoint — needs GET /api/v1/orders?cursor

## later
| id | route | reason |

## drop
| route | reason (e.g. SEO landing page, admin) |

## webview-link
| route | opened as |
```

---

## `migration/DATA.md`

```markdown
Topology: `server-in-next` | `client-direct` | `bff-proxy` | `bff-aggregate` | `bff-auth` (see references/shared/assess.md).

| screen | operation | topology | today (file:line) | backend endpoint | auth | cache rule | status |
|--------|-----------|----------|-------------------|------------------|------|------------|--------|
| orders | list orders | bff-proxy | app/api/orders/route.ts:12 → GET {BE}/v1/orders | GET /v1/orders | bearer | SWR, refresh on focus | ready |
| orders | order summary | bff-aggregate | app/orders/page.tsx:20 (merges /orders + /payments) | — | bearer | refresh on focus | needs endpoint |
| profile | sign in | bff-auth | app/api/auth/[...nextauth]/route.ts:1 | POST /v1/auth/token | — | — | needs mobile auth |
```

---

## `migration/DEPENDENCIES.md`

```markdown
| service | web usage (file:line) | android | ios | decision / owner | status |
|---------|-----------------------|---------|-----|------------------|--------|
```

---

## `migration/STATE_AND_STORAGE.md`

```markdown
| state | web mechanism (file:line) | native mechanism | survives restart? |
|-------|---------------------------|------------------|-------------------|
| session | httpOnly cookie | Keychain / encrypted DataStore token | yes |
| theme | localStorage | DataStore / @AppStorage | yes |
| order filters | searchParams | screen saved state | no |
```

---

## `migration/DECISIONS.md` (index of decision records)

Each decision is a dated record in `docs/decisions/` (`templates/adr.md`). This file only indexes them.

```markdown
| date | decision | choice | record |
|------|----------|--------|--------|
| 2026-10-06 | platform mode | lead-follow (android leads) | [record](../docs/decisions/2026-10-06-platform-mode.md) |
| 2026-10-06 | visual mode | brand-first | [record](../docs/decisions/2026-10-06-visual-mode.md) |
| 2026-10-06 | backend strategy | mobile calls the backend directly | [record](../docs/decisions/2026-10-06-backend-strategy.md) |
| <pending> | payments | <pending> | <pending> |
| 2026-10-06 | repo layout | mobile monorepo | [record](../docs/decisions/2026-10-06-repo-layout.md) |
```

---

## `migration/ASSETS.md`

```markdown
Visual source: <web repo @ commit | redesign repo/URL>   Import: <phase 5 | blocked: reason>

| asset | source path | size | used by (file:line) | bundled/remote | android | ios | licence | status |
|-------|-------------|------|---------------------|----------------|---------|-----|---------|--------|
| logo | public/brand/logo.svg | 6 KB | components/header.tsx:12 | bundled | VectorDrawable | asset catalog SVG | own | ready |
| course art | API `course.image_url` | — | components/course-card.tsx:30 | remote | Coil | caching loader | — | n/a |
| hero | public/images/hero.png | 3.1 MB | app/home/page.tsx:8 | bundled | WebP densities | @2x/@3x | stock (check) | oversized |
| app icon | — | — | — | bundled | adaptive + monochrome | .icon | own | needs source art |
```

---

## `migration/PARITY_CHECKS.md`

```markdown
Baseline viewport: <w>x<h> @<scale>x   Android device: <avd>   iOS device: <simulator>

| platform | screen | state | content | behavior | visual | platform | notes |
|----------|--------|-------|---------|----------|--------|----------|-------|
| android | orders | loaded | pass | pass | fail | pass | card radius 12 vs 8 |
```
