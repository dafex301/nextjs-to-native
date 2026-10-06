# React / Tailwind → Jetpack Compose

Referenced by [`nextjs-to-native`](../../SKILL.md). Idiom map for writing screens. Format: `web → Compose → gotcha`. For current API details, defer to Google's skills and `android docs search`.

## Components and composition

| React | Compose | Gotcha |
|---|---|---|
| Function component | `@Composable fun Name(...)` | Composables emit UI; they do not return values. Name them in PascalCase |
| Props | Function parameters; first optional parameter is `modifier: Modifier = Modifier` | Always accept and apply a `modifier` on the root of reusable components |
| `children` | Trailing lambda `content: @Composable () -> Unit` (or a scoped receiver like `ColumnScope.() -> Unit`) | Slot APIs replace render props too |
| Conditional rendering `{cond && <X/>}` | `if (cond) { X() }` | |
| `.map()` over items | `LazyColumn { items(list, key = { it.id }) { ... } }` | Use lazy lists for anything that can grow; always give stable keys |
| `key` prop | `key = { ... }` in lazy lists; `key(id) { }` elsewhere | |
| Fragments | Not needed; emit multiple composables | |
| Context | `CompositionLocal` for cross-cutting UI values (theme); pass app data explicitly or via ViewModel | Do not use CompositionLocals as a global store |
| Portals (modals, toasts) | `ModalBottomSheet`, `Dialog`, `SnackbarHost` in `Scaffold` | |
| `forwardRef` / imperative handles | State holders (`rememberXState()`), `FocusRequester` | |

## State and effects

| React | Compose | Gotcha |
|---|---|---|
| `useState` | `var x by remember { mutableStateOf(...) }` | Survives recomposition only. Use `rememberSaveable` to survive rotation/process death |
| Lifting state up | State hoisting: stateless composable + `value`/`onValueChange` parameters | Screens take `UiState` + event lambdas; previews pass fakes |
| `useReducer`, Zustand/Redux store | `ViewModel` holding `MutableStateFlow<UiState>`, exposing `StateFlow`; events as functions | One `UiState` data class per screen; `copy()` for updates |
| React Query / SWR | Repository returning `Flow`/`suspend` results, cached in the repository or Room; ViewModel maps to `UiState` | Loading/error/success modeled explicitly (sealed interface) |
| `useEffect(() => {...}, [dep])` | `LaunchedEffect(dep) { ... }` | Coroutine-scoped, cancelled when `dep` changes or the composable leaves |
| `useEffect` cleanup / subscriptions | `DisposableEffect(key) { onDispose { } }` | |
| `useMemo` | `remember(dep) { compute() }`; `derivedStateOf` for values derived from frequently changing state | |
| `useCallback` | Usually unnecessary; lambdas referencing stable state are fine | Optimize only from evidence |
| `useRef` (mutable box) | `remember { mutableListOf() }` / a plain `remember { Ref() }` | Reading it does not trigger recomposition |
| Data fetch on mount | Fetch in `ViewModel` `init` or on an explicit event | Not in a composable body |
| `useEffect` on route focus | `LifecycleResumeEffect` / lifecycle-aware collection | |

## Styling and layout (Tailwind → Modifier)

