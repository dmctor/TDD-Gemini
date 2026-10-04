/// Criterios de filtrado del resumen financiero (RN-06 a RN-09).
class FilterCriteria {
  final String? name;
  final String? ruc;
  final String? dependency;
  final String? ispName;
  final String? operatorQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;

  const FilterCriteria({
    this.name,
    this.ruc,
    this.dependency,
    this.ispName,
    this.operatorQuery,
    this.startDate,
    this.endDate,
    this.minAmount = 0.0,
    this.maxAmount = 999999.0,
  });

  bool get isActive =>
      (name != null && name!.trim().isNotEmpty) ||
      (ruc != null && ruc!.trim().isNotEmpty) ||
      (dependency != null && dependency!.trim().isNotEmpty) ||
      (ispName != null && ispName!.trim().isNotEmpty) ||
      (operatorQuery != null && operatorQuery!.trim().isNotEmpty) ||
      startDate != null ||
      endDate != null ||
      (minAmount != null && minAmount! > 0.0) ||
      (maxAmount != null && maxAmount! < 999999.0);
}
