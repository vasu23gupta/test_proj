import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/locator.dart';
import 'package:test_proj/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_proj/screens/wrapperCaller.dart';
import 'package:test_proj/services/auth.dart';
import 'services/preferences.dart';

Preferences preferences = Preferences();
String theme;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  theme = await preferences.getSystemTheme();
  print("main here");
  if (theme == null) await preferences.setSystemTheme();

  await Firebase.initializeApp();
  // ignore: await_only_futures
  await setupServices();
  runApp(MyApp());
  runApp(ChangeNotifierProvider<Preferences>(
      create: (_) => Preferences(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'LocalPedia',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: WrapperCaller(),
      ),
    );
  }
}
