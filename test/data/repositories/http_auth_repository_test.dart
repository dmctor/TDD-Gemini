import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:proveedify/core/result.dart';
import 'package:proveedify/data/repositories/http_auth_repository.dart';
import 'package:proveedify/domain/contracts/auth_repository.dart';
import 'package:proveedify/domain/contracts/session_storage.dart';
import 'package:proveedify/models/entities/user_token.dart';

class MockSessionStorage extends Mock implements SessionStorage {}

void main() {
  late MockSessionStorage mockSessionStorage;
  const String tBaseUrl = 'https://api.proveedify.com';

  setUp(() {
    mockSessionStorage = MockSessionStorage();
  });

  group('RN-01: Validacion y envio de credenciales sanitizadas', () {
    test(
      'debe enviar las credenciales sin espacios en los extremos y retornar UserToken con proveedores cuando son validas',
      () async {
        // Arrange
        final client = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          if (body['username'] == 'admin' && body['password'] == 'secret123') {
            return http.Response(
              jsonEncode({
                'token': 'jwt_mock_token_123',
                'providerIds': ['prov-1', 'prov-2'],
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response(
              jsonEncode({'message': 'Credenciales invalidas'}), 400);
        });

        when(() => mockSessionStorage.saveToken(any()))
            .thenAnswer((_) async {});

        final repository = HttpAuthRepository(
          client: client,
          session: mockSessionStorage,
          baseUrl: tBaseUrl,
        );

        // Act
        final result = await repository.signIn(
          username: '   admin   ',
          password: '   secret123   ',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, isA<UserToken>());
        expect(result.data?.token, equals('jwt_mock_token_123'));
        expect(result.data?.providerIds, equals(['prov-1', 'prov-2']));
      },
    );

    test(
      'debe retornar un error de credenciales cuando la respuesta es 400 o 404 y no guardar sesion',
      () async {
        // Arrange
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Credenciales incorrectas'}),
            400,
            headers: {'content-type': 'application/json'},
          );
        });

        final repository = HttpAuthRepository(
          client: client,
          session: mockSessionStorage,
          baseUrl: tBaseUrl,
        );

        // Act
        final result = await repository.signIn(
          username: 'admin',
          password: 'wrong_password',
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error?.message, equals('Credenciales incorrectas'));
        verifyNever(() => mockSessionStorage.saveToken(any()));
      },
    );
  });

  group('RN-02: Persistencia del token tras autenticacion exitosa', () {
    test(
      'debe almacenar el token recibido en la sesion tras una autenticacion exitosa',
      () async {
        // Arrange
        const tToken = 'jwt_mock_token_123';
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'token': tToken,
              'providerIds': ['prov-1'],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        when(() => mockSessionStorage.saveToken(any()))
            .thenAnswer((_) async {});

        final repository = HttpAuthRepository(
          client: client,
          session: mockSessionStorage,
          baseUrl: tBaseUrl,
        );

        // Act
        final result = await repository.signIn(
          username: 'admin',
          password: 'password123',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockSessionStorage.saveToken(tToken)).called(1);
      },
    );
  });

  group('RN-15: Normalizacion de respuestas y manejo de excepciones de red',
      () {
    test(
      'debe retornar error con codigo 500 y no lanzar excepcion cuando ocurre un fallo de red o socket',
      () async {
        // Arrange
        final client = MockClient((request) async {
          throw http.ClientException('Fallo de conexion de red');
        });

        final repository = HttpAuthRepository(
          client: client,
          session: mockSessionStorage,
          baseUrl: tBaseUrl,
        );

        // Act
        final result = await repository.signIn(
          username: 'admin',
          password: 'password123',
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error?.code, equals(500));
        verifyNever(() => mockSessionStorage.saveToken(any()));
      },
    );

    test(
      'debe retornar error de dominio con mensaje extraido cuando la respuesta es 404',
      () async {
        // Arrange
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Usuario no encontrado'}),
            404,
            headers: {'content-type': 'application/json'},
          );
        });

        final repository = HttpAuthRepository(
          client: client,
          session: mockSessionStorage,
          baseUrl: tBaseUrl,
        );

        // Act
        final result = await repository.signIn(
          username: 'no_existe',
          password: 'password123',
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error?.message, equals('Usuario no encontrado'));
        expect(result.error?.code, equals(404));
        verifyNever(() => mockSessionStorage.saveToken(any()));
      },
    );
  });
}
