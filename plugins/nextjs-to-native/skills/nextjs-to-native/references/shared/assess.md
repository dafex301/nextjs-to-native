# Assess a Next.js repo

Phase 1 of [`nextjs-to-native`](../../SKILL.md). Read-only: produce the worklist and inventories, change nothing in the web repo.

Every material claim gets a citation (`path/to/file.tsx:42`) and a label:

- `observed` — read in code or seen running
- `assumed` — inferred, not confirmed (say from what)
- `unknown` — could not establish; if it blocks a decision, it becomes a question

## 1. Establish scope

- Find every client of the product: the Next.js app, any separate backend/API repo, any existing mobile app, admin panels. A monorepo (`apps/`, `packages/`, Turborepo/Nx/pnpm workspaces) may hold several.
- Find the backend. If the Next.js app calls a separate backend (look for API base URL env vars, API client modules, `fetch` to absolute URLs, rewrites in `next.config.*`), that backend repo is **in scope**: the mobile app will talk to it directly, and phase 3 work happens there. If it is not accessible, mark everything that depends on it `unknown` and ask for access before phase 3.

- **Assess what is deployed, not what is checked out.** For each repo: `git fetch`, compare the local branch with the deployed branch (usually the remote default branch), note uncommitted changes, and record the commit you assessed in `SCREENS.md`. A stale backend checkout makes existing endpoints look missing.
- **Look for existing native clients** of the same backend: search the web/backend READMEs, docs, CI, and the organization's repos for iOS/Android apps. If one exists, ask whether this migration replaces it, reuses parts of it (brand assets, auth UX, conventions), or ignores it. It may change the store listing (an update to an existing app vs a new app).
- **Multi-brand / white-label web apps:** look for theme registries (`theme/*.json`, brand configs), runtime branding endpoints, per-tenant/platform IDs sent at login. Ask which brand(s) the app ships as and whether theming is fixed at build time or loaded at runtime; this changes the token pipeline, app IDs/flavors, and login payloads.
- **Redesign in progress:** ask whether the web UI is being redesigned. If yes, separate the **behavior spec** (flows, states, data, copy — usually the current production web) from the **visual spec** (tokens, component look — whatever will ship: a redesign branch, prototype repo, staging URL, or Figma). Record the source per screen. Non-visual work (backend contract, networking, auth, persistence, navigation skeleton) can proceed while visual baselines and tokens are blocked.
- **Large repos:** for more than ~20 routes, split the read-only assessment across parallel subagents by area (routes/pages, web data layer, backend), each returning rows in the exact `SCREENS.md` / `DATA.md` column shape with `file:line`, so results merge without rework. Respect the user's working agreements about subagent use.

## 1b. Classify data topology per operation

Apps frequently mix topologies, so label each data operation, not the app:

| Label | How to recognize it | What mobile needs |
|---|---|---|
| `server-in-next` | RSC/Server Actions/route handlers query a DB or contain business logic | Extract into an endpoint (`backend-contract.md`) |
| `client-direct` | Client components call the backend's absolute URL directly | Usually nothing; confirm bearer auth works |
| `bff-proxy` | A route handler / server action forwards to a backend endpoint unchanged. Common hybrid: the browser already holds the backend token (e.g. in the auth session) and sends it through a same-origin pass-through proxy — note it, because then phase 3 is nearly free | Call the backend endpoint directly |
| `bff-aggregate` | Next calls several backend endpoints, merges, filters, or reshapes | Move the composition into a backend endpoint, or reproduce it in the app's repository layer (decide per case) |
| `bff-auth` | Next holds the backend token server-side (session cookie ↔ backend token) | Mobile authenticates against the backend directly — usually the main phase 3 blocker |

Record the label in `DATA.md` for every operation used by a `nativize` screen. Server-only *libraries* in Next.js (e.g. a Node text-processing library behind a route handler) are `server-in-next` too; see `backend-contract.md` for the move-to-backend vs reproduce-on-device choice.

## 2. Read the framework signals

