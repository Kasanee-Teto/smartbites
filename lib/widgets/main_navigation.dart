// Owner: Louis | FR: FR-02, FR-29, FR-30

import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/achievement.dart';
import 'package:budget_bites/models/daily_log.dart';
import 'package:budget_bites/models/grocery_item.dart';
import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/meal_preferences.dart';
import 'package:budget_bites/models/pantry_item.dart';
import 'package:budget_bites/models/planned_meal.dart';
import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/models/waste_record.dart';
import 'package:budget_bites/models/water_record.dart';
import 'package:budget_bites/screens/achievements_screen.dart';
import 'package:budget_bites/screens/food_waste_screen.dart';
import 'package:budget_bites/screens/grocery_screen.dart';
import 'package:budget_bites/screens/home_screen.dart';
import 'package:budget_bites/screens/insight_screen.dart';
import 'package:budget_bites/screens/meal_plan_screen.dart';
import 'package:budget_bites/screens/pantry_screen.dart';
import 'package:budget_bites/screens/profile_screen.dart';
import 'package:budget_bites/screens/water_tracker_screen.dart';
import 'package:budget_bites/utils/badge_rules.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/app_bar.dart';
import 'package:flutter/material.dart';

/// Single source of truth for all shared application data (FR-02).
/// All shared state lives in [_MainNavigationState] and flows down
/// via constructors and callbacks.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  int _airWasteTab = 0;

  // Single source of truth parent state variables
  late UserProfile _profile;
  late List<Meal> _meals;
  late List<PlannedMeal> _plan;
  final GlobalKey _mealPlanKey = GlobalKey(debugLabel: 'meal-planner');
  Map<Nutrient, double> _nutritionGoals = {};
  NutritionFocus _nutritionFocus = NutritionFocus.general;
  late List<GroceryItem> _grocery;
  late List<PantryItem> _pantry;
  late List<WaterRecord> _waterRecords;
  late List<WasteRecord> _wasteRecords;
  late List<DailyLog> _dailyLogs;
  late List<Achievement> _achievements;

  static const List<String> _titles = [
    'Beranda',
    'Menu',
    'Belanja',
    'Air & Waste',
    'Profil',
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Beranda',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_menu_outlined),
      selectedIcon: Icon(Icons.restaurant_menu),
      label: 'Menu',
    ),
    NavigationDestination(
      icon: Icon(Icons.shopping_bag_outlined),
      selectedIcon: Icon(Icons.shopping_bag),
      label: 'Belanja',
    ),
    NavigationDestination(
      icon: Icon(Icons.water_drop_outlined),
      selectedIcon: Icon(Icons.water_drop),
      label: 'Air & Waste',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  static const List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Beranda'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.restaurant_menu_outlined),
      selectedIcon: Icon(Icons.restaurant_menu),
      label: Text('Menu'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.shopping_bag_outlined),
      selectedIcon: Icon(Icons.shopping_bag),
      label: Text('Belanja'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.water_drop_outlined),
      selectedIcon: Icon(Icons.water_drop),
      label: Text('Air & Waste'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('Profil'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _profile = mockUserProfile;
    _meals = List<Meal>.from(mockMeals);
    _plan = seedMealPlan(DateTime.now(), mockWeekPlan, mockEaten);
    _grocery = List<GroceryItem>.from(mockGroceryItems);
    _pantry = List<PantryItem>.from(mockPantryItems);
    _waterRecords = List<WaterRecord>.from(mockWaterRecords);
    _wasteRecords = List<WasteRecord>.from(mockWasteRecords);
    _dailyLogs = List<DailyLog>.from(mockDailyLogs);
    _achievements = List<Achievement>.from(mockAchievements);
  }

  void _syncMealLog(DateTime date) {
    final day = calendarDay(date);
    final eatenIds = mealsOnDay(
      _plan,
      day,
    ).where((e) => e.isEaten).map((e) => e.mealId).toList();
    final index = _dailyLogs.indexWhere((log) => sameDay(log.date, day));
    if (index < 0) {
      if (eatenIds.isNotEmpty) {
        _dailyLogs.add(
          DailyLog(
            date: day,
            waterMl: 0,
            mealsEaten: eatenIds,
            wasteLogged: false,
            noWasteMarked: false,
          ),
        );
      }
      return;
    }
    final previous = _dailyLogs[index];
    if (eatenIds.isEmpty &&
        previous.waterMl == 0 &&
        !previous.wasteLogged &&
        !previous.noWasteMarked) {
      _dailyLogs.removeAt(index);
    } else {
      _dailyLogs[index] = previous.copyWith(mealsEaten: eatenIds);
    }
  }

  void _savePlannedMeal(PlannedMeal entry) {
    if (!_meals.any((meal) => meal.id == entry.mealId) ||
        !entry.servings.isFinite ||
        entry.servings < 0.25 ||
        entry.servings > 10 ||
        (entry.isEaten &&
            calendarDay(entry.scheduledAt)
                .isAfter(calendarDay(DateTime.now())))) {
      return;
    }
    final index = _plan.indexWhere((item) => item.id == entry.id);
    final previous = index < 0 ? null : _plan[index];
    void apply(PlannedMeal? value) {
      setState(() {
        _plan.removeWhere((item) => item.id == entry.id);
        if (value != null) _plan.add(value);
        _syncMealLog(entry.scheduledAt);
        if (previous != null &&
            !sameDay(previous.scheduledAt, entry.scheduledAt)) {
          _syncMealLog(previous.scheduledAt);
        }
      });
    }

    _applyWithUndo(
      entry.isEaten ? 'Menu dicatat dimakan' : 'Rencana menu disimpan',
      () {
        apply(entry);
      },
      () {
        apply(previous);
      },
    );
  }

  void _deletePlannedMeal(String id) {
    final index = _plan.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final previous = _plan[index];
    _applyWithUndo(
      'Menu dihapus dari rencana',
      () => setState(() {
        _plan.removeWhere((entry) => entry.id == id);
        _syncMealLog(previous.scheduledAt);
      }),
      () => setState(() {
        _plan.add(previous);
        _syncMealLog(previous.scheduledAt);
      }),
    );
  }

  void _addRecipeGroceries(Meal meal, double servings) {
    final prefix = 'recipe_${DateTime.now().microsecondsSinceEpoch}';
    final items = recipeGroceries(meal, servings, prefix);
    if (items.isEmpty) return;
    final ids = items.map((item) => item.id).toSet();
    _applyWithUndo(
      'Bahan ditambahkan ke belanja',
      () => setState(() => _grocery.addAll(items)),
      () =>
          setState(() => _grocery.removeWhere((item) => ids.contains(item.id))),
    );
  }

  void _updateProfile(UserProfile profile) {
    final previous = _profile;
    _applyWithUndo(
      'Preferensi profil disimpan',
      () => setState(() => _profile = profile),
      () => setState(() => _profile = previous),
    );
  }

  void _saveMealPreferences(
    List<String> allergies,
    MealPreferences preferences,
  ) {
    if ((preferences.maxPrice != null &&
            (preferences.maxPrice! < 0 || preferences.maxPrice! > 10000000)) ||
        (preferences.maxCookMinutes != null &&
            (preferences.maxCookMinutes! < 0 ||
                preferences.maxCookMinutes! > 1440))) {
      return;
    }
    _updateProfile(
      _profile.copyWith(
        allergies: List.of(allergies),
        mealPreferences: preferences,
      ),
    );
  }

  void _markNoWaste() {
          final today = calendarDay(DateTime.now());
          final index = _dailyLogs.indexWhere(
            (log) => sameDay(log.date, today),
          );
          final prevLog = index >= 0 ? _dailyLogs[index] : null;

          _applyWithUndo(
            'Komitmen bebas sampah hari ini tercatat! 🌟',
            () {
              setState(() {
                if (index >= 0) {
                  _dailyLogs[index] = _dailyLogs[index].copyWith(
                    noWasteMarked: true,
                  );
                } else {
                  _dailyLogs.add(
                    DailyLog(
                      date: today,
                      waterMl: 0,
                      mealsEaten: const [],
                      wasteLogged: false,
                      noWasteMarked: true,
                    ),
                  );
                }
              });
            },
            () {
              setState(() {
                if (prevLog != null) {
                  _dailyLogs[index] = prevLog;
                } else {
                  _dailyLogs.removeWhere(
                    (log) =>
                        sameDay(log.date, today) &&
                        log.noWasteMarked &&
                        !log.wasteLogged &&
                        log.waterMl == 0 &&
                        log.mealsEaten.isEmpty,
                  );
                }
              });
            },
          );
  }

  void _addWasteRecord(WasteRecord record) {
    final previousRecords = List<WasteRecord>.from(_wasteRecords);
    final previousLogs = List<DailyLog>.from(_dailyLogs);
    final today = calendarDay(DateTime.now());
    _applyWithUndo(
      'Food waste dicatat',
      () => setState(() {
        _wasteRecords.add(record);
        final index = _dailyLogs.indexWhere((log) => sameDay(log.date, today));
        if (index >= 0) {
          _dailyLogs[index] = _dailyLogs[index].copyWith(wasteLogged: true);
        } else {
          _dailyLogs.add(
            DailyLog(
              date: today,
              waterMl: 0,
              mealsEaten: const [],
              wasteLogged: true,
              noWasteMarked: false,
            ),
          );
        }
      }),
      () => setState(() {
        _wasteRecords
          ..clear()
          ..addAll(previousRecords);
        _dailyLogs
          ..clear()
          ..addAll(previousLogs);
      }),
    );
  }

  void _deleteWasteRecord(String id) {
    final index = _wasteRecords.indexWhere((record) => record.id == id);
    if (index < 0) return;
    final removed = _wasteRecords[index];
    _applyWithUndo(
      'Catatan food waste dihapus',
      () => setState(() => _wasteRecords.removeAt(index)),
      () => setState(
        () => _wasteRecords.insert(index.clamp(0, _wasteRecords.length), removed),
      ),
    );
  }

  void _resetData() {
    setState(() {
      _profile = mockUserProfile;
      _meals = List<Meal>.from(mockMeals);
      _plan = seedMealPlan(DateTime.now(), mockWeekPlan, mockEaten);
      _nutritionGoals = {};
      _nutritionFocus = NutritionFocus.general;
      _grocery = List<GroceryItem>.from(mockGroceryItems);
      _pantry = List<PantryItem>.from(mockPantryItems);
      _waterRecords = List<WaterRecord>.from(mockWaterRecords);
      _wasteRecords = List<WasteRecord>.from(mockWasteRecords);
      _dailyLogs = List<DailyLog>.from(mockDailyLogs);
      _achievements = List<Achievement>.from(mockAchievements);
    });
  }

  void _openAchievements() {
    final achievements = BadgeRules.evaluate(
      logs: _dailyLogs,
      waterTargetMl: _profile.waterTargetMl,
      weekPlan: mockWeekPlan,
      meals: _meals,
      weeklyBudget: _profile.weeklyBudget,
      grocery: _grocery,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (navContext) => AchievementsScreen(
          achievements: achievements,
          currentStreak: BadgeRules.currentStreak(_dailyLogs, DateTime.now()),
          onBack: () => Navigator.of(navContext).pop(),
        ),
      ),
    );
  }

  Widget _buildAirWaste({required Widget water, required Widget waste}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                value: 0,
                icon: Icon(Icons.water_drop_outlined),
                label: Text('Air'),
              ),
              ButtonSegment<int>(
                value: 1,
                icon: Icon(Icons.delete_outline),
                label: Text('Food Waste'),
              ),
            ],
            selected: {_airWasteTab},
            onSelectionChanged: (selection) =>
                setState(() => _airWasteTab = selection.first),
          ),
        ),
        Expanded(
          child: IndexedStack(index: _airWasteTab, children: [water, waste]),
        ),
      ],
    );
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _applyWithUndo(String message, VoidCallback apply, VoidCallback revert) {
    apply();
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () {
              if (mounted) {
                revert();
              }
            },
          ),
        ),
      );
  }

  void _showQuickLogPlaceholder() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catat Cepat dibuka (fitur lengkap di Step 4)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildFab() {
    final theme = Theme.of(context);
    return FloatingActionButton.extended(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      icon: const Icon(Icons.bolt),
      label: const Text('Catat Cepat'),
      onPressed: _showQuickLogPlaceholder,
    );
  }

  List<Widget> _buildScreens() {
    // Current water total for today
    final todayWater = _waterRecords.fold<int>(
      0,
      (sum, item) => sum + item.amountMl,
    );

    // Current spend from checked grocery items
    final currentSpent = _grocery
        .where((item) => item.isChecked)
        .fold<int>(0, (sum, item) => sum + item.price);

    // Streak count calculated dynamically from daily logs
    final streakDays = _dailyLogs.isNotEmpty ? _dailyLogs.length : 5;

    final mealMap = {for (final meal in _meals) meal.id: meal};
    final todayEntries = mealsOnDay(
      _plan,
      DateTime.now(),
    ).where((entry) => mealMap.containsKey(entry.mealId)).toList();
    final todayMeals = todayEntries
        .map((entry) => mealMap[entry.mealId]!)
        .toList();
    final todayEaten = todayEntries.map((entry) => entry.isEaten).toList();

    // Reference pantry, waste records, and achievements for child screen
    // integration
    debugPrint(
      'State audit: ${_pantry.length} pantry items, '
      '${_wasteRecords.length} waste records, '
      '${_achievements.length} achievements loaded.',
    );

    return [
      HomeScreen(
        profile: _profile,
        todayMeals: todayMeals,
        todayEaten: todayEaten,
        totalWeeklyBudget: _profile.weeklyBudget,
        currentSpent: currentSpent,
        todayWaterMl: todayWater,
        streakDays: streakDays,
        onQuickWaterAdd: (amount) {
          _applyWithUndo(
            '+$amount ml air dicatat',
            () {
              setState(() {
                _waterRecords.add(
                  WaterRecord(
                    id: 'w_${DateTime.now().millisecondsSinceEpoch}',
                    amountMl: amount,
                    time: DateTime.now(),
                  ),
                );
              });
            },
            () {
              setState(() {
                if (_waterRecords.isNotEmpty) {
                  _waterRecords.removeLast();
                }
              });
            },
          );
        },
        onToggleMealEaten: (slotIndex, eaten) {
          if (slotIndex < todayEntries.length) {
            _savePlannedMeal(todayEntries[slotIndex].copyWith(isEaten: eaten));
          }
        },
        onOpenMealPlan: () => setState(() => _selectedIndex = 1),
        onGoToTab: (index) => setState(() => _selectedIndex = index),
        onOpenStreak: () => setState(() => _selectedIndex = 4),
        onNoWaste: _markNoWaste,
        onOpenInsight: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (navContext) => InsightScreen(
              currentSpent: currentSpent,
              weeklyBudget: _profile.weeklyBudget,
              onBack: () => Navigator.of(navContext).pop(),
            ),
          ),
        ),
      ),
      MealPlanScreen(
        key: _mealPlanKey,
        entries: _plan,
        meals: _meals,
        allergies: _profile.allergies,
        preferences: _profile.mealPreferences,
        onPreferencesChanged: _saveMealPreferences,
        goals: _nutritionGoals,
        focus: _nutritionFocus,
        weeklyBudget: _profile.weeklyBudget,
        onSave: _savePlannedMeal,
        onDelete: _deletePlannedMeal,
        onFocusChanged: (focus) => setState(() => _nutritionFocus = focus),
        onGoalsChanged: (goals) {
          final previous = _nutritionGoals;
          _applyWithUndo(
            'Target gizi disimpan',
            () => setState(() => _nutritionGoals = Map.of(goals)),
            () => setState(() => _nutritionGoals = previous),
          );
        },
        onAddToGrocery: _addRecipeGroceries,
      ),
      GroceryScreen(
        items: _grocery,
        weeklyBudget: _profile.weeklyBudget,
        onToggleItem: (id) {
          final index = _grocery.indexWhere((item) => item.id == id);
          if (index != -1) {
            final prev = _grocery[index].isChecked;
            _applyWithUndo(
              !prev ? 'Item belanja dicentang' : 'Item belanja batal dicentang',
              () {
                setState(() {
                  _grocery[index] = _grocery[index].copyWith(isChecked: !prev);
                });
              },
              () {
                setState(() {
                  _grocery[index] = _grocery[index].copyWith(isChecked: prev);
                });
              },
            );
          }
        },
        onAddItem: (item) {
          _applyWithUndo(
            '${item.name} ditambahkan ke daftar belanja',
            () => setState(() => _grocery.add(item)),
            () => setState(() => _grocery.removeWhere((g) => g.id == item.id)),
          );
        },
        onDeleteItem: (id) {
          final index = _grocery.indexWhere((item) => item.id == id);
          if (index == -1) return;
          final removed = _grocery[index];
          _applyWithUndo(
            '${removed.name} dihapus',
            () => setState(() => _grocery.removeAt(index)),
            () => setState(
              () => _grocery.insert(index.clamp(0, _grocery.length), removed),
            ),
          );
        },
        // FR-17: move checked grocery items into the pantry.
        onClearChecked: () {
          final prevGrocery = List<GroceryItem>.from(_grocery);
          final prevPantry = List<PantryItem>.from(_pantry);
          final checked = _grocery.where((g) => g.isChecked).toList();
          if (checked.isEmpty) return;
          final now = DateTime.now();
          _applyWithUndo(
            '${checked.length} item dipindahkan ke Pantry',
            () => setState(() {
              _grocery.removeWhere((g) => g.isChecked);
              _pantry.addAll(
                checked.map(
                  (g) => PantryItem(
                    id: 'p_${g.id}_${now.millisecondsSinceEpoch}',
                    name: g.name,
                    category: 'Lainnya',
                    quantity: g.quantity,
                    minQuantity: 0,
                    unit: g.unit,
                    expiryDate: now.add(const Duration(days: 7)),
                  ),
                ),
              );
            }),
            () => setState(() {
              _grocery
                ..clear()
                ..addAll(prevGrocery);
              _pantry
                ..clear()
                ..addAll(prevPantry);
            }),
          );
        },
        pantryView: PantryScreen(
          items: _pantry,
          onUpdateItem: (updated) {
            final index = _pantry.indexWhere((p) => p.id == updated.id);
            if (index == -1) return;
            setState(() => _pantry[index] = updated);
          },
        ),
      ),
      _buildAirWaste(
        water: WaterTrackerScreen(
        dailyTargetMl: _profile.waterTargetMl,
        currentWaterMl: todayWater,
        records: _waterRecords,
        onAddWater: (amount) {
          _applyWithUndo(
            '+$amount ml air berhasil dicatat',
            () {
              setState(() {
                _waterRecords.add(
                  WaterRecord(
                    id: 'w_${DateTime.now().millisecondsSinceEpoch}',
                    amountMl: amount,
                    time: DateTime.now(),
                  ),
                );
              });
            },
            () {
              setState(() {
                if (_waterRecords.isNotEmpty) {
                  _waterRecords.removeLast();
                }
              });
            },
          );
        },
      ),
        waste: FoodWasteScreen(
          records: _wasteRecords,
          onAddRecord: _addWasteRecord,
          onDeleteRecord: _deleteWasteRecord,
          pantryItems: _pantry,
          recentMeals: todayMeals,
          noWasteMarked: _dailyLogs.any(
            (log) =>
                sameDay(log.date, DateTime.now()) && log.noWasteMarked,
          ),
          onMarkNoWaste: _markNoWaste,
        ),
      ),
      ProfileScreen(
        profile: _profile,
        onUpdateProfile: _updateProfile,
        onResetData: _resetData,
        onOpenAchievements: _openAchievements,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();
    final extraTextHeight = MediaQuery.textScalerOf(context).scale(28) - 28;
    final appBarHeight = 64 + (extraTextHeight > 0 ? extraTextHeight : 0.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final windowSize = windowSizeFor(constraints.maxWidth);
        final isCompact = windowSize == WindowSize.compact;

        if (isCompact) {
          return Scaffold(
            appBar: SmartBitesAppBar(
              height: appBarHeight,
              subtitle: _titles[_selectedIndex],
              streakDays: 5,
            ),
            body: SafeArea(
              child: IndexedStack(index: _selectedIndex, children: screens),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: _destinations,
            ),
            floatingActionButton: _selectedIndex == 1 ? null : _buildFab(),
          );
        }

        return Scaffold(
          appBar: SmartBitesAppBar(
            height: appBarHeight,
            subtitle: _titles[_selectedIndex],
            streakDays: 5,
          ),
          body: SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: _railDestinations,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: screens),
                ),
              ],
            ),
          ),
          floatingActionButton: _selectedIndex == 1 ? null : _buildFab(),
        );
      },
    );
  }
}
