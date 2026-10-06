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
| screen | operation | today (origin, file:line) | endpoint | auth | cache rule | status |
|--------|-----------|---------------------------|----------|------|------------|--------|
| orders | list orders | RSC prisma query, app/orders/page.tsx:20 | GET /api/v1/orders | bearer | SWR, refresh on focus | todo |
| orders | cancel order | server action, app/orders/actions.ts:8 | POST /api/v1/orders/{id}/cancel | bearer | update item | todo |
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

## `migration/DECISIONS.md`

```markdown
| # | decision | choice | why | date |
|---|----------|--------|-----|------|
| 1 | platform mode | lead-follow | single reviewer, Android-majority users | |
| 2 | lead platform | android | | |
| 3 | visual mode | brand-first | | |
| 4 | backend strategy | route handlers in the Next.js app | | |
| 5 | payments | n/a / store billing / provider SDK | | |
```

---

## `migration/PARITY_CHECKS.md`

```markdown
Baseline viewport: <w>x<h> @<scale>x   Android device: <avd>   iOS device: <simulator>

| platform | screen | state | content | behavior | visual | platform | notes |
|----------|--------|-------|---------|----------|--------|----------|-------|
| android | orders | loaded | pass | pass | fail | pass | card radius 12 vs 8 |
```
