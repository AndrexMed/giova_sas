import 'package:uuid/uuid.dart';

import '../entities/quotation.dart';
import '../entities/quotation_item.dart';
import '../repositories/quotation_repository.dart';
import 'calculate_quotation_total.dart'; // Necesitamos el use case de cálculo

/// Use Case: Crea una nueva cotización, calcula sus totales y la guarda.
class CreateQuotation {
  final QuotationRepository quotationRepository;
  final CalculateQuotationTotal calculateTotal;
  final Uuid uuid;

  CreateQuotation({
    required this.quotationRepository,
    required this.calculateTotal,
    Uuid? uuid,
  }) : this.uuid = uuid ?? const Uuid();

  /// Ejecuta la creación de la cotización.
  Future<void> execute({
    required String clientId,
    required String clientName,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    required DateTime issueDate,
    required DateTime validUntil,
    required double taxPercentage,
    required double discountPercentage,
    required List<QuotationItem> items,
    String? notes,
    String? termsConditions,
  }) async {
    // 1. Generar un ID único para la nueva cotización.
    final quotationId = uuid.v4();

    // 2. Calcular los totales finales antes de guardar.
    final calculation = calculateTotal.execute(
      items: items,
      taxPercentage: taxPercentage,
      discountPercentage: discountPercentage,
    );

    // 3. Crear la entidad Quotation final.
    final now = DateTime.now();
    final newQuotation = Quotation(
      id: quotationId,
      quotationNumber: _generateQuotationNumber(
        now,
      ), // Lógica para el número de cotización
      clientId: clientId,
      clientName: clientName,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      clientAddress: clientAddress,
      issueDate: issueDate,
      validUntil: validUntil,
      subtotal: calculation.subtotal,
      taxPercentage: taxPercentage,
      taxAmount: calculation.taxAmount,
      discountPercentage: discountPercentage,
      discountAmount: calculation.discountAmount,
      total: calculation.total,
      status: 'Draft', // Estado inicial
      notes: notes,
      termsConditions: termsConditions,
      createdAt: now,
      updatedAt: now,
      // Los items deben tener el quotationId asignado si lo necesitara el repositorio,
      // pero aquí solo se pasan los ítems tal cual están listos.
      items: items
          .map(
            (item) => item.copyWith(
              id: item.id.isEmpty
                  ? uuid.v4()
                  : item.id, // Asegura que cada item tenga ID
            ),
          )
          .toList(),
    );

    // 4. Guardar la cotización completa (incluyendo ítems) a través del repositorio.
    await quotationRepository.saveQuotation(newQuotation);
  }

  /// NOTA: Esta es una lógica simple de ejemplo. Podría ser un Use Case aparte.
  String _generateQuotationNumber(DateTime date) {
    // Ejemplo: Q-YYYYMMDD-UUIDCorto
    final dateStr =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return 'Q-$dateStr-${uuid.v4().substring(0, 4).toUpperCase()}';
  }
}
