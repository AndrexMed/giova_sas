// lib/domain/entities/quotation_item.dart

/// Clase de Entidad pura que representa un Ítem dentro de una Cotización.
class QuotationItem {
  final String id;
  // NOTA: No necesitamos quotation_id aquí, se maneja en el Repositorio de Cotizaciones.
  final String?
  productId; // Puede ser nulo si el ítem es una descripción personalizada.
  final String description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double
  subtotal; // Este subtotal debe ser calculado: quantity * unitPrice
  final int position; // Para mantener el orden de los ítems

  QuotationItem({
    required this.id,
    this.productId,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.subtotal,
    required this.position,
  });

  QuotationItem copyWith({
    String? id,
    String? productId,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? subtotal,
    int? position,
  }) {
    return QuotationItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      position: position ?? this.position,
    );
  }
}
