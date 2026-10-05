# Commands

Run these from the repository root.

## Setup

```bash
flutter pub get
```

## Static analysis

```bash
flutter analyze
```

The analyzer uses `analysis_options.yaml`, which includes `flutter_lints` and project rules such as `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, and `avoid_print`.

## Tests

```bash
flutter test
```

Run a focused test while iterating:

```bash
flutter test test/widget_test.dart
```

## Run the app

```bash
flutter run
```

For UI work, check a compact phone layout and a medium or expanded layout when an emulator or device is available.

## Before handoff

Run `flutter pub get`, `flutter analyze`, and `flutter test`. If a device or emulator is unavailable, report that UI runtime validation was skipped.
