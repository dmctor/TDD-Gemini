import '../../core/result.dart';
import '../../models/entities/invoice.dart';
import '../../models/entities/isp_service.dart';
import '../../models/entities/provider_service.dart';
import '../../models/entities/user_token.dart';
import '../../core/result.dart';

/// Almacenamiento de la sesion (RN-02).
abstract class SessionStorage {
  Future<void> saveToken(String token);
  Future<String?> readToken();
  Future<void> clear();
}

/// Autenticacion del administrador (RN-01, RN-02).
abstract class AuthRepository {
  Future<Result<UserToken>> signIn({
    required String username,
    required String password,
  });
}

abstract class ProviderServiceRepository {
  Future<Result<List<ProviderService>>> fetchByProvider(int providerId);
  Future<Result<List<ProviderService>>> getServicesByProvider(String providerId);
}

abstract class IspServiceRepository {
  Future<Result<List<IspService>>> fetchByProvider(int providerId);

  /// RN-13, RN-14
  Future<Result<IspService>> create(IspService service);
}

abstract class InvoiceRepository {
  Future<Result<List<Invoice>>> getProviderInvoices(
      List<ProviderService> services);
  Future<Result<List<Invoice>>> getIspInvoices(List<IspService> services);

  /// RN-12
  Future<Result<bool>> markAsInvoiced(Invoice invoice);
}
