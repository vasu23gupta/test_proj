import 'package:test_proj/services/auth.dart';

import 'package:test_proj/screens/profile/usercontroller.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupServices() {
  locator.registerSingleton<AuthService>(AuthService());
  locator.registerSingleton<UserController>(UserController());
}