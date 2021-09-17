import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/settings/change_password.dart';
import 'package:test_proj/settings/darkthemebutton.dart';
import 'package:test_proj/shared/constants.dart';

class SettingsPage extends StatefulWidget {
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
    //final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: BACKGROUND_COLOR,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text(
                  'Change Password',
                  style: TextStyle(
                      /* color: Colors.black,*/ fontWeight: FontWeight.w500),
                ),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => ChangePassword())),
                trailing: Icon(Icons.edit),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(8.0),
              /*color: Colors.green[200],*/
              child: ListTile(
                title: Text(
                  'Themes',
                  style: TextStyle(
                      /*color: Colors.white,*/ fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThemeButton()),
                ),
              ),
            ),
            if (!_user.emailVerified)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                margin: const EdgeInsets.all(8.0),
                //  color: Colors.green[200],
                child: ListTile(
                  onTap: _user.sendEmailVerification,
                  title: Text(
                    'Resend verification email',
                    style: TextStyle(
                        /* color: Colors.white,*/ fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
