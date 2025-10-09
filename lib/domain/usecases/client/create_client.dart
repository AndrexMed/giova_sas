// lib/domain/usecases/create_client.dart

import '../../entities/client.dart';
import '../../repositories/client_repository.dart';

/// Use Case: Se encarga de crear un nuevo cliente en el repositorio.
class CreateClient {
  final ClientRepository repository;

  CreateClient(this.repository);

  Future<void> execute({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? address,
    String? company,
    String? identification,
  }) async {
    final client = Client(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      company: company,
      identification: identification,  
      createdAt: DateTime.now(),
    );
    await repository.saveClient(client);
  }
}
