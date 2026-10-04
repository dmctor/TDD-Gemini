import '../contracts/logic.dart';
import '../models/validation_result.dart';

/// RN-13: validacion del formulario de registro de servicio ISP.
class IspServiceFormValidatorImpl implements IspServiceFormValidator {
  @override
  ValidationResult validate({
    required String description,
    required String price,
    required String payCode,
    required int? ispId,
  }) {
    final errors = <String, String>{};

    if (description.trim().isEmpty) {
      errors['description'] = 'La descripcion es obligatoria';
    }

    final priceText = price.trim();
    if (priceText.isEmpty) {
      errors['price'] = 'El precio es obligatorio';
    } else {
      final parsed = double.tryParse(priceText);
      if (parsed == null || parsed.isNaN || parsed.isInfinite) {
        errors['price'] = 'El precio debe ser numerico';
      } else if (parsed <= 0) {
        errors['price'] = 'El precio debe ser mayor que cero';
      }
    }

    if (payCode.trim().isEmpty) {
      errors['payCode'] = 'El codigo de pago es obligatorio';
    }

    if (ispId == null) {
      errors['ispId'] = 'Debe seleccionar un operador';
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}
