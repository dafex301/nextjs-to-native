# Component: <Name>

Living spec in `shared/components/<name>.md`. Both platforms implement this contract; neither platform's code is the source of truth.

- **Web source:** `components/ui/button.tsx:1` (and where it is used most)
- **Android:** `android/core/designsystem/.../BrandButton.kt`
- **iOS:** `ios/Packages/DesignSystem/Sources/.../BrandButton.swift`
- **Web reference capture:** `migration/baselines/_components/button.png`

## API (same names on both platforms)

| Parameter | Type | Default | Notes |
|---|---|---|---|
| `variant` | `primary \| secondary \| outline \| ghost \| destructive` | `primary` | |
| `size` | `sm \| md \| lg` | `md` | |
| `label` | text | — | |
| `leadingIcon` | icon? | none | |
| `isLoading` | bool | false | shows spinner, keeps width, disables taps |
| `isEnabled` | bool | true | |
| `onClick` / `action` | callback | — | |

Kotlin: `BrandButton(label, onClick, variant = BrandButtonVariant.Primary, size = BrandButtonSize.Md, ...)`
Swift: `BrandButton(label, variant: .primary, size: .md, action: { })`

## Anatomy

<container → leading icon → label → trailing icon / spinner; alignment, gaps>

## Tokens per variant and state

| variant | state | background | content | border | other |
|---|---|---|---|---|---|
| primary | default | `primary` | `on-primary` | — | radius `md` |
| primary | pressed | `primary` @ 90% | `on-primary` | — | |
| primary | disabled | `primary` @ 50% | `on-primary` @ 70% | — | |
| primary | loading | `primary` | spinner `on-primary` | — | |

## Sizes

| size | height | horizontal padding | text style | icon size |
|---|---|---|---|---|
| sm | 36 | 12 | `sm/medium` | 16 |
| md | 40 | 16 | `sm/medium` | 16 |
| lg | 44 | 32 | `base/medium` | 20 |

Touch target is at least 48dp (Android) / 44pt (iOS) even when the visual height is smaller.

## Behavior and accessibility

- Role: button. Label read by screen readers; icon-only variant requires an accessibility label.
- Haptics: <none / on press for destructive confirm>.

## Platform notes

- <Any intentional difference, and why.>
