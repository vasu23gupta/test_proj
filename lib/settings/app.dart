import 'package:flutter/material.dart';
import 'package:test_proj/services/preferences.dart';

class AppProvider with ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();
  bool useSystemTheme;
  bool light;
  Preferences pref = Preferences();
  BuildContext context;
  AppProvider(BuildContext context) {
    this.context = context;
    getSystemTheme();
  }

  Future useLightTheme() async {
    light = true;
    useSystemTheme = false;
    await pref.setSystemThemeFalse();
    await pref.setThemeFalse();

    notifyListeners();
  }

  Future useDarkTheme() async {
    light = false;
    useSystemTheme = false;
    await pref.setSystemThemeFalse();
    await pref.setTheme();

    notifyListeners();
  }

  Future useSystemThem() async {
    useSystemTheme = true;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    if (darkModeOn)
      light = false;
    else
      light = true;
    notifyListeners();
    await pref.setSystemTheme();
    if (light)
      await pref.setThemeFalse();
    else
      await pref.setTheme();
  }

  ThemeData get currentTheme => _currentTheme;

  set currentTheme(value) {
    _currentTheme = value;

    notifyListeners();
  }

  void switchTheme() {
    currentTheme =
        currentTheme == ThemeData.dark() ? ThemeData.light() : ThemeData.dark();
    notifyListeners();
  }

  Future getSystemTheme() async {
    if (await pref.getSystemTheme() == "f") {
      useSystemTheme = false;
      if (await pref.getTheme() == "t") {
        light = false;
      } else {
        light = true;
      }
      notifyListeners();
    } else {
      print("using system theme");
      useSystemTheme = true;
      var brightness = MediaQuery.of(context).platformBrightness;
      bool darkModeOn = brightness == Brightness.dark;
      if (darkModeOn)
        light = false;
      else
        light = true;

      notifyListeners();
      if (light)
        await pref.setThemeFalse();
      else
        await pref.setTheme();
    }
  }

  Future getTheme() async {
    light = await pref.getTheme() == "f" ? true : false;
    notifyListeners();
  }

  Future<void> switchSystemTheme() async {
    var th = await pref.getSystemTheme();

    await pref.switchSystemTheme();
    if (th == "f") {
      print(th);
      var brightness = MediaQuery.of(context).platformBrightness;
      bool darkModeOn = brightness == Brightness.dark;
      if (darkModeOn)
        _currentTheme = ThemeData.dark();
      else
        _currentTheme = ThemeData.light();
      useSystemTheme = true;
    } else
      useSystemTheme = false;
    notifyListeners();
  }
}
