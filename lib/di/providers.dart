// lib/di/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// --- Capa de Datos (Data Layer) ---
import '../../datasources/database_helper.dart';
import '../data/repositories/client_repository_impl.dart';
import '../data/repositories/quotation_repository_impl.dart';

// --- Capa de Dominio (Domain Layer) ---
import '../domain/repositories/client_repository.dart';
import '../domain/repositories/quotation_repository.dart';
import '../domain/usecases/calculate_quotation_total.dart';
import '../domain/usecases/create_client.dart';
import '../domain/usecases/create_quotation.dart';
import '../domain/usecases/get_clients.dart';
import '../domain/usecases/get_quotations.dart';
import '../domain/usecases/update_client.dart'; // ¡AÑADIDO!
import '../domain/usecases/delete_client.dart'; // ¡AÑADIDO!

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

// ¡NUEVOS PROVIDERS AÑADIDOS!
final updateClientUseCaseProvider = Provider<UpdateClient>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return UpdateClient(repository);
});

final deleteClientUseCaseProvider = Provider<DeleteClient>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return DeleteClient(repository);
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
