# Third-party services and SDKs

Referenced by [`nextjs-to-native`](../../SKILL.md) in phases 1–2. Browser SDKs do not run in native apps. Each service needs a native SDK, a backend change, or a product decision. Decide during assessment, not at store review.

Always confirm current SDK names, versions, and policies in the vendor's docs; this table is a map of decisions, not a version reference.

## Payments — decide first

| What is sold | Android | iOS | Notes |
|---|---|---|---|
| Digital goods, subscriptions, premium features, credits used in the app | Google Play Billing | StoreKit (In-App Purchase) | Store billing is required for digital goods consumed in the app, with a store commission. Shipping Stripe/Midtrans/Xendit checkout for these leads to rejection. Regional exceptions and external-link entitlements exist and change; check current policy for the target markets. RevenueCat or similar can unify both stores and sync entitlements to your backend |
| Physical goods, real-world services (delivery, rides, bookings, tickets for events) | Any payment provider's native SDK, or a hosted checkout in Custom Tabs | Same, or `SFSafariViewController`; Apple Pay via the provider | Store billing is not allowed for these |
| Local payment methods (e-wallets, virtual accounts, QRIS, bank transfer) | Provider's native SDK or hosted checkout page opened in Custom Tabs, returning via deep link | Same with `SFSafariViewController` / `ASWebAuthenticationSession` | Payment result must be confirmed server-side (webhook), never trusted from the client redirect |

The backend must become the source of truth for entitlements when purchases can come from the web, Play, and the App Store.

## Common services

| Web | Native | Notes |
|---|---|---|
| Auth.js / NextAuth | Backend token endpoint + native sign-in UI | See `backend-contract.md` |
| Clerk / Supabase Auth / Firebase Auth / Auth0 | Vendor's Android and iOS SDKs | Usually the smoothest path |
| Google sign-in | Credential Manager (Android); Google Sign-In SDK (iOS) | |
| Apple sign-in | Sign in with Apple (iOS, and web flow for Android if offered) | Required on iOS when other third-party social logins exist |
| Passkeys (WebAuthn) | Credential Manager passkeys; `ASAuthorization` passkeys | Needs `assetlinks.json` / associated domains on the web domain |
| GA4 / GTM | Firebase Analytics or the analytics vendor's native SDK | Keep event names identical |
| PostHog / Mixpanel / Amplitude / Segment | Vendor native SDKs | |
| Sentry | Sentry Android / Sentry Cocoa (or Crashlytics) | Upload mapping files (R8) and dSYMs in CI |
| Web push, OneSignal web | FCM (Android), APNs (iOS); or OneSignal/vendor native SDKs | Backend stores device tokens per user/device |
| Google Maps JS / Mapbox GL JS | Maps Compose / MapKit for SwiftUI or Google Maps iOS SDK; Mapbox native SDKs | Separate API keys per platform, restricted by package/bundle id |
| reCAPTCHA / Turnstile / hCaptcha | Play Integrity API (Android), App Attest / DeviceCheck (iOS) | Bot protection works differently in apps; involve the backend |
| Intercom / Crisp / Zendesk widget | Vendor native SDKs | |
| Algolia / Meilisearch InstantSearch | Call the search API directly or use the vendor's native client | |
| Uploads (S3/R2 presigned, UploadThing) | Presigned URL from the backend + native upload with progress | Photo picker + permissions in the screen spec |
| Pusher / Ably / Supabase Realtime / Socket.IO | Vendor native SDKs or a WebSocket client (OkHttp / `URLSessionWebSocketTask`) | Reconnect on foreground; stop when backgrounded |
| Vercel AI SDK streaming | HTTP streaming client | See false friends → streaming |
| Feature flags (LaunchDarkly, Statsig, GrowthBook, Vercel flags) | Vendor native SDKs or Firebase Remote Config | Cached defaults for first launch |
| CMS (Sanity, Contentful, Strapi) | Call the CMS API; render structured content natively | Rich text needs a native renderer |

## Store and privacy obligations triggered by services

- **Account creation in the app** ⇒ in-app account deletion is required by both stores.
- **Any tracking/analytics SDK** ⇒ Play Data safety form and Apple privacy nutrition labels must declare it; iOS also requires a privacy manifest and, for cross-app tracking, the App Tracking Transparency prompt.
- **Location, camera, photos, contacts, notifications** ⇒ runtime permission prompts with purpose strings explaining why.
