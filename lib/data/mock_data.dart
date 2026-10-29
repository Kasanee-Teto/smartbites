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
final List<Meal> mockMeals = [
  const Meal(
    id: 'm1',
    name: 'Oatmeal Pisang Kayu Manis',
    category: 'Sarapan',
    imageAsset: 'assets/images/meal_oatmeal.png',
    price: 8000,
    calories: 310,
    cookTimeMinutes: 8,
    ingredients: [
      'Oatmeal 40g',
      'Pisang 1 buah',
      'Kayu Manis Bubuk',
      'Madu 1 sdm',
    ],
    allergens: [],
    steps: [
      'Masak oat dengan air',
      'Tambahkan irisan pisang dan madu',
      'Taburi kayu manis',
    ],
  ),
  const Meal(
    id: 'm2',
    name: 'Gado-Gado Komplit',
    category: 'Makan Siang',
    imageAsset: 'assets/images/meal_gado_gado.png',
    price: 15000,
    calories: 380,
    cookTimeMinutes: 20,
    ingredients: [
      'Tahu 100g',
      'Tempe 100g',
      'Bayam 1 ikat',
      'Tauge 50g',
      'Bumbu Kacang',
    ],
    allergens: ['Kacang'],
    steps: [
      'Rebus sayuran',
      'Goreng tahu dan tempe',
      'Sajikan dengan bumbu kacang',
    ],
  ),
  const Meal(
    id: 'm3',
    name: 'Ayam Panggang & Sayur Rebus',
    category: 'Makan Malam',
    imageAsset: 'assets/images/meal_ayam_panggang.png',
    price: 18000,
    calories: 420,
    cookTimeMinutes: 25,
    ingredients: [
      'Dada Ayam 150g',
      'Wortel 1 buah',
      'Buncis 50g',
      'Bawang Putih',
    ],
    allergens: [],
    steps: [
      'Marinasi ayam dengan bawang putih',
      'Panggang hingga matang',
      'Rebus wortel dan buncis',
    ],
  ),
  const Meal(
    id: 'm4',
    name: 'Nasi Goreng Telur Sayur',
    category: 'Sarapan',
    imageAsset: 'assets/images/meal_nasi_goreng.png',
    price: 10000,
    calories: 390,
    cookTimeMinutes: 12,
    ingredients: [
      'Nasi Putih 150g',
      'Telur 1 butir',
      'Sawi Hijau',
      'Kecap Manis',
    ],
    allergens: ['Telur'],
    steps: [
      'Tumis bumbu dan telur',
      'Masukkan nasi dan sawi',
      'Bumbui dengan kecap dan garam',
    ],
  ),
  const Meal(
    id: 'm5',
    name: 'Sup Tahu Bayam',
    category: 'Makan Siang',
    imageAsset: 'assets/images/meal_sup_tahu.png',
    price: 9000,
    calories: 250,
    cookTimeMinutes: 15,
    ingredients: [
      'Tahu Putih 2 kotak',
      'Bayam 1 ikat',
      'Bawang Putih 2 siung',
      'Kaldu',
    ],
    allergens: ['Kedelai'],
    steps: [
      'Didihkan air kaldu',
      'Masukkan bawang putih dan tahu',
      'Tambahkan bayam sesaat sebelum diangkat',
    ],
  ),
  const Meal(
    id: 'm6',
    name: 'Tumis Buncis Tempe',
    category: 'Makan Malam',
    imageAsset: 'assets/images/meal_tumis_buncis.png',
    price: 8500,
    calories: 280,
    cookTimeMinutes: 15,
    ingredients: [
      'Buncis 100g',
      'Tempe 100g',
      'Bawang Merah 3 siung',
      'Cabai Merah 1 buah',
    ],
    allergens: ['Kedelai'],
    steps: [
      'Potong tempe dan buncis',
      'Tumis bumbu iris',
      'Masukkan tempe dan buncis hingga empuk',
    ],
  ),
];

