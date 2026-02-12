import '../entities/company_config.dart';

abstract class CompanyConfigRepository {
  Future<CompanyConfig> getCompanyConfig();
  Future<void> updateCompanyConfig(CompanyConfig config);
}
