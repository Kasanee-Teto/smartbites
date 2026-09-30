// Owner: Louis | FR: FR-05, FR-36, FR-40

class DailyLog {
  final DateTime date;
  final int waterMl;
  final List<String> mealsEaten;
  final bool wasteLogged;
  final bool noWasteMarked;

  const DailyLog({
    required this.date,
    required this.waterMl,
    required this.mealsEaten,
    required this.wasteLogged,
    required this.noWasteMarked,
  });
}
