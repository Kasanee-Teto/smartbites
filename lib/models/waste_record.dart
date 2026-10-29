// Owner: Edbert | FR: FR-24, FR-25, FR-33, FR-34

class WasteRecord {
  const WasteRecord({
    required this.id,
    required this.itemName,
    required this.portion,
    required this.reason,
    required this.estimatedLoss,
    required this.date,
  });
  final String id;
  final String itemName;
  final String portion;
  final String reason;
  final int estimatedLoss;
  final DateTime date;
}
