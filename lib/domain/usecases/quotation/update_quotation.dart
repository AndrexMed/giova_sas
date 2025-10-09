import 'package:giova_sas/domain/entities/quotation.dart';
import 'package:giova_sas/domain/repositories/quotation_repository.dart';

class UpdateQuotation {
  final QuotationRepository repository;
  UpdateQuotation(this.repository);

  Future<void> execute(Quotation quotation) async =>
      await repository.updateQuotation(quotation);
}
