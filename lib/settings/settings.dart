import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/appUser.dart';
import 'package:test_proj/screens/profile/change_password.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/settings/darkthemebutton.dart';

class SettingsPage extends StatefulWidget{
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  User _user;

   @override
  void initState() {
    super.initState(); 
    _user = Provider.of<User>(context, listen: false);  
    }
  
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(8.0),
              color: Colors.green[200],
              child: ListTile(
                leading: Icon(Icons.lock_outline, color: Colors.black),
                title: Text(
                  'Change Password',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                      Response response =
                          await UserDBService(jwt: await _user.getIdToken())
                              .getUserByJWT();
                      AppUser us = AppUser(jsonDecode(response.body));
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ChangePassword(user: us)));
                    },
                trailing: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
               
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(8.0),
              color: Colors.green[200],
              child: ListTile(
                title: Text(
                  'Themes',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThemeButton()),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(8.0),
              color: Colors.green[200],
              child: ListTile(
                title: Text(
                  'Change Language',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
            ),
            if (!user.emailVerified)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                margin: const EdgeInsets.all(8.0),
                color: Colors.green[200],
                child: ListTile(
                  onTap: () {
                    user.sendEmailVerification();
                  },
                  title: Text(
                    'Resend verification email',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
