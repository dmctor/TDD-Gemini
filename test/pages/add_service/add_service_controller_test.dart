import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:proveedify/core/result.dart';
import 'package:proveedify/domain/contracts/isp_service_repository.dart';
import 'package:proveedify/domain/logic/isp_service_form_validator_impl.dart';
import 'package:proveedify/models/entities/isp_service.dart';
import 'package:proveedify/pages/add_service/add_service_controller.dart';

class MockIspServiceRepository extends Mock implements IspServiceRepository {}

void main() {
  late MockIspServiceRepository repository;
  late AddServiceControllerImpl controller;

  setUpAll(() {
    registerFallbackValue(IspService());
  });

  setUp(() {
    repository = MockIspServiceRepository();
    controller = AddServiceControllerImpl(
      validator: IspServiceFormValidatorImpl(),
      repository: repository,
      providerId: 1,
      ispOptions: const {1: 'Movistar'},
    );
  });

  group('RN-13: El formulario invalido no envia la solicitud', () {
    test(
      'Criterio 2: Dado una descripcion vacia, cuando se envia el formulario, entonces es invalido y no se envia la solicitud',
      () async {
        // Arrange
        const description = '';

        // Act
        final ok = await controller.submit(
          description: description,
          price: '120.50',
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(ok, isFalse);
        expect(controller.fieldErrors.containsKey('description'), isTrue);
        verifyNever(() => repository.create(any()));
      },
    );

    test(
      'Criterio 4: Dado un precio abc, cuando se envia el formulario, entonces se informa que el precio debe ser numerico y no se envia la solicitud',
      () async {
        // Arrange
        const price = 'abc';

        // Act
        final ok = await controller.submit(
          description: 'Enlace dedicado',
          price: price,
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(ok, isFalse);
        expect(controller.fieldErrors['price'], contains('numerico'));
        verifyNever(() => repository.create(any()));
      },
    );

    test(
      'Criterio 5: Dado un precio 0, cuando se envia el formulario, entonces no se envia la solicitud',
      () async {
        // Arrange
        const price = '0';

        // Act
        final ok = await controller.submit(
          description: 'Enlace dedicado',
          price: price,
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(ok, isFalse);
        verifyNever(() => repository.create(any()));
      },
    );

    test(
      'Criterio 3: Dado un formulario sin operador, cuando se envia, entonces no se envia la solicitud',
      () async {
        // Arrange
        const int? ispId = null;

        // Act
        final ok = await controller.submit(
          description: 'Enlace dedicado',
          price: '120.50',
          payCode: 'PC-0001',
          ispId: ispId,
        );

        // Assert
        expect(ok, isFalse);
        expect(controller.fieldErrors.containsKey('ispId'), isTrue);
        verifyNever(() => repository.create(any()));
      },
    );
  });

  group('RN-13 / RN-14: Registro del servicio', () {
    test(
      'Criterio 1 y 6: Dado un formulario valido con espacios en los extremos, cuando se envia, entonces se registra el servicio sin dichos espacios',
      () async {
        // Arrange
        when(() => repository.create(any())).thenAnswer(
          (_) async => Result.success(IspService(description: 'Enlace')),
        );

        // Act
        final ok = await controller.submit(
          description: '  Enlace dedicado  ',
          price: '120.50',
          payCode: ' PC-0001 ',
          ispId: 1,
        );

        // Assert
        expect(ok, isTrue);
        expect(controller.fieldErrors, isEmpty);
        expect(controller.errorMessage, isNull);
        final enviado = verify(() => repository.create(captureAny()))
            .captured
            .single as IspService;
        expect(enviado.description, equals('Enlace dedicado'));
        expect(enviado.payCode, equals('PC-0001'));
        expect(enviado.cost, equals(120.5));
        expect(enviado.ispId, equals(1));
        expect(enviado.providerId, equals(1));
      },
    );

    test(
      'Criterio 8: Dado un 409 del repositorio, cuando se envia el formulario, entonces se informa que el servicio ya existe',
      () async {
        // Arrange
        when(() => repository.create(any())).thenAnswer(
          (_) async => Result.failure(
            const DomainError(message: 'El servicio ya existe', code: 409),
          ),
        );

        // Act
        final ok = await controller.submit(
          description: 'Enlace dedicado',
          price: '120.50',
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(ok, isFalse);
        expect(controller.errorMessage, equals('El servicio ya existe'));
      },
    );

    test(
      'Criterio 9: Dado un error 500 del repositorio, cuando se envia el formulario, entonces se informa el error sin lanzar excepcion',
      () async {
        // Arrange
        when(() => repository.create(any())).thenAnswer(
          (_) async => Result.failure(
            const DomainError(message: 'Fallo de conexion de red', code: 500),
          ),
        );

        // Act
        final ok = await controller.submit(
          description: 'Enlace dedicado',
          price: '120.50',
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(ok, isFalse);
        expect(controller.errorMessage, equals('Fallo de conexion de red'));
      },
    );
  });
}
