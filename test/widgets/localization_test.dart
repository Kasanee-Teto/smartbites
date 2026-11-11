import 'package:budget_bites/app.dart';
import 'package:budget_bites/i18n/generated/app_localizations.dart';
import 'package:budget_bites/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app defaults to Indonesian even on an English device', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(const SmartBitesApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(WelcomeScreen));
    expect(Localizations.localeOf(context), const Locale('id'));
    expect(AppLocalizations.of(context).save, 'Simpan');
    expect(MaterialLocalizations.of(context).cancelButtonLabel, 'Batal');
  });

  testWidgets('app resolves translations and falls back to Indonesian', (
    tester,
  ) async {
    const cases = [
      (Locale('en'), 'en', 'Save'),
      (Locale('zh', 'CN'), 'zh', '保存'),
      (Locale('fr'), 'id', 'Simpan'),
    ];

    for (final (requested, languageCode, save) in cases) {
      await tester.pumpWidget(SmartBitesApp(locale: requested));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(WelcomeScreen));
      expect(Localizations.localeOf(context).languageCode, languageCode);
      expect(AppLocalizations.of(context).save, save);
      expect(AppLocalizations.of(context).appName, 'SmartBites');
    }
  });
}
