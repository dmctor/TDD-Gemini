import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/result.dart';
import '../../domain/contracts/repositories.dart';
import '../../models/entities/user_token.dart';

class HttpAuthRepository implements AuthRepository {
  final http.Client client;
  final SessionStorage session;
  final String baseUrl;

  HttpAuthRepository({
    required this.client,
    required this.session,
    required this.baseUrl,
  });

  @override
  Future<Result<UserToken>> signIn({
    required String username,
    required String password,
  }) async {
    // RN-01: Limpieza de espacios en los extremos
    final sanitizedUsername = username.trim();
    final sanitizedPassword = password.trim();

    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final response = await client.post(
        uri,
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'username': sanitizedUsername,
          'password': sanitizedPassword,
        }),
      );

      // RN-15 y RN-01: Respuestas 200 devuelven el cuerpo esperado
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final userToken = UserToken(
          token: data['token'] as String,
          adminId: data['adminId'] is int ? data['adminId'] as int : null,
          username: data['username'] is String ? data['username'] as String : null,
          providerIds: List<String>.from(data['providerIds'] ?? []),
        );

        // RN-02: Guardar el token en la sesión bajo jwt_token
        await session.saveToken(userToken.token);

        return Result.success(userToken);
      }

      // RN-15: Errores 400 y 404 devuelven mensaje de dominio
      if (response.statusCode == 400 || response.statusCode == 404) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Credenciales invalidas';
        return Result.failure(DomainError(message: message, code: response.statusCode));
      }

      // Otras respuestas HTTP no esperadas
      return Result.failure(
        DomainError(message: 'Error en la solicitud', code: response.statusCode),
      );
    } catch (e) {
      // RN-15: Cualquier excepción se normaliza con código 500 sin romperse
      return Result.failure(
        DomainError(message: 'Fallo de conexion de red', code: 500),
      );
    }
  }
}
