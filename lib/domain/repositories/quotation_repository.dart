import '../entities/quotation.dart';
import '../entities/quotation_item.dart';

/// Clase abstracta (Interface) que define el contrato de lo que un Repositorio de Cotizaciones debe hacer.
abstract class QuotationRepository {
  /// Obtiene una cotización completa (incluyendo sus ítems) por ID.
  Future<Quotation?> getQuotationById(String id);

  /// Obtiene todas las cotizaciones (sin sus ítems).
  Future<List<Quotation>> getAllQuotations();

  /// Guarda una nueva cotización y todos sus ítems en una sola transacción.
  Future<void> saveQuotation(Quotation quotation);

  /// Actualiza la cotización y todos sus ítems en una sola transacción.
  Future<void> updateQuotation(Quotation quotation);

  /// Elimina una cotización y todos sus ítems relacionados.
  Future<void> deleteQuotation(String id);

  /// Obtiene solo los ítems de una cotización específica.
  Future<List<QuotationItem>> getItemsByQuotationId(String quotationId);

  /// Cuenta cuántas cotizaciones usan un producto específico.
  Future<int> countQuotationsUsingProduct(String productId);

  /// Cuenta cuántas cotizaciones tiene un cliente específico.
  Future<int> countQuotationsByClient(String clientId);
}
