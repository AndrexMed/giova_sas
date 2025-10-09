// lib/presentation/views/client/client_form_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifiers/client_notifier.dart';

class ClientFormModal extends ConsumerStatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? clientToEdit;

  const ClientFormModal({super.key, this.isEditing = false, this.clientToEdit});

  @override
  ConsumerState<ClientFormModal> createState() => _ClientFormModalState();
}

class _ClientFormModalState extends ConsumerState<ClientFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _identificationController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, precargamos los datos
    if (widget.clientToEdit != null) {
      final data = widget.clientToEdit!;
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _companyController.text = data['company'] ?? '';
      _addressController.text = data['address'] ?? '';
      _identificationController.text = data['identification'] ?? '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(clientNotifierProvider.notifier);

      await notifier.createClient(
        name: _nameController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        company: _companyController.text.isNotEmpty
            ? _companyController.text
            : null,
        address: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        identification: _identificationController.text.isNotEmpty
            ? _identificationController.text
            : null,
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar cliente: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _identificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Cliente' : 'Nuevo Cliente'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo (*)',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Campo obligatorio'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Empresa',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _identificationController,
                decoration: const InputDecoration(
                  labelText: 'Cédula / Identificación',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Guardar Cambios' : 'Guardar'),
        ),
      ],
    );
  }
}
