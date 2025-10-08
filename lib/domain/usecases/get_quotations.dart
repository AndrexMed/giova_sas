import '../entities/quotation.dart';
import '../repositories/quotation_repository.dart';

/// Use Case: Obtiene una lista de todas las cotizaciones.
class GetQuotations {
  final QuotationRepository repository;

  GetQuotations(this.repository);

  /// Ejecuta la consulta al repositorio.
  Future<List<Quotation>> execute() {
    // Aquí se podría añadir lógica como filtrar por estado o fecha,
    // pero por ahora solo se pide la lista completa.
    return repository.getAllQuotations();
  }
}
