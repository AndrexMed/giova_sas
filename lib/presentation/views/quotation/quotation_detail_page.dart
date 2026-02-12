import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/quotation.dart';
import '../../../di/providers.dart';
import '../../notifiers/quotation_notifier.dart';
import 'quotation_form_modal.dart';

class QuotationDetailPage extends ConsumerWidget {
  final String quotationId;

  const QuotationDetailPage({required this.quotationId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationListAsync = ref.watch(quotationNotifierProvider);

    return quotationListAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (quotations) {
        final quotation = quotations.cast<Quotation?>().firstWhere(
              (q) => q!.id == quotationId,
              orElse: () => null,
            );

        if (quotation == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('No encontrada')),
            body: const Center(child: Text('Cotizacion no encontrada')),
          );
        }

        return _DetailContent(quotation: quotation);
      },
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final Quotation quotation;

  const _DetailContent({required this.quotation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Cotizacion #${quotation.quotationNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) =>
                    QuotationFormModal(quotationToEdit: quotation),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) =>
                _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf_view',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('Ver PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'pdf_share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Compartir PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'whatsapp',
                child: ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Enviar por WhatsApp'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'email',
                child: ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Enviar por Email'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'status',
                child: ListTile(
                  leading: Icon(Icons.swap_horiz),
                  title: Text('Cambiar Estado'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status chip
            Center(
              child: Chip(
                label: Text(
                  quotation.status,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                backgroundColor: _statusColor(quotation.status),
              ),
            ),
            const SizedBox(height: 16),

            // Client card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.person, color: Colors.indigo, size: 20),
                        SizedBox(width: 8),
                        Text('Cliente',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Divider(),
                    Text(quotation.clientName,
                        style: const TextStyle(fontSize: 15)),
                    if (quotation.clientEmail != null &&
                        quotation.clientEmail!.isNotEmpty)
                      Text(quotation.clientEmail!,
                          style: TextStyle(color: Colors.grey[600])),
                    if (quotation.clientPhone != null &&
                        quotation.clientPhone!.isNotEmpty)
                      Text('Tel: ${quotation.clientPhone}',
                          style: TextStyle(color: Colors.grey[600])),
                    if (quotation.clientAddress != null &&
                        quotation.clientAddress!.isNotEmpty)
                      Text(quotation.clientAddress!,
                          style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dates card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha de emision',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          Text(dateFormat.format(quotation.issueDate),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vigencia hasta',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          Text(dateFormat.format(quotation.validUntil),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Items table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.list_alt, color: Colors.indigo, size: 20),
                        SizedBox(width: 8),
                        Text('Items',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Divider(),
                    if (quotation.items.isEmpty)
                      const Text('Sin items',
                          style: TextStyle(color: Colors.grey))
                    else
                      ...quotation.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  child: Text('${item.position}.',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.description,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit} x ${currencyFormat.format(item.unitPrice)}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  currencyFormat
                                      .format(item.quantity * item.unitPrice),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Totals card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTotalRow(
                        'Subtotal', currencyFormat.format(quotation.subtotal)),
                    if (quotation.discountPercentage > 0) ...[
                      _buildTotalRow(
                        'Descuento (${quotation.discountPercentage}%)',
                        '-${currencyFormat.format(quotation.discountAmount)}',
                      ),
                      _buildTotalRow(
                        'Subtotal con descuento',
                        currencyFormat.format(
                            quotation.subtotal - quotation.discountAmount),
                      ),
                    ],
                    _buildTotalRow(
                      'IVA (${quotation.taxPercentage.toStringAsFixed(0)}%)',
                      currencyFormat.format(quotation.taxAmount),
                    ),
                    const Divider(thickness: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(
                          currencyFormat.format(quotation.total),
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
              ),
            ),

            // Notes
            if (quotation.notes != null && quotation.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notas',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(quotation.notes!),
                    ],
                  ),
                ),
              ),
            ],

            // Terms
            if (quotation.termsConditions != null &&
                quotation.termsConditions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Terminos y Condiciones',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(quotation.termsConditions!),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Ver PDF'),
                    onPressed: () => _viewPdf(context, ref),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                    onPressed: () => _sharePdf(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Borrador':
        return Colors.grey;
      case 'Enviada':
        return Colors.blue;
      case 'Aceptada':
        return Colors.green;
      case 'Rechazada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'pdf_view':
        _viewPdf(context, ref);
        break;
      case 'pdf_share':
        _sharePdf(context, ref);
        break;
      case 'whatsapp':
        _sendWhatsApp(context);
        break;
      case 'email':
        _sendEmail(context);
        break;
      case 'status':
        _showChangeStatusSheet(context, ref);
        break;
    }
  }

  Future<void> _viewPdf(BuildContext context, WidgetRef ref) async {
    try {
      final pdfService = ref.read(pdfServiceProvider);
      final configAsync = await ref.read(getCompanyConfigProvider.future);

      final pdfBytes = await pdfService.generateQuotationPdf(
        quotation: quotation,
        config: configAsync,
      );

      if (!context.mounted) return;

      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'Cotizacion_${quotation.quotationNumber}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generando PDF: $e')),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context, WidgetRef ref) async {
    try {
      final pdfService = ref.read(pdfServiceProvider);
      final configAsync = await ref.read(getCompanyConfigProvider.future);

      final pdfBytes = await pdfService.generateQuotationPdf(
        quotation: quotation,
        config: configAsync,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/Cotizacion_${quotation.quotationNumber}.pdf');
      await file.writeAsBytes(pdfBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Cotizacion #${quotation.quotationNumber} - ${quotation.clientName}',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error compartiendo PDF: $e')),
        );
      }
    }
  }

  Future<void> _sendWhatsApp(BuildContext context) async {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    final phone = (quotation.clientPhone ?? '').replaceAll(RegExp(r'[^\d+]'), '');
    final message = Uri.encodeComponent(
      'Hola ${quotation.clientName}, le enviamos la cotizacion '
      '#${quotation.quotationNumber} por un total de '
      '${currencyFormat.format(quotation.total)}. Quedo atento.',
    );

    final url = phone.isNotEmpty
        ? 'https://wa.me/$phone?text=$message'
        : 'https://wa.me/?text=$message';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    final email = quotation.clientEmail ?? '';
    final subject = Uri.encodeComponent(
      'Cotizacion #${quotation.quotationNumber}',
    );
    final body = Uri.encodeComponent(
      'Estimado/a ${quotation.clientName},\n\n'
      'Adjunto encontrara la cotizacion #${quotation.quotationNumber} '
      'por un total de ${currencyFormat.format(quotation.total)}.\n\n'
      'Quedo atento a sus comentarios.\n\nSaludos cordiales.',
    );

    final uri = Uri.parse('mailto:$email?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el cliente de correo')),
        );
      }
    }
  }

  void _showChangeStatusSheet(BuildContext context, WidgetRef ref) {
    final statuses = ['Borrador', 'Enviada', 'Aceptada', 'Rechazada'];

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Cambiar Estado',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            ...statuses.map((status) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(status),
                    radius: 12,
                  ),
                  title: Text(status),
                  trailing: status == quotation.status
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    if (status != quotation.status) {
                      final updated = quotation.copyWith(
                        status: status,
                        updatedAt: DateTime.now(),
                      );
                      ref
                          .read(quotationNotifierProvider.notifier)
                          .updateQuotation(updated);
                    }
                    Navigator.of(context).pop();
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
