# Next.js false friends

Referenced by [`nextjs-to-native`](../../SKILL.md). Framework concepts that look like they have a native counterpart but do not, or whose counterpart behaves differently. Platform-neutral; idiom-level mappings live in `../android/react-to-compose.md` and `../ios/react-to-swiftui.md`.

## Rendering and data

| Next.js | Native reality | Gotcha |
|---|---|---|
| Server Components (`async` page fetching data) | No server render. The screen renders immediately with a loading state, then fetches over HTTP | Every RSC data read needs an endpoint first (`backend-contract.md`). Design the loading state; the web may never have shown one |
| Server Actions | HTTP call from a ViewModel / observable model | Also re-implement what happened implicitly after the action: revalidation, redirect, form reset |
| `loading.tsx` / Suspense boundaries | Explicit loading state in screen state | Good source for what the loading UI should look like |
| `error.tsx` / error boundaries | Explicit error state + retry in screen state | Error copy and retry behavior come from here |
| `not-found.tsx`, `notFound()` | A not-found state on the screen, driven by a 404 | No global not-found route |
| `layout.tsx` (nested layouts) | Navigation containers: tab scaffold, nested navigation stacks, shared top bars | Layout state persistence (a layout does not re-mount between child pages) ≈ a tab's back stack keeping its state |
| `template.tsx` | Usually nothing; re-mount on navigation is the native default | |
| Parallel routes (`@slot`) | Separate panes on large screens (list-detail), or separate tabs on phones | Treat as an adaptive-layout decision |
| Intercepting routes (`(.)photo`, modal over list) | A sheet/dialog destination over the current screen | Deep link to the same URL opens the full screen on web; decide the native equivalent |
| Route groups `(marketing)` | Nothing; they only organize files | Often mark `drop` candidates |
| Dynamic segments `[id]`, catch-all `[...slug]` | Typed navigation arguments | Validate and handle missing/invalid ids in screen state |
| `searchParams` as state (filters, tabs, pagination) | Screen state that survives configuration change/process death; deep-link parameters | The URL was the persistence and share mechanism; replace both deliberately (saved state + share links) |
| `revalidate`, ISR, `revalidatePath/Tag`, `'use cache'` | Client-side cache policy per repository | Decide stale-while-revalidate vs always-fresh per endpoint; refresh on screen focus and pull-to-refresh |
| Streaming (`ai` SDK `useChat`, SSE) | Incremental read of an HTTP stream (OkHttp/Retrofit streaming, `URLSession.bytes`) | Needs explicit backpressure/cancellation on screen exit |

## Routing and navigation

| Next.js | Native reality | Gotcha |
|---|---|---|
| `next/link`, `<a href>` | Typed navigation call | No URL bar; "open in new tab" and middle-click have no meaning |
| `useRouter().push/replace/back` | Navigate / replace / pop on the back stack | `replace` semantics matter for auth flows: the login screen must not be reachable via back after sign-in |
| `redirect()` in server code | Navigation decision in client state (e.g., auth state → root destination) | |
| `middleware.ts` auth/locale gates | App-level auth state deciding the root graph; locale from system settings | Middleware is also not security for API calls; the API must enforce auth |
| URLs as deep links | Android App Links / iOS Universal Links mapped to destinations | Requires `assetlinks.json` / `apple-app-site-association` hosted on the web domain — a backend task |
| Hash links / scroll-to-anchor | Scroll to item in a lazy list | |
| Browser back/forward cache | Back stack state restoration | Restore scroll position and form input on back |

## Platform APIs

| Next.js / browser | Native reality | Gotcha |
|---|---|---|
| Cookies, `cookies()` | Bearer token in Keystore/Keychain-backed storage | No shared session with the website |
| `localStorage` / `sessionStorage` | DataStore / `UserDefaults` for preferences; a database (Room / SwiftData) for real data | Never put tokens in plain preferences. No "session" storage; decide what survives an app restart |
| `next/image` | Image loading library with caching (Coil / `AsyncImage` or a caching library) | The web's automatic resizing came from the image optimizer; request sized images from the CDN directly |
| `next/font` | Bundled font files | Check the font license covers app embedding |
| `next/head`, Metadata API, OG images, sitemap, robots | Nothing | SEO artifacts do not exist in apps; `drop` |
| `NEXT_PUBLIC_*` env vars | Build config (Gradle `buildConfigField` / product flavors; Xcode build settings / `.xcconfig`) | Anything compiled into an app is public. Never ship a secret |
| Server-only env vars | Stay on the server | If a client feature needed a secret, it needs an endpoint |
| `window.matchMedia`, responsive breakpoints | Window size classes / horizontal size class | Phones are one column; tablets can use list-detail |
| `navigator.share`, clipboard, geolocation, camera | Platform APIs with runtime permissions | Permission UX is part of the screen spec |
| Web push / service workers | FCM / APNs push | Different permission model and token lifecycle; backend must store device tokens |
| PWA offline (service worker cache) | Local database + sync policy | Decide offline scope explicitly |
| `dangerouslySetInnerHTML` / MDX / CMS rich text | Render structured content natively, or a Markdown renderer | An embedded WebView for rich text is a last resort |

## Build and runtime

| Next.js | Native reality | Gotcha |
|---|---|---|
| Deploy = instant update for everyone | Store review + staged rollout; old versions stay installed for months | Version the API, plan forced-update for breaking changes |
| Vercel preview deployments | Internal testing tracks (Play internal testing, TestFlight) | Set up early; reviewers need builds |
| Feature flags read on the server | Remote config fetched on launch, with cached defaults | The app must work before the flags arrive |
| Analytics snippet | Native analytics SDK firing the same event names | Keep event names identical for comparable dashboards |
