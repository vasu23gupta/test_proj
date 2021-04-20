import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/screens/authenticate/sign_in.dart';
import 'package:test_proj/screens/home/home.dart';
import 'package:test_proj/settings/app.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    var theme = Provider.of<AppProvider>(context);
    // var brightness = MediaQuery.of(context).platformBrightness;
    // bool darkModeOn = brightness == Brightness.dark;
    // if(darkModeOn)
    //   theme.currentTheme=ThemeData.dark();
    // else
    //   theme.currentTheme=ThemeData.light();
    //return either home or authenticate
    // Future<String> getSystemTheme() async {
    //   th= await pref.getSystemTheme();
    //   print(th);
    //   return th;
    // }
    // getSystemTheme();

    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    //print("darrtsdfjghdlhgdj");
    print("hrere2");
    if (darkModeOn) print("darkmodeisonbroyeahhhhhh");
    print(theme.light);
    if (_user == null) {
      return SignIn();
    } else {
      return MaterialApp(
        home: Home(),
        theme: theme.useSystemTheme
            ? (!darkModeOn)
                ? ThemeData.light()
                : ThemeData.dark()
            : theme.light
                ? ThemeData.light()
                : ThemeData.dark(),
        //darkTheme: theme.useSystemTheme?ThemeData.dark():theme.currentTheme,
        //themeMode: ThemeMode.system,
      );
    }
  }
}
