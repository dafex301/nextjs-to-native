# React / Tailwind → SwiftUI

Referenced by [`nextjs-to-native`](../../SKILL.md). Idiom map for writing screens. Format: `web → SwiftUI → gotcha`. For current API details and deprecations, defer to `swiftui-expert-skill`.

## Components and composition

| React | SwiftUI | Gotcha |
|---|---|---|
| Function component | `struct Name: View { var body: some View { ... } }` | Views are cheap value types; extract subviews freely |
| Props | Stored `let` properties (memberwise init) | |
| `children` | `@ViewBuilder let content: Content` with a generic `Content: View` | Slot APIs replace render props too |
| Conditional rendering | `if cond { X() }` inside `body` | Conditionals change view identity; prefer modifiers (e.g. `.opacity`) when animating show/hide of the same view |
| `.map()` over items | `ForEach(items) { ... }` inside `List` or `LazyVStack` | Items must be `Identifiable` (or pass `id:`); use lazy stacks for long content |
| `key` prop | `Identifiable.id`, `.id(_:)` | |
| Fragments | `Group { }` or just multiple views in a `@ViewBuilder` | |
| Context | `@Environment` with custom keys (`@Entry`) | Use for theme/services, not as a global mutable store |
| Portals (modals, toasts) | `.sheet`, `.fullScreenCover`, `.alert`, `.confirmationDialog`, overlays | Presentation is state-driven (`isPresented` / `item:`) |
| `forwardRef` / imperative focus | `@FocusState` + `.focused(...)` | |

## State and effects

| React | SwiftUI | Gotcha |
|---|---|---|
| `useState` | `@State private var x = ...` | Owned by the view; resets if view identity changes |
| Lifting state up | Parent owns `@State`, child takes a `Binding` (`$x`) | Screen views take a model; previews pass fake models |
| `useReducer`, Zustand/Redux store | `@Observable final class ScreenModel` owned with `@State` at the screen root; methods for events | Annotate UI models `@MainActor` |
| React Query / SWR | Service returning `async` results with an in-memory/SwiftData cache; model maps to a view state enum | Model loading/empty/error/loaded explicitly |
| `useEffect(() => {...}, [dep])` | `.task(id: dep) { await ... }` | Cancelled when `dep` changes or the view disappears |
| `useEffect` cleanup / subscriptions | `.task` cancellation, `.onDisappear` | |
| `useEffect` on value change | `.onChange(of: value) { old, new in ... }` | |
| `useMemo` | Computed properties; cache in the model if expensive | Do not put heavy work in `body` |
| `useRef` (mutable box) | A non-observed property on a model, or `@State` holding a reference type | |
| Data fetch on mount | `.task { await model.load() }` | `.task` reruns when the view reappears; guard against redundant loads |
| Route focus / visibility | `.onAppear`, `scenePhase` for app foreground | |

## Styling and layout (Tailwind → modifiers)

