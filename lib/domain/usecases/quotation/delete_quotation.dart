import 'package:giova_sas/domain/repositories/quotation_repository.dart';

class DeleteQuotation {
  final QuotationRepository repository;
  DeleteQuotation(this.repository);

  Future<void> execute(String id) async => await repository.deleteQuotation(id);
}
