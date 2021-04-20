import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/screens/wrapper.dart';
import 'package:test_proj/settings/app.dart';

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
