// lib/domain/usecases/delete_client.dart

import '../repositories/client_repository.dart';

/// Use Case: Se encarga de eliminar un cliente por su ID.
class DeleteClient {
  final ClientRepository repository;

  DeleteClient(this.repository);

  Future<void> execute(String clientId) async {
    await repository.deleteClient(clientId);
  }
}
