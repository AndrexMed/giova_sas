import '../../entities/quotation_item.dart';

/// Define la estructura para el resultado de un cálculo de cotización.
class CalculationResult {
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double total;

  CalculationResult({
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.total,
  });
}

/// Use Case: Se encarga de calcular el total, impuestos y descuentos de una cotización.
class CalculateQuotationTotal {
  /// Ejecuta el cálculo.
  /// Toma una lista de ítems, el porcentaje de impuesto y el porcentaje de descuento.
  CalculationResult execute({
    required List<QuotationItem> items,
    required double taxPercentage,
    required double discountPercentage,
  }) {
    // 1. Calcular el subtotal total sumando los subtotales de cada ítem.
    // El subtotal de cada item debe ser calculado previamente (cantidad * precio_unitario)
    final totalSubtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);

    // 2. Calcular el monto del descuento sobre el subtotal.
    final discountFactor = discountPercentage / 100.0;
    final calculatedDiscountAmount = totalSubtotal * discountFactor;

    // Subtotal después de aplicar el descuento (base para el impuesto).
    final subtotalAfterDiscount = totalSubtotal - calculatedDiscountAmount;

    // 3. Calcular el monto del impuesto (IVA, etc.)
    final taxFactor = taxPercentage / 100.0;
    final calculatedTaxAmount = subtotalAfterDiscount * taxFactor;

    // 4. Calcular el total final.
    final calculatedTotal = subtotalAfterDiscount + calculatedTaxAmount;

    return CalculationResult(
      subtotal: totalSubtotal,
      taxAmount: calculatedTaxAmount,
      discountAmount: calculatedDiscountAmount,
      total: calculatedTotal,
    );
  }
}
