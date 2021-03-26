import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/screens/authenticate/authenticate.dart';
import 'package:test_proj/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);

    //return either home or authenticate
    if (_user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
