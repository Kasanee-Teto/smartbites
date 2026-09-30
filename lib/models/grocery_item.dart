// Owner: Gilbert | FR: FR-14, FR-15, FR-16, FR-17

class GroceryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final int price;
  final bool isChecked;

  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    this.isChecked = false,
  });

  GroceryItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    int? price,
    bool? isChecked,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
