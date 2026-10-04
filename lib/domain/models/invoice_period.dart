/// Periodo de facturacion (RN-17).
class InvoicePeriod {
  final int year;
  final int month;

  const InvoicePeriod({required this.year, required this.month});

  static const List<String> _meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  String get label => '${_meses[month - 1]} $year';

  @override
  bool operator ==(Object other) {
    if (other is! InvoicePeriod) {
      return false;
    }
    return other.year == year && other.month == month;
  }

  @override
  int get hashCode => Object.hash(year, month);
}
