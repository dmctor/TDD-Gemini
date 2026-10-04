import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:proveedify/domain/models/invoice_item.dart';
import 'package:proveedify/domain/models/invoice_period.dart';
import 'package:proveedify/pages/invoices/invoices_controller.dart';
import 'package:proveedify/pages/invoices/invoices_page.dart';

class MockInvoicesController extends Mock implements InvoicesController {}

void main() {
  late MockInvoicesController mockController;

  setUp(() {
    mockController = MockInvoicesController();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: InvoicesPage(controller: mockController),
    );
  }

  group('HU-05 / RN-11 / RN-17: Vista de consulta y seleccion de servicios',
      () {
    testWidgets(
      'Criterio 1: Dado una lista de servicios del periodo, cuando se consulta, entonces se muestran con su descripcion, operador, monto y estado',
      (tester) async {
        // Arrange
        final items = [
          InvoiceItem(
            id: 1,
            servicio: 'Internet Simetrico 500M',
            isp: 'Win',
            monto: 119.0,
            estado: InvoiceStatus.pendiente,
          ),
        ];

        when(() => mockController.items).thenReturn(items);
        when(() => mockController.selectedIds).thenReturn({});
        when(() => mockController.availablePeriods)
            .thenReturn([InvoicePeriod(year: 2025, month: 3)]);
        when(() => mockController.activePeriod)
            .thenReturn(InvoicePeriod(year: 2025, month: 3));

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Assert
        expect(find.text('Internet Simetrico 500M'), findsOneWidget);
        expect(find.textContaining('Win'), findsOneWidget);
        expect(find.textContaining('119.0'), findsOneWidget);
        expect(find.textContaining('pendiente', skipOffstage: false),
            findsOneWidget);
      },
    );

    testWidgets(
      'Criterio 5: Dado un periodo sin servicios pendientes, cuando se consulta, entonces se muestra una lista vacia sin generar error',
      (tester) async {
        // Arrange
        when(() => mockController.items).thenReturn([]);
        when(() => mockController.selectedIds).thenReturn({});
        when(() => mockController.availablePeriods).thenReturn([]);
        when(() => mockController.activePeriod).thenReturn(null);

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Assert
        expect(tester.takeException(), isNull);
        expect(find.byType(ListView), findsNothing);
        expect(find.text('No hay servicios disponibles'), findsOneWidget);
      },
    );

    testWidgets(
      'Criterio 4: Al interactuar con un servicio facturado, no se dispara accion de seleccion',
      (tester) async {
        // Arrange
        final itemFacturado = InvoiceItem(
          id: 5,
          servicio: 'Hosting Dedicado',
          isp: 'Claro',
          monto: 250.0,
          estado: InvoiceStatus.facturado,
        );

        when(() => mockController.items).thenReturn([itemFacturado]);
        when(() => mockController.selectedIds).thenReturn({});
        when(() => mockController.availablePeriods)
            .thenReturn([InvoicePeriod(year: 2025, month: 3)]);
        when(() => mockController.activePeriod)
            .thenReturn(InvoicePeriod(year: 2025, month: 3));

        // Act
        await tester.pumpWidget(buildTestableWidget());
        await tester.tap(find.text('Hosting Dedicado'));
        await tester.pump();

        // Assert
        verifyNever(() => mockController.toggleSelection(any()));
      },
    );

    testWidgets(
      'Criterio 8: Dado un cambio de periodo, cuando se recarga la lista, entonces la seleccion previa queda vacia',
      (tester) async {
        // Arrange
        final periodoMarzo = InvoicePeriod(year: 2025, month: 3);
        final periodoFebrero = InvoicePeriod(year: 2025, month: 2);

        when(() => mockController.items).thenReturn([]);
        when(() => mockController.selectedIds).thenReturn({101});
        when(() => mockController.availablePeriods)
            .thenReturn([periodoMarzo, periodoFebrero]);
        when(() => mockController.activePeriod).thenReturn(periodoMarzo);

        // Act
        await tester.pumpWidget(buildTestableWidget());

        await tester.tap(find.byType(DropdownButton<InvoicePeriod>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(periodoFebrero.label).last);
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockController.changePeriod(periodoFebrero)).called(1);
        verify(() => mockController.clearSelection()).called(1);
      },
    );
  });

  group('HU-06 / RN-12: Confirmacion explicita de la facturacion', () {
    void stubSeleccion() {
      when(() => mockController.items).thenReturn([]);
      when(() => mockController.selectedIds).thenReturn({1, 2});
      when(() => mockController.availablePeriods).thenReturn([]);
      when(() => mockController.activePeriod).thenReturn(null);
      when(() => mockController.confirmInvoicing())
          .thenAnswer((_) async => true);
    }

    testWidgets(
      'Criterio 4: Dado una accion de facturacion, cuando se solicita, entonces se muestra una confirmacion y solo al aceptarla se aplica el cambio',
      (tester) async {
        // Arrange
        stubSeleccion();
        await tester.pumpWidget(buildTestableWidget());

        // Act
        await tester.tap(find.byKey(const Key('btn_invoice_services')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('¿Desea facturar los servicios seleccionados?'),
            findsOneWidget);
        verifyNever(() => mockController.confirmInvoicing());

        // Act
        await tester.tap(find.byKey(const Key('btn_confirm_dialog_action')));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockController.confirmInvoicing()).called(1);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets(
      'Criterio 4: Dado un dialogo de confirmacion, cuando el usuario cancela, entonces no se aplica la facturacion',
      (tester) async {
        // Arrange
        stubSeleccion();
        await tester.pumpWidget(buildTestableWidget());

        // Act
        await tester.tap(find.byKey(const Key('btn_invoice_services')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_cancel_dialog_action')));
        await tester.pumpAndSettle();

        // Assert
        verifyNever(() => mockController.confirmInvoicing());
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets(
      'Criterio 2: Dado ningun servicio seleccionado, cuando se muestra la pantalla, entonces la accion de facturar no esta disponible',
      (tester) async {
        // Arrange
        when(() => mockController.items).thenReturn([]);
        when(() => mockController.selectedIds).thenReturn({});
        when(() => mockController.availablePeriods).thenReturn([]);
        when(() => mockController.activePeriod).thenReturn(null);

        // Act
        await tester.pumpWidget(buildTestableWidget());
        await tester.tap(find.byKey(const Key('btn_invoice_services')),
            warnIfMissed: false);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsNothing);
        verifyNever(() => mockController.confirmInvoicing());
      },
    );
  });
}
