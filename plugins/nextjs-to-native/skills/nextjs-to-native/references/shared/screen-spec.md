# Screen specs

Phase 4 of [`nextjs-to-native`](../../SKILL.md). A screen spec is the platform-agnostic description of one screen, derived from the web code and the running website. Both native apps are written from it, which is what makes `lead-follow` and `parallel` modes possible without the platforms drifting apart.

Write one file per `nativize` screen: `migration/screens/<screen-id>.md`, from `templates/screen-spec.md`.

## What goes in

- **Identity** — screen id, web route, source files (`file:line`), bucket, priority, complexity.
- **Purpose** — one sentence: what the user comes here to do.
- **Entry points** — where users arrive from (tabs, links, deep links, push notifications) and with which parameters.
- **Data** — each read: endpoint (from the OpenAPI spec), parameters, caching/freshness rule, pagination. Each write: endpoint, payload, optimistic update or not, what refreshes afterwards.
- **States** — loaded, empty, loading, error, offline, unauthenticated/forbidden, partial (some sections failed). For each: what is shown and which baseline image shows it.
- **Content** — the elements on screen top to bottom, with the token-level styling that matters (e.g. "title: `text-xl font-semibold`, `foreground`").
- **Actions** — every interactive element: what it does, validation rules, success/failure feedback, where it navigates.
- **Web-only behavior to drop or replace** — hover states, tooltips, keyboard shortcuts, right-click menus, multi-column layout, SEO-only content; and the native replacement if any (long-press menu, swipe action, single column).
- **Native additions** — pull-to-refresh, swipe actions, haptics, share sheet, system pickers; only where they serve the same purpose as the web behavior.
- **Analytics events** — events fired on the web for this screen, so the native app fires the same ones.
- **Accessibility** — labels for icon-only buttons, heading structure, reading order notes.
- **Open questions** — anything `unknown` that blocks implementation.

## Rules

- Describe behavior and content, not web implementation. "Shows the 20 most recent orders, newest first, with infinite scroll" — not "uses `useInfiniteQuery` with `getNextPageParam`".
- Reference components by their design-system name (`Button/primary/lg`, `OrderCard`), so both platforms map them to the same primitive.
- Every state listed must have a baseline image, or a note why it could not be captured.
- Keep specs current: if implementation reveals a missing state or rule, update the spec first, then both platforms.
