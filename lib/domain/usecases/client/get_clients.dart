// lib/domain/usecases/get_clients.dart

import '../../entities/client.dart';
import '../../repositories/client_repository.dart';

/// Use Case: Obtiene la lista completa de clientes.
class GetClients {
  final ClientRepository repository;

  GetClients(this.repository);

  Future<List<Client>> execute() {
    return repository.getClients();
  }
}
