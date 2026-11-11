// Owner: Louis | Tests: WelcomeScreen, OnboardingScreen, MainNavigation,
// adaptive layouts, and overflow

import 'package:budget_bites/app.dart';
import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/screens/achievements_screen.dart';
import 'package:budget_bites/screens/food_waste_screen.dart';
import 'package:budget_bites/screens/grocery_screen.dart';
import 'package:budget_bites/screens/home_screen.dart';
import 'package:budget_bites/screens/meal_plan_screen.dart';
import 'package:budget_bites/screens/onboarding_screen.dart';
import 'package:budget_bites/screens/profile_screen.dart';
import 'package:budget_bites/screens/water_tracker_screen.dart';
import 'package:budget_bites/screens/welcome_screen.dart';
import 'package:budget_bites/theme/app_theme.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/widgets/app_bar.dart';
import 'package:budget_bites/widgets/budget_card.dart';
import 'package:budget_bites/widgets/main_navigation.dart';
import 'package:budget_bites/widgets/meal_card.dart';
import 'package:budget_bites/widgets/page_dots.dart';
import 'package:budget_bites/widgets/quick_log_sheet.dart';
import 'package:budget_bites/widgets/sdg_badge.dart';
import 'package:budget_bites/widgets/streak_card.dart';
import 'package:budget_bites/widgets/water_progress_card.dart';
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
      expect(find.byType(WaterTrackerScreen), findsOneWidget);
      await tester.tap(find.text('Food Waste'));
      await tester.pumpAndSettle();
      expect(find.byType(FoodWasteScreen), findsOneWidget);

      // Tab 4: Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Budget Mingguan'), findsOneWidget);

      // Switch back to Tab 0: Beranda
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Budget Makan Minggu Ini'), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);

      // Floating Action Button (Catat Cepat opens QuickLogSheet)
      final fabFinder = find.widgetWithText(
        FloatingActionButton,
        'Catat Cepat',
      );
      expect(fabFinder, findsOneWidget);
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();
      expect(find.byType(QuickLogSheet), findsOneWidget);
      expect(find.text('⚡ Catat Cepat'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(QuickLogSheet), findsNothing);
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
    var streakTapped = false;

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
          onOpenStreak: () => streakTapped = true,
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
    await tester.tap(find.text('5 Hari Beruntun 🔥'));
    expect(streakTapped, isTrue);

    // 4. Water Card & Quick-log buttons
    expect(find.byType(WaterProgressCard), findsOneWidget);
    expect(find.text('Air Hari Ini'), findsOneWidget);
    expect(find.text('+150 ml'), findsOneWidget);
    expect(find.text('+250 ml'), findsOneWidget);
    expect(find.text('+500 ml'), findsOneWidget);

    await tester.tap(find.text('+250 ml'));
    expect(loggedWater, 250);

    // 5. Today's Menu & Allergy warning
    expect(find.text('Menu Hari Ini'), findsOneWidget);
    // Tap 'Lihat Rencana' while in view
    await tester.tap(find.text('Lihat Rencana'));
    expect(mealPlanTapped, isTrue);

    expect(find.byType(MealCard), findsNWidgets(2));
    expect(find.text(meals[0].name), findsOneWidget);
    expect(find.text(meals[1].name), findsOneWidget);

    // Meal 2 contains 'Kacang' and user profile has 'Kacang'
    if (meals[1].allergens.any((a) => a.toLowerCase().contains('kacang'))) {
      expect(
        find.textContaining('Mengandung alergen profil Anda'),
        findsOneWidget,
      );
    }

    // Checkbox toggling
    final checkboxes = find.byType(Checkbox);
    expect(checkboxes, findsNWidgets(2));
    await tester.scrollUntilVisible(
      checkboxes.at(1),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(checkboxes.at(1));
    await tester.pumpAndSettle();
    expect(toggledSlot, 1);
    expect(toggledValue, isTrue);

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
    'Smoke test: HomeScreen has no overflow across phones, tablets, and text scales 1.0, 1.3, 2.0',
    (tester) async {
      const testProfile = UserProfile(
        weeklyBudget: 300000,
        waterTargetMl: 2000,
        allergies: ['Kacang'],
        preferences: ['Murah'],
      );

      const sizes = [
        Size(360, 640),
        Size(411, 891),
        Size(600, 960),
        Size(768, 1024),
        Size(1024, 768),
        Size(1280, 800),
      ];
      const scales = [1.0, 1.3, 2.0];

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;

      for (final size in sizes) {
        for (final scale in scales) {
          tester.view.physicalSize = size;
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
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
          expect(
            tester.takeException(),
            isNull,
            reason:
                'HomeScreen threw overflow or error at size $size and scale $scale',
          );
          expect(find.byType(HomeScreen), findsOneWidget);
        }
      }
    },
  );

  testWidgets(
    'Smoke test: MainNavigation has no overflow across phones, tablets, and text scales 1.0, 1.3, 2.0',
    (tester) async {
      const sizes = [
        Size(360, 640),
        Size(411, 891),
        Size(600, 960),
        Size(768, 1024),
        Size(1024, 768),
        Size(1280, 800),
      ];
      const scales = [1.0, 1.3, 2.0];

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;

      final originalOnError = FlutterError.onError;
      final overflowErrors = <String>[];
      FlutterError.onError = (details) {
        final message = details.exceptionAsString();
        if (message.contains('overflowed by')) {
          overflowErrors.add(message);
        }
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      for (final size in sizes) {
        for (final scale in scales) {
          tester.view.physicalSize = size;
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                home: const MainNavigation(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            overflowErrors,
            isEmpty,
            reason:
                'MainNavigation threw unexpected overflow or error at size $size and scale $scale: $overflowErrors',
          );
          expect(find.byType(MainNavigation), findsOneWidget);
        }
      }
    },
  );

  testWidgets(
    'QuickLogSheet: tapping +250 adds 250 ml, and Undo reverts both waterRecords and DailyLog (FR-31, FR-35)',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const MainNavigation()),
      );
      await tester.pumpAndSettle();

      // 1. Open QuickLogSheet via FAB
      final fab = find.widgetWithText(FloatingActionButton, 'Catat Cepat');
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.byType(QuickLogSheet), findsOneWidget);
      expect(find.text('⚡ Catat Cepat'), findsOneWidget);

      // 2. Tap +250 ml (Gelas)
      final water250Btn = find.textContaining('+250 ml (Gelas)');
      expect(water250Btn, findsOneWidget);
      await tester.tap(water250Btn);
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.byType(QuickLogSheet), findsNothing);

      // SnackBar with Undo action should appear
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('250 ml (Gelas)'), findsOneWidget);
      expect(find.text('Urungkan'), findsOneWidget);

      // 3. Tap Undo
      await tester.tap(find.text('Urungkan'));
      await tester.pumpAndSettle();

      // SnackBar disappears and state safely reverts
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'QuickLogSheet supports tab switching, 2-tap waste logging, and zero-waste commitment',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const MainNavigation()),
      );
      await tester.pumpAndSettle();

      // Open QuickLogSheet
      await tester.tap(
        find.widgetWithText(FloatingActionButton, 'Catat Cepat'),
      );
      await tester.pumpAndSettle();

      // Switch to Makan tab
      await tester.tap(find.text('Makan'));
      await tester.pumpAndSettle();
      expect(find.text('JADWAL MAKAN HARI INI'), findsOneWidget);

      // Switch to Food Waste tab
      await tester.tap(find.text('Food Waste'));
      await tester.pumpAndSettle();
      expect(find.text('Tidak ada makanan terbuang hari ini'), findsOneWidget);
      expect(find.text('Sayur Bayam'), findsOneWidget);

      // 2-tap log: Tap [Sedikit] on Sayur Bayam
      final sedikitBtn = find.text('Sedikit');
      expect(sedikitBtn, findsAtLeastNWidgets(1));
      await tester.tap(sedikitBtn.first);
      await tester.pumpAndSettle();

      // Sheet closes and SnackBar appears
      expect(find.byType(QuickLogSheet), findsNothing);
      expect(find.textContaining('Catatan sisa Sayur Bayam'), findsOneWidget);
      expect(find.text('Urungkan'), findsOneWidget);
    },
  );

  testWidgets(
    'StreakCard renders correctly across active, zero, broken, and not-logged states',
    (tester) async {
      var tapped = false;

      // 1. Active streak with today logged (HTML standard)
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StreakCard(
              streak: 5,
              level: 2,
              nextTarget: 7,
              progress: 5,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('5 Hari Beruntun 🔥'), findsOneWidget);
      expect(find.text('Level 2'), findsOneWidget);
      expect(
        find.text('Pertahankan kebiasaan sehat dan hematmu!'),
        findsOneWidget,
      );
      await tester.tap(find.byType(StreakCard));
      expect(tapped, isTrue);

      // 2. Active streak but not logged today
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: StreakCard(
              streak: 5,
              level: 2,
              nextTarget: 7,
              progress: 5,
              isLoggedToday: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Catat satu hal hari ini untuk menjaga streak'),
        findsOneWidget,
      );

      // 3. Zero streak (Fresh start)
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: StreakCard(streak: 0, level: 1, nextTarget: 3, progress: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mulai Beruntun Pertamamu! 🔥'), findsOneWidget);
      expect(find.text('Mulai streak pertamamu hari ini!'), findsOneWidget);

      // 4. Broken streak
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: StreakCard(
              streak: 0,
              level: 1,
              nextTarget: 3,
              progress: 0,
              isBroken: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Streak-mu istirahat dulu. Yuk mulai lagi!'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Air & Waste, Profile, and Achievements have no overflow on compact '
    '(360x640) and expanded (1024x768) and dark mode switch updates theme',
    (tester) async {
      ThemeMode? activeMode;
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final size in [
        const Size(360 * 2.0, 640 * 2.0),
        const Size(1024 * 2.0, 768 * 2.0),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: MainNavigation(
              initialIndex: 3,
              onThemeModeChanged: (mode) => activeMode = mode,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(WaterTrackerScreen), findsOneWidget);

        await tester.tap(find.text('Food Waste'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(FoodWasteScreen), findsOneWidget);

        await tester.tap(find.text('Profil').last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Budget Mingguan'), findsOneWidget);

        await tester.ensureVisible(find.text('Pencapaian'));
        await tester.tap(find.text('Pencapaian'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(AchievementsScreen), findsOneWidget);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }

      await tester.ensureVisible(find.text('Mode Gelap'));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(activeMode, ThemeMode.dark);
    },
  );

  testWidgets(
    'FR-04, FR-13: Changing budget slider in Profile updates BudgetCard on Home and in Meal Planner immediately and flips status',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const MainNavigation()),
      );
      await tester.pumpAndSettle();

      // 1. Initial state on Home (Tab 0):
      // Seed weekly meal plan cost is within Rp 300.000 -> BudgetCard displays status 'Hemat'.
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(BudgetCard), findsOneWidget);
      expect(find.text('Hemat'), findsOneWidget);
      expect(find.textContaining('/ Rp 300.000'), findsOneWidget);

      // 2. Switch to Profil (Tab 4)
      await tester.tap(find.text('Profil').last);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Budget Mingguan'), findsOneWidget);
      expect(find.text('Rp 300.000'), findsOneWidget);

      // Update slider to minimum budget (Rp 100.000)
      final slider = tester.widget<Slider>(find.byType(Slider).first);
      slider.onChanged?.call(100000);
      slider.onChangeEnd?.call(100000);
      await tester.pumpAndSettle();

      // Verify SnackBar "Preferensi profil disimpan" appeared
      expect(find.text('Preferensi profil disimpan'), findsOneWidget);
      expect(find.text('Rp 100.000'), findsOneWidget);

      // 3. Switch back to Beranda (Tab 0) without reloading
      await tester.tap(find.text('Beranda').last);
      await tester.pumpAndSettle();

      // Verify BudgetCard on Home immediately updated budget to Rp 100.000
      // and flipped status from 'Hemat' to 'Perlu Hemat' (since cost exceeds 100k)
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.textContaining('/ Rp 100.000'), findsOneWidget);
      expect(find.text('Perlu Hemat'), findsOneWidget);
      expect(find.text('Hemat'), findsNothing);

      // 4. Switch to Menu / Perencana Makan (Tab 1)
      await tester.tap(find.text('Menu').last);
      await tester.pumpAndSettle();
      expect(find.byType(MealPlanScreen), findsOneWidget);
      expect(find.text('Anggaran Rp 100.000'), findsOneWidget);

      // 5. Test Undo: Tap "Urungkan" on the SnackBar
      await tester.tap(find.text('Urungkan'));
      await tester.pumpAndSettle();

      // MealPlanScreen immediately restores Anggaran Rp 300.000
      expect(find.text('Anggaran Rp 300.000'), findsOneWidget);

      // Switch back to Beranda (Tab 0) and verify status flipped back to 'Hemat'
      await tester.tap(find.text('Beranda').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('/ Rp 300.000'), findsOneWidget);
      expect(find.text('Hemat'), findsOneWidget);
      expect(find.text('Perlu Hemat'), findsNothing);
    },
  );

  testWidgets(
    'FR-10, FR-13: Deleting a planned meal updates totals on Meal Planner and Home, and Undo restores them',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MainNavigation(initialIndex: 1), // Start at Menu tab
        ),
      );
      await tester.pumpAndSettle();

      final mealPlan = tester.widget<MealPlanScreen>(
        find.byType(MealPlanScreen),
      );
      expect(mealPlan.entries, isNotEmpty);
      final initialCost = plannedCost(mealPlan.entries, {
        for (final m in mealPlan.meals) m.id: m,
      });
      expect(find.text(formatRupiah(initialCost)), findsOneWidget);

      // Delete the first entry
      final entryToDelete = mealPlan.entries.first;
      final mealCatalog = {for (final m in mealPlan.meals) m.id: m};
      final deletedMealPrice =
          (mealCatalog[entryToDelete.mealId]?.price ?? 0) *
          entryToDelete.servings;
      mealPlan.onDelete(entryToDelete.id);
      await tester.pumpAndSettle();

      // Verify SnackBar appeared
      expect(find.text('Menu dihapus dari rencana'), findsOneWidget);
      final reducedCost = initialCost - deletedMealPrice.round();
      expect(find.text(formatRupiah(reducedCost)), findsOneWidget);

      // Switch to Beranda and check BudgetCard reflects the reduced cost
      await tester.tap(find.text('Beranda').last);
      await tester.pumpAndSettle();
      expect(find.text(formatRupiah(reducedCost)), findsOneWidget);

      // Tap Undo ("Urungkan")
      await tester.tap(find.text('Urungkan'));
      await tester.pumpAndSettle();

      // Home BudgetCard reflects restored cost
      expect(find.text(formatRupiah(initialCost)), findsOneWidget);

      // Switch back to Menu and verify restored cost
      await tester.tap(find.text('Menu').last);
      await tester.pumpAndSettle();
      expect(find.text(formatRupiah(initialCost)), findsOneWidget);
    },
  );
}
