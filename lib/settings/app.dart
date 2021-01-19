import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier {
  ThemeData _currentTheme;

  AppProvider() {
    _currentTheme = ThemeData.light();
  }

  ThemeData get currentTheme => _currentTheme;

  set currentTheme(value) {
    _currentTheme = value;

    notifyListeners();
  }
}
