class Invoice {
  final String id;
  final String serviceId;
  final double amount;
  final DateTime issueDate;

  final String invoiceNumber;
  final String serviceType;
  final int invoiceMonth;
  final bool invoiced;
  final DateTime dueDate;

  Invoice({
    Object? id,
    Object? serviceId,
    Object? amount,
    DateTime? issueDate,
    String? invoiceNumber,
    String? serviceType,
    Object? invoiceMonth,
    bool? invoiced,
    DateTime? dueDate,
    // Alias usados por las pruebas de periodo (RN-17)
    DateTime? fechaEmision,
    Object? mesFacturacion,
    bool? estaFacturada,
  })  : id = id?.toString() ?? '',
        serviceId = serviceId?.toString() ?? '',
        amount = _asDouble(amount),
        issueDate =
            issueDate ?? fechaEmision ?? DateTime.fromMillisecondsSinceEpoch(0),
        invoiceNumber = invoiceNumber ?? '',
        serviceType = serviceType ?? '',
        invoiceMonth = _asInt(invoiceMonth ?? mesFacturacion),
        invoiced = invoiced ?? estaFacturada ?? false,
        dueDate = dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);

  DateTime get fechaEmision => issueDate;
  int get mesFacturacion => invoiceMonth;
  bool get estaFacturada => invoiced;

  static int _asInt(Object? value) {
    final parsed = int.tryParse(value?.toString() ?? '');
    return parsed ?? 0;
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawServiceId = json['serviceId'] ?? json['service_id'];
    final rawAmount = json['amount'] ?? 0.0;
    final rawIssueDate = json['issueDate'] ?? json['issue_date'];

    return Invoice(
      id: rawId,
      serviceId: rawServiceId,
      amount: rawAmount,
      issueDate: rawIssueDate is String ? DateTime.parse(rawIssueDate) : null,
      invoiceNumber: json['invoice_number'] ?? json['invoiceNumber'] ?? '',
      serviceType: json['service_type'] ?? json['serviceType'] ?? '',
      invoiceMonth: json['invoice_month'] ?? json['invoiceMonth'] ?? 0,
      invoiced: json['invoiced'] ?? false,
      dueDate: json['due_date'] is String ? DateTime.parse(json['due_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'amount': amount,
      'issueDate': issueDate.toIso8601String(),
      'invoice_number': invoiceNumber,
      'service_type': serviceType,
      'invoice_month': invoiceMonth,
      'invoiced': invoiced,
      'due_date': dueDate.toIso8601String(),
    };
  }
}
