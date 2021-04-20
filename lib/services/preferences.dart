import 'package:flutter/foundation.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Preferences with ChangeNotifier {
  static String useSystemTheme ;
  String isDark = "f";

  Future switchSystemTheme() async
  {
    print("hell2");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var th=await getSystemTheme();
    await preferences.setString("useSystemTheme",th=="f"?"t":"f");
    notifyListeners();
    print("hell yeah2");
  }
  Future setSystemTheme() async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("useSystemTheme","t");
    //notifyListeners();
  }
  Future setSystemThemeFalse() async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("useSystemTheme","f");
    //notifyListeners();
  }
  Future switchCurrentTheme() async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(isDark,isDark=="f"?"t":"f");
  }
  Future setTheme() async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("isDark","t");
  }
  Future setThemeFalse() async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("isDark","f");
  }
  Future<String> getSystemTheme() async{
    print("hell");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = preferences.getString("useSystemTheme");
    notifyListeners();
    print(url);
    print("hell yeah");
    return url;
  }
  Future<String> getTheme() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = preferences.getString("isDark");
    notifyListeners();
    return url;
  }
  
}