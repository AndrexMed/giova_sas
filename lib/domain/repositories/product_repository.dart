// lib/domain/repositories/product_repository.dart

import '../entities/product.dart';

/// Contrato (Interface) para el manejo de Productos y Servicios.
/// Define las operaciones CRUD que deben ser implementadas en la Capa de Datos.
abstract class ProductRepository {
  /// Obtiene todos los productos.
  Future<List<Product>> getProducts();

  /// Obtiene un producto por su ID.
  Future<Product?> getProductById(String id);

  /// Guarda un nuevo producto.
  Future<void> saveProduct(Product product);

  /// Actualiza la información de un producto existente.
  Future<void> updateProduct(Product product);

  /// Elimina un producto por su ID.
  Future<void> deleteProduct(String id);
}
