import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_proj/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'LocalPedia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        //darkTheme: ThemeData.dark(),
        home: Wrapper(),
      ),
    );
  }
}
