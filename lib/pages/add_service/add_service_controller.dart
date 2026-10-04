import '../../domain/contracts/logic.dart';
import '../../domain/contracts/repositories.dart';
import '../../models/entities/isp_service.dart';

/// Controlador de la pantalla de registro de servicio ISP (HU-07).
abstract class AddServiceController {
  /// Operadores disponibles: id -> nombre.
  Map<int, String> get ispOptions;

  /// Errores de validacion por campo (RN-13).
  Map<String, String> get fieldErrors;

  /// Error de registro devuelto por la capa de datos (RN-14, RN-15).
  String? get errorMessage;

  /// Valida y registra el servicio. Devuelve true si se registro.
  Future<bool> submit({
    required String description,
    required String price,
    required String payCode,
    required int? ispId,
  });
}

class AddServiceControllerImpl implements AddServiceController {
  final IspServiceFormValidator validator;
  final IspServiceRepository repository;
  final int providerId;

  @override
  final Map<int, String> ispOptions;

  @override
  Map<String, String> fieldErrors = {};

  @override
  String? errorMessage;

  AddServiceControllerImpl({
    required this.validator,
    required this.repository,
    required this.providerId,
    this.ispOptions = const {},
  });

  @override
  Future<bool> submit({
    required String description,
    required String price,
    required String payCode,
    required int? ispId,
  }) async {
    fieldErrors = {};
    errorMessage = null;

    final validation = validator.validate(
      description: description,
      price: price,
      payCode: payCode,
      ispId: ispId,
    );

    // RN-13: un formulario invalido no envia la solicitud
    if (!validation.isValid) {
      fieldErrors = validation.errors;
      return false;
    }

    final result = await repository.create(
      IspService(
        ispId: ispId,
        providerId: providerId,
        description: description,
        cost: double.parse(price.trim()),
        payCode: payCode,
      ),
    );

    if (result.isFailure) {
      errorMessage = result.error?.message ?? 'Error al registrar el servicio';
      return false;
    }

    return true;
  }
}
