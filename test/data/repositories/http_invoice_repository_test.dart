import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:proveedify/data/repositories/http_invoice_repository.dart';
import 'package:proveedify/models/entities/invoice.dart';
import 'package:proveedify/models/entities/isp_service.dart';
import 'package:proveedify/models/entities/provider_service.dart';

void main() {
  const baseUrl = 'https://api.proveedify.pe';

  // ---------------------------------------------------------------------------
  // CAPA DE DATOS: InvoiceRepository (HTTP)
  // ---------------------------------------------------------------------------
  group('InvoiceRepository - getProviderInvoices', () {
    test(
        'Retorna lista de facturas de servicios propios en Result.success cuando el endpoint responde 200',
        () async {
      // Arrange
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, equals('/invoices/provider'));
        return http.Response(
          jsonEncode([
            {
              'id': 'inv-001',
              'serviceId': 'srv-001',
              'amount': 100.0,
              'issueDate': '2025-03-07T00:00:00.000Z',
            }
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository =
          HttpInvoiceRepository(client: mockClient, baseUrl: baseUrl);
      final services = [
        ProviderService(id: 'srv-001', name: 'Fibra', price: 100.0)
      ];

      // Act
      final result = await repository.getProviderInvoices(services);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<List<Invoice>>());
      expect(result.data!.length, equals(1));
      expect(result.data!.first.id, equals('inv-001'));
      expect(result.data!.first.amount, equals(100.0));
    });

    test('Retorna Result.failure cuando el servidor responde con status 500',
        () async {
      // Arrange
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final repository =
          HttpInvoiceRepository(client: mockClient, baseUrl: baseUrl);

      // Act
      final result = await repository.getProviderInvoices([]);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.error, isNotNull);
    });
  });

  group('InvoiceRepository - getIspInvoices', () {
    test(
        'Retorna lista de facturas de ISP en Result.success cuando el endpoint responde 200',
        () async {
      // Arrange
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, equals('/invoices/isp'));
        return http.Response(
          jsonEncode([
            {
              'id': 'isp-inv-001',
              'serviceId': 'isp-srv-001',
              'amount': 120.0,
              'issueDate': '2025-03-07T00:00:00.000Z',
            }
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository =
          HttpInvoiceRepository(client: mockClient, baseUrl: baseUrl);
      final services = [
        IspService(id: 'isp-srv-001', name: 'Carrier', cost: 120.0)
      ];

      // Act
      final result = await repository.getIspInvoices(services);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<List<Invoice>>());
      expect(result.data!.length, equals(1));
      expect(result.data!.first.amount, equals(120.0));
    });
  });

  group('RN-15 - Normalizacion de errores y respuestas de la capa de datos',
      () {
    test(
        'Criterio 5: Retorna Result.success con true cuando el servicio responde 200',
        () async {
      // Arrange
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, equals('/invoices/inv-001/mark'));
        return http.Response('OK', 200);
      });

      final repository =
          HttpInvoiceRepository(client: mockClient, baseUrl: baseUrl);
      final invoice = Invoice(
        id: 'inv-001',
        serviceId: 'srv-001',
        amount: 100.0,
        issueDate: DateTime(2025, 3, 7),
      );

      // Act
      final result = await repository.markAsInvoiced(invoice);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isTrue);
    });

    test(
        'Criterio 6: Retorna Result.failure con error de dominio normalizado y mensaje cuando el servicio responde 404',
        () async {
      // Arrange
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Factura no encontrada'}),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository =
          HttpInvoiceRepository(client: mockClient, baseUrl: baseUrl);
      final invoice = Invoice(
        id: 'inv-999',
        serviceId: 'srv-999',
        amount: 50.0,
        issueDate: DateTime(2025, 3, 7),
      );

      // Act
      final result = await repository.markAsInvoiced(invoice);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.error, isNotNull);
      expect(result.error!.message, equals('Factura no encontrada'));
      expect(result.error!.code, equals(404));
      expect(result.data, isNull);
    });

    test(
        'Retorna error con codigo 500 y no lanza excepcion cuando ocurre un fallo de red',
        () async {
      // Arrange
      final mockClient = MockClient((request) async {
        throw http.ClientException('Sin conexion');
      });

      final repository =
          HttpInvoiceRepository(client: mockClient, baseUrl: baseUrl);
      final invoice = Invoice(id: 'inv-001');

      // Act
      final result = await repository.markAsInvoiced(invoice);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.error!.code, equals(500));
    });
  });
}
