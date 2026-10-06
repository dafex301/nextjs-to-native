# Web UX patterns → iOS

Referenced by [`nextjs-to-native`](../../SKILL.md), phase 7. `react-to-swiftui.md` maps idioms; this maps *patterns*. Apply `../shared/brand-vs-platform.md`: in brand-first mode, the "Brand-first" column wins for custom-designed web components; system behavior is always native.

| Web pattern | Brand-first (default) | Platform-first | Always native |
|---|---|---|---|
| Top navbar with links | `TabView` with brand tint and icons (3–5 top destinations); sidebar-adaptable on iPad | Stock `TabView` | Each tab keeps its own `NavigationStack`; tapping the active tab pops to root |
| Hamburger / side drawer | Move destinations to tabs or a Profile/More screen | | |
| Page header + breadcrumbs | Navigation bar with brand title font/colors (`.toolbar`, toolbar background) | Large titles with collapse on scroll | Edge-swipe back always works; do not hide the back button without replacing it |
| Footer | Drop; move links into settings/about | | |
| Modal dialog | `.sheet` with brand-styled content and `.presentationDetents` | Stock sheet / `.alert` | Swipe-to-dismiss (or `.interactiveDismissDisabled` with a reason) |
| Dropdown menu (actions) | `Menu` with brand label | `Menu` | |
| Hover tooltip / hover card | Info button opening a popover/sheet | `.popover` / `.help` | |
| Right-click context menu | `.contextMenu` (long-press) | | Haptic + preview |
| Tabs within a page | Ported segmented component; swipe via paging `TabView` or `ScrollView` paging | `Picker(...).pickerStyle(.segmented)` | |
| Data table | List of cards/rows with key columns; detail screen for the rest | | |
| Infinite scroll / "Load more" | `LazyVStack` / `List` with load-more on last row | | `.refreshable` |
| Toast | Brand overlay toast with transition | | Respect safe area and VoiceOver announcements (`AccessibilityNotification.Announcement`) |
| Search bar in header | Ported search field, or `.searchable` styled via tint | `.searchable` | Return key = Search; cancel clears |
| Filters sidebar | Sheet with filters + "Apply"; active filters as chips | | |
| Multi-step form / wizard | Pushed screens or a paging container with progress; state in one shared model | | Back keeps entered data |
| Date input | `DatePicker` with brand tint (or ported custom picker if the web designed one) | `DatePicker` | |
| File upload input | `PhotosPicker` / `.fileImporter` → upload with progress | | No photo-library permission needed for `PhotosPicker` |
| Share button | `ShareLink` | | |
| Copy-to-clipboard | Copy + brand toast confirmation | | |
| Carousel | Paging `ScrollView` (`.scrollTargetBehavior(.paging)`) with ported indicators | | |
| Accordion | Ported component, or `DisclosureGroup` styled | `DisclosureGroup` | |
| Empty state illustration | Port as-is | `ContentUnavailableView` | |
| Skeleton loaders | Port as-is, or `.redacted(reason: .placeholder)` | `.redacted` | |
| Sticky "Buy" / CTA bar | `.safeAreaInset(edge: .bottom)` with brand button | | Above home indicator and keyboard |
| Cookie banner | Drop | | |
| "Install our app" banner | Drop | | |
| Email magic link | Universal Link into the app | | Requires `apple-app-site-association` on the web domain |
| Light/dark toggle in UI | Follow system by default; keep an in-app override only if the web had one (`.preferredColorScheme`) | | |

Feel checklist per screen: edge-swipe back is interruptible and keeps state; scroll bounce and momentum feel native; keyboard never covers the focused field and can be dismissed (scroll or toolbar); press states on every tappable element; haptics (`.sensoryFeedback`) on significant confirmations and selection changes; Dynamic Type at large sizes does not clip; VoiceOver order is sensible.
