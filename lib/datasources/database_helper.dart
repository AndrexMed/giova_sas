import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quotations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Tabla de Clientes
    await db.execute('''
      CREATE TABLE clients (
        id $idType,
        name $textType,
        email $textTypeNullable,
        phone $textTypeNullable,
        address $textTypeNullable,
        company $textTypeNullable,
        identification $textTypeNullable,
        created_at $textType
      )
    ''');

    // Tabla de Productos/Servicios
    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        description $textTypeNullable,
        unit_price $realType,
        unit $textTypeNullable,
        category $textTypeNullable,
        created_at $textType
      )
    ''');

    // Tabla de Cotizaciones
    await db.execute('''
      CREATE TABLE quotations (
        id $idType,
        quotation_number $textType,
        client_id $textType,
        client_name $textType,
        client_email $textTypeNullable,
        client_phone $textTypeNullable,
        client_address $textTypeNullable,
        issue_date $textType,
        valid_until $textType,
        subtotal $realType,
        tax_percentage $realType,
        tax_amount $realType,
        discount_percentage $realType,
        discount_amount $realType,
        total $realType,
        status $textType,
        notes $textTypeNullable,
        terms_conditions $textTypeNullable,
        created_at $textType,
        updated_at $textType,
        FOREIGN KEY (client_id) REFERENCES clients (id)
      )
    ''');

    // Tabla de Items de Cotización
    await db.execute('''
      CREATE TABLE quotation_items (
        id $idType,
        quotation_id $textType,
        product_id $textTypeNullable,
        description $textType,
        quantity $realType,
        unit $textType,
        unit_price $realType,
        subtotal $realType,
        position $integerType,
        FOREIGN KEY (quotation_id) REFERENCES quotations (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Tabla de Configuración de la Empresa
    await db.execute('''
      CREATE TABLE company_config (
        id $idType,
        company_name $textType,
        email $textTypeNullable,
        phone $textTypeNullable,
        address $textTypeNullable,
        tax_id $textTypeNullable,
        logo_path $textTypeNullable,
        default_tax_percentage $realType,
        default_terms_conditions $textTypeNullable,
        currency $textType,
        updated_at $textType
      )
    ''');

    // Insertar configuración por defecto
    await db.insert('company_config', {
      'id': 'default',
      'company_name': 'Giova SAS',
      'email': 'contacto@miempresa.com',
      'phone': '+57 321 883 3424',
      'address': 'Medellín, Antioquia, Colombia',
      'tax_id': '',
      'logo_path': null,
      'default_tax_percentage': 19.0,
      'default_terms_conditions':
          '1. Esta cotización tiene validez de 15 días.\n'
          '2. Los precios no incluyen IVA.\n'
          '3. Forma de pago: 50% anticipo, 50% contra entrega.\n'
          '4. El tiempo de entrega es aproximado y puede variar según disponibilidad.',
      'currency': 'COP',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
