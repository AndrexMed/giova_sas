import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/providers.dart';
import '../../../domain/entities/company_config.dart';

class CompanyConfigView extends ConsumerStatefulWidget {
  const CompanyConfigView({super.key});

  @override
  ConsumerState<CompanyConfigView> createState() => _CompanyConfigViewState();
}

class _CompanyConfigViewState extends ConsumerState<CompanyConfigView> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _taxPercentageController = TextEditingController();
  final _currencyController = TextEditingController();
  final _termsController = TextEditingController();

  bool _isLoading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _taxPercentageController.dispose();
    _currencyController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  void _loadConfig(CompanyConfig config) {
    if (_initialized) return;
    _initialized = true;
    _companyNameController.text = config.companyName;
    _emailController.text = config.email ?? '';
    _phoneController.text = config.phone ?? '';
    _addressController.text = config.address ?? '';
    _taxIdController.text = config.taxId ?? '';
    _taxPercentageController.text =
        config.defaultTaxPercentage.toStringAsFixed(0);
    _currencyController.text = config.currency;
    _termsController.text = config.defaultTermsConditions ?? '';
  }

  Future<void> _save(CompanyConfig currentConfig) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final updated = currentConfig.copyWith(
        companyName: _companyNameController.text.trim(),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        taxId: _taxIdController.text.trim().isNotEmpty
            ? _taxIdController.text.trim()
            : null,
        defaultTaxPercentage:
            double.tryParse(_taxPercentageController.text) ?? 19.0,
        currency: _currencyController.text.trim().isNotEmpty
            ? _currencyController.text.trim()
            : 'COP',
        defaultTermsConditions: _termsController.text.trim().isNotEmpty
            ? _termsController.text.trim()
            : null,
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(companyConfigRepositoryProvider);
      await repository.updateCompanyConfig(updated);

      // Invalidar el provider para que se recargue
      ref.invalidate(getCompanyConfigProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuracion guardada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(getCompanyConfigProvider);

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (config) {
        _loadConfig(config);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Datos de empresa
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.business, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text('Datos de la Empresa',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                        const Divider(),
                        TextFormField(
                          controller: _companyNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la Empresa (*)',
                            prefixIcon: Icon(Icons.corporate_fare),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Campo obligatorio'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _taxIdController,
                          decoration: const InputDecoration(
                            labelText: 'NIT / Identificacion Fiscal',
                            prefixIcon: Icon(Icons.badge),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Direccion',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Telefono',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Configuracion fiscal
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.percent, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text('Configuracion Fiscal',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                        const Divider(),
                        TextFormField(
                          controller: _taxPercentageController,
                          decoration: const InputDecoration(
                            labelText: 'IVA por defecto (%)',
                            prefixIcon: Icon(Icons.receipt_outlined),
                            suffixText: '%',
                            helperText:
                                'Este valor se usara como IVA predeterminado en las cotizaciones',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Campo obligatorio';
                            }
                            final val = double.tryParse(v);
                            if (val == null || val < 0 || val > 100) {
                              return 'Valor entre 0 y 100';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _currencyController,
                          decoration: const InputDecoration(
                            labelText: 'Moneda',
                            prefixIcon: Icon(Icons.attach_money),
                            helperText: 'Ej: COP, USD, EUR',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Terminos y condiciones
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.description, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text('Terminos y Condiciones',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                        const Divider(),
                        TextFormField(
                          controller: _termsController,
                          decoration: const InputDecoration(
                            labelText: 'Terminos y condiciones por defecto',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                            helperText:
                                'Se incluiran automaticamente en las cotizaciones nuevas',
                          ),
                          maxLines: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Boton guardar
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Guardar Configuracion'),
                    onPressed: _isLoading ? null : () => _save(config),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
