// Owner: Gilbert | FR: FR-18, FR-19, FR-20, FR-21

class PantryItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final double minQuantity;
  final String unit;
  final DateTime expiryDate;

  const PantryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minQuantity,
    required this.unit,
    required this.expiryDate,
  });

  PantryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    double? minQuantity,
    String? unit,
    DateTime? expiryDate,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
