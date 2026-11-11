# Translations

SmartBites uses Flutter's built-in `gen-l10n` with Indonesian (`id`, the default
and template), English (`en`), and Simplified Chinese (`zh`).

Edit the ARB files here, then run from the repository root:

```sh
flutter pub get
flutter gen-l10n
```

`flutter pub get` also generates the Dart files automatically. The generated
directory is ignored by Git; do not edit its contents manually.

Use translations in a widget below `MaterialApp`:

```dart
import 'package:budget_bites/i18n/generated/app_localizations.dart';

final l10n = AppLocalizations.of(context);
Text(l10n.save);
```

Add each new key to `app_id.arb` with a description, and translate that same key
in both other files. Use ARB placeholders for dynamic values rather than joining
translated sentence fragments.

The app defaults to Indonesian. To preview another language, construct
`SmartBitesApp(locale: Locale('en'))` or `SmartBitesApp(locale: Locale('zh'))`.
Unsupported locales fall back to Indonesian. There is no in-app language picker
or persisted language preference yet.

This is the translation foundation: the app title uses the generated resources,
and common actions are available for migration. Existing screen copy, mock data,
and date/currency formatting have not been migrated and remain Indonesian.

See [Flutter internationalization](https://docs.flutter.dev/ui/internationalization)
and the project configuration in [l10n.yaml](../../l10n.yaml).