| Tailwind / CSS | SwiftUI | Gotcha |
|---|---|---|
| `flex flex-col` | `VStack(alignment:spacing:)` | Default stack spacing is not zero; pass `spacing:` explicitly from tokens |
| `flex flex-row` | `HStack` | |
| `relative` + `absolute` | `ZStack(alignment:)`, `.overlay(alignment:)`, `.background { }` | Prefer overlay/background over ZStack when one view decorates another |
| `gap-4` | `spacing: 16` | |
| `justify-between` | `Spacer()` between items | |
| `items-center` | `alignment: .center` on the stack | |
| `p-4`, `px-4 py-2` | `.padding(16)`, `.padding(.horizontal, 16).padding(.vertical, 8)` | No margin: pad the parent or use `Spacer().frame(height:)` |
| `w-full` | `.frame(maxWidth: .infinity, alignment: .leading)` | Alignment inside the frame matters |
| `flex-1` | `.frame(maxWidth: .infinity)`; `.layoutPriority` | |
| `w-12 h-12` | `.frame(width: 48, height: 48)` | |
| `rounded-lg` + `bg-*` | `.background(color, in: RoundedRectangle(cornerRadius: r))` / `.clipShape(...)` | **Modifier order matters**: `.padding().background()` ≠ `.background().padding()` |
| `border` | `.overlay(RoundedRectangle(cornerRadius: r).stroke(color, lineWidth: 1))` | Use `strokeBorder` to keep the stroke inside |
| `shadow-md` | `.shadow(color:radius:x:y:)` | Match intent; iOS shadows read heavier |
| `opacity-50` | `.opacity(0.5)` | |
| `overflow-hidden` | `.clipped()` / `.clipShape` | |
| `overflow-y-auto` | `ScrollView { LazyVStack { } }` or `List` | |
| `truncate`, `line-clamp-2` | `.lineLimit(1/2)`, `.truncationMode(.tail)` | |
| `text-sm font-semibold text-muted-foreground` | `.font(.brand(.sm)).fontWeight(.semibold).foregroundStyle(Color.mutedForeground)` | Pull from the generated theme, never literals |
| `hidden md:block` | `@Environment(\.horizontalSizeClass)` | Phones in portrait are `.compact` |
| `dark:` variants | Asset catalog colors with dark appearance; `@Environment(\.colorScheme)` only when needed | |
| `hover:` | Press states via `ButtonStyle` (`configuration.isPressed`) | `.hoverEffect` applies to iPad pointer only |
| `transition`, `animate-*` | `withAnimation`, `.animation(_:value:)`, `.transition`, `PhaseAnimator`/`KeyframeAnimator` | |
| `aspect-video` | `.aspectRatio(16/9, contentMode: .fit)` | |
| `grid grid-cols-2` | `LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())])`; `Grid` for small fixed tables | |
| `sticky top-0` | `LazyVStack(pinnedViews: [.sectionHeaders])`, or toolbar/`safeAreaInset(edge: .top)` | |

## Elements and events

| Web | SwiftUI | Gotcha |
|---|---|---|
| `<div onClick>` | `Button { } label: { }` with a custom `ButtonStyle` | Avoid `.onTapGesture` for actions: it loses button accessibility traits and press states |
| `<button>` | Brand `ButtonStyle` / `PrimaryButton` primitive | |
| `<a href>` (internal) | Append to the navigation path / `NavigationLink(value:)` | |
| `<a href>` (external) | `SFSafariViewController` wrapper, or `openURL` for system handling | |
| `<input>` | `TextField` / `SecureField` with `.textContentType`, `.keyboardType`, `.submitLabel`, `.textInputAutocapitalization` | Custom-styled fields: `.textFieldStyle(.plain)` + brand background |
| `<form onSubmit>` | Model `submit()` from a button and `.onSubmit` | `Form` is a settings-style container, not an HTML form; brand-first screens usually use a `ScrollView` |
| `<select>` | `Picker` / `Menu` (generic) or the ported custom component | |
| Checkbox / toggle | `Toggle` with a custom `ToggleStyle` for brand checkboxes | |
| `<img>` / `next/image` | `AsyncImage` (or caching library) with placeholder; `Image` for bundled assets | Mark decorative images `.accessibilityHidden(true)` |
| SVG icon | Asset catalog SVG (preserve vector data) → `Image("icon")` | |
| `alert()/confirm()` | `.alert` / `.confirmationDialog` | |
| Toasts | Overlay + transition + auto-dismiss, ported to brand style | No system toast on iOS |
| `aria-label` | `.accessibilityLabel` | |
| `role="heading"` | `.accessibilityAddTraits(.isHeader)` | |
| Infinite scroll | `.onAppear` of the last row (or `onScrollTargetVisibilityChange`) → `model.loadMore()` | Guard against duplicate loads |
| Clipboard | `UIPasteboard.general` / `PasteButton` | |
| Pull-to-refresh | `.refreshable { await model.refresh() }` | |
