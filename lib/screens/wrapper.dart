import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/screens/authenticate/authenticate.dart';
import 'package:test_proj/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    print(user);
    //return either home or authenticate
    return Authenticate();
  }
}
