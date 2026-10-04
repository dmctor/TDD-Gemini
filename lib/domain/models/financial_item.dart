/// Registro consolidado del resumen financiero (RN-03).
///
/// Mantiene compatibilidad con dos contratos del dominio:
/// - el modelo actual usa `issueDate` y `amount`
/// - las pruebas de filtro esperan `id`, `date` y un constructor tolerante
class FinancialItem {
  final String id;
  final String name;
  final String ruc;
  final String dependency;
  final String? ispName;
  final DateTime issueDate;
  final double amount;

  DateTime get date => issueDate;

  FinancialItem({
    this.id = '',
    required this.name,
    required this.ruc,
    required this.dependency,
    this.ispName,
    DateTime? issueDate,
    DateTime? date,
    required this.amount,
  }) : issueDate = issueDate ?? date ?? DateTime(1970, 1, 1);
}
