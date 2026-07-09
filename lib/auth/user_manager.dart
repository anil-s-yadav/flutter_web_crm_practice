import 'dart:developer';
import '../models/user_model.dart';
import '../utils/shared_preferences.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  UserModel? _currentUser;

  Future<void> init() async {
    _currentUser = LocalStoragePref().getUserModel();
    log("UserManager init: $_currentUser");
  }

  Future<void> setUser(UserModel user) async {
    _currentUser = user;
    await LocalStoragePref().setUserModel(user);
  }

  UserModel? get currentUser => _currentUser;

  Future<void> clearUser() async {
    _currentUser = null;
    await LocalStoragePref().clearKey(LocalStorageKeys.userProfile);
    await LocalStoragePref().setLoginBool(false);
  }

  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isSales => _currentUser?.role == UserRole.sales;
  bool get isSourcing => _currentUser?.role == UserRole.sourcing;
  bool get isExecutive => _currentUser?.role == UserRole.executive;

  String get homeRoute {
    switch (_currentUser?.role) {
      case UserRole.admin:
        return '/admin';
      case UserRole.sales:
        return '/sales';
      case UserRole.sourcing:
        return '/sourcing';
      case UserRole.executive:
        return '/executive';
      default:
        return '/login';
    }
  }
}
