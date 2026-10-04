import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:proveedify/data/repositories/http_isp_service_repository.dart';
import 'package:proveedify/domain/contracts/session_storage.dart';
import 'package:proveedify/models/entities/isp_service.dart';

class MockSessionStorage extends Mock implements SessionStorage {}

void main() {
  const baseUrl = 'https://api.proveedify.pe';
  late MockSessionStorage session;

  setUp(() {
    session = MockSessionStorage();
    when(() => session.readToken()).thenAnswer((_) async => 'jwt-token');
  });

  IspService buildService({String description = 'Enlace dedicado 100 Mbps'}) {
    return IspService(
      ispId: 1,
      providerId: 1,
      description: description,
      cost: 120.0,
      payCode: 'PC-0001',
    );
  }

  group('RN-14: Codigos de respuesta del registro de servicios ISP', () {
    test(
      'Criterio 7: Dado una respuesta 201 del servicio de registro, cuando se registra el servicio, entonces la operacion se considera exitosa',
      () async {
        // Arrange
        final client = MockClient((request) async {
          expect(request.method, equals('POST'));
          expect(request.url.path, equals('/isp-services'));
          return http.Response(
            jsonEncode({
              'id': 10,
              'isp_id': 1,
              'provider_id': 1,
              'description': 'Enlace dedicado 100 Mbps',
              'cost': 120.0,
              'pay_code': 'PC-0001',
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        });
        final repository = HttpIspServiceRepository(
            client: client, session: session, baseUrl: baseUrl);

        // Act
        final result = await repository.create(buildService());

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, isA<IspService>());
        expect(result.data!.id, equals('10'));
        expect(result.data!.description, equals('Enlace dedicado 100 Mbps'));
      },
    );

    test(
      'Criterio 7 (limite): Dado una respuesta 201 sin cuerpo, cuando se registra el servicio, entonces la operacion sigue siendo exitosa',
      () async {
        // Arrange
        final client = MockClient((request) async => http.Response('', 201));
        final repository = HttpIspServiceRepository(
            client: client, session: session, baseUrl: baseUrl);

        // Act
        final result = await repository.create(buildService());

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
      },
    );

    test(
      'Criterio 8: Dado una respuesta 409 del servicio de registro, cuando se registra el servicio, entonces se informa que el servicio ya existe',
      () async {
        // Arrange
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Conflicto'}),
            409,
            headers: {'content-type': 'application/json'},
          );
        });
        final repository = HttpIspServiceRepository(
            client: client, session: session, baseUrl: baseUrl);

        // Act
        final result = await repository.create(buildService());

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error!.code, equals(409));
        expect(result.error!.message.toLowerCase(), contains('ya existe'));
      },
    );

    test(
      'Dado cualquier otro codigo de respuesta, cuando se registra el servicio, entonces se obtiene un error de registro con ese codigo',
      () async {
        // Arrange
        final client =
            MockClient((request) async => http.Response('Error', 422));
        final repository = HttpIspServiceRepository(
            client: client, session: session, baseUrl: baseUrl);

        // Act
        final result = await repository.create(buildService());

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error!.code, equals(422));
        expect(result.error!.message, isNotEmpty);
      },
    );
  });

  group('RN-13: Almacenamiento sin espacios en los extremos', () {
    test(
      'Criterio 6: Dado una descripcion y un codigo de pago con espacios en los extremos, cuando se construye y registra el servicio, entonces se almacenan sin dichos espacios',
      () async {
        // Arrange
        late Map<String, dynamic> enviado;
        final client = MockClient((request) async {
          enviado = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('', 201);
        });
        final repository = HttpIspServiceRepository(
            client: client, session: session, baseUrl: baseUrl);
        final servicio = IspService(
          ispId: 1,
          providerId: 1,
          description: '   Enlace dedicado   ',
          cost: 120.0,
          payCode: '  PC-0001  ',
        );

        // Act
        await repository.create(servicio);

        // Assert
        expect(servicio.description, equals('Enlace dedicado'));
        expect(enviado['description'], equals('Enlace dedicado'));
        expect(enviado['pay_code'], equals('PC-0001'));
      },
    );
  });

  group('RN-15: Normalizacion de errores de la capa de datos', () {
    test(
      'Criterio 9: Dado un fallo de red durante el registro, cuando se registra el servicio, entonces se obtiene un error con codigo 500 y no se interrumpe la aplicacion',
      () async {
        // Arrange
        final client = MockClient((request) async {
          throw http.ClientException('Fallo de conexion de red');
        });
        final repository = HttpIspServiceRepository(
            client: client, session: session, baseUrl: baseUrl);

        // Act
        final result = await repository.create(buildService());

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error!.code, equals(500));
      },
    );

    test(
      'Dado un fallo de red al consultar los servicios del proveedor, cuando se consulta, entonces se obtiene un error con codigo 500',
      () async {
        // Arrange
        final client = MockClient((request) async {
          throw http.ClientException('Fallo de conexion de red');
        });
        final repository = HttpIspServiceRepository(
            client: client, session: session, baseUrl: baseUrl);

        // Act
        final result = await repository.fetchByProvider(1);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error!.code, equals(500));
      },
    );
  });

  group('RN-14: Consulta de servicios ISP por proveedor', () {
    test(
      'Dado una respuesta 200, cuando se consultan los servicios del proveedor, entonces se devuelve la lista de servicios',
      () async {
        // Arrange
        final client = MockClient((request) async {
          expect(request.method, equals('GET'));
          expect(request.url.path, equals('/providers/1/isp-services'));
          return http.Response(
            jsonEncode([
              {
                'id': 10,
                'isp_id': 1,
                'provider_id': 1,
                'description': 'Enlace dedicado 100 Mbps',
                'cost': 120.00,
                'pay_code': 'PC-0001'
              },
              {
                'id': 11,
                'isp_id': 2,
                'provider_id': 1,
                'description': 'Enlace de respaldo 50 Mbps',
                'cost': 80.00,
                'pay_code': 'PC-0002'
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final repository = HttpIspServiceRepository(
            client: client, session: session, baseUrl: baseUrl);

        // Act
        final result = await repository.fetchByProvider(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.length, equals(2));
        expect(result.data!.first.cost, equals(120.0));
        expect(result.data!.last.payCode, equals('PC-0002'));
      },
    );
  });
}
