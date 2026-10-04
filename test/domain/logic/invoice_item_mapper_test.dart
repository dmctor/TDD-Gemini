import 'package:flutter_test/flutter_test.dart';
import 'package:proveedify/domain/contracts/invoice_item_mapper.dart';
import 'package:proveedify/domain/logic/invoice_item_mapper_impl.dart';
import 'package:proveedify/domain/models/invoice.dart';
import 'package:proveedify/domain/models/invoice_item.dart';
import 'package:proveedify/domain/models/isp_service.dart';

void main() {
  late InvoiceItemMapper mapper;

  setUp(() {
    mapper = InvoiceItemMapperImpl();
  });

  group('RN-17 / RN-04: Mapeo de facturas a items de servicio', () {
    test(
      'Criterio 7: Dado una factura no facturada, su estado es pendiente; si ya fue facturada, su estado es facturado',
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
              fechaEmision: DateTime(2025, 3, 1),
              mesFacturacion: 3,
              serviceId: 20,
              estaFacturada: true),
        ];
        final servicios = [
          IspService(id: 10, descripcion: 'Fibra 100M', ispId: 1, monto: 45.0),
          IspService(id: 20, descripcion: 'IP Fija', ispId: 1, monto: 15.0),
        ];
        final isps = {1: 'TotalPlay'};

        // Act
        final items =
            mapper.map(invoices: facturas, services: servicios, ispNames: isps);

        // Assert
        final pendiente = items.firstWhere((i) => i.id == 1);
        final facturado = items.firstWhere((i) => i.id == 2);

        expect(pendiente.estado, equals(InvoiceStatus.pendiente));
        expect(pendiente.servicio, equals('Fibra 100M'));
        expect(pendiente.monto, equals(45.0));
        expect(pendiente.isp, equals('TotalPlay'));

        expect(facturado.estado, equals(InvoiceStatus.facturado));
        expect(facturado.servicio, equals('IP Fija'));
        expect(facturado.monto, equals(15.0));
      },
    );

    test(
      'RN-04: Una factura cuyo servicio no exista en la lista consultada se omite',
      () {
        // Arrange
        final facturas = [
          Invoice(
              id: 1,
              fechaEmision: DateTime(2025, 3, 1),
              mesFacturacion: 3,
              serviceId: 999,
              estaFacturada: false),
          Invoice(
              id: 2,
              fechaEmision: DateTime(2025, 3, 1),
              mesFacturacion: 3,
              serviceId: 10,
              estaFacturada: false),
        ];
        final servicios = [
          IspService(id: 10, descripcion: 'Plan Activo', ispId: 1, monto: 50.0),
        ];
        final isps = {1: 'TotalPlay'};

        // Act
        final items =
            mapper.map(invoices: facturas, services: servicios, ispNames: isps);

        // Assert
        expect(items.length, equals(1));
        expect(items.first.id, equals(2));
      },
    );
  });
}
