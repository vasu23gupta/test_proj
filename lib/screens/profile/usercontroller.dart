import 'package:test_proj/services/auth.dart';
import 'dart:io';
import 'package:test_proj/models/appUser.dart';
import 'package:test_proj/locator.dart';

class UserController {
  AppUser _currentUser;
  AuthService _authRepo = locator.get<AuthService>();
  Future init;


Future<bool> validateCurrentPassword(String password) async {
    return await _authRepo.validatePassword(password);
  }

 void updateUserPassword(String password) {
    _authRepo.updatePassword(password);
  }
}
