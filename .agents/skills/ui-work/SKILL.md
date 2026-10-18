---
name: ui-work
description: Use when changing SmartBites Flutter screens, widgets, navigation, responsive layouts, Material 3 styling, or user-facing interactions.
---

# Flutter UI work

## When to use

Use this for user-facing Flutter UI changes in `lib/`, including widgets, screens, themes, settings rows, user-facing layout, and interaction behavior.

## Conventions

- Inspect nearby screens and widgets before adding a new pattern.
- Reuse the shared theme, `AppColors`, constants, and responsive breakpoint helpers.
- Keep screens responsible for composition and navigation; keep reusable presentation in widgets.
- Keep state transitions explicit and compatible with the existing `setState()` approach.
- Keep Indonesian copy consistent with the surrounding screen and the product requirements.
- Support compact phone and medium or expanded layouts; avoid fixed widths that cause overflow.
- Use `const` where possible and keep controllers and other disposable objects owned by the state that created them.
- Reuse bundled assets declared in `pubspec.yaml` before adding new assets.

## Verification

- Run `flutter analyze`.
- Run `flutter test` and add a focused widget test when behavior changes.
- Run the app on a compact phone and a medium or expanded layout when available.
- Check navigation, loading or empty states, touch targets, overflow, and text scaling.

## Pitfalls

- Do not duplicate colors, spacing, breakpoints, or mock records in a new screen.
- Do not put substantial business logic in `build()` methods.
- Do not introduce a new state-management library for a local UI change.
- Do not leave timers, controllers, focus nodes, or animations undisposed.
- Do not treat a visual change as complete until both narrow and wider layouts have been considered.
