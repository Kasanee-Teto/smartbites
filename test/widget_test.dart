import 'package:budget_bites/app.dart';
import 'package:budget_bites/widgets/app_bar.dart';
import 'package:budget_bites/widgets/app_logo.dart';
import 'package:budget_bites/widgets/section_title.dart';
import 'package:budget_bites/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SmartBites Step 1b preview page renders and toggles theme',
      (WidgetTester tester) async {
    ThemeMode? capturedMode;

    await tester.pumpWidget(
      SmartBitesApp(
        onThemeModeChanged: (mode) {
          capturedMode = mode;
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TempStep1bPreviewPage), findsOneWidget);
    expect(find.byType(SmartBitesAppBar), findsOneWidget);
    expect(find.byType(StatusBadge), findsAtLeastNWidgets(4));
    expect(find.byType(AppLogo), findsAtLeastNWidgets(1));
    expect(find.byType(SectionTitle), findsAtLeastNWidgets(1));
    expect(find.byType(Card), findsAtLeastNWidgets(2));
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Tap theme toggle button
    final toggleButton = find.byType(FilledButton).first;
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    expect(capturedMode, isNotNull);
  });

  testWidgets('No overflow on compact (360dp) and expanded (1024dp) at text scale 1.3',
      (WidgetTester tester) async {
    // Test on compact screen: 360 x 800
    tester.view.physicalSize = const Size(360 * 2.0, 800 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: SmartBitesApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('COMPACT'), findsOneWidget);

    // Test on expanded screen: 1024 x 768
    tester.view.physicalSize = const Size(1024 * 2.0, 768 * 2.0);
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: SmartBitesApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('EXPANDED'), findsOneWidget);
  });
}
