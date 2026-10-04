class Formatters {
  static String currency(double amount) {
    return 'S/ ${amount.toStringAsFixed(2)}';
  }

  static String date(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day/$month/$year';
  }
}
