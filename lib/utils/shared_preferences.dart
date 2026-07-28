import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalStoragePref {
  static final LocalStoragePref _instance = LocalStoragePref._internal();
  static SharedPreferences? _storage;
  static LocalStoragePref get instance => _instance;
  factory LocalStoragePref() => _instance;
  LocalStoragePref._internal();

  Future<void> initPrefBox() async {
    _storage ??= await SharedPreferences.getInstance();
  }

  Future<void> clearKey(String key) async => _storage?.remove(key);

  Future<void> setLoginBool(bool value) async {
    await _storage?.setBool(LocalStorageKeys.isLoggedIn, value);
  }

  bool? getLoginBool() {
    return _storage?.getBool(LocalStorageKeys.isLoggedIn);
  }

  Future<void> clearPrefBox() async => _storage?.clear();

  Future<void> saveToken(String token) async {
    await _storage?.setString(LocalStorageKeys.jwtToken, token);
  }

  String? getToken() {
    return _storage?.getString(LocalStorageKeys.jwtToken);
  }

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    await _storage?.setString(LocalStorageKeys.userProfile, jsonEncode(userJson));
  }

  Future<void> setUserModel(UserModel model) async {
    final jsonString = jsonEncode(model.toJson());
    await _storage?.setString(LocalStorageKeys.userProfile, jsonString);
  }

  UserModel? getUserModel() {
    final jsonStr = _storage?.getString(LocalStorageKeys.userProfile);
    if (jsonStr == null) return null;
    final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
    return UserModel.fromJson(jsonMap);
  }
}

class LocalStorageKeys {
  static const isLoggedIn = 'isLoggedIn';
  static const userProfile = 'user_profile';
  static const jwtToken = 'jwt_token';
}
