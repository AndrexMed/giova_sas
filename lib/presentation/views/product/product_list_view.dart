import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/product.dart';
import '../../notifiers/product_notifier.dart';
import 'product_form_modal.dart';

class ProductListView extends ConsumerWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productListAsync = ref.watch(productNotifierProvider);

    return productListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay productos registrados.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Presiona "+" para anadir el primero.',
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
              onEdit: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      ProductFormModal(productToEdit: product),
                );
              },
            );
          },
        );
      },
    );
  }
}

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
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: onEdit,
            ),
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
        title: const Text('Confirmar eliminacion'),
        content: Text('Deseas eliminar "${product.name}"?'),
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
