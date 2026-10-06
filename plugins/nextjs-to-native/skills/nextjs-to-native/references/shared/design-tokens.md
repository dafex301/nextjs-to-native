# Design tokens: web → Compose / SwiftUI

Phase 5 of [`nextjs-to-native`](../../SKILL.md). The website is the source of truth for the brand. Extract its tokens once into a platform-neutral file, generate each platform's theme from it, and never hand-copy hex values into screens.

## 1. Find the tokens

| Web setup | Where the tokens live |
|---|---|
| Tailwind v3 | `tailwind.config.{js,ts}` → `theme` / `theme.extend` (colors, spacing, borderRadius, fontSize, fontFamily, boxShadow) |
| Tailwind v4 | CSS `@theme { --color-*: ...; --radius-*: ...; --font-*: ... }`, usually in `app/globals.css` |
| shadcn/ui | CSS variables in `globals.css` under `:root` and `.dark` (`--background`, `--foreground`, `--primary`, `--muted`, `--border`, `--ring`, `--radius`, ...), often in `oklch()` or HSL |
| CSS Modules / plain CSS | Custom properties on `:root`; repeated literal values (grep for hex/rgb/oklch and px values to find the de facto scale) |
| styled-components / Emotion | The `ThemeProvider` theme object |
| MUI / Chakra / Mantine | The theme created with `createTheme` / `extendTheme` |
| Fonts | `next/font` calls in `layout.tsx` (Google or local files); note weights actually used |
| Icons | `lucide-react`, Heroicons, Radix icons, custom SVGs |

Also capture what the code actually uses, not only what is defined: grep class names (`bg-`, `text-`, `rounded-`, `p-`, `gap-`) across `nativize` screens to find the effective palette and scale. Unused tokens do not need porting.

## 2. Normalize into `tokens.json`

Write one platform-neutral file (DTCG-style naming is a good default) in `migration/tokens.json`:

- **color** — semantic roles (`background`, `surface`, `primary`, `on-primary`, `muted`, `border`, `destructive`, ...) with light and dark values. Convert `oklch()` / HSL to sRGB hex with alpha; note any out-of-gamut values that were clamped.
- **typography** — font families, and a type scale (size, line height, weight, letter spacing) for the text styles the screens use (`text-sm`, `text-base`, `text-xl font-semibold`, ...). Convert `rem` with the web root size (usually 16px).
- **spacing** — the scale actually used (Tailwind's 4px base: `p-4` = 16).
- **radius**, **elevation/shadow**, **opacity**, **motion** (durations/easings if the web defines them).

Units: CSS `px` maps to Android `dp` and iOS `pt` one-to-one at the phone viewport the baselines were captured at. Font sizes map to `sp` on Android (respecting user font scale) and to points on iOS (use Dynamic Type-aware custom fonts where possible).

## 3. Generate the platform themes

Generate code from `tokens.json` (a small script, or Style Dictionary with custom formats) instead of writing it by hand, so token changes regenerate cleanly:

- **Compose:** a `BrandTheme` composable that provides `BrandColors`, `BrandTypography`, `BrandSpacing`, `BrandShapes` through `CompositionLocal`s, *and* maps the matching roles into a `MaterialTheme(colorScheme, typography, shapes)` so any stock M3 component used by the app inherits the brand. Light/dark from `isSystemInDarkTheme()`. Disable dynamic color (Material You) in brand-first mode.
- **SwiftUI:** an asset catalog color set per semantic color (light/dark variants) or a generated `Color` extension, a `Font` extension for the type scale (`Font.custom(_:size:relativeTo:)` so Dynamic Type scales it), spacing/radius constants, and a `ShapeStyle`/environment entry if components need theme injection.
- **Fonts:** bundle the same font files the web uses (check the license allows app embedding). Google Fonts used via `next/font/google` can be downloaded and bundled.
- **Icons:** prefer the same icon set to keep the brand. Lucide and Heroicons publish SVGs: convert the ones in use to Android Vector Drawables and iOS asset-catalog SVG/PDF symbols. Use Material Symbols / SF Symbols only in platform-first mode or for system affordances.

## 4. Primitives and the gallery screen

Build only the primitives the `nativize` screens use: inventory the shared components in the web repo (`components/ui/*` for shadcn) and port each one as a themed composable / view with the same variants (`variant`, `size`) and states (default, pressed, disabled, focused, loading, error).

Create a **gallery screen** (debug builds only) that renders every primitive in every variant and state, in light and dark. It is the cheapest visual regression surface an agent has: one screenshot verifies the whole design system. Each primitive also gets a Compose `@Preview` / SwiftUI `#Preview`.

**Gate:** gallery screenshots match the web components (open the web's equivalent component page or a Storybook if one exists) on color, type, radius, spacing, and states.
