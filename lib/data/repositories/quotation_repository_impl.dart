import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/quotation.dart';
import '../../domain/entities/quotation_item.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../datasources/database_helper.dart';

/// Implementación del contrato QuotationRepository usando DatabaseHelper (sqflite).
class QuotationRepositoryImpl implements QuotationRepository {
  final DatabaseHelper _dbHelper;
  final String _quotationTable = 'quotations';
  final String _itemsTable = 'quotation_items';

  QuotationRepositoryImpl(this._dbHelper);

  // --- Mappers ---

  /// Convierte un Map (resultado de la BD) en una Entidad QuotationItem.
  QuotationItem _itemFromMap(Map<String, dynamic> map) {
    return QuotationItem(
      id: map['id'] as String,
      productId: map['product_id'] as String?,
      description: map['description'] as String,
      quantity: map['quantity'] as double,
      unit: map['unit'] as String,
      unitPrice: mapToDouble(map['unit_price']),
      subtotal: mapToDouble(map['subtotal']),
      position: map['position'] as int,
    );
  }

  /// Convierte una Entidad QuotationItem en un Map (para guardar en la BD).
  Map<String, dynamic> _itemToMap(QuotationItem item, String quotationId) {
    return {
      'id': item.id,
      'quotation_id': quotationId,
      'product_id': item.productId,
      'description': item.description,
      'quantity': item.quantity,
      'unit': item.unit,
      'unit_price': item.unitPrice,
      'subtotal': item.subtotal,
      'position': item.position,
    };
  }

  /// Convierte un Map (resultado de la BD) en una Entidad Quotation.
  Quotation _quotationFromMap(
    Map<String, dynamic> map,
    List<QuotationItem> items,
  ) {
    return Quotation(
      id: map['id'] as String,
      quotationNumber: map['quotation_number'] as String,
      clientId: map['client_id'] as String,
      clientName: map['client_name'] as String,
      clientEmail: map['client_email'] as String?,
      clientPhone: map['client_phone'] as String?,
      clientAddress: map['client_address'] as String?,
      issueDate: DateTime.parse(map['issue_date'] as String),
      validUntil: DateTime.parse(map['valid_until'] as String),
      subtotal: mapToDouble(map['subtotal']),
      taxPercentage: mapToDouble(map['tax_percentage']),
      taxAmount: mapToDouble(map['tax_amount']),
      discountPercentage: mapToDouble(map['discount_percentage']),
      discountAmount: mapToDouble(map['discount_amount']),
      total: mapToDouble(map['total']),
      status: map['status'] as String,
      notes: map['notes'] as String?,
      termsConditions: map['terms_conditions'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      items: items,
    );
  }

  /// Convierte una Entidad Quotation en un Map (para guardar en la BD).
  Map<String, dynamic> _quotationToMap(Quotation q) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return {
      'id': q.id,
      'quotation_number': q.quotationNumber,
      'client_id': q.clientId,
      'client_name': q.clientName,
      'client_email': q.clientEmail,
      'client_phone': q.clientPhone,
      'client_address': q.clientAddress,
      'issue_date': formatter.format(q.issueDate),
      'valid_until': formatter.format(q.validUntil),
      'subtotal': q.subtotal,
      'tax_percentage': q.taxPercentage,
      'tax_amount': q.taxAmount,
      'discount_percentage': q.discountPercentage,
      'discount_amount': q.discountAmount,
      'total': q.total,
      'status': q.status,
      'notes': q.notes,
      'terms_conditions': q.termsConditions,
      'created_at': formatter.format(q.createdAt),
      'updated_at': formatter.format(q.updatedAt),
    };
  }

  /// Helper para manejar tipos de datos (entero/double) que vienen de SQLite como num.
  double mapToDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }

  // --- Implementación de Métodos ---

  @override
  Future<List<Quotation>> getAllQuotations() async {
    final db = await _dbHelper.database;

    // Obtener todas las cotizaciones
    final quotationMaps = await db.query(
      _quotationTable,
      orderBy: 'created_at DESC',
    );

    // Para cada cotización, cargar sus ítems
    final quotations = <Quotation>[];
    for (var quotationMap in quotationMaps) {
      final quotationId = quotationMap['id'] as String;

      // Cargar los ítems de esta cotización
      final items = await getItemsByQuotationId(quotationId);

      // Crear la cotización con sus ítems
      quotations.add(_quotationFromMap(quotationMap, items));
    }

    return quotations;
  }

  @override
  Future<Quotation?> getQuotationById(String id) async {
    final db = await _dbHelper.database;
    final quotationMaps = await db.query(
      _quotationTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (quotationMaps.isEmpty) {
      return null;
    }

    // Obtiene los ítems relacionados.
    final items = await getItemsByQuotationId(id);

    // Combina los datos de la cotización principal y los ítems.
    return _quotationFromMap(quotationMaps.first, items);
  }

  @override
  Future<List<QuotationItem>> getItemsByQuotationId(String quotationId) async {
    final db = await _dbHelper.database;
    final itemMaps = await db.query(
      _itemsTable,
      where: 'quotation_id = ?',
      whereArgs: [quotationId],
      orderBy: 'position ASC',
    );
    return itemMaps.map((map) => _itemFromMap(map)).toList();
  }

  @override
  Future<void> saveQuotation(Quotation quotation) async {
    final db = await _dbHelper.database;

    // ** TRANSACCIÓN **: Asegura que si falla la inserción de ítems, no se guarda la cotización.
    await db.transaction((txn) async {
      // 1. Insertar la cotización principal.
      await txn.insert(
        _quotationTable,
        _quotationToMap(quotation),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Insertar todos los ítems relacionados.
      for (var item in quotation.items) {
        await txn.insert(
          _itemsTable,
          _itemToMap(item, quotation.id),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> updateQuotation(Quotation quotation) async {
    final db = await _dbHelper.database;

    // ** TRANSACCIÓN **: Para asegurar que la actualización es atómica.
    await db.transaction((txn) async {
      // 1. Actualizar la cotización principal.
      await txn.update(
        _quotationTable,
        _quotationToMap(quotation),
        where: 'id = ?',
        whereArgs: [quotation.id],
      );

      // 2. Eliminar todos los ítems anteriores.
      await txn.delete(
        _itemsTable,
        where: 'quotation_id = ?',
        whereArgs: [quotation.id],
      );

      // 3. Insertar la nueva lista de ítems (los actualizados).
      for (var item in quotation.items) {
        await txn.insert(
          _itemsTable,
          _itemToMap(item, quotation.id),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> deleteQuotation(String id) async {
    final db = await _dbHelper.database;

    // ** TRANSACCIÓN **: Se elimina la cotización principal y sus ítems.
    await db.transaction((txn) async {
      // 1. Eliminar ítems relacionados.
      await txn.delete(_itemsTable, where: 'quotation_id = ?', whereArgs: [id]);

      // 2. Eliminar la cotización principal.
      await txn.delete(_quotationTable, where: 'id = ?', whereArgs: [id]);
    });
  }

  @override
  Future<int> countQuotationsUsingProduct(String productId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT quotation_id) as count FROM $_itemsTable WHERE product_id = ?',
      [productId],
    );
    return result.first['count'] as int;
  }

  @override
  Future<int> countQuotationsByClient(String clientId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_quotationTable WHERE client_id = ?',
      [clientId],
    );
    return result.first['count'] as int;
  }
}
