# Screen: <id>

- **Web route:** `/orders/[id]`
- **Source:** `app/orders/[id]/page.tsx:1`, `app/orders/[id]/actions.ts:1`
- **Bucket / priority / complexity:** nativize / 3 / stateful
- **Behavior source:** <web repo @ commit>   **Visual source:** <web | redesign branch/prototype/Figma URL @ commit> (or `blocked: <reason>`)
- **Fixtures:** `shared/fixtures/<id>/<state>.json`   **Web behavior audit:** `docs/notes/<date>-<id>-web-audit.md` (interactive screens)
- **Purpose:** <one sentence: what the user comes here to do>

## Entry points

| from | parameters |
|------|------------|
| Orders list row tap | `orderId` |
| Push notification "order shipped" | `orderId` |
| Deep link `https://<domain>/orders/<id>` | `orderId` |

## Data

| operation | endpoint | params | freshness | notes |
|-----------|----------|--------|-----------|-------|
| read order | `GET /api/v1/orders/{id}` | id | refresh on appear + pull | |
| cancel | `POST /api/v1/orders/{id}/cancel` | id | update in place | confirm first |

## States

| state | when | shows | baseline |
|-------|------|-------|----------|
| loaded | 200 | full detail | `baselines/order-detail/loaded.png` |
| loading | request in flight | skeleton | `baselines/order-detail/loading.png` |
| error | network/5xx | message + retry | `baselines/order-detail/error.png` |
| not-found | 404 | not-found message + back to orders | `baselines/order-detail/not-found.png` |
| forbidden | 401/403 | sign-in prompt | — (redirect to sign-in) |

## Content (top to bottom)

1. Header: order number (`text-xl font-semibold`, `foreground`), status badge (`Badge/<variant by status>`).
2. ...

## Actions

| element | does | validation / confirmation | on success | on failure |
|---------|------|---------------------------|------------|------------|
| Cancel order | POST cancel | confirm dialog; only when status = pending | status → cancelled, toast | error toast, state unchanged |

## Web-only behavior

| web | native replacement |
|-----|--------------------|
| Hover tooltip on status | Tap badge → sheet with status explanation |

## Native additions

- Pull-to-refresh. Share order link via share sheet.

## Analytics

- `order_viewed { order_id }` on appear; `order_cancelled { order_id }` on success.

## Accessibility

- Status badge reads "Status: shipped". Header is a heading.

## Open questions

- <unknowns that block implementation>
