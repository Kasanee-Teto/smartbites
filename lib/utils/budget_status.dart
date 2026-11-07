// Owner: Louis | FR: FR-04, FR-13
// Documented addition to PRD 9.1: Pure budget status calculation & weekly total

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/planned_meal.dart';

/// Status kesehatan anggaran makan mingguan.
/// - [hemat]: Pengeluaran berada di bawah atau sama dengan 90% dari anggaran.
/// - [pas]: Pengeluaran berada di antara 90% hingga 100% dari anggaran.
/// - [melebihi]: Pengeluaran telah melampaui 100% dari anggaran yang ditetapkan.
/// - [belumDiatur]: Anggaran belum ditentukan (nilai anggaran <= 0).
enum BudgetStatus { hemat, pas, melebihi, belumDiatur }

/// Fungsi murni untuk menentukan [BudgetStatus] berdasarkan pengeluaran dan anggaran.
///
/// Aturan:
/// - Jika [budget] <= 0, mengembalikan [BudgetStatus.belumDiatur].
/// - [spent] negatif akan di-clamp menjadi 0.
/// - Rasio pengeluaran (safeSpent / budget):
///   - Rasio <= 0.90 -> [BudgetStatus.hemat]
///   - Rasio > 0.90 dan <= 1.00 -> [BudgetStatus.pas]
///   - Rasio > 1.00 -> [BudgetStatus.melebihi]
BudgetStatus budgetStatus(int spent, int budget) {
  if (budget <= 0) {
    return BudgetStatus.belumDiatur;
  }

  final safeSpent = spent < 0 ? 0 : spent;
  final ratio = safeSpent / budget;

  if (ratio <= 0.90) {
    return BudgetStatus.hemat;
  }
  if (ratio <= 1.00) {
    return BudgetStatus.pas;
  }
  return BudgetStatus.melebihi;
}

/// Fungsi murni untuk menghitung total biaya rencana makan mingguan (FR-04, FR-13).
///
/// Menghitung akumulasi harga dari seluruh `mealId` yang ada di dalam:
/// 1. Matriks [weekPlan] berbentuk `List<List<String>>` (7 hari x N slot makan), ATAU
/// 2. Koleksi [weekPlan] bertipe `Iterable<PlannedMeal>`.
/// Berdasarkan katalog [meals].
///
/// Penanganan Edge Cases (Task 5):
/// - [weekPlan] null atau kosong, atau [meals] kosong -> mengembalikan 0.
/// - `mealId` yang tidak ditemukan dalam katalog -> diabaikan dengan aman (0).
/// - Harga makanan 0 atau bernilai negatif -> ditangani dengan aman tanpa crash.
/// - Porsi (`servings`) pada `PlannedMeal` jika <= 0 -> ditangani dengan aman.
int weeklyTotal(Object? weekPlan, List<Meal> meals) {
  if (weekPlan == null || meals.isEmpty) return 0;

  final priceMap = <String, int>{
    for (final meal in meals) meal.id: meal.price < 0 ? 0 : meal.price,
  };

  if (weekPlan is List<List<String>>) {
    if (weekPlan.isEmpty) return 0;
    var total = 0;
    for (final daySlots in weekPlan) {
      for (final mealId in daySlots) {
        total += priceMap[mealId] ?? 0;
      }
    }
    return total;
  }

  if (weekPlan is Iterable<PlannedMeal>) {
    var total = 0.0;
    for (final entry in weekPlan) {
      final price = priceMap[entry.mealId] ?? 0;
      if (price > 0) {
        final servings = entry.servings < 0 ? 0.0 : entry.servings;
        total += price * servings;
      }
    }
    return total.round();
  }

  if (weekPlan is Iterable) {
    if (weekPlan.isEmpty) return 0;
    var total = 0.0;
    for (final item in weekPlan) {
      if (item is Iterable<String>) {
        for (final mealId in item) {
          total += priceMap[mealId] ?? 0;
        }
      } else if (item is PlannedMeal) {
        final price = priceMap[item.mealId] ?? 0;
        if (price > 0) {
          final servings = item.servings < 0 ? 0.0 : item.servings;
          total += price * servings;
        }
      }
    }
    return total.round();
  }

  return 0;
}

/// Memeriksa apakah seluruh 21 slot makan (7 hari x 3 waktu makan) terisi penuh.
/// Diekspos melalui kontrak integrasi untuk evaluasi badge 'Perencana Handal' (FR-37).
bool isMealPlanFull(List<List<String>> weekPlan) {
  if (weekPlan.length < 7) return false;
  return weekPlan.every(
    (daySlots) => daySlots.length >= 3 && daySlots.every((id) => id.isNotEmpty),
  );
}

/// Memeriksa apakah rencana anggaran mingguan aman (total terencana > 0 dan <= budget mingguan).
/// Diekspos melalui kontrak integrasi untuk evaluasi badge 'Dompet Aman' (FR-37).
bool isBudgetSafe(int planTotal, int weeklyBudget) {
  return weeklyBudget > 0 && planTotal > 0 && planTotal <= weeklyBudget;
}