| Tailwind / CSS | Compose | Gotcha |
|---|---|---|
| `flex flex-col` | `Column` | Default web flex is row; pick explicitly |
| `flex flex-row` | `Row` | |
| `relative` + `absolute` children | `Box` with `Modifier.align(...)` / offsets | |
| `gap-4` | `Arrangement.spacedBy(16.dp)` | |
| `justify-*`, `items-*` | `horizontalArrangement`/`verticalArrangement`, `horizontalAlignment`/`verticalAlignment` | Main/cross axis naming differs by container |
| `p-4`, `px-4 py-2` | `Modifier.padding(16.dp)`, `padding(horizontal = 16.dp, vertical = 8.dp)` | No margin: use padding on the parent or `Spacer` |
| `m-*` | Parent padding / `Spacer(Modifier.height(...))` | |
| `w-full`, `h-full` | `fillMaxWidth()`, `fillMaxHeight()`; `fillMaxSize()` | |
| `flex-1` | `Modifier.weight(1f)` inside `Row`/`Column` | |
| `w-12 h-12` | `size(48.dp)` | |
| `rounded-lg` + `bg-*` | `background(color, RoundedCornerShape(r))` and `clip(shape)` | **Modifier order matters**: `padding().background()` ≠ `background().padding()` |
| `border` | `border(1.dp, color, shape)` | |
| `shadow-md` | `shadow(elevation, shape)` or `Surface(shadowElevation = ...)` | Shadows render differently; match intent, not pixels |
| `opacity-50` | `alpha(0.5f)` | |
| `overflow-hidden` | `clip(shape)` | |
| `overflow-y-auto` | `verticalScroll(rememberScrollState())` or a `LazyColumn` | Never nest a same-direction scroll inside a lazy list |
| `truncate`, `line-clamp-2` | `maxLines = 1/2, overflow = TextOverflow.Ellipsis` | |
| `text-sm font-semibold text-muted-foreground` | `Text(style = BrandTypography.sm.copy(fontWeight = SemiBold), color = BrandColors.mutedForeground)` | Pull from theme objects, never literal values |
| `hidden md:block` | Window size class (`currentWindowAdaptiveInfo()`) | Phones get the mobile branch |
| `dark:` variants | Theme light/dark color schemes | |
| `hover:` | Pressed/focused state via `interactionSource`; ripple/indication | No hover on phones (mouse/stylus hover exists on large screens) |
| `transition`, `animate-*` | `animate*AsState`, `AnimatedVisibility`, `AnimatedContent`, `updateTransition` | |
| `aspect-video` | `aspectRatio(16f / 9f)` | |
| `grid grid-cols-2` | `LazyVerticalGrid(GridCells.Fixed(2))` or a `Row` of weighted children for small fixed sets | |
| `sticky top-0` | `stickyHeader { }` in `LazyColumn`, or `Scaffold` top bar | |

## Elements and events

| Web | Compose | Gotcha |
|---|---|---|
| `<div onClick>` | `Modifier.clickable { }` (or a `Button`/`Surface(onClick)`) | Clickable areas need min 48dp touch target and a semantic role |
| `<button>` | Brand `Button` primitive built on M3 `Button`/`Surface` | |
| `<a href>` (internal) | Navigation event to the ViewModel/navigator | |
| `<a href>` (external) | Custom Tabs (`androidx.browser`) | |
| `<input>` | `TextField`/`OutlinedTextField` or `BasicTextField` for custom design | Prefer the state-based `TextFieldState` API where available; set `KeyboardOptions` (type, imeAction) and autofill hints |
| `<form onSubmit>` | ViewModel `submit()` triggered by button and `imeAction = Done` | Validate in the ViewModel; show errors via `supportingText`/`isError` |
| `<select>` | `ExposedDropdownMenuBox` (generic) or the ported custom component | |
| `<input type="checkbox">` / toggle | `Checkbox` / `Switch` with `Modifier.toggleable` on the row | |
| `<img>` / `next/image` | `AsyncImage` (Coil) with `contentScale`, placeholder, `contentDescription` | |
| SVG icon | Vector drawable → `Icon(painterResource(...))` | `contentDescription = null` only for decorative icons |
| `alert()/confirm()` | `AlertDialog` | |
| Toasts (sonner, react-hot-toast) | `Snackbar` via `SnackbarHostState` | |
| `aria-label` | `Modifier.semantics { contentDescription = ... }` | |
| `role="heading"` | `Modifier.semantics { heading() }` | |
| `onScroll` infinite load | Observe `LazyListState` (e.g. last visible index) → ViewModel `loadMore()`; or Paging 3 | |
| `navigator.clipboard` | `LocalClipboard` / `ClipboardManager` | |
| Pull-to-refresh | `PullToRefreshBox` | |
