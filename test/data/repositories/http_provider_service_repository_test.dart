import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:proveedify/data/repositories/http_provider_service_repository.dart';
import 'package:proveedify/models/entities/provider_service.dart';

void main() {
  const baseUrl = 'https://api.proveedify.pe';

  group('ProviderServiceRepository - getServicesByProvider', () {
    test(
        'Retorna lista de servicios en Result.success cuando el servicio responde 200',
        () async {
      // Arrange
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, equals('/providers/prov-10/services'));
        return http.Response(
          jsonEncode([
            {'id': 'srv-1', 'name': 'Fibra Óptica 200 Mbps', 'price': 250.50},
            {'id': 'srv-2', 'name': 'IP Pública Dinámica', 'price': 49.50},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository =
          HttpProviderServiceRepository(client: mockClient, baseUrl: baseUrl);

      // Act
      final result = await repository.getServicesByProvider('prov-10');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<List<ProviderService>>());
      expect(result.data!.length, equals(2));
      expect(result.data!.first.name, equals('Fibra Óptica 200 Mbps'));
      expect(result.data!.first.price, equals(250.50));
    });

    test(
        'Retorna Result.failure cuando el proveedor no existe y la respuesta es 404',
        () async {
      // Arrange
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final repository =
          HttpProviderServiceRepository(client: mockClient, baseUrl: baseUrl);

      // Act
      final result = await repository.getServicesByProvider('prov-invalid');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.error, isNotNull);
    });
  });
}
