import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/result.dart';
import '../../domain/contracts/repositories.dart';
import '../../models/entities/isp_service.dart';

/// RN-14, RN-15.
class HttpIspServiceRepository implements IspServiceRepository {
  final http.Client client;
  final SessionStorage session;
  final String baseUrl;

  HttpIspServiceRepository({
    required this.client,
    required this.session,
    required this.baseUrl,
  });

  Future<Map<String, String>> _headers() async {
    final token = await session.readToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<Result<List<IspService>>> fetchByProvider(int providerId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/providers/$providerId/isp-services'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final services = jsonList
            .map((item) => IspService.fromJson(item as Map<String, dynamic>))
            .toList();
        return Result.success(services);
      }

      return Result.failure(DomainError(
        message: 'Error al consultar los servicios',
        code: response.statusCode,
      ));
    } catch (_) {
      return Result.failure(
        const DomainError(message: 'Fallo de conexion de red', code: 500),
      );
    }
  }

  @override
  Future<Result<IspService>> create(IspService service) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/isp-services'),
        headers: await _headers(),
        body: jsonEncode({
          'isp_id': service.ispId,
          'provider_id': service.providerId,
          'description': service.description,
          'cost': service.cost,
          'pay_code': service.payCode,
        }),
      );

      // RN-14: 201 registro exitoso
      if (response.statusCode == 201) {
        IspService created = service;
        try {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic>) {
            created = IspService.fromJson(body);
          }
        } catch (_) {
          // Cuerpo vacio o no JSON: se conserva el servicio enviado.
        }
        return Result.success(created, status: 201);
      }

      // RN-14: 409 el servicio ya existe
      if (response.statusCode == 409) {
        return Result.failure(const DomainError(
          message: 'El servicio ya existe',
          code: 409,
        ));
      }

      // RN-14: cualquier otro codigo es error de registro
      return Result.failure(DomainError(
        message: 'Error al registrar el servicio',
        code: response.statusCode,
      ));
    } catch (_) {
      // RN-15: toda excepcion se normaliza con codigo 500
      return Result.failure(
        const DomainError(message: 'Fallo de conexion de red', code: 500),
      );
    }
  }
}
