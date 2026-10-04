import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:proveedify/pages/add_service/add_service_controller.dart';
import 'package:proveedify/pages/add_service/add_service_page.dart';

class MockAddServiceController extends Mock implements AddServiceController {}

void main() {
  late MockAddServiceController controller;
  late bool enviado;

  setUp(() {
    controller = MockAddServiceController();
    enviado = false;
    when(() => controller.ispOptions)
        .thenReturn({1: 'Movistar', 2: 'Claro'});
  });

  /// Los getters devuelven los valores indicados solo despues de enviar.
  void stubResultado({
    required bool exito,
    Map<String, String> fieldErrors = const {},
    String? errorMessage,
  }) {
    when(() => controller.fieldErrors)
        .thenAnswer((_) => enviado ? fieldErrors : <String, String>{});
    when(() => controller.errorMessage)
        .thenAnswer((_) => enviado ? errorMessage : null);
    when(() => controller.submit(
          description: any(named: 'description'),
          price: any(named: 'price'),
          payCode: any(named: 'payCode'),
          ispId: any(named: 'ispId'),
        )).thenAnswer((_) async {
      enviado = true;
      return exito;
    });
  }

  Future<void> llenarFormulario(
    WidgetTester tester, {
    String description = 'Enlace dedicado',
    String price = '120.50',
    String payCode = 'PC-0001',
    bool elegirOperador = true,
  }) async {
    await tester.enterText(
        find.byKey(const Key('add_service_description_field')), description);
    await tester.enterText(
        find.byKey(const Key('add_service_price_field')), price);
    await tester.enterText(
        find.byKey(const Key('add_service_paycode_field')), payCode);
    if (elegirOperador) {
      await tester.tap(find.byKey(const Key('add_service_isp_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Movistar').last);
      await tester.pumpAndSettle();
    }
  }

  Future<void> enviar(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('add_service_submit_button')));
    await tester.pumpAndSettle();
  }

  Widget buildTestableWidget() {
    return MaterialApp(home: AddServicePage(controller: controller));
  }

  group('RN-13: Formulario de registro de servicio ISP', () {
    testWidgets(
      'Criterio 1: Dado un formulario completo, cuando se presiona registrar, entonces se envian los datos al controlador y se informa el exito',
      (tester) async {
        // Arrange
        stubResultado(exito: true);
        await tester.pumpWidget(buildTestableWidget());

        // Act
        await llenarFormulario(tester);
        await enviar(tester);

        // Assert
        verify(() => controller.submit(
              description: 'Enlace dedicado',
              price: '120.50',
              payCode: 'PC-0001',
              ispId: 1,
            )).called(1);
        expect(find.text('Servicio registrado correctamente'),
            findsOneWidget);
      },
    );

    testWidgets(
      'Criterio 2: Dado una descripcion vacia, cuando se presiona registrar, entonces se muestra el error de descripcion y no se informa exito',
      (tester) async {
        // Arrange
        stubResultado(
          exito: false,
          fieldErrors: {'description': 'La descripcion es obligatoria'},
        );
        await tester.pumpWidget(buildTestableWidget());

        // Act
        await llenarFormulario(tester, description: '');
        await enviar(tester);

        // Assert
        expect(find.text('La descripcion es obligatoria'), findsOneWidget);
        expect(find.text('Servicio registrado correctamente'), findsNothing);
      },
    );

    testWidgets(
      'Criterio 3: Dado un formulario sin operador, cuando se presiona registrar, entonces se envia sin operador y se muestra el error de operador',
      (tester) async {
        // Arrange
        stubResultado(
          exito: false,
          fieldErrors: {'ispId': 'Debe seleccionar un operador'},
        );
        await tester.pumpWidget(buildTestableWidget());

        // Act
        await llenarFormulario(tester, elegirOperador: false);
        await enviar(tester);

        // Assert
        verify(() => controller.submit(
              description: 'Enlace dedicado',
              price: '120.50',
              payCode: 'PC-0001',
              ispId: null,
            )).called(1);
        expect(find.text('Debe seleccionar un operador'), findsOneWidget);
      },
    );

    testWidgets(
      'Criterio 4: Dado un precio abc, cuando se presiona registrar, entonces se muestra que el precio debe ser numerico',
      (tester) async {
        // Arrange
        stubResultado(
          exito: false,
          fieldErrors: {'price': 'El precio debe ser numerico'},
        );
        await tester.pumpWidget(buildTestableWidget());

        // Act
        await llenarFormulario(tester, price: 'abc');
        await enviar(tester);

        // Assert
        expect(find.text('El precio debe ser numerico'), findsOneWidget);
      },
    );

    testWidgets(
      'Criterio 5: Dado un precio 0, cuando se presiona registrar, entonces se muestra que el precio debe ser mayor que cero',
      (tester) async {
        // Arrange
        stubResultado(
          exito: false,
          fieldErrors: {'price': 'El precio debe ser mayor que cero'},
        );
        await tester.pumpWidget(buildTestableWidget());

        // Act
        await llenarFormulario(tester, price: '0');
        await enviar(tester);

        // Assert
        expect(find.text('El precio debe ser mayor que cero'),
            findsOneWidget);
      },
    );
  });

  group('RN-14 y RN-15: Errores de registro mostrados al usuario', () {
    testWidgets(
      'Criterio 8: Dado un servicio ya existente, cuando se presiona registrar, entonces se informa que el servicio ya existe',
      (tester) async {
        // Arrange
        stubResultado(exito: false, errorMessage: 'El servicio ya existe');
        await tester.pumpWidget(buildTestableWidget());

        // Act
        await llenarFormulario(tester);
        await enviar(tester);

        // Assert
        expect(find.text('El servicio ya existe'), findsOneWidget);
        expect(find.text('Servicio registrado correctamente'), findsNothing);
      },
    );

    testWidgets(
      'Criterio 9: Dado un fallo de red, cuando se presiona registrar, entonces se muestra el error sin interrumpir la aplicacion',
      (tester) async {
        // Arrange
        stubResultado(exito: false, errorMessage: 'Fallo de conexion de red');
        await tester.pumpWidget(buildTestableWidget());

        // Act
        await llenarFormulario(tester);
        await enviar(tester);

        // Assert
        expect(find.text('Fallo de conexion de red'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
