import '../../domain/contracts/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsSessionStorage implements SessionStorage {
  static const String _tokenKey = 'jwt_token';

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
