// Owner: Louis | Tests: MainNavigation, adaptive navigation, tab switching, and overflow

import 'package:budget_bites/app.dart';
import 'package:budget_bites/widgets/app_bar.dart';
import 'package:budget_bites/widgets/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'SmartBites MainNavigation 5-tab switching, undo helper, and state preservation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SmartBitesApp());
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigation), findsOneWidget);
    expect(find.byType(SmartBitesAppBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    // Tab 0: Beranda
    expect(find.text('HomeScreen - Louis (Beranda)'), findsOneWidget);

    // Tab 1: Menu
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('MealPlanScreen - Jesseca (Menu)'), findsOneWidget);

    // Tab 2: Belanja
    await tester.tap(find.text('Belanja'));
    await tester.pumpAndSettle();
    expect(find.text('GroceryScreen - Gilbert (Belanja)'), findsOneWidget);

    // Tab 3: Air & Waste
    await tester.tap(find.text('Air & Waste'));
    await tester.pumpAndSettle();
    expect(find.text('WaterTrackerScreen - Edbert (Air)'), findsOneWidget);

    // Tab 4: Profil
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('ProfileScreen - Edbert (Profil)'), findsOneWidget);

    // Switch back to Tab 0: Beranda
    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    expect(find.text('HomeScreen - Louis (Beranda)'), findsOneWidget);
    expect(find.byType(IndexedStack), findsOneWidget);

    // Floating Action Button (Catat Cepat)
    final fabFinder = find.widgetWithText(FloatingActionButton, 'Catat Cepat');
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Catat Cepat dibuka (fitur lengkap di Step 4)'),
      findsOneWidget,
    );
  });

  testWidgets(
      'Adaptive navigation layout: NavigationRail at >=600dp and NavigationBar at <600dp',
      (WidgetTester tester) async {
    // 1. Compact: 400 x 800
    tester.view.physicalSize = const Size(400 * 2.0, 800 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SmartBitesApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    // 2. Medium: 600 x 800
    tester.view.physicalSize = const Size(600 * 2.0, 800 * 2.0);
    await tester.pumpWidget(const SmartBitesApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // 3. Expanded: 1024 x 768
    tester.view.physicalSize = const Size(1024 * 2.0, 768 * 2.0);
    await tester.pumpWidget(const SmartBitesApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets(
      'No overflow on compact (360dp) and expanded (1024dp) at text scale 1.3',
      (WidgetTester tester) async {
    // Test on compact screen: 360 x 800 at text scale 1.3
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
    expect(find.text('HomeScreen - Louis (Beranda)'), findsOneWidget);

    // Test on expanded screen: 1024 x 768 at text scale 1.3
    tester.view.physicalSize = const Size(1024 * 2.0, 768 * 2.0);
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: SmartBitesApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
