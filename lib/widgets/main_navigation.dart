// Owner: Louis | FR: FR-02, FR-29, FR-30

import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/achievement.dart';
import 'package:budget_bites/models/daily_log.dart';
import 'package:budget_bites/models/grocery_item.dart';
import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/pantry_item.dart';
import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/models/waste_record.dart';
import 'package:budget_bites/models/water_record.dart';
import 'package:budget_bites/screens/grocery_screen.dart';
import 'package:budget_bites/screens/home_screen.dart';
import 'package:budget_bites/screens/meal_plan_screen.dart';
import 'package:budget_bites/screens/profile_screen.dart';
import 'package:budget_bites/screens/water_tracker_screen.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/app_bar.dart';
import 'package:flutter/material.dart';

/// Single source of truth for all shared application data (FR-02).
/// All shared state lives in [_MainNavigationState] and flows down
/// via constructors and callbacks.
class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  // Single source of truth parent state variables
  late UserProfile _profile;
  late List<Meal> _meals;
  late List<List<String>> _weekPlan;
  late List<List<bool>> _eaten;
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
    _weekPlan = mockWeekPlan.map((day) => List<String>.from(day)).toList();
    _eaten = mockEaten.map((day) => List<bool>.from(day)).toList();
    _grocery = List<GroceryItem>.from(mockGroceryItems);
    _pantry = List<PantryItem>.from(mockPantryItems);
    _waterRecords = List<WaterRecord>.from(mockWaterRecords);
    _wasteRecords = List<WasteRecord>.from(mockWasteRecords);
    _dailyLogs = List<DailyLog>.from(mockDailyLogs);
    _achievements = List<Achievement>.from(mockAchievements);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Private helper that executes an action and displays a floating SnackBar
  /// with an "Urungkan" action button to revert the change safely.
  void _applyWithUndo(
    String message,
    VoidCallback apply,
    VoidCallback revert,
  ) {
    apply();
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
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
    return FloatingActionButton.extended(
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

    // Today meals (e.g. Day 0: Senin)
    final todayMealIds = _weekPlan.isNotEmpty ? _weekPlan[0] : <String>[];
    final todayMeals = todayMealIds
        .map(
          (id) => _meals.firstWhere(
            (m) => m.id == id,
            orElse: () => _meals.first,
          ),
        )
        .toList();
    final todayEaten =
        _eaten.isNotEmpty ? _eaten[0] : <bool>[false, false, false];

    // Reference pantry, waste records, and achievements for child screen integration
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
          final prev = _eaten[0][slotIndex];
          _applyWithUndo(
            eaten ? 'Menu ditandai selesai dimakan' : 'Tanda makan dibatalkan',
            () {
              setState(() {
                _eaten[0][slotIndex] = eaten;
              });
            },
            () {
              setState(() {
                _eaten[0][slotIndex] = prev;
              });
            },
          );
        },
        onOpenMealPlan: () => setState(() => _selectedIndex = 1),
      ),
      MealPlanScreen(
        weekPlan: _weekPlan,
        eaten: _eaten,
        meals: _meals,
        weeklyBudget: _profile.weeklyBudget,
        onToggleMealEaten: (dayIndex, slotIndex, eaten) {
          final prev = _eaten[dayIndex][slotIndex];
          _applyWithUndo(
            eaten ? 'Menu ditandai sudah dimakan' : 'Tanda makan dibatalkan',
            () {
              setState(() {
                _eaten[dayIndex][slotIndex] = eaten;
              });
            },
            () {
              setState(() {
                _eaten[dayIndex][slotIndex] = prev;
              });
            },
          );
        },
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
      ProfileScreen(
        profile: _profile,
        onUpdateProfile: (newProfile) {
          final prev = _profile;
          _applyWithUndo(
            'Profil berhasil diperbarui',
            () {
              setState(() {
                _profile = newProfile;
              });
            },
            () {
              setState(() {
                _profile = prev;
              });
            },
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();

    return LayoutBuilder(
      builder: (context, constraints) {
        final windowSize = windowSizeFor(constraints.maxWidth);
        final isCompact = windowSize == WindowSize.compact;

        if (isCompact) {
          return Scaffold(
            appBar: SmartBitesAppBar(
              subtitle: _titles[_selectedIndex],
              streakDays: 5,
            ),
            body: SafeArea(
              child: IndexedStack(
                index: _selectedIndex,
                children: screens,
              ),
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
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: screens,
                  ),
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
