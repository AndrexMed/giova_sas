import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

/// Caso de uso para obtener la lista completa de productos.
class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  /// Invoca el caso de uso, retornando la lista directamente o lanzando una excepción.
  // Se cambia el tipo de retorno de Future<Either<Failure, List<Product>>> a Future<List<Product>>
  Future<List<Product>> execute() async {
    // Se asume que repository.getAllProducts() retorna List<Product> o lanza una excepción.
    final products = await repository.getAllProducts();

    // Lógica de dominio: ordenar los productos por nombre
    final sortedProducts = List<Product>.from(products);
    sortedProducts.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return sortedProducts;
  }
}
