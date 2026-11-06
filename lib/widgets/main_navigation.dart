// Owner: Louis | FR: FR-02, FR-29, FR-30

import 'dart:async';

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
import 'package:budget_bites/screens/grocery_screen.dart';
import 'package:budget_bites/screens/home_screen.dart';
import 'package:budget_bites/screens/insight_screen.dart';
import 'package:budget_bites/screens/meal_plan_screen.dart';
import 'package:budget_bites/screens/pantry_screen.dart';
import 'package:budget_bites/screens/profile_screen.dart';
import 'package:budget_bites/screens/water_tracker_screen.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/utils/streak_logic.dart';
import 'package:budget_bites/widgets/app_bar.dart';
import 'package:budget_bites/widgets/quick_log_sheet.dart';
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

  /// Memperbarui catatan [DailyLog] untuk hari ini berdasarkan data
  /// air minum (_waterRecords), makanan selesai (_plan), dan sisa makanan (_wasteRecords).
  void _recompute() {
    final today = calendarDay(DateTime.now());
    final todayWater = _waterRecords
        .where((w) => sameDay(w.time, today))
        .fold<int>(0, (sum, w) => sum + w.amountMl);
    final todayEatenIds = mealsOnDay(
      _plan,
      today,
    ).where((m) => m.isEaten).map((m) => m.mealId).toList();
    final todayWaste = _wasteRecords.any((w) => sameDay(w.date, today));

    final idx = _dailyLogs.indexWhere((log) => sameDay(log.date, today));
    final noWaste = idx >= 0 && _dailyLogs[idx].noWasteMarked;

    final updatedLog = DailyLog(
      date: today,
      waterMl: todayWater,
      mealsEaten: todayEatenIds,
      wasteLogged: todayWaste,
      noWasteMarked: noWaste,
    );

    if (hasActivity(updatedLog)) {
      if (idx >= 0) {
        _dailyLogs[idx] = updatedLog;
      } else {
        _dailyLogs.add(updatedLog);
      }
    } else {
      if (idx >= 0) {
        _dailyLogs.removeAt(idx);
      }
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
        _recompute();
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

  int _lastWaterMl = 250;

  void _handleLogWater(int amount) {
    setState(() => _lastWaterMl = amount);
    final now = DateTime.now();
    final waterRecord = WaterRecord(
      id: 'w_${now.millisecondsSinceEpoch}',
      amountMl: amount,
      time: now,
    );

    final label = amount == 150
        ? 'Cangkir'
        : (amount == 250 ? 'Gelas' : 'Botol');

    _applyWithUndo(
      '✓ Minum $amount ml ($label) berhasil dicatat!',
      () {
        setState(() {
          _waterRecords.add(waterRecord);
          _recompute();
        });
      },
      () {
        setState(() {
          _waterRecords.removeWhere((w) => w.id == waterRecord.id);
          _recompute();
        });
      },
    );
  }

  // TODO(Jessica): Hook to full meal diary in Step 6
  void _handleQuickMarkMealEaten(PlannedMeal plannedMeal) {
    _savePlannedMeal(plannedMeal.copyWith(isEaten: true));
  }

  // TODO(Edbert): Hook to full food waste tracker in Step 8
  void _handleQuickLogWaste(
    String itemName,
    String portion,
    int estimatedLoss,
  ) {
    final now = DateTime.now();
    final wasteRecord = WasteRecord(
      id: 'waste_${now.millisecondsSinceEpoch}',
      itemName: itemName,
      portion: portion,
      reason: 'Sisa makanan tak habis',
      estimatedLoss: estimatedLoss,
      date: now,
    );

    _applyWithUndo(
      '✓ Catatan sisa $itemName ($portion) tersimpan! (-${formatRupiah(estimatedLoss)})',
      () {
        setState(() {
          _wasteRecords.add(wasteRecord);
          _recompute();
        });
      },
      () {
        setState(() {
          _wasteRecords.removeWhere((w) => w.id == wasteRecord.id);
          _recompute();
        });
      },
    );
  }

  // TODO(Edbert): Hook to SDG 12.3 zero-waste streak in Step 8
  void _handleQuickNoWaste() {
    final today = calendarDay(DateTime.now());
    final index = _dailyLogs.indexWhere((log) => sameDay(log.date, today));
    final prevLog = index >= 0 ? _dailyLogs[index] : null;

    _applyWithUndo(
      '🌟 Hebat! Tidak ada sisa makanan hari ini (+1 Streak SDG 12.3)',
      () {
        setState(() {
          final idx = _dailyLogs.indexWhere((log) => sameDay(log.date, today));
          if (idx >= 0) {
            _dailyLogs[idx] = _dailyLogs[idx].copyWith(noWasteMarked: true);
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
          _recompute();
        });
      },
      () {
        setState(() {
          final currentIdx = _dailyLogs.indexWhere(
            (log) => sameDay(log.date, today),
          );
          if (prevLog != null) {
            if (currentIdx >= 0) {
              _dailyLogs[currentIdx] = prevLog;
            }
          } else {
            if (currentIdx >= 0) {
              _dailyLogs[currentIdx] = _dailyLogs[currentIdx].copyWith(
                noWasteMarked: false,
              );
            }
          }
          _recompute();
        });
      },
    );
  }

  void _openQuickLog() {
    final now = DateTime.now();
    final today = calendarDay(now);
    final todayEntries = mealsOnDay(_plan, today);
    final todayWater = _waterRecords
        .where((w) => sameDay(w.time, today))
        .fold<int>(0, (sum, w) => sum + w.amountMl);

    unawaited(
      showQuickLogSheet(
        context,
        dailyWaterTargetMl: _profile.waterTargetMl,
        currentWaterMl: todayWater,
        todayPlannedMeals: todayEntries,
        mealCatalog: _meals,
        onLogWater: _handleLogWater,
        onMarkMealEaten: _handleQuickMarkMealEaten,
        onLogWaste: _handleQuickLogWaste,
        onNoWaste: _handleQuickNoWaste,
        lastWaterMl: _lastWaterMl,
        pantryItems: _pantry,
        onOpenWasteForm: () => setState(() => _selectedIndex = 3),
      ),
    );
  }

  Widget _buildFab() {
    final colorScheme = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: Icon(Icons.bolt, color: colorScheme.onPrimary),
      label: Text(
        'Catat Cepat',
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: _openQuickLog,
    );
  }

  List<Widget> _buildScreens() {
    final today = calendarDay(DateTime.now());
    final currentStreak = calculateStreak(_dailyLogs, today);
    final streakLvl = streakLevel(currentStreak);
    final nextProgress = nextBadgeProgress(currentStreak);
    final todayLog = _dailyLogs
        .where((log) => sameDay(log.date, today))
        .firstOrNull;
    final isLoggedToday = todayLog != null && hasActivity(todayLog);

    // Current water total for today
    final todayWater = _waterRecords
        .where((item) => sameDay(item.time, today))
        .fold<int>(0, (sum, item) => sum + item.amountMl);

    // Current spend from checked grocery items
    final currentSpent = _grocery
        .where((item) => item.isChecked)
        .fold<int>(0, (sum, item) => sum + item.price);

    final mealMap = {for (final meal in _meals) meal.id: meal};
    final todayEntries = mealsOnDay(
      _plan,
      today,
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
        streakDays: currentStreak,
        streakLevelValue: streakLvl,
        nextTarget: nextProgress.target,
        streakProgress: nextProgress.progress,
        isLoggedToday: isLoggedToday,
        onQuickWaterAdd: _handleLogWater,
        onToggleMealEaten: (slotIndex, eaten) {
          if (slotIndex < todayEntries.length) {
            _savePlannedMeal(todayEntries[slotIndex].copyWith(isEaten: eaten));
          }
        },
        onOpenMealPlan: () => setState(() => _selectedIndex = 1),
        onGoToTab: (index) => setState(() => _selectedIndex = index),
        onOpenStreak: () => setState(() => _selectedIndex = 4),
        onNoWaste: _handleQuickNoWaste,
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
      WaterTrackerScreen(
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
      ProfileScreen(profile: _profile, onUpdateProfile: _updateProfile),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final today = calendarDay(DateTime.now());
    final currentStreak = calculateStreak(_dailyLogs, today);
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
              streakDays: currentStreak,
            ),
            body: SafeArea(
              child: IndexedStack(index: _selectedIndex, children: screens),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: _destinations,
            ),
            floatingActionButton: _buildFab(),
          );
        }

        return Scaffold(
          appBar: SmartBitesAppBar(
            height: appBarHeight,
            subtitle: _titles[_selectedIndex],
            streakDays: currentStreak,
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
          floatingActionButton: _buildFab(),
        );
      },
    );
  }
}
