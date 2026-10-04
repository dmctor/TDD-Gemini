import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:proveedify/core/result.dart';
import 'package:proveedify/domain/contracts/auth_repository.dart';
import 'package:proveedify/models/entities/user_token.dart';
import 'package:proveedify/pages/sign_in/sign_in_controller.dart';
import 'package:proveedify/pages/sign_in/sign_in_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInController signInController;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInController = SignInController(authRepository: mockAuthRepository);
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(home: child);
  }

  group('RN-01: Validacion de campos en formulario y envio de credenciales', () {
    testWidgets(
      'no debe enviar la solicitud y debe mostrar mensaje de campos obligatorios cuando el usuario o contrasena estan vacios',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestableWidget(SignInPage(controller: signInController)),
        );

        await tester.tap(find.byKey(const Key('sign_in_submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Los campos son obligatorios'), findsOneWidget);
        verifyNever(
          () => mockAuthRepository.signIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    testWidgets(
      'debe procesar el envio de credenciales sanitizadas al presionar el boton de inicio de sesion',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.signIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            UserToken(token: 'token', providerIds: []),
          ),
        );

        await tester.pumpWidget(
          buildTestableWidget(SignInPage(controller: signInController)),
        );

        await tester.enterText(
          find.byKey(const Key('sign_in_username_field')),
          '   admin   ',
        );
        await tester.enterText(
          find.byKey(const Key('sign_in_password_field')),
          '   secret123   ',
        );
        await tester.tap(find.byKey(const Key('sign_in_submit_button')));
        await tester.pumpAndSettle();

        verify(
          () => mockAuthRepository.signIn(
            username: 'admin',
            password: 'secret123',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'debe mostrar el mensaje de error de credenciales en pantalla cuando la autenticacion falla',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.signIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => Result.failure(
            DomainError(message: 'Credenciales invalidas', code: 400),
          ),
        );

        await tester.pumpWidget(
          buildTestableWidget(SignInPage(controller: signInController)),
        );

        await tester.enterText(
          find.byKey(const Key('sign_in_username_field')),
          'admin',
        );
        await tester.enterText(
          find.byKey(const Key('sign_in_password_field')),
          'wrong_pass',
        );
        await tester.tap(find.byKey(const Key('sign_in_submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Credenciales invalidas'), findsOneWidget);
      },
    );
  });

  group('RN-15: Visualizacion de errores normalizados de red', () {
    testWidgets(
      'debe desplegar mensaje de error del servidor sin que la aplicacion se interrumpa ante error 500',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.signIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => Result.failure(
            DomainError(message: 'Error interno del servidor', code: 500),
          ),
        );

        await tester.pumpWidget(
          buildTestableWidget(SignInPage(controller: signInController)),
        );

        await tester.enterText(
          find.byKey(const Key('sign_in_username_field')),
          'admin',
        );
        await tester.enterText(
          find.byKey(const Key('sign_in_password_field')),
          'secret123',
        );
        await tester.tap(find.byKey(const Key('sign_in_submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Error interno del servidor'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
