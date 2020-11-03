import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/appUser.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    final users = Provider.of<List<AppUser>>(context);
    users.forEach((user) {
      print(user.name);
    });

    return Container();
  }
}
