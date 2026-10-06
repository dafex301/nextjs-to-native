# Backend contract

Phase 3 of [`nextjs-to-native`](../../SKILL.md). Goal: every read and write a native screen needs is an authenticated HTTP endpoint described by an OpenAPI spec. Do this in the web/backend repo, in PRs separate from native work, and keep the website working throughout.

## Principle: extract, don't fork

Move the logic out of the page or action into a plain server-side function (a "service"), then call that function from **both** the existing web code path and a new route handler. The website keeps rendering with RSC/actions; the app gets HTTP. One source of business logic.

```
before:  page.tsx (RSC) ──▶ prisma.query(...)
         actions.ts ('use server') ──▶ validate + prisma.mutate(...)

after:   page.tsx (RSC) ──┐
         actions.ts ──────┼──▶ lib/services/orders.ts (validate + DB)
         app/api/v1/orders/route.ts ──┘        ▲ shared Zod schemas
```

## Mapping

| Web today | Native-callable contract |
|---|---|
| Async Server Component reading data | `GET /api/v1/...` route handler calling the extracted service |
| Server Action (`'use server'`) | `POST/PATCH/DELETE /api/v1/...`; reuse the action's Zod schema for request validation |
| `getServerSideProps` / `getStaticProps` | `GET` endpoint returning the same props shape (minus presentation-only fields) |
| `redirect()` / `notFound()` inside data code | HTTP status codes (`401`, `403`, `404`, `409`) with a stable error body; the client decides navigation |
| `revalidatePath` / `revalidateTag` after a mutation | Return the updated resource (or an `ETag`) so the client can update its cache; document freshness expectations per endpoint |
| `middleware.ts` auth gate | Same check enforced inside each `/api/v1` handler (middleware is not a security boundary for API clients) |
| Form posts with `FormData` / file inputs | JSON for fields; presigned upload URLs (or `multipart/form-data`) for files |
| Streaming responses (AI SDK, SSE) | Keep SSE, document event format; native clients read the stream incrementally |
| Pagination via page params | Cursor-based pagination (`?cursor=&limit=`), consistent across list endpoints |

Version the API from day one (`/api/v1`). Installed app versions live for months; the web can change freely, the API cannot.

## When the backend is a separate service (BFF topologies)

If assessment labelled operations `client-direct` or `bff-*`, the mobile app talks to the **backend**, not to Next.js. Do not route mobile traffic through the Next.js BFF: it couples app releases to web deploys and usually authenticates by browser cookie.

| Label | Phase 3 work (in the backend repo) |
|---|---|
| `client-direct` | Confirm the endpoint accepts bearer tokens and returns stable, typed errors; add it to the OpenAPI spec if missing |
| `bff-proxy` | Same as above for the proxied endpoint; note any headers the BFF injected (locale, tenant, API keys — keys must never ship in the app) |
| `bff-aggregate` | Prefer a backend endpoint that returns what the screen needs. Reproduce the composition in the app only when it is trivial and both platforms can share the rule via the screen spec |
| `bff-auth` | Add a mobile auth flow on the backend (see below); the BFF's cookie session is not reusable |

The backend owns the OpenAPI spec. The mobile repo keeps a pinned copy in `shared/api/` (see `repo-layout.md`).

## Auth: cookies → bearer tokens

Browser sessions ride on cookies; native apps send `Authorization: Bearer <token>` and store tokens in the Keystore/Keychain.

- **Auth.js / NextAuth:** the session cookie is not designed for mobile. Add a token endpoint (sign in → short-lived access token + rotating refresh token), or move auth to a provider with native SDKs. Verify the token in route handlers in addition to the cookie session.
- **Clerk, Supabase, Firebase Auth:** use their native Android/iOS SDKs; the backend verifies their JWT. Usually the least work.
- **Custom JWT in an httpOnly cookie:** also accept the same JWT from the `Authorization` header; add refresh.
- **OAuth / social sign-in:** native flows (Credential Manager / Sign in with Google on Android, `ASAuthorizationController` / Sign in with Apple on iOS) produce an ID token that the backend exchanges for its own session token. **Apple requires Sign in with Apple** if the iOS app offers other third-party social logins.
- Session restore, token refresh on `401`, and sign-out (revoke refresh token) are part of the contract; specify them.

## OpenAPI and codegen

The spec is the contract both native apps generate their networking layer from.

- **Source of the spec, in order of preference:** (1) the backend already has one; (2) generate it from the shared Zod schemas (`zod-openapi`, `@asteasolutions/zod-to-openapi`, or the framework's equivalent — check what is current); (3) write it by hand from `DATA.md`, then validate it with a linter (e.g. Redocly or Spectral).
- **Android:** OpenAPI Generator with the Kotlin client targeting Retrofit + kotlinx.serialization (`generatorName = "kotlin"`, `library = "jvm-retrofit2"`, `serializationLibrary = "kotlinx_serialization"`), run as a Gradle task so the client regenerates on build. Confirm current option names in the generator docs.
- **iOS:** Apple's `swift-openapi-generator` as a SwiftPM build plugin with `swift-openapi-urlsession` as the transport.
- Keep generated code out of hand edits; wrap it in a repository/service layer the app owns.

## Contract checklist (the gate)

- [ ] Every `nativize` screen's reads and writes map to an endpoint in `DATA.md`.
- [ ] Every endpoint authenticates via bearer token and returns typed errors.
- [ ] A token obtained through the real auth flow works with `curl` against a deployed (staging) environment.
- [ ] The OpenAPI spec validates and both codegen targets compile.
- [ ] The website still works (its existing tests/build pass) after the extraction.
- [ ] A staging base URL exists that the native apps can reach (emulators: `10.0.2.2` maps to the host's `localhost` on Android; the iOS simulator shares the host network).
