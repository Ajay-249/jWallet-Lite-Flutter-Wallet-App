import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'cached_user';

  final SharedPreferences _prefs;

  AuthLocalDataSource(this._prefs);

  static Future<AuthLocalDataSource> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthLocalDataSource(prefs);
  }

  Future<void> saveAuthSession({
    required String token,
    required UserModel user,
  }) async {
    await _prefs.setString(_keyToken, token);
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  UserModel? getCachedUser() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  bool hasValidSession() {
    return _prefs.containsKey(_keyToken) && _prefs.getString(_keyToken) != null;
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
  }
}
