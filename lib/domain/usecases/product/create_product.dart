// lib/domain/usecases/create_product.dart

import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<void> execute({
    required String id,
    required String name,
    required double unitPrice,
    String? description,
    String? unit,
    String? category,
  }) async {
    final product = Product(
      id: id,
      name: name,
      unitPrice: unitPrice,
      description: description,
      unit: unit!,
      category: category,
      createdAt: DateTime.now(),
    );
    await repository.saveProduct(product);
  }
}
