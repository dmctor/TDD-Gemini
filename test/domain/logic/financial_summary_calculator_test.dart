import 'package:flutter_test/flutter_test.dart';
import 'package:proveedify/domain/logic/financial_summary_calculator_impl.dart';
import 'package:proveedify/domain/models/financial_item.dart';

void main() {
  late FinancialSummaryCalculatorImpl calculator;

  setUp(() {
    calculator = FinancialSummaryCalculatorImpl();
  });

  FinancialItem buildItem(double amount) {
    return FinancialItem(
      name: 'Servicio Base',
      ruc: '20123456789',
      dependency: 'Sede Principal',
      ispName: null,
      issueDate: DateTime(2025, 3, 7),
      amount: amount,
    );
  }

  group('RN-03: Cálculo de totales por tipo de flujo', () {
    test(
        'Criterio 1: Suma total de ingresos debe ser 400.00 para facturas de 100.00, 250.50 y 49.50',
        () {
      // Arrange
      final ingresos = [
        buildItem(100.00),
        buildItem(250.50),
        buildItem(49.50),
      ];
      final egresos = <FinancialItem>[];

      // Act
      final summary =
          calculator.calculate(ingresos: ingresos, egresos: egresos);

      // Assert
      expect(summary.totalIngresos, equals(400.00));
    });

    test(
        'Criterio 2: Suma total de egresos debe ser 200.00 para facturas de 120.00 y 80.00',
        () {
      // Arrange
      final ingresos = <FinancialItem>[];
      final egresos = [
        buildItem(120.00),
        buildItem(80.00),
      ];

      // Act
      final summary =
          calculator.calculate(ingresos: ingresos, egresos: egresos);

      // Assert
      expect(summary.totalEgresos, equals(200.00));
    });
  });

  group('RN-05: Saldo sobre registros visibles y casos de saldo negativo/vacío',
      () {
    test(
        'Criterio 3: Saldo debe ser 200.00 con ingresos de 400.00 y egresos de 200.00',
        () {
      // Arrange
      final ingresos = [buildItem(400.00)];
      final egresos = [buildItem(200.00)];

      // Act
      final summary =
          calculator.calculate(ingresos: ingresos, egresos: egresos);

      // Assert
      expect(summary.saldo, equals(200.00));
    });

    test(
        'Criterio 4: Saldo debe ser negativo cuando los egresos superan los ingresos',
        () {
      // Arrange
      final ingresos = [buildItem(100.00)];
      final egresos = [buildItem(300.00)];

      // Act
      final summary =
          calculator.calculate(ingresos: ingresos, egresos: egresos);

      // Assert
      expect(summary.saldo, equals(-200.00));
      expect(summary.saldo.isNegative, isTrue);
    });

    test('Criterio 5: Retornar totales en 0.00 cuando las listas están vacías',
        () {
      // Arrange
      final ingresos = <FinancialItem>[];
      final egresos = <FinancialItem>[];

      // Act
      final summary =
          calculator.calculate(ingresos: ingresos, egresos: egresos);

      // Assert
      expect(summary.totalIngresos, equals(0.00));
      expect(summary.totalEgresos, equals(0.00));
      expect(summary.saldo, equals(0.00));
    });
  });
}
