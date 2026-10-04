import '../contracts/financial_filter.dart'; // O '../contracts/logic.dart' según como esté nombrado tu archivo de contrato
import '../models/filter_criteria.dart';
import '../models/financial_item.dart';

class FinancialFilterImpl implements FinancialFilter {
  @override
  List<FinancialItem> apply(
      List<FinancialItem> items, FilterCriteria criteria) {
    if (!criteria.isActive) {
      return items;
    }

    final resultado = <FinancialItem>[];

    for (final item in items) {
      var pasaElFiltro = true;

      if (criteria.name != null && criteria.name!.trim().isNotEmpty) {
        final textoBuscado = criteria.name!.trim().toLowerCase();
        if (!item.name.toLowerCase().contains(textoBuscado)) {
          pasaElFiltro = false;
        }
      }

      if (criteria.ruc != null && criteria.ruc!.trim().isNotEmpty) {
        final rucBuscado = criteria.ruc!.trim();
        if (!item.ruc.contains(rucBuscado)) {
          pasaElFiltro = false;
        }
      }

      if (criteria.dependency != null && criteria.dependency!.trim().isNotEmpty) {
        final depBuscada = criteria.dependency!.trim().toLowerCase();
        if (!item.dependency.toLowerCase().contains(depBuscada)) {
          pasaElFiltro = false;
        }
      }

      final queryOperador = criteria.operatorQuery ?? criteria.ispName;
      if (queryOperador != null && queryOperador.trim().isNotEmpty) {
        if (item.ispName == null ||
            !item.ispName!.toLowerCase().contains(queryOperador.trim().toLowerCase())) {
          pasaElFiltro = false;
        }
      }

      if (criteria.startDate != null && item.date.isBefore(criteria.startDate!)) {
        pasaElFiltro = false;
      }

      if (criteria.endDate != null && item.date.isAfter(criteria.endDate!)) {
        pasaElFiltro = false;
      }

      final minAmount = criteria.minAmount ?? 0.0;
      final maxAmount = criteria.maxAmount ?? 999999.0;
      if (item.amount < minAmount || item.amount > maxAmount) {
        pasaElFiltro = false;
      }

      if (pasaElFiltro) {
        resultado.add(item);
      }
    }

    return resultado;
  }
}
