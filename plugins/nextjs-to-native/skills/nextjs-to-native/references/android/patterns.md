# Web UX patterns → Android

Referenced by [`nextjs-to-native`](../../SKILL.md), phase 7. `react-to-compose.md` maps idioms; this maps *patterns*. Apply `../shared/brand-vs-platform.md`: in brand-first mode, the "Brand-first" column wins for custom-designed web components; system behavior is always native.

| Web pattern | Brand-first (default) | Platform-first | Always native |
|---|---|---|---|
| Top navbar with links | Bottom navigation bar styled with brand tokens (3–5 top destinations); `NavigationRail` on large screens | M3 `NavigationBar` / `NavigationSuiteScaffold` | Per-tab back stacks, system back returns to start destination then exits |
| Hamburger / side drawer | Move destinations to tabs or a Profile/More screen | `ModalNavigationDrawer` only if many destinations | |
| Page header + breadcrumbs | Brand top bar (title, back arrow, actions) | M3 `TopAppBar` (center/medium/large with scroll behavior) | Back arrow = up navigation; insets handled |
| Footer | Drop; move links into settings/about | | |
| Modal dialog | Bottom sheet styled with brand tokens for content; `Dialog` for short confirmations | `ModalBottomSheet` / `AlertDialog` | Dismiss on back and scrim tap; IME-aware |
| Dropdown menu (actions) | Brand-styled `DropdownMenu` | M3 `DropdownMenu` | |
| Hover tooltip / hover card | Long-press or an info icon opening a sheet | `TooltipBox` (long-press) | |
| Right-click context menu | Long-press menu | | Haptic on long-press |
| Tabs within a page | Ported tab component with swipe via `HorizontalPager` | M3 `PrimaryTabRow` + `HorizontalPager` | |
| Data table | List of cards/rows showing the key columns; detail screen for the rest | | Horizontal table scroll only as a last resort |
| Infinite scroll / "Load more" | `LazyColumn` with load-more trigger or Paging 3 | | Pull-to-refresh |
| Toast | Brand snackbar | M3 `Snackbar` | Never covers bottom nav; respects insets |
| Search bar in header | Ported search field on top of the list | M3 `SearchBar` / `DockedSearchBar` | IME action Search; back clears/closes |
| Filters sidebar | Bottom sheet with filters, "Apply" button; active filters as chips | | |
| Multi-step form / wizard | One step per screen (or pager), progress indicator, state in a shared ViewModel | | Back goes to previous step without losing input |
| Date input | System date picker in a brand-colored container (or ported custom picker if the web designed one) | M3 `DatePickerDialog` | |
| File upload input | Photo Picker / document picker → upload with progress | | No storage permission needed for Photo Picker |
| Share button | Android share sheet (`Intent.ACTION_SEND`) | | |
| Copy-to-clipboard | Copy + snackbar confirmation | | Android 13+ shows its own clipboard confirmation; avoid double feedback |
| Carousel | `HorizontalPager` with ported indicators | `HorizontalMultiBrowseCarousel` | |
| Accordion | Ported component with `AnimatedVisibility` | | |
| Empty state illustration | Port as-is (vector drawable) | | |
| Skeleton loaders | Port as-is (shimmer placeholders) | | |
| Sticky "Buy" / CTA bar | `Scaffold(bottomBar = ...)` with brand button | | Above system nav bar inset and IME |
| Cookie banner | Drop | | |
| "Install our app" banner | Drop | | |
| Email magic link | Deep link via App Links into the app | | Requires `assetlinks.json` on the web domain |
| Light/dark toggle in UI | Follow system by default; keep an in-app override only if the web had one | | |

Feel checklist per screen: predictive back animates correctly; list fling and overscroll feel native; IME pushes content and the focused field stays visible; press states on every tappable element; haptic feedback on long-press and significant confirmations; screen state survives rotation and process death.
