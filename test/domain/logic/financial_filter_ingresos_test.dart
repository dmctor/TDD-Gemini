// test/domain/logic/financial_filter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:proveedify/domain/contracts/financial_filter.dart';
import 'package:proveedify/domain/logic/financial_filter_impl.dart';
import 'package:proveedify/domain/models/filter_criteria.dart';
import 'package:proveedify/domain/models/financial_item.dart';

void main() {
  late FinancialFilter filter;
  late List<FinancialItem> sampleItems;

  setUp(() {
    filter = FinancialFilterImpl();

    sampleItems = [
      FinancialItem(
        id: '1',
        name: 'Servicio Fibra Óptica Lima',
        ruc: '20100123456',
        dependency: 'Sede Central',
        ispName: 'FibraNet',
        amount: 100.0,
        date: DateTime(2025, 3, 1),
      ),
      FinancialItem(
        id: '2',
        name: 'Mantenimiento Red Cobre',
        ruc: '20200987654',
        dependency: 'Sucursal Norte',
        ispName: 'TelcoPeru',
        amount: 350.0,
        date: DateTime(2025, 3, 15),
      ),
      FinancialItem(
        id: '3',
        name: 'Instalación FIBRA Dedicada',
        ruc: '20100654321',
        dependency: 'Sede Central',
        ispName: 'FibraNet',
        amount: 500.0,
        date: DateTime(2025, 3, 31),
      ),
      FinancialItem(
        id: '4',
        name: 'Enlace Satelital',
        ruc: '20500112233',
        dependency: 'Sucursal Sur',
        ispName: 'SatLink',
        amount: 1200.0,
        date: DateTime(2025, 4, 10),
      ),
    ];
  });

  group(
      'RN-06: Filtros de texto con coincidencia parcial e insensibles a mayúsculas',
      () {
    test(
      'debe conservar solo los registros cuyo nombre contiene "fibra" sin distinguir mayúsculas ni minúsculas (CA-1)',
      () {
        // Arrange
        final criteria = FilterCriteria(name: 'fibra');
        final expected = [sampleItems[0], sampleItems[2]];

        // Act
        final result = filter.apply(sampleItems, criteria);

        // Assert
        expect(result, equals(expected));
      },
    );

    test(
      'debe conservar los registros cuyo RUC contiene la secuencia parcial provista (CA-2)',
      () {
        // Arrange
        final criteria = FilterCriteria(ruc: '20100');
        final expected = [sampleItems[0], sampleItems[2]];

        // Act
        final result = filter.apply(sampleItems, criteria);

        // Assert
        expect(result, equals(expected));
      },
    );

    test(
      'no debe restringir el conjunto cuando los filtros de texto son cadenas vacías o espacios',
      () {
        // Arrange
        final criteria = FilterCriteria(name: '', ruc: '   ', dependency: '');
        final expected = sampleItems;

        // Act
        final result = filter.apply(sampleItems, criteria);

        // Assert
        expect(result, equals(expected));
      },
    );
  });

  group(
      'RN-07: Filtros de rango de fechas y montos inclusivos en ambos extremos',
      () {
    test(
      'debe conservar registros emitidos dentro del rango de fechas incluyendo las fechas límite (CA-4)',
      () {
        // Arrange
        final criteria = FilterCriteria(
          startDate: DateTime(2025, 3, 1),
          endDate: DateTime(2025, 3, 31),
        );
        final expected = [sampleItems[0], sampleItems[1], sampleItems[2]];

        // Act
        final result = filter.apply(sampleItems, criteria);

        // Assert
        expect(result, equals(expected));
      },
    );

    test(
      'debe conservar registros dentro del rango de montos incluyendo los valores mínimo y máximo (CA-5)',
      () {
        // Arrange
        final criteria = FilterCriteria(
          minAmount: 100.0,
          maxAmount: 500.0,
        );
        final expected = [sampleItems[0], sampleItems[1], sampleItems[2]];

        // Act
        final result = filter.apply(sampleItems, criteria);

        // Assert
        expect(result, equals(expected));
      },
    );
  });

  group('RN-08: Conjunción lógica de filtros activos y casos sin coincidencias',
      () {
    test(
      'debe conservar solo los registros que satisfacen simultáneamente el filtro de nombre y dependencia (CA-3)',
      () {
        // Arrange
        final criteria = FilterCriteria(
          name: 'fibra',
          dependency: 'Sede Central',
        );
        final expected = [sampleItems[0], sampleItems[2]];

        // Act
        final result = filter.apply(sampleItems, criteria);

        // Assert
        expect(result, equals(expected));
      },
    );

    test(
      'debe retornar una lista vacía cuando ningún registro coincide con los criterios especificados (CA-6)',
      () {
        // Arrange
        final criteria = FilterCriteria(
          name: 'Inexistente XYZ',
          minAmount: 90000.0,
        );

        // Act
        final result = filter.apply(sampleItems, criteria);

        // Assert
        expect(result, isEmpty);
      },
    );

    test(
      'debe retornar una lista idéntica al conjunto original cuando ningún filtro está activo',
      () {
        // Arrange
        final criteria = FilterCriteria(); // isActive == false

        // Act
        final result = filter.apply(sampleItems, criteria);

        // Assert
        expect(result, equals(sampleItems));
      },
    );

    test(
      'debe permitir calcular el total financiero únicamente sobre los registros filtrados visibles (CA-7)',
      () {
        // Arrange
        final criteria = FilterCriteria(
          startDate: DateTime(2025, 3, 1),
          endDate: DateTime(2025, 3, 15),
        );
        // sampleItems[0].amount (100.0) + sampleItems[1].amount (350.0) = 450.0
        const expectedTotal = 450.0;

        // Act
        final filteredItems = filter.apply(sampleItems, criteria);
        final totalCalculated = filteredItems.fold<double>(
          0.0,
          (sum, item) => sum + item.amount,
        );

        // Assert
        expect(totalCalculated, equals(expectedTotal));
      },
    );
  });

  group('RN-10: Restitución del conjunto original al limpiar filtros', () {
    test(
      'debe restituir el conjunto original de datos cuando se limpian o desactivan los filtros aplicados (CA-8)',
      () {
        // Arrange
        final activeCriteria = FilterCriteria(name: 'Enlace Satelital');
        final clearedCriteria = FilterCriteria();

        // Act
        final intermediateResult = filter.apply(sampleItems, activeCriteria);
        final restoredResult = filter.apply(sampleItems, clearedCriteria);

        // Assert
        expect(intermediateResult.length, equals(1));
        expect(restoredResult, equals(sampleItems));
      },
    );
  });
}
