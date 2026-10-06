# Brand vs platform: what stays custom, what becomes native

Referenced throughout [`nextjs-to-native`](../../SKILL.md). The default visual mode is **brand-first**: the app should be recognizably the same product as the website. But some things must behave like the OS, or the app feels broken no matter how faithful the pixels are.

## Brand-first (default)

**Keep from the web (port faithfully, built from tokens):**

- Colors, typography, iconography, illustration, imagery.
- Custom components the web designed on purpose: cards, list rows, buttons, chips, badges, empty states, hero sections, charts, onboarding.
- Layout composition of each screen, adapted to a single column at phone width.
- Copy, tone, and the information shown on each screen.

**Always native, in every mode:**

| Concern | Android | iOS |
|---|---|---|
| Back navigation | System back + predictive back gesture | Edge-swipe back, navigation bar back button |
| Screen chrome | Edge-to-edge, status/navigation bar insets | Safe areas, status bar, home indicator |
| Navigation containers | Bottom navigation / nav rail behavior, back stack per tab | Tab bar behavior, push/pop, sheets with detents |
| Keyboard | IME insets, `imeAction`, keyboard types | Keyboard avoidance, return key types, `@FocusState` |
| Scrolling | Overscroll, fling physics, pull-to-refresh | Bounce, momentum, pull-to-refresh |
| System pickers | Photo picker, date/time pickers, file picker, share sheet | `PhotosPicker`, date pickers, document picker, share sheet |
| Permissions | Runtime permission dialogs + rationale | Permission prompts + purpose strings |
| Feedback | Haptics, ripple/press states | Haptics, highlight states |
| Accessibility | TalkBack, font scaling | VoiceOver, Dynamic Type |
| Text input | Autofill, password managers, copy/paste menus | AutoFill, password managers, text selection menus |
| Links out | Custom Tabs | `SFSafariViewController` |

The web navigation chrome (top navbar, hamburger menu, footer, breadcrumbs) is replaced by native navigation containers styled with brand tokens. A hamburger menu is not a mobile app pattern; its destinations go into tabs or a profile/settings screen.

**Generic web controls become stock native controls, themed:** a plain `<select>` → a native menu/picker; a native `<input type="date">` → the platform date picker; a browser `confirm()` → a native dialog. If the web replaced the generic control with a custom-designed one (a styled combobox, a branded date picker), treat it as a custom component and port it.

## Platform-first (opt-in)

Use stock Material 3 / SwiftUI components and navigation patterns wherever one exists; brand enters through color, typography, and iconography only. Custom web components are redesigned rather than ported. Choose this when the user explicitly wants the app to feel like a first-party OS app more than like the website.

## Parity implications

- Brand-first: parity covers content, behavior, **and** visual fidelity of brand components (layout, spacing, color, type) against the web baseline, with tolerance for platform differences in font rendering, system chrome, and native controls.
- Platform-first: parity covers content and behavior; visuals are judged against platform guidelines, not the web.
