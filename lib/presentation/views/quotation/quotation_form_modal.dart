// lib/presentation/views/quotation/quotation_form_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/quotation.dart';
import '../../../domain/entities/quotation_item.dart';
import '../../../domain/entities/client.dart';
import '../../../domain/entities/product.dart';
import '../../notifiers/quotation_notifier.dart';
import '../../../di/providers.dart';

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
  late TextEditingController _discountPercentageController;

  String? _selectedClientId;
  List<QuotationItem> _items = [];
  bool _includeIva = true;
  double _configTaxPercentage = 19.0;

  @override
  void initState() {
    super.initState();
    final q = widget.quotationToEdit;
    _clientNameController = TextEditingController(text: q?.clientName ?? '');
    _clientEmailController = TextEditingController(text: q?.clientEmail ?? '');
    _notesController = TextEditingController(text: q?.notes ?? '');
    _discountPercentageController = TextEditingController(
      text: (q?.discountPercentage ?? 0).toString(),
    );

    _selectedClientId = q?.clientId;

    // Si estamos editando, determinar si tenía IVA
    if (q != null) {
      _includeIva = q.taxPercentage > 0;
    }

    // CORRECCIÓN: Cargar los ítems correctamente
    if (q != null && q.items.isNotEmpty) {
      _items = q.items.map((item) {
        return QuotationItem(
          id: item.id,
          productId: item.productId,
          description: item.description,
          quantity: item.quantity,
          unit: item.unit,
          unitPrice: item.unitPrice,
          subtotal: item.subtotal,
          position: item.position,
        );
      }).toList();

    } else {
      _items = [];
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _notesController.dispose();
    _discountPercentageController.dispose();
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
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(position: i + 1);
      }
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedItems = _items
        .map((i) => i.copyWith(subtotal: i.quantity * i.unitPrice))
        .toList();

    final subtotal = updatedItems.fold<double>(0.0, (s, i) => s + i.subtotal);
    final discountPercentage =
        double.tryParse(_discountPercentageController.text) ?? 0.0;
    final discountAmount = subtotal * (discountPercentage / 100);
    final subtotalAfterDiscount = subtotal - discountAmount;
    final taxPercentage = _includeIva ? _configTaxPercentage : 0.0;
    final taxAmount = subtotalAfterDiscount * (taxPercentage / 100);
    final total = subtotalAfterDiscount + taxAmount;

    // Leer terminos por defecto de la configuracion
    String? defaultTerms;
    final configAsync = ref.read(getCompanyConfigProvider);
    configAsync.whenData((config) {
      defaultTerms = config.defaultTermsConditions;
    });

    final quotation = Quotation(
      id: widget.quotationToEdit?.id ?? _uuid.v4(),
      quotationNumber:
          widget.quotationToEdit?.quotationNumber ??
          'COT-${DateTime.now().millisecondsSinceEpoch}',
      clientId: _selectedClientId ?? '',
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
      discountPercentage: discountPercentage,
      discountAmount: discountAmount,
      total: total,
      status: widget.quotationToEdit?.status ?? 'Borrador',
      notes: _notesController.text.trim(),
      termsConditions:
          widget.quotationToEdit?.termsConditions ?? defaultTerms ?? '',
      createdAt: widget.quotationToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      items: updatedItems,
    );

    try {
      final notifier = ref.read(quotationNotifierProvider.notifier);

      if (widget.quotationToEdit == null) {
        await notifier.createQuotation(quotation);
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

  Widget _totalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final getAllClients = ref.watch(getClientsUseCaseProvider);
    final getAllProducts = ref.watch(getAllProductsUseCaseProvider);

    // Leer el % de IVA desde la configuracion de empresa
    final configAsync = ref.watch(getCompanyConfigProvider);
    configAsync.whenData((config) {
      _configTaxPercentage = config.defaultTaxPercentage;
    });

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
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

                  // === Cargar clientes y productos una sola vez ===
                  FutureBuilder<List<Client>>(
                    future: getAllClients.execute(),
                    builder: (context, clientsSnapshot) {
                      if (clientsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }
                      if (clientsSnapshot.hasError) {
                        return Text(
                          'Error cargando clientes: ${clientsSnapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      final clients = clientsSnapshot.data ?? [];

                      return Column(
                        children: [
                          // === Autocomplete de clientes ===
                          _ClientAutocompleteField(
                            clients: clients,
                            initialName: _clientNameController.text,
                            initialEmail: _clientEmailController.text,
                            onClientSelected: (client) {
                              setState(() {
                                _selectedClientId = client.id;
                                _clientNameController.text = client.name;
                                _clientEmailController.text =
                                    client.email ?? '';
                              });
                            },
                            onNameChanged: (name) {
                              _clientNameController.text = name;
                              if (!clients.any((c) => c.name == name)) {
                                setState(() {
                                  _selectedClientId = null;
                                });
                              }
                            },
                            hasSelectedClient: _selectedClientId != null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _clientEmailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo (opcional)',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      );
                    },
                  ),

                  const Divider(height: 24),

                  // === ÍTEMS ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ítems',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      FilledButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Añadir ítem'),
                        onPressed: _addItem,
                      ),
                    ],
                  ),
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'No hay ítems añadidos. Haz clic en "Añadir ítem"',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Cargar productos una sola vez para todos los ítems
                  FutureBuilder<List<Product>>(
                    future: getAllProducts.execute(),
                    builder: (context, productsSnapshot) {
                      if (productsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (productsSnapshot.hasError) {
                        return Text(
                          'Error cargando productos: ${productsSnapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      final products = productsSnapshot.data ?? [];

                      return Column(
                        children: [
                          for (int i = 0; i < _items.length; i++)
                            _QuotationItemField(
                              key: ValueKey(_items[i].id),
                              item: _items[i],
                              products: products,
                              onChanged: (updated) => _updateItemAt(i, updated),
                              onRemove: () => _removeItemAt(i),
                            ),
                        ],
                      );
                    },
                  ),

                  const Divider(height: 24),

                  // === Descuento ===
                  TextFormField(
                    controller: _discountPercentageController,
                    decoration: const InputDecoration(
                      labelText: 'Descuento (%)',
                      prefixIcon: Icon(Icons.discount_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                      suffixText: '%',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final val = double.tryParse(v);
                        if (val == null || val < 0 || val > 100) {
                          return 'Valor entre 0 y 100';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // === Toggle IVA ===
                  SwitchListTile(
                    title: Text(
                      'Incluir IVA (${_configTaxPercentage.toStringAsFixed(0)}%)',
                    ),
                    subtitle: Text(
                      _includeIva
                          ? 'Se aplicara IVA del ${_configTaxPercentage.toStringAsFixed(0)}%'
                          : 'Sin IVA - precios finales',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    secondary: Icon(
                      Icons.receipt_outlined,
                      color: _includeIva ? Colors.indigo : Colors.grey,
                    ),
                    value: _includeIva,
                    onChanged: (value) => setState(() => _includeIva = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas / Comentarios',
                      prefixIcon: Icon(Icons.note_outlined),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // === Total preview ===
                  if (_items.isNotEmpty)
                    Builder(builder: (context) {
                      final subtotal = _items.fold<double>(
                        0.0,
                        (s, i) => s + (i.quantity * i.unitPrice),
                      );
                      final discPct = double.tryParse(
                              _discountPercentageController.text) ??
                          0.0;
                      final discAmt = subtotal * (discPct / 100);
                      final afterDiscount = subtotal - discAmt;
                      final taxPct = _includeIva ? _configTaxPercentage : 0.0;
                      final iva = afterDiscount * (taxPct / 100);
                      final total = afterDiscount + iva;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _totalRow('Subtotal',
                                '\$${subtotal.toStringAsFixed(0)}'),
                            if (discPct > 0)
                              _totalRow('Descuento ($discPct%)',
                                  '-\$${discAmt.toStringAsFixed(0)}'),
                            if (_includeIva)
                              _totalRow(
                                  'IVA (${taxPct.toStringAsFixed(0)}%)',
                                  '\$${iva.toStringAsFixed(0)}'),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total estimado:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '\$${total.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        icon: const Icon(Icons.save, size: 18),
                        onPressed: _saveForm,
                        label: const Text('Guardar'),
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

// Widget separado para el autocomplete de clientes (mismo patrón que productos)
class _ClientAutocompleteField extends StatefulWidget {
  final List<Client> clients;
  final String initialName;
  final String initialEmail;
  final Function(Client) onClientSelected;
  final Function(String) onNameChanged;
  final bool hasSelectedClient;

  const _ClientAutocompleteField({
    required this.clients,
    required this.initialName,
    required this.initialEmail,
    required this.onClientSelected,
    required this.onNameChanged,
    required this.hasSelectedClient,
  });

  @override
  State<_ClientAutocompleteField> createState() =>
      _ClientAutocompleteFieldState();
}

class _ClientAutocompleteFieldState extends State<_ClientAutocompleteField> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Client>(
      initialValue: TextEditingValue(text: _nameController.text),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Client>.empty();
        }
        return widget.clients.where(
          (client) =>
              client.name.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ) ||
              (client.email?.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ) ??
                  false),
        );
      },
      displayStringForOption: (Client client) => client.name,
      onSelected: (Client selectedClient) {
        setState(() {
          _nameController.text = selectedClient.name;
        });
        widget.onClientSelected(selectedClient);
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 400),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final client = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: const CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.person, size: 16),
                    ),
                    title: Text(client.name),
                    subtitle: Text(
                      client.email ?? 'Sin correo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSelected(client),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            if (textEditingController.text.isEmpty &&
                _nameController.text.isNotEmpty) {
              textEditingController.text = _nameController.text;
            }

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Cliente (elige o escribe uno nuevo)',
                prefixIcon: const Icon(Icons.person_outline),
                hintText: 'Escribe para buscar o crear nuevo',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: widget.hasSelectedClient
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      )
                    : null,
              ),
              onChanged: (value) {
                // Solo actualizar sin llamar setState
                _nameController.text = value;
              },
              onEditingComplete: () {
                // Actualizar solo al terminar
                widget.onNameChanged(textEditingController.text);
              },
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nombre del cliente requerido'
                  : null,
            );
          },
    );
  }
}

class _QuotationItemField extends StatefulWidget {
  final QuotationItem item;
  final List<Product> products;
  final ValueChanged<QuotationItem> onChanged;
  final VoidCallback onRemove;

  const _QuotationItemField({
    super.key,
    required this.item,
    required this.products,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_QuotationItemField> createState() => _QuotationItemFieldState();
}

class _QuotationItemFieldState extends State<_QuotationItemField> {
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _unitPriceController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.item.description,
    );
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _unitController = TextEditingController(text: widget.item.unit);
    _unitPriceController = TextEditingController(
      text: widget.item.unitPrice.toString(),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Autocomplete de Productos ===
            Autocomplete<Product>(
              initialValue: TextEditingValue(text: _descriptionController.text),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Product>.empty();
                }
                return widget.products.where(
                  (product) =>
                      product.name.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ) ||
                      (product.description?.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ) ??
                          false),
                );
              },
              displayStringForOption: (Product product) => product.name,
              onSelected: (Product selectedProduct) {
                setState(() {
                  _descriptionController.text =
                      selectedProduct.description ?? selectedProduct.name;
                  _unitController.text = selectedProduct.unit ?? 'unidad';
                  _unitPriceController.text = selectedProduct.unitPrice
                      .toString();
                });

                widget.onChanged(
                  widget.item.copyWith(
                    productId: selectedProduct.id,
                    description:
                        selectedProduct.description ?? selectedProduct.name,
                    unit: selectedProduct.unit ?? 'unidad',
                    unitPrice: selectedProduct.unitPrice,
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 400,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final product = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            title: Text(product.name),
                            subtitle: Text(
                              '${product.description ?? ''} - \${product.unitPrice}/${product.unit ?? 'unidad'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => onSelected(product),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    // Inicializar solo una vez
                    if (textEditingController.text.isEmpty &&
                        _descriptionController.text.isNotEmpty) {
                      textEditingController.text = _descriptionController.text;
                    }

                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Producto / Descripción',
                        hintText: 'Busca un producto o escribe descripción',
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: widget.item.productId != null
                            ? const Icon(
                                Icons.link,
                                color: Colors.green,
                                size: 20,
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        // Solo actualizar el controlador interno
                        _descriptionController.text = value;
                      },
                      onEditingComplete: () {
                        // Actualizar solo al terminar de editar
                        widget.onChanged(
                          widget.item.copyWith(
                            description: textEditingController.text,
                            productId: null,
                          ),
                        );
                      },
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Descripción requerida'
                          : null,
                    );
                  },
            ),

            const SizedBox(height: 12),

            // === Campos de cantidad, unidad y precio ===
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    onChanged: (v) {
                      // Solo actualizar localmente
                      _quantityController.text = v;
                    },
                    onEditingComplete: () {
                      // Actualizar al terminar
                      widget.onChanged(
                        widget.item.copyWith(
                          quantity:
                              double.tryParse(_quantityController.text) ?? 0,
                        ),
                      );
                    },
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'Cantidad inválida';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _unitController,
                    onChanged: (v) {
                      // Solo actualizar localmente
                      _unitController.text = v;
                    },
                    onEditingComplete: () {
                      // Actualizar al terminar
                      widget.onChanged(
                        widget.item.copyWith(unit: _unitController.text),
                      );
                    },
                    decoration: const InputDecoration(
                      labelText: 'Unidad',
                      border: OutlineInputBorder(),
                      isDense: true,
                      hintText: 'ej: unidad, hora',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _unitPriceController,
                    onChanged: (v) {
                      // Solo actualizar localmente
                      _unitPriceController.text = v;
                    },
                    onEditingComplete: () {
                      // Actualizar al terminar
                      widget.onChanged(
                        widget.item.copyWith(
                          unitPrice:
                              double.tryParse(_unitPriceController.text) ?? 0.0,
                        ),
                      );
                    },
                    decoration: const InputDecoration(
                      labelText: 'Precio Unitario',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val < 0) return 'Precio inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Subtotal calculado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        '\$${(widget.item.quantity * widget.item.unitPrice).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Eliminar ítem',
                  onPressed: widget.onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
