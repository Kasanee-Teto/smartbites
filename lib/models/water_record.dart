// Owner: Edbert | FR: FR-22, FR-23

class WaterRecord {
  const WaterRecord({
    required this.id,
    required this.amountMl,
    required this.time,
  });
  final String id;
  final int amountMl;
  final DateTime time;
}