// 7 Hari x 3 Waktu Makan (Sarapan, Makan Siang, Makan Malam)
final List<List<String>> mockWeekPlan = [
  ['m1', 'm2', 'm3'], // Senin
  ['m4', 'm5', 'm6'], // Selasa
  ['m1', 'm2', 'm3'], // Rabu
  ['m4', 'm5', 'm6'], // Kamis
  ['m1', 'm2', 'm3'], // Jumat
  ['m4', 'm5', 'm6'], // Sabtu
  ['m1', 'm2', 'm3'], // Minggu
];

// 7 Hari x 3 Status Selesai Makan (Senin siang belum, Senin sarapan sudah)
final List<List<bool>> mockEaten = [
  [true, false, false], // Senin
  [false, false, false], // Selasa
  [false, false, false], // Rabu
  [false, false, false], // Kamis
  [false, false, false], // Jumat
  [false, false, false], // Sabtu
  [false, false, false], // Minggu
];

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
  ),
  GroceryItem(
    id: 'g5',
    name: 'Mie Instan Goreng',
    quantity: 5,
    unit: 'bungkus',
    price: 15000,
  ),
  GroceryItem(
    id: 'g6',
    name: 'Bawang Merah',
    quantity: 250,
    unit: 'g',
    price: 9000,
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
final List<WaterRecord> mockWaterRecords = [
  WaterRecord(id: 'w1', amountMl: 250, time: DateTime(2026, 10, 19, 8)),
  WaterRecord(id: 'w2', amountMl: 250, time: DateTime(2026, 10, 19, 11, 30)),
  WaterRecord(id: 'w3', amountMl: 250, time: DateTime(2026, 10, 19, 14, 15)),
];

final List<WasteRecord> mockWasteRecords = [
  WasteRecord(
    id: 'wr1',
    itemName: 'Sawi Putih',
    portion: '1/4 porsi',
    reason: 'Beli Kebanyakan',
    estimatedLoss: 3000,
    date: DateTime(2026, 10, 18),
  ),
  WasteRecord(
    id: 'wr2',
    itemName: 'Nasi Putih',
    portion: '1/2 porsi',
    reason: 'Sisa Piring',
    estimatedLoss: 2500,
    date: DateTime(2026, 10, 17),
  ),
];

const UserProfile mockUserProfile = UserProfile(
  weeklyBudget: 300000,
  waterTargetMl: 2000,
  allergies: ['Kacang'],
  preferences: ['Hemat', 'Tinggi Protein'],
);

final List<Achievement> mockAchievements = [
  const Achievement(
    id: 'a1',
    title: 'Pahlawan Pangan',
    description: 'Catat food waste 3 hari berturut-turut',
    iconAsset: 'assets/icons/badge_waste.png',
    target: 3,
    progress: 3,
    isUnlocked: true,
  ),
  const Achievement(
    id: 'a2',
    title: 'Master Hemat',
    description: 'Belanja mingguan di bawah target budget',
    iconAsset: 'assets/icons/badge_budget.png',
    target: 1,
    progress: 1,
    isUnlocked: true,
  ),
  const Achievement(
    id: 'a3',
    title: 'Hidrasi Disiplin',
    description: 'Capai target minum 2000 ml selama 5 hari',
    iconAsset: 'assets/icons/badge_water.png',
    target: 5,
    progress: 5,
    isUnlocked: true,
  ),
  const Achievement(
    id: 'a4',
    title: 'Disiplin 7 Hari',
    description: 'Pertahankan catatan harian selama 7 hari berturut-turut',
    iconAsset: 'assets/icons/badge_streak.png',
    target: 7,
    progress: 5,
  ),
];

// ===== DAILY LOG (Louis) =====
final List<DailyLog> mockDailyLogs = [
  DailyLog(
    date: DateTime(2026, 10, 17),
    waterMl: 2000,
    mealsEaten: ['m1', 'm2', 'm3'],
    wasteLogged: true,
    noWasteMarked: false,
  ),
  DailyLog(
    date: DateTime(2026, 10, 18),
    waterMl: 2000,
    mealsEaten: ['m4', 'm5', 'm6'],
    wasteLogged: true,
    noWasteMarked: false,
  ),
  DailyLog(
    date: DateTime(2026, 10, 19),
    waterMl: 750,
    mealsEaten: ['m1'],
    wasteLogged: false,
    noWasteMarked: false,
  ),
];
