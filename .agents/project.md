# Project overview

SmartBites (`budget_bites`) is a Flutter mobile front end for healthy, budget-conscious meal planning and food-waste reduction. It supports SDG 3 and SDG 12.3 and uses Material Design 3, responsive layouts, local mock data, and in-memory state managed with `setState()`.

## Technical baseline

- Flutter application using Dart SDK `^3.13.3`.
- Runtime dependency: `shared_preferences`.
- Test dependency: `flutter_test` and `flutter_lints`.
- No backend or network data layer is currently part of the app.
- Assets are declared in `pubspec.yaml` under `assets/images/` and `assets/icons/`.

## Repository layout

- `lib/main.dart`, `lib/app.dart`: entry point and app shell.
- `lib/models/`: domain models such as meals, groceries, pantry items, water, waste, profiles, and achievements.
- `lib/data/mock_data.dart`: shared deterministic sample data.
- `lib/screens/`: feature screens and navigation destinations.
- `lib/widgets/`: reusable UI components.
- `lib/theme/`, `lib/utils/`: theme, colors, constants, breakpoints, and rules.
- `test/`: unit and widget tests.
- `assets/`: bundled images and icons.

## Product references

Use `README.md` for setup, team ownership, and feature ownership. Use `PRD_SmartBites.md` for functional requirements and product behavior.
