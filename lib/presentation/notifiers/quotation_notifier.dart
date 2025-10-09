// lib/presentation/notifiers/quotation_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/providers.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/quotation_item.dart';
import '../../domain/usecases/quotation/create_quotation.dart';
import '../../domain/usecases/quotation/get_quotations.dart';

/// Gestor de estado (Controller) para las cotizaciones.
/// El estado es AsyncValue<List<Quotation>>.
class QuotationNotifier extends AsyncNotifier<List<Quotation>> {
  // Los Use Cases se obtienen con ref.read() dentro de los métodos.

  /// El método `build` se llama una vez para inicializar el estado.
  @override
  Future<List<Quotation>> build() async {
    final getQuotations = ref.read(getQuotationsUseCaseProvider);
    return getQuotations.execute();
  }

  /// Recarga la lista de cotizaciones desde la base de datos.
  Future<void> loadQuotations() async {
    state = const AsyncValue.loading();
    try {
      final quotations = await ref.read(getQuotationsUseCaseProvider).execute();
      state = AsyncValue.data(quotations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Crea y guarda una nueva cotización.
  Future<void> createQuotation(Quotation quotation) async {
    final createQuotationUC = ref.read(createQuotationUseCaseProvider);

    state = await AsyncValue.guard(() async {
      // 1. Ejecutar el Use Case de creación
      await createQuotationUC.execute(quotation);

      // 2. Si la creación es exitosa, recargamos la lista
      return ref.read(getQuotationsUseCaseProvider).execute();
    });
  }

  Future<void> deleteQuotation(String id) async {
    final deleteQuotationUC = ref.read(deleteQuotationUseCaseProvider);
    await deleteQuotationUC.execute(id);
    await loadQuotations();
  }

  Future<void> updateQuotation(Quotation quotation) async {
    final updateQuotationUC = ref.read(updateQuotationUseCaseProvider);
    await updateQuotationUC.execute(quotation);
    await loadQuotations();
  }
}

/// Provider que expone el QuotationNotifier
final quotationNotifierProvider =
    AsyncNotifierProvider<QuotationNotifier, List<Quotation>>(
      QuotationNotifier.new,
    );
