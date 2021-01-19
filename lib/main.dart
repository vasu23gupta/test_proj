import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_proj/services/auth.dart';
import 'package:test_proj/settings/app.dart';

class ThemeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppProvider(),
        ),
      ],
      child: App(),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppProvider>(context);
    return MaterialApp(
      theme: appState.currentTheme,
      home: MyApp(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<CustomUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: Wrapper(),
      ),
    );
  }
}
