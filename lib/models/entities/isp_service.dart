class IspService {
  final String id;
  final int ispId;
  final int providerId;
  final String description;
  final String name;
  final double cost;
  final String payCode;

  IspService({
    Object? id,
    Object? name,
    String? description,
    Object? ispId,
    Object? providerId,
    Object? cost,
    String? payCode,
    // Alias usados por las pruebas de HU-05
    String? descripcion,
    Object? monto,
  })  : id = id?.toString() ?? '',
        ispId = _asInt(ispId),
        providerId = _asInt(providerId),
        // RN-13: descripcion y codigo de pago se almacenan sin espacios
        description =
            (description ?? descripcion ?? (name is String ? name : '')).trim(),
        name = (name is String ? name : (description ?? descripcion ?? ''))
            .trim(),
        cost = _asDouble(cost ?? monto),
        payCode = (payCode ?? '').trim();

  String get descripcion => description;
  double get monto => cost;

  static int _asInt(Object? value) {
    final parsed = int.tryParse(value?.toString() ?? '');
    return parsed ?? 0;
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory IspService.fromJson(Map<String, dynamic> json) {
    return IspService(
      id: json['id'],
      ispId: json['isp_id'] ?? json['ispId'] ?? 0,
      providerId: json['provider_id'] ?? json['providerId'] ?? 0,
      description: json['description'] ?? json['name'] ?? '',
      cost: json['cost'] ?? 0.0,
      payCode: json['pay_code'] ?? json['payCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isp_id': ispId,
      'provider_id': providerId,
      'description': description,
      'name': name,
      'cost': cost,
      'pay_code': payCode,
    };
  }
}
