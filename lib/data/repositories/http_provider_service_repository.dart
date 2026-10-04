import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proveedify/core/result.dart';
import 'package:proveedify/domain/contracts/repositories.dart';
import 'package:proveedify/models/entities/provider_service.dart';

class HttpProviderServiceRepository implements ProviderServiceRepository {
  final http.Client client;
  final String baseUrl;

  HttpProviderServiceRepository({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<Result<List<ProviderService>>> getServicesByProvider(
      String providerId) async {
    try {
      final url = Uri.parse('$baseUrl/providers/$providerId/services');
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<ProviderService> services = [];
        for (var item in jsonList) {
          services.add(
            ProviderService(
              id: item['id'],
              dependencyId: item['dependencyId'] ?? 0,
              providerId: item['providerId'] ?? 0,
              description: item['description'] ?? item['name'] ?? '',
              price: (item['price'] as num).toDouble(),
            ),
          );
        }
        return Result.success(services);
      } else {
        return Result.failure('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('Error de red: $e');
    }
  }

  @override
  Future<Result<List<ProviderService>>> fetchByProvider(int providerId) {
    return getServicesByProvider(providerId.toString());
  }
}
