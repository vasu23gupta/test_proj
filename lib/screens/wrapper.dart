import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/screens/Search/filters.dart';
import 'package:test_proj/settings/app.dart';
import 'authenticate/sign_in.dart';
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
      return ChangeNotifierProvider(create:(context) => Filters(), child:MaterialApp(
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
      ));
    }
  }
}
