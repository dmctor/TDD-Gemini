import '../../models/entities/invoice.dart';
import '../../models/entities/isp_service.dart';
import '../models/filter_criteria.dart';
import '../models/financial_item.dart';
import '../models/financial_summary.dart';
import '../models/invoice_item.dart';
import '../models/invoice_period.dart';
import '../models/validation_result.dart';

/// Calculo de los totales del resumen financiero (RN-05).
abstract class FinancialSummaryCalculator {
  FinancialSummary calculate({
    required List<FinancialItem> ingresos,
    required List<FinancialItem> egresos,
  });
}

/// Filtrado de los registros del resumen financiero (RN-06 a RN-09).
abstract class FinancialFilter {
  List<FinancialItem> apply(
    List<FinancialItem> items,
    FilterCriteria criteria,
  );
}

/// Seleccion y confirmacion de servicios a facturar (RN-11, RN-12).
abstract class InvoicingSelection {
  Set<int> toggle(Set<int> selection, int index, List<InvoiceItem> services);
  List<InvoiceItem> confirm(Set<int> selection, List<InvoiceItem> services);
}

/// Validacion del formulario de registro de servicio ISP (RN-13).
abstract class IspServiceFormValidator {
  ValidationResult validate({
    required String description,
    required String price,
    required String payCode,
    required int? ispId,
  });
}

/// Determina el periodo de facturacion (RN-17).
abstract class InvoicePeriodResolver {
  InvoicePeriod periodOf(Invoice invoice);
  List<InvoicePeriod> availablePeriods(List<Invoice> invoices);
  InvoicePeriod? activePeriod(List<Invoice> invoices);
  List<Invoice> filterByPeriod(List<Invoice> invoices, InvoicePeriod period);
}

/// Construye la lista de servicios a facturar (RN-04, RN-11).
abstract class InvoiceItemMapper {
  List<InvoiceItem> map({
    required List<Invoice> invoices,
    required List<IspService> services,
    Map<int, String>? ispNames,
  });
}
