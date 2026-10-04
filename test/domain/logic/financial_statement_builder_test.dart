import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:proveedify/core/result.dart';
import 'package:proveedify/domain/contracts/invoice_repository.dart';
import 'package:proveedify/domain/contracts/financial_summary_calculator.dart';
import 'package:proveedify/domain/logic/financial_statement_builder.dart';
import 'package:proveedify/domain/models/financial_item.dart';
import 'package:proveedify/domain/models/financial_summary.dart';
import 'package:proveedify/models/entities/invoice.dart';
import 'package:proveedify/models/entities/provider_service.dart';
import 'package:proveedify/models/entities/isp_service.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

class MockFinancialSummaryCalculator extends Mock
    implements FinancialSummaryCalculator {}

void main() {
  late MockInvoiceRepository mockRepo;
  late MockFinancialSummaryCalculator mockCalculator;
  late FinancialStatementBuilder builder;

  setUpAll(() {
    registerFallbackValue(<FinancialItem>[]);
    registerFallbackValue(<ProviderService>[]);
    registerFallbackValue(<IspService>[]);
  });

  setUp(() {
    mockRepo = MockInvoiceRepository();
    mockCalculator = MockFinancialSummaryCalculator();
    when(() => mockCalculator.calculate(
          ingresos: any(named: 'ingresos'),
          egresos: any(named: 'egresos'),
        )).thenReturn(
      const FinancialSummary(totalIngresos: 0.0, totalEgresos: 0.0),
    );
    builder = FinancialStatementBuilder(
      invoiceRepository: mockRepo,
      calculator: mockCalculator,
    );
  });

  group('RN-04: Omisión de identificadores de servicio inexistentes', () {
    test(
        'Criterio 6: Debe omitir la factura cuyo identificador no coincida y procesar las demás',
        () async {
      // Arrange
      final providerServices = [
        ProviderService(id: 'srv-1', name: 'Servicio 1', price: 100.0),
        ProviderService(id: 'srv-2', name: 'Servicio 2', price: 50.0),
      ];

      final invoicesFromRepo = [
        Invoice(
            id: 'inv-1',
            serviceId: 'srv-1',
            amount: 100.0,
            issueDate: DateTime(2025, 3, 7)),
        Invoice(
            id: 'inv-unknown',
            serviceId: 'srv-999',
            amount: 800.0,
            issueDate: DateTime(2025, 3, 7)),
        Invoice(
            id: 'inv-2',
            serviceId: 'srv-2',
            amount: 50.0,
            issueDate: DateTime(2025, 3, 7)),
      ];

      when(() => mockRepo.getProviderInvoices(providerServices))
          .thenAnswer((_) async => Result.success(invoicesFromRepo));
      when(() => mockRepo.getIspInvoices([]))
          .thenAnswer((_) async => Result.success([]));

      // Act
      final result = await builder.buildStatement(
        providerServices: providerServices,
        ispServices: [],
        ruc: '20123456789',
        dependency: 'Sede Lima',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      final statement = result.data!;
      expect(statement.ingresos.length, equals(2));
      expect(statement.ingresos.any((item) => item.amount == 800.0), isFalse);
    });
  });

  group(
      'RN-03 y RN-05: Integración de servicios vacíos y asignación de costos/precios',
      () {
    test(
        'Criterio 5: Proveedor sin servicios registrados retorna listas vacías sin consultar repositorios',
        () async {
      // Arrange
      final emptyProviderServices = <ProviderService>[];
      final emptyIspServices = <IspService>[];

      // Act
      final result = await builder.buildStatement(
        providerServices: emptyProviderServices,
        ispServices: emptyIspServices,
        ruc: '20123456789',
        dependency: 'Sede Lima',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.ingresos, isEmpty);
      expect(result.data!.egresos, isEmpty);
      verifyNever(() => mockRepo.getProviderInvoices(any()));
      verifyNever(() => mockRepo.getIspInvoices(any()));
    });
  });
}
