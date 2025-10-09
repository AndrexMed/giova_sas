// lib/data/repositories/product_repository_impl.dart

import 'package:sqflite/sqflite.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../datasources/database_helper.dart'; // Asegúrate de que esta ruta sea correcta
// NO necesitamos importar ProductModel si mapeamos directamente a la Entidad
// import '../models/product_model.dart';

/// Implementación concreta del contrato ProductRepository usando SQFlite.
class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper dbHelper;
  static const String _tableName = 'products';

  ProductRepositoryImpl(this.dbHelper);

  // --- Mappers ---

  /// Convierte un Map de la DB a una Entidad Product.
  Product _productFromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      unit: map['unit'] as String,
      unitPrice: (map['unit_price'] ?? map['price']) is int
          ? (map['unit_price'] ?? map['price']).toDouble()
          : (map['unit_price'] ?? map['price']) as double,
      category: map['category'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convierte una Entidad Product a un Map para la DB.
  Map<String, dynamic> _productToMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'unit': product.unit,
      'unit_price': product.unitPrice,
      'category': product.category,
      'created_at': product.createdAt.toIso8601String(),
    };
  }

  // --- Implementación de Métodos ---

  @override
  Future<void> saveProduct(Product product) async {
    try {
      final db = await dbHelper.database;

      await db.insert(
        _tableName,
        _productToMap(product),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error al guardar el producto: $e');
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return _productFromMap(maps.first);
    } catch (e) {
      throw Exception('Error al obtener el producto con ID $id: $e');
    }
  }

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'name ASC',
      );

      // Usando el mapper interno, igual que en ClientRepositoryImpl
      return maps.map((map) => _productFromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener todos los productos: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      final db = await dbHelper.database;

      final rowsAffected = await db.update(
        _tableName,
        _productToMap(product),
        where: 'id = ?',
        whereArgs: [product.id],
      );

      if (rowsAffected == 0) {
        throw Exception(
          'Producto no encontrado para actualizar (ID: ${product.id})',
        );
      }
    } catch (e) {
      throw Exception('Error al actualizar el producto: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final db = await dbHelper.database;

      final rowsAffected = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw Exception('Producto no encontrado para eliminar (ID: $id)');
      }
    } catch (e) {
      throw Exception('Error al eliminar el producto: $e');
    }
  }
}
