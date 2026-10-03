import 'package:flutter/foundation.dart';
import 'package:practice_app/api/api_client.dart';
import 'package:practice_app/auth/user_manager.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/utils/shared_preferences.dart';

class AuthRepository {
  Future<UserModel> login(String email, String password) async {
    try {
      ApiClient.invalidateAll();
      final response = await ApiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      // Save token securely
      final String token = response['token'];
      await LocalStoragePref().saveToken(token);

      // Save User Data locally (optional, but good for offline restore)
      final userJson = response['user'];
      await LocalStoragePref().saveUser(userJson);

      final user = UserModel.fromJson(userJson);
      await UserManager().setUser(user);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    ApiClient.invalidateAll();
    await UserManager().clearUser();
    await LocalStoragePref().clearPrefBox();
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await ApiClient.put('/users/fcm-token/update', {
        'token': fcmToken,
      });
    } catch (e) {
      debugPrint('Failed to update FCM token: $e');
    }
  }
}
