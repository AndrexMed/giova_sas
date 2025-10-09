// lib/presentation/notifiers/product_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../di/providers.dart';
import '../../domain/entities/product.dart';

/// Notifier para gestionar productos.
/// Controla la carga, creación, actualización y eliminación.
class ProductNotifier extends AsyncNotifier<List<Product>> {
  final _uuid = const Uuid();

  @override
  Future<List<Product>> build() async {
    final getAllProducts = ref.read(getAllProductsUseCaseProvider);
    return await getAllProducts.execute();
  }

  /// Recarga la lista de productos desde la base de datos.
  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final getAllProducts = ref.read(getAllProductsUseCaseProvider);
      final products = await getAllProducts.execute();
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Crea y guarda un nuevo producto.
  Future<void> createProduct({
    required String name,
    required double unitPrice,
    String? description,
    String? unit,
    String? category,
  }) async {
    final createProductUC = ref.read(createProductUseCaseProvider);

    await createProductUC.execute(
      id: _uuid.v4(),
      name: name,
      unitPrice: unitPrice,
      description: description,
      unit: unit,
      category: category,
    );

    await loadProducts();
  }

  /// Actualiza un producto existente.
  Future<void> updateProduct(Product product) async {
    final updateProductUC = ref.read(updateProductUseCaseProvider);
    await updateProductUC.execute(product);
    await loadProducts();
  }

  /// Elimina un producto por su ID.
  Future<void> deleteProduct(String id) async {
    final deleteProductUC = ref.read(deleteProductUseCaseProvider);
    await deleteProductUC.execute(id);
    await loadProducts();
  }
}

/// Provider que expone el ProductNotifier
final productNotifierProvider =
    AsyncNotifierProvider<ProductNotifier, List<Product>>(ProductNotifier.new);
