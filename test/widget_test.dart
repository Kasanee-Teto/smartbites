// Owner: Louis | Tests: WelcomeScreen, OnboardingScreen, MainNavigation,
// adaptive layouts, and overflow

import 'package:budget_bites/app.dart';
import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/screens/grocery_screen.dart';
import 'package:budget_bites/screens/home_screen.dart';
import 'package:budget_bites/screens/meal_plan_screen.dart';
import 'package:budget_bites/screens/onboarding_screen.dart';
import 'package:budget_bites/screens/welcome_screen.dart';
import 'package:budget_bites/theme/app_theme.dart';
import 'package:budget_bites/widgets/app_bar.dart';
import 'package:budget_bites/widgets/budget_card.dart';
import 'package:budget_bites/widgets/main_navigation.dart';
import 'package:budget_bites/widgets/page_dots.dart';
import 'package:budget_bites/widgets/sdg_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'WelcomeScreen renders branding, SDG badges, and navigates to Onboarding',
    (tester) async {
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
    },
  );

  testWidgets(
    'OnboardingScreen 3-slide PageView, PageDots, SDG 3 explanation, and '
    'button/swipe navigation',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(PageDots), findsOneWidget);

      // Slide 1 checks: copy & SDG 3 explanation
      expect(
        find.text('Makan Enak, Hemat & Sehat Tanpa Boros'),
        findsOneWidget,
      );
      expect(find.text('Pantau Hidrasi 1-Ketukan'), findsOneWidget);
      expect(
        find.text(
          'Target harian 2 liter air terjaga tanpa repot mengetik detail.',
        ),
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
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();

      // Slide 3 checks
      expect(
        find.text('Bentuk Rutinitas Sehat & Berkelanjutan'),
        findsOneWidget,
      );
      expect(find.text('Konsistensi Streak Harian'), findsOneWidget);
      expect(find.text('Mulai Rencanakan Makan (3 Menit)'), findsOneWidget);

      // Finish onboarding via primary button -> replaces route with
      // MainNavigation
      await tester.tap(find.text('Mulai Rencanakan Makan (3 Menit)'));
      await tester.pumpAndSettle();

      expect(find.byType(MainNavigation), findsOneWidget);
    },
  );

  testWidgets(
    'SmartBites MainNavigation 5-tab switching, undo helper, and state '
    'preservation',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const MainNavigation()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MainNavigation), findsOneWidget);
      expect(find.byType(SmartBitesAppBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // Tab 0: Beranda
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Budget Makan Minggu Ini'), findsOneWidget);

      // Tab 1: Menu
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      expect(find.byType(MealPlanScreen), findsOneWidget);
      expect(find.text('Menu & Gizi'), findsOneWidget);

      // Tab 2: Belanja ('Belanja' also appears as a TabBar label inside the
      // screen)
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Belanja'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GroceryScreen), findsOneWidget);
      expect(find.text('Pindahkan 3 item ke Pantry'), findsOneWidget);

      // Tab 3: Air & Waste
      await tester.tap(find.text('Air & Waste'));
      await tester.pumpAndSettle();
      expect(find.text('WaterTrackerScreen - Edbert (Air)'), findsOneWidget);

      // Tab 4: Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Profil & preferensi'), findsOneWidget);

      // Switch back to Tab 0: Beranda
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Budget Makan Minggu Ini'), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);

      // Floating Action Button (Catat Cepat)
      final fabFinder = find.widgetWithText(
        FloatingActionButton,
        'Catat Cepat',
      );
      expect(fabFinder, findsOneWidget);
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Catat Cepat dibuka (fitur lengkap di Step 4)'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Adaptive navigation layout: NavigationRail at >=600dp and NavigationBar '
    'at <600dp',
    (tester) async {
      // 1. Compact: 400 x 800
      tester.view.physicalSize = const Size(400 * 2.0, 800 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // 2. Medium: 600 x 800
      tester.view.physicalSize = const Size(600 * 2.0, 800 * 2.0);
      await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // 3. Expanded: 1024 x 768
      tester.view.physicalSize = const Size(1024 * 2.0, 768 * 2.0);
      await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    },
  );

  testWidgets(
    'No overflow on compact (360x640) and expanded (1024x768 landscape) at '
    'text scale 1.3',
    (tester) async {
      // Test WelcomeScreen & OnboardingScreen on compact 360 x 640 at text
      // scale 1.3
      tester.view.physicalSize = const Size(360 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: MaterialApp(home: WelcomeScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(WelcomeScreen), findsOneWidget);

      // Test OnboardingScreen on 360 x 640
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: MaterialApp(home: OnboardingScreen()),
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
          child: MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingScreen), findsOneWidget);
    },
  );

  testWidgets(
    'BudgetCard renders in standard mode, compact mode, and handles budget <= 0',
    (tester) async {
      // 1. Standard mode (spent: 235000, budget: 300000)
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: BudgetCard(spent: 235000, budget: 300000)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Budget Makan Minggu Ini'), findsOneWidget);
      expect(find.text('Rp 235.000'), findsOneWidget);
      expect(find.text('/ Rp 300.000'), findsOneWidget);
      expect(find.text('78%'), findsOneWidget);
      expect(find.text('Hemat'), findsOneWidget);
      expect(find.textContaining('Rp 65.000'), findsOneWidget);

      // 2. Compact mode (Perencana Makan)
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: BudgetCard(spent: 235000, budget: 300000, compact: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Rencana Mingguan'), findsOneWidget);
      expect(find.text('Terpakai 78%'), findsOneWidget);
      expect(find.text('Hemat (Di Bawah Target)'), findsOneWidget);

      // 3. Budget <= 0 (Unset budget)
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: BudgetCard(spent: 50000, budget: 0)),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Atur budget di Profil untuk memantau pengeluaran.'),
        findsOneWidget,
      );
      expect(find.text('Atur di Profil'), findsOneWidget);
    },
  );

  testWidgets('HomeScreen renders all 6 sections and handles water quick log, checkboxes, '
      'and zero-waste commitment', (tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var loggedWater = 0;
    var toggledSlot = -1;
    var toggledValue = false;
    var zeroWasteTapped = false;
    var insightTapped = false;
    var mealPlanTapped = false;

    const testProfile = UserProfile(
      weeklyBudget: 300000,
      waterTargetMl: 2000,
      allergies: ['Kacang'],
      preferences: ['Murah'],
    );

    final meals = [mockCookMeals[0], mockCookMeals[1]];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HomeScreen(
          profile: testProfile,
          todayMeals: meals,
          todayEaten: const [true, false],
          currentSpent: 235000,
          todayWaterMl: 750,
          streakDays: 5,
          onQuickWaterAdd: (amount) => loggedWater += amount,
          onToggleMealEaten: (slot, val) {
            toggledSlot = slot;
            toggledValue = val;
          },
          onNoWaste: () => zeroWasteTapped = true,
          onOpenInsight: () => insightTapped = true,
          onOpenMealPlan: () => mealPlanTapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header greeting
    expect(find.text('Halo, Rani! 👋'), findsOneWidget);
    expect(find.text('20 thn • Mahasiswa Kost Aktif'), findsOneWidget);
    expect(find.textContaining('Pilihan Bijak Hari Ini'), findsOneWidget);

    // Tap insight button
    await tester.tap(find.byIcon(Icons.tips_and_updates_outlined));
    expect(insightTapped, isTrue);

    // 2. BudgetCard
    expect(find.byType(BudgetCard), findsOneWidget);

    // 3. Streak Card
    expect(find.text('5 Hari Beruntun 🔥'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);

    // 4. Water Card & Quick-log buttons
    expect(find.text('Konsumsi Air Hari Ini'), findsOneWidget);
    expect(find.text('+150 ml'), findsOneWidget);
    expect(find.text('+250 ml'), findsOneWidget);
    expect(find.text('+500 ml'), findsOneWidget);

    await tester.tap(find.text('+250 ml'));
    expect(loggedWater, 250);

    // 5. Today's Menu & Allergy warning
    expect(find.text('Menu Hari Ini'), findsOneWidget);
    expect(find.text(meals[0].name), findsOneWidget);
    expect(find.text(meals[1].name), findsOneWidget);

    // Meal 2 contains 'Kacang' and user profile has 'Kacang'
    if (meals[1].allergens.any((a) => a.toLowerCase().contains('kacang'))) {
      expect(
        find.textContaining('Peringatan: Mengandung Alergen'),
        findsOneWidget,
      );
    }

    // Checkbox toggling
    final checkboxes = find.byType(Checkbox);
    expect(checkboxes, findsNWidgets(2));
    await tester.tap(checkboxes.at(1));
    expect(toggledSlot, 1);
    expect(toggledValue, isTrue);

    // Tap 'Lihat Rencana'
    await tester.tap(find.text('Lihat Rencana'));
    expect(mealPlanTapped, isTrue);

    // 6. Zero Waste Commitment Card
    await tester.scrollUntilVisible(
      find.text('Pahlawan Bebas Sampah'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Pahlawan Bebas Sampah'), findsOneWidget);
    await tester.tap(find.text('Habis Semua! 🌟'));
    expect(zeroWasteTapped, isTrue);
  });

  testWidgets(
    'HomeScreen renders empty state when todayMeals is empty and allows planning',
    (tester) async {
      var planCalled = false;
      const testProfile = UserProfile(
        weeklyBudget: 300000,
        waterTargetMl: 2000,
        allergies: [],
        preferences: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: HomeScreen(
            profile: testProfile,
            onOpenMealPlan: () => planCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada menu hari ini'), findsOneWidget);
      expect(
        find.text('Mulai rencanakan menu mingguan hematmu sekarang!'),
        findsOneWidget,
      );
      expect(find.text('Rencanakan Menu'), findsOneWidget);

      await tester.tap(find.text('Rencanakan Menu'));
      expect(planCalled, isTrue);
    },
  );

  testWidgets(
    'HomeScreen has no overflow on compact (360x640) and wide (1024x768) at text scale 1.3',
    (tester) async {
      const testProfile = UserProfile(
        weeklyBudget: 300000,
        waterTargetMl: 2000,
        allergies: ['Kacang'],
        preferences: ['Murah'],
      );

      // 1. Compact 360 x 640
      tester.view.physicalSize = const Size(360 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: HomeScreen(
              profile: testProfile,
              todayMeals: [mockCookMeals[0], mockCookMeals[1]],
              todayEaten: const [true, false],
              currentSpent: 235000,
              todayWaterMl: 750,
              streakDays: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);

      // 2. Wide 1024 x 768
      tester.view.physicalSize = const Size(1024 * 2.0, 768 * 2.0);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: HomeScreen(
              profile: testProfile,
              todayMeals: [mockCookMeals[0], mockCookMeals[1]],
              todayEaten: const [true, false],
              currentSpent: 235000,
              todayWaterMl: 750,
              streakDays: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );
}
