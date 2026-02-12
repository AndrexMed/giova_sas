import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/quotation.dart';
import '../../notifiers/quotation_notifier.dart';
import 'quotation_form_modal.dart';
import 'quotation_detail_page.dart';

class QuotationListView extends ConsumerWidget {
  const QuotationListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationListAsync = ref.watch(quotationNotifierProvider);

    return quotationListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error al cargar cotizaciones: $err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (quotations) {
        if (quotations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay cotizaciones registradas.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Presiona "+" para crear la primera.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: quotations.length,
          itemBuilder: (context, index) {
            final q = quotations[index];
            return QuotationListTile(quotation: q);
          },
        );
      },
    );
  }
}

class QuotationListTile extends ConsumerWidget {
  final Quotation quotation;

  const QuotationListTile({required this.quotation, super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QuotationDetailPage(quotationId: quotation.id),
            ),
          );
        },
        leading: const Icon(Icons.receipt_long, color: Colors.indigo),
        title: Text(
          'Cotizacion #${quotation.quotationNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                '${quotation.clientName}  ·  ${currencyFormat.format(quotation.total)}',
              ),
            ),
            Chip(
              label: Text(
                quotation.status,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: _statusColor(quotation.status),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      QuotationFormModal(quotationToEdit: quotation),
                );
              },
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
        title: const Text('Confirmar Eliminacion'),
        content: Text(
          'Estas seguro de que quieres eliminar la cotizacion #${quotation.quotationNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(quotationNotifierProvider.notifier)
                  .deleteQuotation(quotation.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
