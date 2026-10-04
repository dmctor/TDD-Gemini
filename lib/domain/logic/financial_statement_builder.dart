import 'package:proveedify/core/result.dart';
import 'package:proveedify/domain/contracts/logic.dart';
import 'package:proveedify/domain/contracts/repositories.dart';
import 'package:proveedify/domain/models/financial_item.dart';
import 'package:proveedify/domain/models/financial_summary.dart';
import 'package:proveedify/models/entities/invoice.dart';
import 'package:proveedify/models/entities/isp_service.dart';
import 'package:proveedify/models/entities/provider_service.dart';

class FinancialStatementResult {
  final List<FinancialItem> ingresos;
  final List<FinancialItem> egresos;
  final FinancialSummary summary;

  FinancialStatementResult({
    required this.ingresos,
    required this.egresos,
    required this.summary,
  });
}

class FinancialStatementBuilder {
  final InvoiceRepository invoiceRepository;
  final FinancialSummaryCalculator calculator;

  FinancialStatementBuilder({
    required this.invoiceRepository,
    required this.calculator,
  });

  Future<Result<FinancialStatementResult>> buildStatement({
    required List<ProviderService> providerServices,
    required List<IspService> ispServices,
    required String ruc,
    required String dependency,
  }) async {
    // Si no hay servicios registrados se devuelven listas vacías (Criterio 5)
    if (providerServices.isEmpty && ispServices.isEmpty) {
      final emptySummary = calculator.calculate(ingresos: [], egresos: []);
      return Result.success(
        FinancialStatementResult(
          ingresos: [],
          egresos: [],
          summary: emptySummary,
        ),
      );
    }

    // 1. Obtener facturas de servicios propios
    final providerInvoicesResult =
        await invoiceRepository.getProviderInvoices(providerServices);
    if (providerInvoicesResult.isFailure) {
      return Result.failure(providerInvoicesResult.error ??
          'Error al obtener facturas de proveedor');
    }

    // 2. Obtener facturas de operador
    final ispInvoicesResult =
        await invoiceRepository.getIspInvoices(ispServices);
    if (ispInvoicesResult.isFailure) {
      return Result.failure(
          ispInvoicesResult.error ?? 'Error al obtener facturas de operador');
    }

    // 3. Procesar ingresos aplicando RN-03 y RN-04 (omitir no coincidentes)
    final List<FinancialItem> ingresos = [];
    final List<Invoice> providerInvoices = providerInvoicesResult.data ?? [];
    for (var invoice in providerInvoices) {
      ProviderService? matchedService;
      for (var s in providerServices) {
        if (s.id == invoice.serviceId) {
          matchedService = s;
          break;
        }
      }

      if (matchedService != null) {
        ingresos.add(
          FinancialItem(
            name: matchedService.description,
            ruc: ruc,
            dependency: dependency,
            ispName: null,
            issueDate: invoice.issueDate,
            amount: matchedService.price,
          ),
        );
      }
    }

    // 4. Procesar egresos aplicando RN-03 y RN-04 (omitir no coincidentes)
    final List<FinancialItem> egresos = [];
    final List<Invoice> ispInvoices = ispInvoicesResult.data ?? [];
    for (var invoice in ispInvoices) {
      IspService? matchedIsp;
      for (var s in ispServices) {
        if (s.id == invoice.serviceId) {
          matchedIsp = s;
          break;
        }
      }

      if (matchedIsp != null) {
        egresos.add(
          FinancialItem(
            name: matchedIsp.description,
            ruc: ruc,
            dependency: dependency,
            ispName: matchedIsp.description,
            issueDate: invoice.issueDate,
            amount: matchedIsp.cost,
          ),
        );
      }
    }

    // 5. Calcular resumen final con las listas depuradas
    final summary = calculator.calculate(ingresos: ingresos, egresos: egresos);

    return Result.success(
      FinancialStatementResult(
        ingresos: ingresos,
        egresos: egresos,
        summary: summary,
      ),
    );
  }
}
