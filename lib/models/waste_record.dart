// Owner: Edbert | FR: FR-24, FR-25, FR-33, FR-34

class WastePortions {
  WastePortions._();

  static const String sedikit = 'Sedikit';
  static const String setengah = 'Setengah';
  static const String semua = 'Semua';

  static const List<String> all = [sedikit, setengah, semua];

  /// Pecahan dari harga penuh item.
  static double fractionOf(String portion) {
    switch (portion) {
      case sedikit:
        return 0.25;
      case setengah:
        return 0.5;
      case semua:
        return 1;
      default:
        return 1;
    }
  }

  static int estimateLoss(String portion, int fullPrice) =>
      (fullPrice * fractionOf(portion)).round();
}

class WasteRecord {
  const WasteRecord({
    required this.id,
    required this.itemName,
    required this.portion,
    required this.estimatedLoss,
    required this.date,
    this.reason = '',
  });

  final String id;
  final String itemName;
  final String portion;
  final String reason;
  final int estimatedLoss;
  final DateTime date;
}
