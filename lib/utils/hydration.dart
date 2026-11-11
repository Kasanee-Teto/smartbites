import 'package:budget_bites/models/water_record.dart';
import 'package:budget_bites/utils/meal_planning.dart';

String formatHydration(double score) => score == score.roundToDouble()
    ? score.toStringAsFixed(0)
    : score.toStringAsFixed(1).replaceFirst('.', ',');

Iterable<WaterRecord> drinksOn(Iterable<WaterRecord> records, DateTime day) =>
    records.where((record) => sameDay(record.time, day));

double hydrationScore(Iterable<WaterRecord> records) =>
    records.fold<int>(0, (sum, record) {
      return sum + record.amountMl * record.category.creditPercent;
    }) /
    100;

int plainWaterMl(Iterable<WaterRecord> records) => records
    .where((record) => record.category == DrinkCategory.water)
    .fold(0, (sum, record) => sum + record.amountMl);

int hydrationStreak(List<WaterRecord> records, DateTime today, int goal) {
  if (goal <= 0) return 0;
  var day = hydrationScore(drinksOn(records, today)) >= goal
      ? calendarDay(today)
      : calendarDay(today, -1);
  var streak = 0;
  while (hydrationScore(drinksOn(records, day)) >= goal) {
    streak++;
    day = calendarDay(day, -1);
  }
  return streak;
}
