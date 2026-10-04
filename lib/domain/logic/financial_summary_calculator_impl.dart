import '../contracts/logic.dart';
import '../models/financial_item.dart';
import '../models/financial_summary.dart';

class FinancialSummaryCalculatorImpl implements FinancialSummaryCalculator {
  @override
  FinancialSummary calculate({
    required List<FinancialItem> ingresos,
    required List<FinancialItem> egresos,
  }) {
    double totalIngresos = 0.0;
    for (var item in ingresos) {
      totalIngresos = totalIngresos + item.amount;
    }

    double totalEgresos = 0.0;
    for (var item in egresos) {
      totalEgresos = totalEgresos + item.amount;
    }

    return FinancialSummary(
      totalIngresos: totalIngresos,
      totalEgresos: totalEgresos,
    );
  }
}
