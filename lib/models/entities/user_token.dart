class UserToken {
  final String token;
  final int? adminId;
  final String? username;
  final List<String> providerIds;

  const UserToken({
    required this.token,
    this.adminId,
    this.username,
    this.providerIds = const [],
  });

  factory UserToken.fromJson(Map<String, dynamic> json) {
    final admin = json['admin'] as Map<String, dynamic>?;
    final list = (admin?['list_provider'] as List<dynamic>? ?? const <dynamic>[]);
    return UserToken(
      token: json['token'] as String,
      adminId: admin?['id'] as int?,
      username: admin?['username'] as String?,
      providerIds: list.map((e) => e.toString()).toList(),
    );
  }
}
