// lib/presentation/views/product/product_form_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/product.dart';
import '../../notifiers/product_notifier.dart';

/// Modal para crear o editar un producto o servicio.
class ProductFormModal extends ConsumerStatefulWidget {
  /// Si se provee, el modal estará en modo edición; si es null, modo creación.
  final Product? productToEdit;

  const ProductFormModal({super.key, this.productToEdit});

  @override
  ConsumerState<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends ConsumerState<ProductFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _unitController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Si estamos editando, precargamos los datos del producto
    if (widget.productToEdit != null) {
      final p = widget.productToEdit!;
      _nameController.text = p.name;
      _descriptionController.text = p.description ?? '';
      _unitPriceController.text = p.unitPrice.toString();
      _unitController.text = p.unit ?? '';
      _categoryController.text = p.category ?? '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final double? unitPrice = double.tryParse(_unitPriceController.text);

    if (unitPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio debe ser un número válido.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final notifier = ref.read(productNotifierProvider.notifier);
      final bool isEditing = widget.productToEdit != null;

      if (isEditing) {
        final updatedProduct = widget.productToEdit!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          unitPrice: unitPrice,
          unit: _unitController.text.isNotEmpty
              ? _unitController.text
              : 'unidad',
          category: _categoryController.text.isNotEmpty
              ? _categoryController.text
              : null,
        );

        await notifier.updateProduct(updatedProduct);
      } else {
        await notifier.createProduct(
          name: _nameController.text,
          unitPrice: unitPrice,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          unit: _unitController.text.isNotEmpty
              ? _unitController.text
              : 'unidad',
          category: _categoryController.text.isNotEmpty
              ? _categoryController.text
              : null,
        );
      }

      // Cerrar el modal y mostrar mensaje de éxito
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Producto actualizado exitosamente'
                  : 'Producto creado exitosamente',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar producto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitPriceController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.productToEdit != null;

    return AlertDialog(
      title: Text(
        isEditing
            ? 'Editar Producto/Servicio'
            : 'Añadir Nuevo Producto/Servicio',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre del producto
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre o Título*',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Precio unitario
              TextFormField(
                controller: _unitPriceController,
                decoration: const InputDecoration(
                  labelText: 'Precio Unitario*',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Debe ser un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Unidad
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unidad (Ej: hr, pza, kg)',
                  prefixIcon: Icon(Icons.straighten),
                ),
              ),
              const SizedBox(height: 10),

              // Categoría
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoría (Opcional)',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 10),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _submit,
          icon: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(isEditing ? 'Guardar Cambios' : 'Crear Producto'),
        ),
      ],
    );
  }
}
