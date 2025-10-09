import 'package:uuid/uuid.dart';
import '../../entities/quotation.dart';
import '../../repositories/quotation_repository.dart';
import 'calculate_quotation_total.dart';

/// Use Case: Crea una nueva cotización, calcula sus totales y la guarda.
class CreateQuotation {
  final QuotationRepository quotationRepository;
  final CalculateQuotationTotal calculateTotal;
  final Uuid uuid;

  CreateQuotation({
    required this.quotationRepository,
    required this.calculateTotal,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  /// Recibe directamente el objeto [Quotation] desde la UI o el notifier.
  Future<void> execute(Quotation quotation) async {
    final now = DateTime.now();

    // 1. Si no tiene ID, se lo generamos.
    final quotationId = quotation.id.isEmpty ? uuid.v4() : quotation.id;

    // 2. Calcular los totales con los ítems actuales.
    final calc = calculateTotal.execute(
      items: quotation.items,
      taxPercentage: quotation.taxPercentage,
      discountPercentage: quotation.discountPercentage,
    );

    // 3. Crear la versión final del objeto lista para guardar.
    final finalQuotation = quotation.copyWith(
      id: quotationId,
      quotationNumber: quotation.quotationNumber.isEmpty
          ? _generateQuotationNumber(now)
          : quotation.quotationNumber,
      subtotal: calc.subtotal,
      taxAmount: calc.taxAmount,
      discountAmount: calc.discountAmount,
      total: calc.total,
      createdAt: quotation.createdAt.isBefore(now) ? quotation.createdAt : now,
      updatedAt: now,
      items: quotation.items.map((item) {
        return item.copyWith(id: item.id.isEmpty ? uuid.v4() : item.id);
      }).toList(),
    );

    // 4. Guardar en base de datos usando el repositorio.
    await quotationRepository.saveQuotation(finalQuotation);
  }

  /// Genera un número de cotización legible.
  String _generateQuotationNumber(DateTime date) {
    final dateStr =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return 'Q-$dateStr-${uuid.v4().substring(0, 4).toUpperCase()}';
  }
}
