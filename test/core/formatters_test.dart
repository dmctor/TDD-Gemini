import 'package:flutter_test/flutter_test.dart';
import 'package:proveedify/core/formatters.dart';

void main() {
  group('RN-16: Formato de presentación para montos y fechas', () {
    test('Criterio 7: Formatear monto decimal con prefijo S/ y dos decimales',
        () {
      // Arrange
      const double amount = 1234.5;

      // Act
      final result = Formatters.currency(amount);

      // Assert
      expect(result, equals('S/ 1234.50'));
    });

    test('Criterio 8: Formatear fecha en formato dd/MM/yyyy', () {
      // Arrange
      final DateTime date = DateTime(2025, 3, 7);

      // Act
      final result = Formatters.date(date);

      // Assert
      expect(result, equals('07/03/2025'));
    });
  });
}
