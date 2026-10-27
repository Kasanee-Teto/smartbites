// Owner: Louis | Tests: WelcomeScreen, OnboardingScreen, MainNavigation, adaptive layouts, and overflow

import 'package:budget_bites/app.dart';
import 'package:budget_bites/screens/onboarding_screen.dart';
import 'package:budget_bites/screens/welcome_screen.dart';
import 'package:budget_bites/theme/app_theme.dart';
import 'package:budget_bites/widgets/app_bar.dart';
import 'package:budget_bites/widgets/main_navigation.dart';
import 'package:budget_bites/widgets/page_dots.dart';
import 'package:budget_bites/widgets/sdg_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'WelcomeScreen renders branding, SDG badges, and navigates to Onboarding',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SmartBitesApp());
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('SmartBites'), findsOneWidget);
    expect(find.text('Sahabat Sehat Anak Kos'), findsOneWidget);
    expect(find.byType(SdgBadge), findsAtLeastNWidgets(2));
    expect(find.text('Mulai Rencanakan Makan'), findsOneWidget);

    // Tap 'Mulai Rencanakan Makan' to navigate to OnboardingScreen
    await tester.tap(find.text('Mulai Rencanakan Makan'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets(
      'OnboardingScreen 3-slide PageView, PageDots, SDG 3 explanation, and button/swipe navigation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(PageDots), findsOneWidget);

    // Slide 1 checks: copy & SDG 3 explanation
    expect(find.text('Makan Enak, Hemat & Sehat Tanpa Boros'), findsOneWidget);
    expect(find.text('Pantau Hidrasi 1-Ketukan'), findsOneWidget);
    expect(
      find.text('Target harian 2 liter air terjaga tanpa repot mengetik detail.'),
      findsOneWidget,
    );
    expect(find.textContaining('SDG 3: Kehidupan Sehat'), findsOneWidget);

    // Tap 'Lanjut' button to advance to Slide 2
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Slide 2 checks
    expect(find.text('Alokasi Uang Makan Realistis'), findsOneWidget);
    expect(find.text('Target Harian Rp 30.000 - Rp 50.000'), findsOneWidget);

    // Swipe left to advance to Slide 3
    await tester.fling(
      find.byType(PageView),
      const Offset(-400, 0),
      1000,
    );
    await tester.pumpAndSettle();

    // Slide 3 checks
    expect(
      find.text('Bentuk Rutinitas Sehat & Berkelanjutan'),
      findsOneWidget,
    );
    expect(find.text('Konsistensi Streak Harian'), findsOneWidget);
    expect(find.text('Mulai Rencanakan Makan (3 Menit)'), findsOneWidget);

    // Finish onboarding via primary button -> replaces route with MainNavigation
    await tester.tap(find.text('Mulai Rencanakan Makan (3 Menit)'));
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigation), findsOneWidget);
  });

  testWidgets(
      'SmartBites MainNavigation 5-tab switching, undo helper, and state preservation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MainNavigation(),
      ),
    );
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

    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigation(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    // 2. Medium: 600 x 800
    tester.view.physicalSize = const Size(600 * 2.0, 800 * 2.0);
    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigation(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // 3. Expanded: 1024 x 768
    tester.view.physicalSize = const Size(1024 * 2.0, 768 * 2.0);
    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigation(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets(
      'No overflow on compact (360x640) and expanded (1024x768 landscape) at text scale 1.3',
      (WidgetTester tester) async {
    // Test WelcomeScreen & OnboardingScreen on compact 360 x 640 at text scale 1.3
    tester.view.physicalSize = const Size(360 * 2.0, 640 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: MaterialApp(
          home: WelcomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(WelcomeScreen), findsOneWidget);

    // Test OnboardingScreen on 360 x 640
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(OnboardingScreen), findsOneWidget);

    // Test OnboardingScreen on 1024 x 768 landscape at text scale 1.3
    tester.view.physicalSize = const Size(1024 * 2.0, 768 * 2.0);
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
