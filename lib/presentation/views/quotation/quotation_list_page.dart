import 'package:flutter/material.dart';
import 'package:giova_sas/domain/usecases/quotation/get_quotations.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/quotation.dart';
import '../../../domain/usecases/quotation/get_quotations.dart';
import '../../../domain/usecases/quotation/delete_quotation.dart';
import '../../../data/repositories/quotation_repository_impl.dart';
import '../../../datasources/database_helper.dart';
import 'quotation_form_modal.dart';

class QuotationListView extends StatefulWidget {
  const QuotationListView({super.key});

  @override
  State<QuotationListView> createState() => _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListView> {
  late final QuotationRepositoryImpl _repository;
  late final GetQuotations _getAllQuotations;
  late final DeleteQuotation _deleteQuotation;

  List<Quotation> _quotations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = QuotationRepositoryImpl(DatabaseHelper.instance);
    _getAllQuotations = GetQuotations(_repository);
    _deleteQuotation = DeleteQuotation(_repository);
    _loadQuotations();
  }

  Future<void> _loadQuotations() async {
    setState(() => _loading = true);
    try {
      final items = await _getAllQuotations.execute();
      setState(() {
        _quotations = items;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Error al cargar cotizaciones: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openForm([Quotation? quotation]) async {
    await showDialog(
      context: context,
      builder: (_) => QuotationFormModal(quotationToEdit: quotation),
    );
    _loadQuotations();
  }

  void _delete(String id) async {
    await _deleteQuotation.execute(id);
    _loadQuotations();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuotations,
          ),
        ],
      ),
      body: _quotations.isEmpty
          ? const Center(child: Text('No hay cotizaciones registradas'))
          : ListView.builder(
              itemCount: _quotations.length,
              itemBuilder: (context, i) {
                final q = _quotations[i];
                return ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text('Cotización #${q.quotationNumber}'),
                  subtitle: Text(
                    '${q.clientName}  ·  Total: ${q.total.toStringAsFixed(2)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openForm(q),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(q.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
