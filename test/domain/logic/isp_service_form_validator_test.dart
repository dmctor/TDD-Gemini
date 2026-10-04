import 'package:flutter_test/flutter_test.dart';
import 'package:proveedify/domain/contracts/logic.dart';
import 'package:proveedify/domain/logic/isp_service_form_validator_impl.dart';

void main() {
  late IspServiceFormValidator validator;

  setUp(() {
    validator = IspServiceFormValidatorImpl();
  });

  group('RN-13: Validacion del formulario de registro de servicio ISP', () {
    test(
      'Criterio 1: Dado descripcion, precio, codigo de pago y operador validos, cuando se valida, entonces el formulario es valido',
      () {
        // Arrange
        const description = 'Enlace dedicado 100 Mbps';
        const price = '120.50';
        const payCode = 'PC-0001';
        const ispId = 1;

        // Act
        final result = validator.validate(
          description: description,
          price: price,
          payCode: payCode,
          ispId: ispId,
        );

        // Assert
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      },
    );

    test(
      'Criterio 2: Dado una descripcion vacia, cuando se valida, entonces el formulario es invalido',
      () {
        // Arrange
        const description = '';

        // Act
        final result = validator.validate(
          description: description,
          price: '120.50',
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors.containsKey('description'), isTrue);
      },
    );

    test(
      'Criterio 2 (limite): Dado una descripcion con solo espacios, cuando se valida, entonces el formulario es invalido',
      () {
        // Arrange
        const description = '     ';

        // Act
        final result = validator.validate(
          description: description,
          price: '120.50',
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors.containsKey('description'), isTrue);
      },
    );

    test(
      'Dado un codigo de pago vacio, cuando se valida, entonces el formulario es invalido',
      () {
        // Arrange
        const payCode = '   ';

        // Act
        final result = validator.validate(
          description: 'Enlace dedicado',
          price: '120.50',
          payCode: payCode,
          ispId: 1,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors.containsKey('payCode'), isTrue);
      },
    );

    test(
      'Criterio 3: Dado un formulario sin operador seleccionado, cuando se valida, entonces el formulario es invalido',
      () {
        // Arrange
        const int? ispId = null;

        // Act
        final result = validator.validate(
          description: 'Enlace dedicado',
          price: '120.50',
          payCode: 'PC-0001',
          ispId: ispId,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors.containsKey('ispId'), isTrue);
      },
    );

    test(
      'Criterio 4: Dado un precio con el valor abc, cuando se valida, entonces es invalido y se informa que el precio debe ser numerico',
      () {
        // Arrange
        const price = 'abc';

        // Act
        final result = validator.validate(
          description: 'Enlace dedicado',
          price: price,
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors['price'], contains('numerico'));
      },
    );

    test(
      'Criterio 5: Dado un precio con el valor 0, cuando se valida, entonces es invalido porque el precio debe ser mayor que cero',
      () {
        // Arrange
        const price = '0';

        // Act
        final result = validator.validate(
          description: 'Enlace dedicado',
          price: price,
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors['price'], contains('mayor que cero'));
      },
    );

    test(
      'Criterio 5 (limite): Dado un precio negativo, cuando se valida, entonces es invalido porque el precio debe ser mayor que cero',
      () {
        // Arrange
        const price = '-15.5';

        // Act
        final result = validator.validate(
          description: 'Enlace dedicado',
          price: price,
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors['price'], contains('mayor que cero'));
      },
    );

    test(
      'Dado un precio vacio, cuando se valida, entonces el formulario es invalido',
      () {
        // Arrange
        const price = '';

        // Act
        final result = validator.validate(
          description: 'Enlace dedicado',
          price: price,
          payCode: 'PC-0001',
          ispId: 1,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors.containsKey('price'), isTrue);
      },
    );
  });
}
