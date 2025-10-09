// lib/presentation/views/product/product_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/product.dart';
import '../../notifiers/product_notifier.dart';
import 'product_form_modal.dart';

/// Vista para mostrar la lista de productos o servicios.
class ProductListView extends ConsumerWidget {
  const ProductListView({super.key});

  /// Abre el modal para crear un nuevo producto
  void _showAddProductForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => const ProductFormModal(),
    );
  }

  /// Abre el modal para editar un producto existente
  void _showEditProductForm(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductFormModal(productToEdit: product),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productListAsync = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos / Servicios'),
        automaticallyImplyLeading: false,
      ),
      body: productListAsync.when(
        // Estado de carga
        loading: () => const Center(child: CircularProgressIndicator()),

        // Estado de error
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error al cargar productos: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),

        // Estado con datos
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay productos registrados.',
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
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductListTile(
                product: product,
                onEdit: () => _showEditProductForm(context, product),
              );
            },
          );
        },
      ),

      // Botón flotante para crear
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget que representa cada producto en la lista
class ProductListTile extends ConsumerWidget {
  final Product product;
  final VoidCallback onEdit;

  const ProductListTile({
    required this.product,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.shopping_bag_outlined, color: Colors.indigo),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${product.unitPrice.toStringAsFixed(2)} / ${product.unit}'
          '${product.category != null ? ' — ${product.category}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Editar
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: onEdit,
            ),
            // Eliminar
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
        title: const Text('Confirmar eliminación'),
        content: Text('¿Deseas eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(productNotifierProvider.notifier)
                  .deleteProduct(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${product.name}" eliminado correctamente'),
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
