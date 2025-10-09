import 'package:giova_sas/domain/entities/product.dart';
import 'package:giova_sas/domain/repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<void> execute(Product product) async {
    await repository.updateProduct(product);
  }
}
