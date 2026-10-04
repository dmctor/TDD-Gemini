import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proveedify/core/result.dart';
import 'package:proveedify/domain/contracts/invoice_repository.dart';
import 'package:proveedify/models/entities/invoice.dart';
import 'package:proveedify/models/entities/provider_service.dart';
import 'package:proveedify/models/entities/isp_service.dart';

class HttpInvoiceRepository implements InvoiceRepository {
  final http.Client client;
  final String baseUrl;

  HttpInvoiceRepository({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<Result<List<Invoice>>> getProviderInvoices(
      List<ProviderService> services) async {
    try {
      final List<String> serviceIds =
          services.where((s) => s.id != null).map((s) => s.id!).toList();

      final url = Uri.parse('$baseUrl/invoices/provider');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'serviceIds': serviceIds}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final invoices = jsonList
            .map((item) => Invoice(
                  id: item['id'],
                  serviceId: item['serviceId'],
                  amount: (item['amount'] as num).toDouble(),
                  issueDate: DateTime.parse(item['issueDate']),
                ))
            .toList();
        return Result.success(invoices);
      } else {
        return Result.failure('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('Excepción de red: $e');
    }
  }

  @override
  Future<Result<List<Invoice>>> getIspInvoices(
      List<IspService> services) async {
    try {
      final List<String> serviceIds =
          services.where((s) => s.id != null).map((s) => s.id!).toList();

      final url = Uri.parse('$baseUrl/invoices/isp');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'serviceIds': serviceIds}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final invoices = jsonList
            .map((item) => Invoice(
                  id: item['id'],
                  serviceId: item['serviceId'],
                  amount: (item['amount'] as num).toDouble(),
                  issueDate: DateTime.parse(item['issueDate']),
                ))
            .toList();
        return Result.success(invoices);
      } else {
        return Result.failure('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('Excepción de red: $e');
    }
  }

  @override
  Future<Result<bool>> markAsInvoiced(Invoice invoice) async {
    try {
      final url = Uri.parse('$baseUrl/invoices/${invoice.id}/mark');
      final response = await client.post(url);

      if (response.statusCode == 200) {
        return Result.success(true);
      }

      // RN-15: Normalización de error extrayendo mensaje de la respuesta
      String errorMessage = 'Error al marcar factura (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          errorMessage = body['message'].toString();
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }

      return Result.failure(
        DomainError(message: errorMessage, code: response.statusCode),
      );
    } catch (e) {
      // RN-15: cualquier excepcion se normaliza con codigo 500
      return Result.failure(
        const DomainError(message: 'Fallo de conexion de red', code: 500),
      );
    }
  }
}
