import '../../models/entities/invoice.dart';
import '../contracts/logic.dart';
import '../models/invoice_period.dart';

class InvoicePeriodResolverImpl implements InvoicePeriodResolver {
  @override
  InvoicePeriod periodOf(Invoice invoice) {
    // El anio viene de la fecha de emision y el mes del mesFacturacion
    return InvoicePeriod(
      year: invoice.fechaEmision.year,
      month: invoice.mesFacturacion,
    );
  }

  @override
  List<InvoicePeriod> availablePeriods(List<Invoice> invoices) {
    final List<InvoicePeriod> periodos = [];

    for (final factura in invoices) {
      final periodo = periodOf(factura);
      // Evitar duplicados
      final yaExiste = periodos.any(
        (p) => p.year == periodo.year && p.month == periodo.month,
      );
      if (!yaExiste) {
        periodos.add(periodo);
      }
    }

    // Ordenar de mas reciente a mas antiguo
    periodos.sort((a, b) {
      if (a.year != b.year) {
        return b.year.compareTo(a.year);
      }
      return b.month.compareTo(a.month);
    });

    return periodos;
  }

  @override
  InvoicePeriod? activePeriod(List<Invoice> invoices) {
    final periodos = availablePeriods(invoices);
    if (periodos.isEmpty) {
      return null;
    }
    // El primero es el mas reciente tras el ordenamiento
    return periodos.first;
  }

  @override
  List<Invoice> filterByPeriod(List<Invoice> invoices, InvoicePeriod period) {
    final List<Invoice> resultado = [];

    for (final factura in invoices) {
      final periodoFactura = periodOf(factura);
      if (periodoFactura.year == period.year &&
          periodoFactura.month == period.month) {
        resultado.add(factura);
      }
    }

    return resultado;
  }
}
