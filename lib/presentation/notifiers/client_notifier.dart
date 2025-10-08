// lib/presentation/notifiers/client_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../di/providers.dart';
import '../../domain/entities/client.dart';

/// Gestor de estado (Controller) para los clientes, usando AsyncNotifier de Riverpod.
/// Maneja la carga, creación, actualización y eliminación de clientes.
class ClientNotifier extends AsyncNotifier<List<Client>> {
  final _uuid = const Uuid();

  /// El método `build` se llama una vez para inicializar el estado.
  /// Aquí obtenemos la dependencia GetClients y cargamos los datos iniciales.
  @override
  Future<List<Client>> build() async {
    // 'ref' está disponible automáticamente dentro del cuerpo de build()
    final getClients = ref.read(getClientsUseCaseProvider);
    return getClients.execute();
  }

  /// Recarga la lista de clientes desde la base de datos.
  Future<void> loadClients() async {
    state = const AsyncValue.loading();
    try {
      // 'ref' es accesible como propiedad de la clase (this.ref)
      final clients = await ref.read(getClientsUseCaseProvider).execute();
      state = AsyncValue.data(clients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Crea y guarda un nuevo cliente.
  Future<void> createClient({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? company,
    String? identification,
  }) async {
    // Usamos ref para acceder al Use Case CreateClient
    final createClientUC = ref.read(createClientUseCaseProvider);

    await createClientUC.execute(
      id: _uuid.v4(),
      name: name,
      email: email,
      phone: phone,
      address: address,
      company: company,
      identification: identification,
    );

    // Tras la creación, recargamos la lista para actualizar la UI
    await loadClients();
  }

  /// Actualiza un cliente existente.
  Future<void> updateClient(Client client) async {
    // **NOTA:** Asumimos que el Use Case UpdateClient ya existe.
    final updateClientUC = ref.read(updateClientUseCaseProvider);
    await updateClientUC.execute(client);
    await loadClients();
  }

  /// Elimina un cliente por su ID.
  Future<void> deleteClient(String id) async {
    final deleteClientUC = ref.read(deleteClientUseCaseProvider);
    await deleteClientUC.execute(id);
    await loadClients();
  }
}

// Provider que expone el ClientNotifier
final clientNotifierProvider =
    AsyncNotifierProvider<ClientNotifier, List<Client>>(ClientNotifier.new);
