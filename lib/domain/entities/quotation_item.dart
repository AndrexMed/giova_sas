// lib/domain/entities/quotation_item.dart

import 'package:equatable/equatable.dart';

class QuotationItem extends Equatable {
  final String id;
  final String? productId;
  final String description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double subtotal;
  final int position;

  const QuotationItem({
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

  @override
  List<Object?> get props => [
    id,
    productId,
    description,
    quantity,
    unit,
    unitPrice,
    subtotal,
    position,
  ];
}
