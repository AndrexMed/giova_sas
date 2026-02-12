// lib/di/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giova_sas/domain/usecases/quotation/update_quotation.dart';
import 'package:uuid/uuid.dart';

// --- Capa de Datos (Data Layer) ---
import '../../datasources/database_helper.dart';
import '../data/repositories/client_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../data/repositories/quotation_repository_impl.dart';
import '../data/repositories/company_config_repository_impl.dart';
import '../data/services/pdf_service.dart';

// --- Capa de Dominio (Domain Layer) ---
import '../domain/entities/company_config.dart';
import '../domain/repositories/client_repository.dart';
import '../domain/repositories/quotation_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/company_config_repository.dart';

// Use Cases de Clientes
import '../domain/usecases/client/update_client.dart';
import '../domain/usecases/client/delete_client.dart';
import '../domain/usecases/client/get_clients.dart';
import '../domain/usecases/client/create_client.dart';

// Use Cases de Productos
import '../domain/usecases/product/create_product.dart';
import '../domain/usecases/product/delete_product.dart';
import '../domain/usecases/product/get_all_products.dart';
import '../domain/usecases/product/update_product.dart';

// Use Cases de Cotizaciones
import '../domain/usecases/quotation/calculate_quotation_total.dart';
import '../domain/usecases/quotation/create_quotation.dart';
import '../domain/usecases/quotation/get_quotations.dart';
import '../domain/usecases/quotation/delete_quotation.dart';

// ----------------------------------------------------
// 1. Providers de Utilidades y Helper (Infrastructure)
// ----------------------------------------------------

/// Proveedor para el Helper de la Base de Datos (Singleton)
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  // Asumiendo que DatabaseHelper tiene un getter estático 'instance'
  return DatabaseHelper.instance;
});

/// Proveedor para la utilidad Uuid
final uuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

// ----------------------------------------------------
// 2. Providers de Repositorios (Interfaces y Implementaciones)
// ----------------------------------------------------

/// Proveedor para el Repositorio de Clientes (Contrato)
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  // Se inyecta la dependencia del DatabaseHelper
  final dbHelper = ref.watch(databaseHelperProvider);
  return ClientRepositoryImpl(dbHelper);
});

/// Proveedor para el Repositorio de Productos (Contrato)
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return ProductRepositoryImpl(dbHelper);
});

/// Proveedor para el Repositorio de Cotizaciones (Contrato)
final quotationRepositoryProvider = Provider<QuotationRepository>((ref) {
  // Se inyecta la dependencia del DatabaseHelper
  final dbHelper = ref.watch(databaseHelperProvider);
  return QuotationRepositoryImpl(dbHelper);
});

// ----------------------------------------------------
// 3. Providers de Casos de Uso (Business Logic)
// ----------------------------------------------------

// --- Use Cases de Clientes ---

final getClientsUseCaseProvider = Provider<GetClients>((ref) {
  // Inyecta el ClientRepository
  final repository = ref.watch(clientRepositoryProvider);
  return GetClients(repository);
});

final createClientUseCaseProvider = Provider<CreateClient>((ref) {
  // Inyecta el ClientRepository
  final repository = ref.watch(clientRepositoryProvider);
  return CreateClient(repository);
});

final updateClientUseCaseProvider = Provider<UpdateClient>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return UpdateClient(repository);
});

final deleteClientUseCaseProvider = Provider<DeleteClient>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return DeleteClient(repository);
});
// -------------------------------------

// --- Use Cases de Productos (AÑADIDOS) ---

final getAllProductsUseCaseProvider = Provider<GetAllProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetAllProducts(repository);
});

final createProductUseCaseProvider = Provider<CreateProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return CreateProduct(repository);
});

final updateProductUseCaseProvider = Provider<UpdateProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return UpdateProduct(repository);
});

final deleteProductUseCaseProvider = Provider<DeleteProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return DeleteProduct(repository);
});
// -------------------------------------

// --- Use Cases de Cotizaciones ---

final calculateQuotationTotalProvider = Provider<CalculateQuotationTotal>((
  ref,
) {
  // Este Use Case no tiene dependencias de Repositorio, solo lógica pura
  return CalculateQuotationTotal();
});

final getQuotationsUseCaseProvider = Provider<GetQuotations>((ref) {
  // Inyecta el QuotationRepository
  final repository = ref.watch(quotationRepositoryProvider);
  return GetQuotations(repository);
});

final createQuotationUseCaseProvider = Provider<CreateQuotation>((ref) {
  // Inyecta el QuotationRepository, el Use Case de cálculo y Uuid
  final repository = ref.watch(quotationRepositoryProvider);
  final calculateTotal = ref.watch(calculateQuotationTotalProvider);
  final uuid = ref.watch(uuidProvider);

  return CreateQuotation(
    quotationRepository: repository,
    calculateTotal: calculateTotal,
    uuid: uuid,
  );
});

final deleteQuotationUseCaseProvider = Provider<DeleteQuotation>((ref) {
  final repository = ref.watch(quotationRepositoryProvider);
  return DeleteQuotation(repository);
});

final updateQuotationUseCaseProvider = Provider<UpdateQuotation>((ref) {
  final repository = ref.watch(quotationRepositoryProvider);
  return UpdateQuotation(repository);
});
// -------------------------------------

// --- CompanyConfig ---

final companyConfigRepositoryProvider = Provider<CompanyConfigRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CompanyConfigRepositoryImpl(dbHelper);
});

final getCompanyConfigProvider = FutureProvider<CompanyConfig>((ref) {
  final repository = ref.watch(companyConfigRepositoryProvider);
  return repository.getCompanyConfig();
});

// --- PDF Service ---

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});
