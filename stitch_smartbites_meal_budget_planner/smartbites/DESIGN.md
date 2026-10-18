---
name: SmartBites
colors:
  surface: '#f5fbf1'
  surface-dim: '#d6dcd2'
  surface-bright: '#f5fbf1'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff6eb'
  surface-container: '#e9f0e5'
  surface-container-high: '#e4eae0'
  surface-container-highest: '#dee4da'
  on-surface: '#171d17'
  on-surface-variant: '#40493d'
  inverse-surface: '#2c322b'
  inverse-on-surface: '#ecf3e8'
  outline: '#707a6c'
  outline-variant: '#bfcaba'
  surface-tint: '#1b6d24'
  primary: '#0d631b'
  on-primary: '#ffffff'
  primary-container: '#2e7d32'
  on-primary-container: '#cbffc2'
  inverse-primary: '#88d982'
  secondary: '#964900'
  on-secondary: '#ffffff'
  secondary-container: '#fc820c'
  on-secondary-container: '#5e2c00'
  tertiary: '#005a8c'
  on-tertiary: '#ffffff'
  tertiary-container: '#0073b2'
  on-tertiary-container: '#e9f2ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a3f69c'
  primary-fixed-dim: '#88d982'
  on-primary-fixed: '#002204'
  on-primary-fixed-variant: '#005312'
  secondary-fixed: '#ffdcc6'
  secondary-fixed-dim: '#ffb786'
  on-secondary-fixed: '#311300'
  on-secondary-fixed-variant: '#723600'
  tertiary-fixed: '#cee5ff'
  tertiary-fixed-dim: '#96ccff'
  on-tertiary-fixed: '#001d32'
  on-tertiary-fixed-variant: '#004a75'
  background: '#f5fbf1'
  on-background: '#171d17'
  surface-variant: '#dee4da'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.03em
  numeric-currency:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '800'
    lineHeight: 28px
    letterSpacing: -0.01em
  numeric-stat:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system establishes a fresh, disciplined, and genuinely uplifting visual ethos tailored for budget-conscious Indonesian university students (*anak kos*) and early-career urban workers. Balancing nutritional mindfulness with economic constraint requires a tone that is encouraging rather than restrictive. 

The aesthetic marries **Material Design 3 (M3) expressiveness** with tactile organic ergonomics:
- **Clean Organic Functionalism**: Clean white and soft sage backings eliminate clutter, allowing dense meal prep and pantry tracking data to breathe.
- **Disciplined Vitality**: Energetic botanical greens signal vitality and wellness, while warm harvest citruses inject urgency and warmth without inducing financial anxiety.
- **Tactile Structure**: Gentle radiuses, tonal container layers, and subtle organic borders evoke meal bento dividers, keeping the experience grounded, approachable, and fast on budget-grade smartphones.

## Colors

The palette is tuned around fresh nutrition, thrift, and pragmatic everyday metrics:
- **Primary (`#2E7D32`)**: Fresh emerald leaf green representing vitality, balanced health, and cost-efficiency. Used for primary actions, success states, and key nutritional completions.
- **Secondary (`#F57C00`)**: Harvest amber representing warm citrus, appetite appeal, and financial savings milestones.
- **Tertiary (`#0288D1`)**: Hydration blue for water tracking, fluid metrics, and calm functional markers.
- **Surface & Backgrounds**: Soft sage tint (`#F8FAF8` in light mode; `#121812` in dark mode) anchored with pure surfaces (`#FFFFFF` in light mode; `#1B241C` in dark mode) to preserve contrast under harsh daylight.
- **Semantic Accents**: Food waste alerts and impending shelf-life expirations utilize warm terracotta (`#D84315`), reserving high-urgency crimson (`#D32F2F`) for over-budget warnings or critical allergen flags.

## Typography

Typography prioritizes fast scanning and tabular clarity. Plus Jakarta Sans provides contemporary warmth with balanced proportions, open apertures, and crisp numeric legibility.

- **Numeric & Financial Prioritization**: Indonesian Rupiah amounts (`Rp 25.000`) and macro calorie calculations (`650 kkal`) must use tabular figures (`font-variant-numeric: tabular-nums`) with semi-bold to extra-bold weights to avoid visual jitter across dynamic budget meters.
- **Rhythm & Hierarchy**: Headlines employ tight negative tracking to keep long Indonesian compound words (e.g., *Pengeluaran*, *Perencanaan*) compact and visually grounded.

