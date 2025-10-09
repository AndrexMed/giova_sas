// lib/domain/usecases/update_client.dart

import '../../entities/client.dart';
import '../../repositories/client_repository.dart';

/// Use Case: Se encarga de actualizar un cliente existente en el repositorio.
class UpdateClient {
  final ClientRepository repository;

  UpdateClient(this.repository);

  Future<void> execute(Client client) async {
    await repository.updateClient(client);
  }
}
