import '../../domain/entities/company_config.dart';
import '../../domain/repositories/company_config_repository.dart';
import '../../datasources/database_helper.dart';

class CompanyConfigRepositoryImpl implements CompanyConfigRepository {
  final DatabaseHelper _dbHelper;

  CompanyConfigRepositoryImpl(this._dbHelper);

  @override
  Future<CompanyConfig> getCompanyConfig() async {
    final db = await _dbHelper.database;
    final maps = await db.query('company_config', where: "id = 'default'");

    if (maps.isEmpty) {
      return CompanyConfig(
        id: 'default',
        companyName: 'Mi Empresa',
        defaultTaxPercentage: 19.0,
        currency: 'COP',
        updatedAt: DateTime.now(),
      );
    }

    final map = maps.first;
    return CompanyConfig(
      id: map['id'] as String,
      companyName: map['company_name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      taxId: map['tax_id'] as String?,
      logoPath: map['logo_path'] as String?,
      defaultTaxPercentage: _toDouble(map['default_tax_percentage']),
      defaultTermsConditions: map['default_terms_conditions'] as String?,
      currency: map['currency'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  Future<void> updateCompanyConfig(CompanyConfig config) async {
    final db = await _dbHelper.database;
    await db.update(
      'company_config',
      {
        'company_name': config.companyName,
        'email': config.email,
        'phone': config.phone,
        'address': config.address,
        'tax_id': config.taxId,
        'logo_path': config.logoPath,
        'default_tax_percentage': config.defaultTaxPercentage,
        'default_terms_conditions': config.defaultTermsConditions,
        'currency': config.currency,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [config.id],
    );
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }
}
