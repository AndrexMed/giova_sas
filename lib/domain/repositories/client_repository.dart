import '../entities/client.dart';

/// Clase abstracta (Interface) que define el contrato de lo que un Repositorio de Clientes debe hacer.
/// La Capa de Dominio SÓLO conoce esta interface, no la implementación (sqflite).
abstract class ClientRepository {
  /// Obtiene una lista de todos los clientes.
  Future<List<Client>> getClients();

  /// Obtiene un cliente por su ID.
  Future<Client?> getClientById(String id);

  /// Guarda un nuevo cliente en la base de datos.
  Future<void> saveClient(Client client);

  /// Actualiza la información de un cliente existente.
  Future<void> updateClient(Client client);

  /// Elimina un cliente por su ID.
  Future<void> deleteClient(String id);

  // NOTA: Para Clean Architecture, también podrías tener "Use Cases" (interactores)
  // que usarían este repositorio para ejecutar la lógica de negocio específica.
}
