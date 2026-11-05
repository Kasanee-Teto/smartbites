// Owner: Louis | FR: FR-04
// Documented addition to PRD 9.1: Pure budget status calculation & weekly total

import 'package:budget_bites/models/meal.dart';

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
/// Menghitung akumulasi harga dari seluruh `mealId` yang ada di dalam matriks
/// [weekPlan] (7 hari x N slot makan) berdasarkan katalog [meals].
int weeklyTotal(List<List<String>> weekPlan, List<Meal> meals) {
  if (weekPlan.isEmpty || meals.isEmpty) return 0;

  final priceMap = <String, int>{for (final meal in meals) meal.id: meal.price};

  var total = 0;
  for (final daySlots in weekPlan) {
    for (final mealId in daySlots) {
      total += priceMap[mealId] ?? 0;
    }
  }
  return total;
}
