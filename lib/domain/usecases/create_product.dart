// lib/domain/usecases/create_product.dart

import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Use Case: Se encarga de crear un nuevo producto en el repositorio.
class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<void> execute(Product product) async {
    await repository.saveProduct(product);
  }
}