## Layout & Spacing

The layout is engineered mobile-first using a fluid 4-column system on compact screens (under 600px), expanding to 8 columns on tablets and 12 columns on desktop web companions.

- **Safe Zones & Margins**: Base mobile canvases utilize a standard `1rem` (16px) margin and gutter to maximize tap targets and card widths on mid-range Android displays.
- **Vertical Rhythm**: Spacing tokens conform to an 8-point harmonic base. Dense data cells (pantry item lists, nutrient tags) apply `space-xs` (4px) and `space-sm` (8px), while sectional dividers and meal category separations apply `space-lg` (24px) and `space-xl` (32px).
- **Sticky Actions**: Quick-log operations adhere to bottom navigation bounds, reserving a 72px floating operational clearance above system navigation bars.

## Elevation & Depth

This system avoids heavy drop shadows, opting for **tonal container layering** coupled with low-contrast organic boundaries:

- **Level 0 (Flat/Base)**: Surface background tint (`#F8FAF8`), non-elevated.
- **Level 1 (Default Containers)**: Pure white background (`#FFFFFF`) with a 1px solid stroke (`rgba(46, 125, 50, 0.08)`) and an ultra-soft ambient tint: `box-shadow: 0 2px 8px -2px rgba(18, 24, 18, 0.04)`.
- **Level 2 (Interactive Floating Elements)**: Meal cards and sticky action bars use `box-shadow: 0 4px 16px -2px rgba(18, 24, 18, 0.08)` along with a 1px border.
- **Level 3 (Modal Bottom Sheets)**: Elevated quick-log trays use a prominent backdrop scrim (`rgba(18, 24, 18, 0.45)`) and upward atmospheric diffusion: `box-shadow: 0 -8px 24px -4px rgba(18, 24, 18, 0.12)`.

## Shapes

The geometric signature uses comfortable, rounded curves (Level 2) that feel organic and approachable without becoming childish:
- Standard UI containers, cards, and input fields adopt `0.5rem` (8px) to `1rem` (16px) radii.
- Interactive chips, budget indicator badges, and meal tags utilize full continuous pill geometry (`rounded-full` / 9999px) for clear affordance and thumb-friendly ergonomics.
- Quick-log bottom sheets feature asymmetric top corner rounding of `1.5rem` (24px).

## Components

### Buttons & Interactive Controls
- **Primary Buttons**: Filled with Primary (`#2E7D32`), white text, full pill roundedness (`9999px`), 48px standard touch height. Active states trigger a subtle scale compression (`scale(0.98)`).
- **Secondary Buttons**: Tonal surface filled with 12% primary tint, bold primary text, no border.
- **Tertiary & Icon Buttons**: Ghost states framed inside 40x40px touch boundaries with a 1px structural border for quick food counter updates (+/-).

### Chips & Filter Pills
- **Meal Category & Allergen Chips**: Pill-shaped with an 8px horizontal padding, 32px height. Selected states take full primary emerald or citrus amber fills with high-contrast text; unselected states use a 1px border with a soft sage background.

### Cards & Pantry Trackers
- **Tactile Recipe & Budget Cards**: Contained with 12px radiuses, 1px soft-sage outlines, and Level 1 elevation. Feature a 72x72px thumbnail badge on the left, clear vertical typography in the center, and a dedicated numeric highlight block on the right.
- **Shelf-Life Indicator Cards**: Feature a 4px vertical accent bar on the leading edge (Terracotta `#D84315` for expiring within 24h; Harvest Amber `#F57C00` for 2–3 days; Leaf Green `#2E7D32` for fresh).

### Progress Bars & Budget Meters
- **Nutrient & Rupiah Gauges**: 8px height with fully rounded pill caps. Background track uses 15% opacity of the track color. Smooth CSS transitions track active values, accompanied by a trailing bold percentage or balance label in `numeric-stat` styling.

### Input Fields & Quick-Log Sheets
- **Inputs**: Outlined text fields with an 8px radius, recessed 12px padding, and floating labels. Numerical fields for Indonesian Rupiah prefix with an immutable, muted `Rp` anchor.
- **Quick-Log Bottom Sheets**: Drag-handle anchored top center (32x4px rounded pill in 20% opacity neutral). Surface stacks ingredients, quick meal presets, and an instant-log action button grouped in the lower natural thumb zone.