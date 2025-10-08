// lib/data/repositories/client_repository_impl.dart

import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../datasources/database_helper.dart';

/// Implementación concreta del ClientRepository usando sqflite.
/// Se encarga de la lógica de conexión directa con la base de datos.
class ClientRepositoryImpl implements ClientRepository {
  final DatabaseHelper _dbHelper;
  final String _tableName = 'clients';

  ClientRepositoryImpl(this._dbHelper);

  // --- Mappers ---

  /// Convierte un Map de la BD a una Entidad Client.
  Client _clientFromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      company: map['company'] as String?,
      identification: map['identification'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convierte una Entidad Client a un Map para la BD.
  Map<String, dynamic> _clientToMap(Client client) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return {
      'id': client.id,
      'name': client.name,
      'email': client.email,
      'phone': client.phone,
      'address': client.address,
      'company': client.company,
      'identification': client.identification,
      'created_at': formatter.format(client.createdAt),
    };
  }

  // --- Implementación de Métodos ---

  @override
  // ¡CORREGIDO! Ahora usa saveClient() para coincidir con tu interface.
  Future<void> saveClient(Client client) async {
    final db = await _dbHelper.database;
    await db.insert(
      _tableName,
      _clientToMap(client),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteClient(String id) async {
    final db = await _dbHelper.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Client>> getClients() async {
    final db = await _dbHelper.database;
    final maps = await db.query(_tableName, orderBy: 'name ASC');
    return maps.map((map) => _clientFromMap(map)).toList();
  }

  @override
  Future<void> updateClient(Client client) async {
    final db = await _dbHelper.database;
    await db.update(
      _tableName,
      _clientToMap(client),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  @override
  Future<Client?> getClientById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return _clientFromMap(maps.first);
    }
    return null;
  }
}
