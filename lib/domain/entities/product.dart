class Product {
  final String id;
  final String name;
  final String? description;
  final double unitPrice; // REAL NOT NULL en la BD
  final String unit; // Unidad de medida (ej: 'unidad', 'hora', 'kg')
  final String? category;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.unitPrice,
    required this.unit,
    this.category,
    required this.createdAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? unitPrice,
    String? unit,
    String? category,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
