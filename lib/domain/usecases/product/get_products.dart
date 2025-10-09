// lib/domain/usecases/get_products.dart

import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

/// Use Case: Obtiene la lista completa de productos disponibles.
class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> execute() {
    return repository.getAllProducts();
  }
}
