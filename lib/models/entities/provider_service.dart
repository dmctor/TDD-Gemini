class ProviderService {
  final String id;
  final int dependencyId;
  final int providerId;
  final String description;
  final String name;
  final double price;

  ProviderService({
    Object? id,
    String? name,
    String? description,
    Object? dependencyId,
    Object? providerId,
    Object? price,
  })  : id = id?.toString() ?? '',
        dependencyId = _asInt(dependencyId),
        providerId = _asInt(providerId),
        description = description ?? name ?? '',
        name = name ?? description ?? '',
        price = _asDouble(price);

  static int _asInt(Object? value) {
    final parsed = int.tryParse(value?.toString() ?? '');
    return parsed ?? 0;
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    return ProviderService(
      id: json['id'],
      dependencyId: json['dependency_id'] ?? json['dependencyId'] ?? 0,
      providerId: json['provider_id'] ?? json['providerId'] ?? 0,
      description: json['description'] ?? json['name'] ?? '',
      price: json['price'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dependency_id': dependencyId,
      'provider_id': providerId,
      'description': description,
      'name': name,
      'price': price,
    };
  }
}
