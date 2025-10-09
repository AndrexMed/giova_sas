import 'package:giova_sas/domain/repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;
  DeleteProduct(this.repository);
  Future<void> execute(String id) async {
    await repository.deleteProduct(id);
  }
}
