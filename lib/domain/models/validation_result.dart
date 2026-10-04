/// Resultado de la validacion de un formulario (RN-13).
class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  const ValidationResult(this.isValid, this.errors);

  factory ValidationResult.valid() => const ValidationResult(true, {});

  factory ValidationResult.invalid(Map<String, String> errors) =>
      ValidationResult(false, errors);
}
