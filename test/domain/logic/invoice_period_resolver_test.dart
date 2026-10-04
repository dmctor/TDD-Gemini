import 'package:flutter_test/flutter_test.dart';
import 'package:proveedify/domain/contracts/invoice_period_resolver.dart';
import 'package:proveedify/domain/logic/invoice_period_resolver_impl.dart';
import 'package:proveedify/domain/models/invoice.dart';
import 'package:proveedify/domain/models/invoice_period.dart';

void main() {
  late InvoicePeriodResolver resolver;

  setUp(() {
    resolver = InvoicePeriodResolverImpl();
  });

  group('RN-17: Resolucion de periodos de facturacion', () {
    test(
      'Criterio 1: Dado una factura emitida en 2025 con mes de facturacion 3, cuando se determina su periodo, entonces el periodo es marzo de 2025',
      () {
        // Arrange
        final factura = Invoice(
          id: 1,
          fechaEmision: DateTime(2025, 4, 10),
          mesFacturacion: 3,
          serviceId: 100,
          estaFacturada: false,
        );

        // Act
        final periodo = resolver.periodOf(factura);

        // Assert
        expect(periodo.year, equals(2025));
        expect(periodo.month, equals(3));
        expect(periodo.label.toLowerCase(), contains('marzo 2025'));
      },
    );

    test(
      'Criterio 2: Dado un conjunto de facturas con periodos repetidos, cuando se listan los periodos disponibles, entonces cada periodo aparece una sola vez',
      () {
        // Arrange
        final facturas = [
          Invoice(
              id: 1,
              fechaEmision: DateTime(2025, 3, 1),
              mesFacturacion: 3,
              serviceId: 10,
              estaFacturada: false),
          Invoice(
              id: 2,
              fechaEmision: DateTime(2025, 3, 15),
              mesFacturacion: 3,
              serviceId: 11,
              estaFacturada: true),
          Invoice(
              id: 3,
              fechaEmision: DateTime(2025, 2, 1),
              mesFacturacion: 2,
              serviceId: 10,
              estaFacturada: false),
        ];

        // Act
        final periodos = resolver.availablePeriods(facturas);

        // Assert
        expect(periodos.length, equals(2));
        final claves = periodos.map((p) => '${p.year}-${p.month}').toSet();
        expect(claves.length, equals(2));
      },
    );

    test(
      'Criterio 3: Dado facturas de periodos distintos, cuando se listan los periodos, entonces se ordenan del mas reciente al mas antiguo',
      () {
        // Arrange
        final facturas = [
          Invoice(
              id: 1,
              fechaEmision: DateTime(2024, 12, 1),
              mesFacturacion: 12,
              serviceId: 10,
              estaFacturada: false),
          Invoice(
              id: 2,
              fechaEmision: DateTime(2025, 5, 1),
              mesFacturacion: 5,
              serviceId: 10,
              estaFacturada: false),
          Invoice(
              id: 3,
              fechaEmision: DateTime(2025, 1, 1),
              mesFacturacion: 1,
              serviceId: 10,
              estaFacturada: false),
        ];

        // Act
        final periodos = resolver.availablePeriods(facturas);

        // Assert
        expect(periodos[0].year, equals(2025));
        expect(periodos[0].month, equals(5));
        expect(periodos[1].year, equals(2025));
        expect(periodos[1].month, equals(1));
        expect(periodos[2].year, equals(2024));
        expect(periodos[2].month, equals(12));
      },
    );

    test(
      'Criterio 4: Dado un conjunto de facturas, cuando se determina el periodo activo, entonces corresponde al mas reciente',
      () {
        // Arrange
        final facturas = [
          Invoice(
              id: 1,
              fechaEmision: DateTime(2025, 2, 1),
              mesFacturacion: 2,
              serviceId: 10,
              estaFacturada: false),
          Invoice(
              id: 2,
              fechaEmision: DateTime(2025, 4, 1),
              mesFacturacion: 4,
              serviceId: 10,
              estaFacturada: false),
          Invoice(
              id: 3,
              fechaEmision: DateTime(2025, 1, 1),
              mesFacturacion: 1,
              serviceId: 10,
              estaFacturada: false),
        ];

        // Act
        final periodoActivo = resolver.activePeriod(facturas);

        // Assert
        expect(periodoActivo, isNotNull);
        expect(periodoActivo!.year, equals(2025));
        expect(periodoActivo.month, equals(4));
      },
    );

    test(
      'Criterio 5: Dado que no hay facturas, cuando se determina el periodo activo, entonces no hay periodo activo',
      () {
        // Arrange
        final facturasVacias = <Invoice>[];

        // Act
        final periodoActivo = resolver.activePeriod(facturasVacias);

        // Assert
        expect(periodoActivo, isNull);
      },
    );

    test(
      'Criterio 6: Dado un periodo seleccionado, cuando se filtran las facturas, entonces solo se conservan las de ese periodo distinguiendo el mismo mes de anios distintos',
      () {
        // Arrange
        final periodoMarzo2025 = InvoicePeriod(year: 2025, month: 3);
        final facturas = [
          Invoice(
              id: 1,
              fechaEmision: DateTime(2025, 3, 10),
              mesFacturacion: 3,
              serviceId: 10,
              estaFacturada: false),
          Invoice(
              id: 2,
              fechaEmision: DateTime(2024, 3, 10),
              mesFacturacion: 3,
              serviceId: 10,
              estaFacturada: false),
          Invoice(
              id: 3,
              fechaEmision: DateTime(2025, 4, 10),
              mesFacturacion: 4,
              serviceId: 10,
              estaFacturada: false),
        ];

        // Act
        final filtradas = resolver.filterByPeriod(facturas, periodoMarzo2025);

        // Assert
        expect(filtradas.length, equals(1));
        expect(filtradas.first.id, equals(1));
      },
    );
  });
}
