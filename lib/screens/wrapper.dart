import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/screens/authenticate/authenticate.dart';
import 'package:test_proj/screens/settings/app.dart';
import 'package:test_proj/services/filters.dart';
import 'home/home.dart';

class WrapperCaller extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(context),
      child: MaterialApp(
        title: 'LocalPedia',
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
      ),
    );
  }
}

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
    //   return th;
    // }
    // getSystemTheme();

    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    if (_user == null) {
      return Authenticate();
    } else {
      return ChangeNotifierProvider(
          create: (context) => Filters(),
          child: MaterialApp(
            home: Home(),
            theme:
                /* theme.useSystemTheme
                ? (!darkModeOn)
                    ? ThemeData.light()
                    : ThemeData.dark()
                : theme.light
                    ? ThemeData.light()
                    : ThemeData.dark(), */
                ThemeData.light(),
            //darkTheme: theme.useSystemTheme?ThemeData.dark():theme.currentTheme,
            //themeMode: ThemeMode.system,
          ));
    }
  }
}
