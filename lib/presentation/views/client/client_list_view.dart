// lib/presentation/views/client/client_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/client.dart';
import '../../notifiers/client_notifier.dart';
import 'client_form_modal.dart';

/// Vista para mostrar la lista de clientes.
class ClientListView extends ConsumerWidget {
  const ClientListView({super.key});

  void _showAddClientForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ClientFormModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Observar el estado de los clientes
    final clientListAsync = ref.watch(clientNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        automaticallyImplyLeading: false,
      ),
      body: clientListAsync.when(
        // 2. Estado de Carga
        loading: () => const Center(child: CircularProgressIndicator()),

        // 3. Estado de Error
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error al cargar clientes: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),

        // 4. Estado con Datos
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add_disabled,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay clientes registrados.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Presiona "+" para añadir el primero.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ClientListTile(client: client);
            },
          );
        },
      ),

      // 5. Botón para añadir clientes
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClientForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget para mostrar la información de un cliente en la lista
class ClientListTile extends ConsumerWidget {
  final Client client;

  const ClientListTile({required this.client, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.indigo),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          client.company ?? client.phone ?? client.email ?? 'Sin detalles',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón de Edición (Faltaría implementar el formulario de edición)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: () {
                // TODO: Implementar showModalBottomSheet con formulario para editar
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text('Editar: ${client.name}')),
                // );
              },
            ),
            // Botón de Eliminación
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar a ${client.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Llamar al Notifier para eliminar
              ref.read(clientNotifierProvider.notifier).deleteClient(client.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
