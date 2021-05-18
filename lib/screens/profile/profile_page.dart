import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/appUser.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/loading.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  AppUser _appUser;
  User _user;

  void getProfile() async {
    Response response =
        await UserDBService(jwt: await _user.getIdToken()).getUserByJWT();

    setState(() {
      _appUser = AppUser(jsonDecode(response.body));
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                Text(_appUser.name, style: TextStyle(fontSize: 30)),
                Row(
                  children: [
                    Text('Points : ',
                        style: TextStyle(fontSize: 20, color: Colors.green)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(_appUser.points.toString(),
                        style: TextStyle(fontSize: 20, color: Colors.yellow)),
                  ],
                ),
                Row(
                  children: [
                    Text('Level : ',
                        style: TextStyle(fontSize: 20, color: Colors.green)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(_appUser.level.toString(),
                        style: TextStyle(fontSize: 20, color: Colors.yellow)),
                  ],
                ),
                Row(
                  children: [
                    Text('NextLevelAt : ',
                        style: TextStyle(fontSize: 20, color: Colors.green)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(_appUser.nextLevelAt.toString(),
                        style: TextStyle(fontSize: 20, color: Colors.yellow)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'points',
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text('Remaining Additions: ',
                        style: TextStyle(fontSize: 20, color: Colors.green)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(_appUser.addsRemainig.toString(),
                        style: TextStyle(fontSize: 20, color: Colors.yellow)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      ' this month',
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text('Remaining Edits: ',
                        style: TextStyle(fontSize: 20, color: Colors.green)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(_appUser.editsRemaing.toString(),
                        style: TextStyle(fontSize: 20, color: Colors.yellow)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      ' this month',
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              ],
            ),
          );
  }
}
