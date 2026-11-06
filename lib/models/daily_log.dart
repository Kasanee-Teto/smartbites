// Owner: Louis | FR: FR-05, FR-36, FR-40

class DailyLog {
  DailyLog({
    required DateTime date,
    required this.waterMl,
    required this.mealsEaten,
    required this.wasteLogged,
    required this.noWasteMarked,
  }) : date = DateTime(date.year, date.month, date.day);
  final DateTime date;
  final int waterMl;
  final List<String> mealsEaten;
  final bool wasteLogged;
  final bool noWasteMarked;

  DailyLog copyWith({
    DateTime? date,
    int? waterMl,
    List<String>? mealsEaten,
    bool? wasteLogged,
    bool? noWasteMarked,
  }) {
    return DailyLog(
      date: date ?? this.date,
      waterMl: waterMl ?? this.waterMl,
      mealsEaten: mealsEaten ?? List<String>.from(this.mealsEaten),
      wasteLogged: wasteLogged ?? this.wasteLogged,
      noWasteMarked: noWasteMarked ?? this.noWasteMarked,
    );
  }
}
