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
const List<GroceryItem> mockGroceryItems = [
  GroceryItem(
    id: 'g1',
    name: 'Telur Ayam',
    quantity: 1,
    unit: 'kg',
    price: 28000,
    isChecked: true,
  ),
  GroceryItem(
    id: 'g2',
    name: 'Beras Ramos',
    quantity: 5,
    unit: 'kg',
    price: 68000,
    isChecked: false,
  ),
  GroceryItem(
    id: 'g3',
    name: 'Tempe Balok',
    quantity: 2,
    unit: 'papan',
    price: 6000,
    isChecked: true,
  ),
  GroceryItem(
    id: 'g4',
    name: 'Tahu Putih',
    quantity: 1,
    unit: 'bungkus',
    price: 4000,
    isChecked: false,
  ),
  GroceryItem(
    id: 'g5',
    name: 'Mie Instan Goreng',
    quantity: 5,
    unit: 'bungkus',
    price: 15000,
    isChecked: false,
  ),
  GroceryItem(
    id: 'g6',
    name: 'Bawang Merah',
    quantity: 250,
    unit: 'g',
    price: 9000,
    isChecked: false,
  ),
  GroceryItem(
    id: 'g7',
    name: 'Cabai Rawit Merah',
    quantity: 150,
    unit: 'g',
    price: 7500,
    isChecked: true,
  ),
  GroceryItem(
    id: 'g8',
    name: 'Kangkung Segar',
    quantity: 2,
    unit: 'ikat',
    price: 5000,
    isChecked: false,
  ),
];

final List<PantryItem> mockPantryItems = [
  PantryItem(
    id: 'p1',
    name: 'Telur Ayam',
    category: 'Protein',
    quantity: 4,
    minQuantity: 6,
    unit: 'butir',
    expiryDate: DateTime(2026, 10, 24),
  ),
  PantryItem(
    id: 'p2',
    name: 'Tahu Kuning',
    category: 'Protein',
    quantity: 5,
    minQuantity: 2,
    unit: 'potong',
    expiryDate: DateTime(2026, 10, 16),
  ),
  PantryItem(
    id: 'p3',
    name: 'Bayam Segar',
    category: 'Sayuran',
    quantity: 1,
    minQuantity: 1,
    unit: 'ikat',
    expiryDate: DateTime(2026, 10, 12),
  ),
  PantryItem(
    id: 'p4',
    name: 'Wortel',
    category: 'Sayuran',
    quantity: 3,
    minQuantity: 2,
    unit: 'buah',
    expiryDate: DateTime(2026, 10, 20),
  ),
  PantryItem(
    id: 'p5',
    name: 'Bawang Putih',
    category: 'Bumbu',
    quantity: 50,
    minQuantity: 100,
    unit: 'g',
    expiryDate: DateTime(2026, 11, 10),
  ),
  PantryItem(
    id: 'p6',
    name: 'Beras Pulen',
    category: 'Pokok',
    quantity: 3,
    minQuantity: 1,
    unit: 'kg',
    expiryDate: DateTime(2026, 12, 15),
  ),
  PantryItem(
    id: 'p7',
    name: 'Mie Telur',
    category: 'Pokok',
    quantity: 1,
    minQuantity: 2,
    unit: 'bungkus',
    expiryDate: DateTime(2026, 10, 15),
  ),
  PantryItem(
    id: 'p8',
    name: 'Susu UHT Cokelat',
    category: 'Minuman',
    quantity: 2,
    minQuantity: 1,
    unit: 'kotak',
    expiryDate: DateTime(2026, 10, 13),
  ),
];

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
