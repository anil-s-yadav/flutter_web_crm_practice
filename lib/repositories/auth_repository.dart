import 'package:practice_app/api/api_client.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/utils/shared_preferences.dart';

class AuthRepository {
  Future<UserModel> login(String email, String password) async {
    try {
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

      // Node.js returns 'id' as String now (e.g. U_123456). Our UserModel expects 'int id'.
      // We will need to update UserModel to use String id. For now, we will parse it carefully.
      return UserModel.fromJson(userJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await LocalStoragePref().clearPrefBox();
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await ApiClient.put('/users/fcm-token/update', {
        'token': fcmToken,
      });
    } catch (e) {
      print('Failed to update FCM token: $e');
    }
  }
}
