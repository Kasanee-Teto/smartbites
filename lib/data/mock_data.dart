// Owner: Shared (Louis, Jesseca, Gilbert, Edbert) | FR: FR-01..40

import 'package:budget_bites/models/achievement.dart';
import 'package:budget_bites/models/daily_log.dart';
import 'package:budget_bites/models/grocery_item.dart';
import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/pantry_item.dart';
import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/models/waste_record.dart';
import 'package:budget_bites/models/water_record.dart';

// ===== MEAL (Jesseca) =====
const List<Meal> mockMeals = [];

// ===== GROCERY / PANTRY (Gilbert) =====
const List<GroceryItem> mockGroceryItems = [];
const List<PantryItem> mockPantryItems = [];

// ===== WATER / WASTE / PROFILE / BADGES (Edbert) =====
const List<WaterRecord> mockWaterRecords = [];
const List<WasteRecord> mockWasteRecords = [];
const List<Achievement> mockAchievements = [];
const UserProfile mockUserProfile = UserProfile(
  weeklyBudget: 300000,
  waterTargetMl: 2000,
  allergies: [],
  preferences: [],
  darkMode: false,
);

// ===== DAILY LOG (Louis) =====
const List<DailyLog> mockDailyLogs = [];
