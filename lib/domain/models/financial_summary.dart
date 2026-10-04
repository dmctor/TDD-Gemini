/// Totales del resumen financiero (RN-05).
class FinancialSummary {
  final double totalIngresos;
  final double totalEgresos;

  const FinancialSummary({
    required this.totalIngresos,
    required this.totalEgresos,
  });

  double get saldo => totalIngresos - totalEgresos;
}
