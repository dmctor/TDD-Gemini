import 'package:flutter_test/flutter_test.dart';
import 'package:proveedify/domain/contracts/invoicing_selection.dart';
import 'package:proveedify/domain/logic/invoicing_selection_impl.dart';
import 'package:proveedify/domain/models/invoice_item.dart';

void main() {
  late InvoicingSelection selectionLogic;

  setUp(() {
    selectionLogic = InvoicingSelectionImpl();
  });

  group('RN-11: Seleccion de servicios a facturar', () {
    final servicioPendiente1 = InvoiceItem(
      id: 101,
      servicio: 'Fibra 300 Mbps',
      isp: 'Movistar',
      monto: 70.0,
      estado: InvoiceStatus.pendiente,
    );

    final servicioPendiente2 = InvoiceItem(
      id: 102,
      servicio: 'Telefonia IP',
      isp: 'Movistar',
      monto: 20.0,
      estado: InvoiceStatus.pendiente,
    );

    final servicioFacturado = InvoiceItem(
      id: 103,
      servicio: 'Cable TV',
      isp: 'Movistar',
      monto: 35.0,
      estado: InvoiceStatus.facturado,
    );

    final servicios = [
      servicioPendiente1,
      servicioPendiente2,
      servicioFacturado
    ];

    test(
      'Criterio 2: Dado un servicio en estado pendiente no seleccionado, cuando se alterna su seleccion, entonces queda incluido en la seleccion',
      () {
        // Arrange
        final seleccionInicial = <int>{};
        const indice = 0; // servicioPendiente1

        // Act
        final resultado =
            selectionLogic.toggle(seleccionInicial, indice, servicios);

        // Assert
        expect(resultado, contains(servicioPendiente1.id));
        expect(resultado.length, equals(1));
      },
    );

    test(
      'Criterio 3: Dado un servicio ya seleccionado, cuando se alterna su seleccion, entonces queda excluido de la seleccion',
      () {
        // Arrange
        final seleccionInicial = <int>{servicioPendiente1.id};
        const indice = 0; // servicioPendiente1

        // Act
        final resultado =
            selectionLogic.toggle(seleccionInicial, indice, servicios);

        // Assert
        expect(resultado, isNot(contains(servicioPendiente1.id)));
        expect(resultado, isEmpty);
      },
    );

    test(
      'Criterio 4: Dado un servicio en estado facturado, cuando se intenta seleccionarlo, entonces la seleccion permanece sin cambios',
      () {
        // Arrange
        final seleccionInicial = <int>{servicioPendiente1.id};
        const indiceFacturado = 2; // servicioFacturado

        // Act
        final resultado =
            selectionLogic.toggle(seleccionInicial, indiceFacturado, servicios);

        // Assert
        expect(resultado, equals(seleccionInicial));
        expect(resultado, isNot(contains(servicioFacturado.id)));
      },
    );
  });

  group('RN-12: Confirmacion de facturacion de los servicios seleccionados', () {
    InvoiceItem item(int id, InvoiceStatus estado) => InvoiceItem(
          id: id,
          servicio: 'Servicio $id',
          isp: 'Movistar',
          monto: 10.0 * id,
          estado: estado,
        );

    test(
      'Criterio 1: Dado dos servicios seleccionados, cuando se confirma la facturacion, entonces ambos quedan facturados y la seleccion queda vacia',
      () {
        // Arrange
        final servicios = [
          item(1, InvoiceStatus.pendiente),
          item(2, InvoiceStatus.pendiente),
          item(3, InvoiceStatus.pendiente),
        ];
        final seleccion = <int>{1, 2};

        // Act
        final resultado = selectionLogic.confirm(seleccion, servicios);

        // Assert
        expect(resultado.firstWhere((s) => s.id == 1).estado,
            equals(InvoiceStatus.facturado));
        expect(resultado.firstWhere((s) => s.id == 2).estado,
            equals(InvoiceStatus.facturado));
        expect(resultado.firstWhere((s) => s.id == 3).estado,
            equals(InvoiceStatus.pendiente));
        expect(seleccion, isEmpty);
      },
    );

    test(
      'Criterio 2: Dado ningun servicio seleccionado, cuando se confirma la facturacion, entonces no se modifica ningun estado',
      () {
        // Arrange
        final servicios = [
          item(1, InvoiceStatus.pendiente),
          item(2, InvoiceStatus.facturado),
        ];
        final seleccion = <int>{};

        // Act
        final resultado = selectionLogic.confirm(seleccion, servicios);

        // Assert
        expect(resultado.map((s) => s.estado).toList(),
            equals([InvoiceStatus.pendiente, InvoiceStatus.facturado]));
        expect(resultado.length, equals(servicios.length));
        expect(seleccion, isEmpty);
      },
    );

    test(
      'Criterio 3: Dado un servicio ya facturado, cuando se confirma la facturacion, entonces su estado permanece facturado y no se genera error',
      () {
        // Arrange
        final servicios = [
          item(1, InvoiceStatus.facturado),
          item(2, InvoiceStatus.pendiente),
        ];
        final seleccion = <int>{1};

        // Act
        late List<InvoiceItem> resultado;
        expect(
          () => resultado = selectionLogic.confirm(seleccion, servicios),
          returnsNormally,
        );

        // Assert
        expect(resultado.firstWhere((s) => s.id == 1).estado,
            equals(InvoiceStatus.facturado));
        expect(resultado.firstWhere((s) => s.id == 2).estado,
            equals(InvoiceStatus.pendiente));
      },
    );
  });
}
