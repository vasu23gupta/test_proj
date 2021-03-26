import 'package:flutter/material.dart';
import 'package:test_proj/screens/authenticate/register.dart';
import 'package:test_proj/screens/authenticate/sign_in.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool _showSignIn = true;
  void toggleView() => setState(() => _showSignIn = !_showSignIn);

  @override
  Widget build(BuildContext context) => _showSignIn
      ? SignIn(toggleView: toggleView)
      : Register(toggleView: toggleView);
}