| Signal | Where | Why it matters |
|---|---|---|
| Router type | `app/` or `src/app/` (App Router) vs `pages/` (Pages Router); both can coexist | Decides where data fetching lives |
| Next.js version | `package.json` | Caching and request API semantics changed across majors |
| Server Components | `async function Page()`, `async` components without `'use client'` | Data is fetched on the server and never exposed as an API |
| Server Actions | `'use server'` (file or function level), `action={...}` on forms, `useActionState`, `useFormStatus` | Mutations with no HTTP endpoint a mobile app can call |
| Route handlers | `app/**/route.ts`, `pages/api/**` | Existing endpoints; check whether they authenticate by cookie only |
| Data fetching (Pages Router) | `getServerSideProps`, `getStaticProps`, `getInitialProps` | Same problem as RSC: logic lives in the page |
| Middleware | `middleware.ts` / `proxy.ts` | Auth gates, redirects, geo/locale logic the native app must reproduce |
| Caching | `fetch(..., { next: { revalidate } })`, `revalidatePath`, `revalidateTag`, `unstable_cache`, `'use cache'` | Freshness rules the native app must re-implement client-side |
| Auth | `next-auth`/Auth.js, Clerk, Supabase, Firebase, Lucia, Better Auth, custom JWT; `cookies()`, `headers()` | Cookie sessions must become bearer tokens |
| DB/ORM in pages | Prisma, Drizzle, Kysely, Mongoose imported in server components or actions | Business logic coupled to rendering; must move behind an endpoint |
| Styling | `tailwind.config.*` (v3), `@theme` in CSS (v4), `components.json` (shadcn), CSS Modules, styled-components, MUI/Chakra | Source of design tokens |
| Client state/data | React Query/TanStack Query, SWR, Zustand, Redux, Jotai, Context | Maps to ViewModel/`@Observable` state and repository caching |
| Forms/validation | react-hook-form, Zod, Yup, Valibot | Validation rules to port; Zod schemas can feed OpenAPI |
| i18n | `next-intl`, `next-i18next`, `[locale]` segments | String resources per platform |
| Realtime | WebSockets, SSE, Pusher, Ably, Supabase realtime, streaming AI (`ai` SDK) | Needs a native client; streaming needs special handling |
| Media/files | `<input type="file">`, uploads to S3/R2/UploadThing, `next/image` | Native pickers, permissions, presigned uploads |
| Static assets | `public/**`, imported images/audio/fonts, icon packages, CSS `url()`, Lottie, synthesized Web Audio SFX, brand configs pointing at logos | Bundled vs remote, per-platform formats, oversized files, missing files; see `assets.md` |
| Parallel legacy and new flows | Two implementations of the same feature selected per item (`/v1/...` vs `/v2/...`, feature flags, per-course switches) | Ask whether every item the app will show uses the new flow; if so, port only that and bucket the legacy routes |
| Media formats | Upload/recording code, backend validators (audio codec, sample rate, image size limits) | Native recorders/pickers default to other formats (AAC, HEIC); match what the backend accepts |
| Account lifecycle | Sign-up, sign-out, account deletion endpoints and UI | Both stores require in-app account deletion when accounts can be created; a missing endpoint becomes phase 3 work |
| Third-party browser SDKs | Stripe.js, GA/GTM, Segment, PostHog, Sentry, Intercom, Maps JS, reCAPTCHA | Each needs a native SDK or a decision; see `services-and-sdks.md` |
| Env vars | `.env*`, `NEXT_PUBLIC_*`, `process.env.*` | Public vs secret; secrets never ship in an app binary |

## 3. Inventory

Write these files under `migration/` (templates in `templates/migration-progress.md`):

- **`SCREENS.md`** — one row per route: path, file, auth required, data reads (with origin: RSC fetch / server action / route handler / client fetch / third-party), mutations, client-only interactions, bucket, priority, notes. Include dynamic segments (`[id]`, `[...slug]`), parallel/intercepting routes (`@modal`, `(.)photo`), and route groups (`(marketing)`).
- **`DATA.md`** — every data source a `nativize` screen touches: topology label, current access path, the backend endpoint behind it (if any), auth mechanism, caching/revalidation rule.
- **`DEPENDENCIES.md`** — third-party services and SDKs, with the native replacement or the open decision.
- **`STATE_AND_STORAGE.md`** — cookies, `localStorage`/`sessionStorage`, IndexedDB, URL state (search params used as state), global stores.
- **`ASSETS.md`** — every static asset a `nativize` screen uses: path, size, users (`file:line`), bundled vs remote, target format, licence; flag oversized and referenced-but-missing files (`assets.md`).
- **`PARITY_CHECKS.md`** — filled in phase 4 and 7; create it empty now.

## 4. Bucket every route

| Bucket | Use for |
|---|---|
| `nativize` | Product screens users come to the app for |
| `drop` | SEO/marketing landing pages, blog, pricing pages aimed at web visitors, sitemap, OG image routes, admin back-office. **Effectively permanent: confirm every `drop` with the user** |
| `webview-link` | Terms, privacy policy, help center: open in an in-app browser (Custom Tabs / `SFSafariViewController`), never as an embedded screen |
| `later` | Screens the first release can ship without: low-traffic screens and product-scope cuts (e.g. partner tooling, B2B/organization management inside the app). The safe default when unsure |

Before bucketing, ask which personas and features the first release is for. Product screens outside that scope are `later`, not `drop`; record the scope cut as a decision record.

Order `nativize` by value: critical paths first (onboarding, sign-in, the core loop), then frequency of use. Mark each `nativize` screen's complexity: `simple` (presentational), `stateful` (forms, lists with pagination), `boundary` (camera, files, payments, push, maps, realtime).

## 5. Report

End phase 1 with a short report to the user, saved as `docs/notes/YYYY-MM-DD-phase-1-assessment.md` (`templates/note.md`):

1. Route counts per bucket.
2. Topology counts for `nativize` operations (`server-in-next` / `client-direct` / `bff-*`) — the size and location (web repo vs backend repo) of phase 3.
3. Auth mechanism and what it takes to issue bearer tokens.
4. Blocking unknowns, most decision-changing first.
5. Proposed lead platform and vertical-slice flows.
6. Repo commits assessed, and whether local checkouts matched the deployed branches.
