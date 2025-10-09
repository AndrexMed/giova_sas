// lib/presentation/views/quotation/quotation_form_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/quotation.dart';
import '../../../domain/entities/quotation_item.dart';
import '../../notifiers/quotation_notifier.dart';

class QuotationFormModal extends ConsumerStatefulWidget {
  final Quotation? quotationToEdit;

  const QuotationFormModal({this.quotationToEdit, super.key});

  @override
  ConsumerState<QuotationFormModal> createState() => _QuotationFormModalState();
}

class _QuotationFormModalState extends ConsumerState<QuotationFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _clientNameController;
  late TextEditingController _clientEmailController;
  late TextEditingController _notesController;

  List<QuotationItem> _items = [];

  @override
  void initState() {
    super.initState();
    final q = widget.quotationToEdit;
    _clientNameController = TextEditingController(text: q?.clientName ?? '');
    _clientEmailController = TextEditingController(text: q?.clientEmail ?? '');
    _notesController = TextEditingController(text: q?.notes ?? '');

    // si viene edición, clonamos los ítems (ya inmutables)
    _items = q?.items.map((i) => i.copyWith()).toList() ?? [];
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(
        QuotationItem(
          id: _uuid.v4(),
          productId: null,
          description: '',
          quantity: 1,
          unit: 'unidad',
          unitPrice: 0.0,
          subtotal: 0.0,
          position: _items.length + 1,
        ),
      );
    });
  }

  void _updateItemAt(int index, QuotationItem updated) {
    setState(() {
      _items[index] = updated;
    });
  }

  void _removeItemAt(int index) {
    setState(() {
      _items.removeAt(index);
      // re-asignar posiciones si quieres
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(position: i + 1);
      }
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    // recalcular subtotal por item y totals
    final updatedItems = _items
        .map((i) => i.copyWith(subtotal: (i.quantity * i.unitPrice)))
        .toList();

    final subtotal = updatedItems.fold<double>(0.0, (s, i) => s + i.subtotal);
    const taxPercentage = 19.0; // o toma de config
    final taxAmount = subtotal * (taxPercentage / 100);
    final total = subtotal + taxAmount;

    final quotation = Quotation(
      id: widget.quotationToEdit?.id ?? _uuid.v4(),
      quotationNumber:
          widget.quotationToEdit?.quotationNumber ??
          'COT-${DateTime.now().millisecondsSinceEpoch}',
      clientId: '', // si tienes selección de cliente usa su id
      clientName: _clientNameController.text.trim(),
      clientEmail: _clientEmailController.text.trim().isNotEmpty
          ? _clientEmailController.text.trim()
          : null,
      clientPhone: widget.quotationToEdit?.clientPhone ?? '',
      clientAddress: widget.quotationToEdit?.clientAddress ?? '',
      issueDate: widget.quotationToEdit?.issueDate ?? DateTime.now(),
      validUntil:
          widget.quotationToEdit?.validUntil ??
          DateTime.now().add(const Duration(days: 15)),
      subtotal: subtotal,
      taxPercentage: taxPercentage,
      taxAmount: taxAmount,
      discountPercentage: widget.quotationToEdit?.discountPercentage ?? 0,
      discountAmount: widget.quotationToEdit?.discountAmount ?? 0,
      total: total,
      status: widget.quotationToEdit?.status ?? 'Borrador',
      notes: _notesController.text.trim(),
      termsConditions:
          widget.quotationToEdit?.termsConditions ?? 'Validez 15 días.',
      createdAt: widget.quotationToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      items: updatedItems,
    );

    try {
      final notifier = ref.read(quotationNotifierProvider.notifier);

      if (widget.quotationToEdit == null) {
        await notifier.createQuotation(
          quotation,
        ); // adapta nombre si usas 'save' o 'add'
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Cotización creada')));
        }
      } else {
        await notifier.updateQuotation(quotation);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cotización actualizada')),
          );
        }
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.quotationToEdit == null
                        ? 'Nueva Cotización'
                        : 'Editar Cotización',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _clientNameController,
                    decoration: const InputDecoration(
                      labelText: 'Cliente *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nombre del cliente requerido'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _clientEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo (opcional)',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ítems',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.indigo,
                        ),
                        onPressed: _addItem,
                      ),
                    ],
                  ),
                  if (_items.isEmpty)
                    const Text(
                      'No hay ítems añadidos.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 8),
                  for (int i = 0; i < _items.length; i++)
                    _QuotationItemField(
                      key: ValueKey(_items[i].id),
                      item: _items[i],
                      onChanged: (updated) => _updateItemAt(i, updated),
                      onRemove: () => _removeItemAt(i),
                    ),
                  const Divider(height: 24),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas / Comentarios',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _saveForm,
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuotationItemField extends StatelessWidget {
  final QuotationItem item;
  final ValueChanged<QuotationItem> onChanged;
  final VoidCallback onRemove;

  const _QuotationItemField({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: item.description,
            onChanged: (v) => onChanged(item.copyWith(description: v)),
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: item.quantity.toString(),
            onChanged: (v) =>
                onChanged(item.copyWith(quantity: double.tryParse(v) ?? 0.0)),
            decoration: const InputDecoration(labelText: 'Cantidad'),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: item.unit,
            onChanged: (v) => onChanged(item.copyWith(unit: v)),
            decoration: const InputDecoration(labelText: 'Unidad'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: item.unitPrice.toString(),
            onChanged: (v) =>
                onChanged(item.copyWith(unitPrice: double.tryParse(v) ?? 0.0)),
            decoration: const InputDecoration(labelText: 'Precio Unitario'),
            keyboardType: TextInputType.number,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: onRemove,
        ),
      ],
    );
  }
}
