import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String data;
  Loading({this.data});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: data == null || data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Text(
              data,
              style: TextStyle(
                  color: Colors.red,
                  decoration: TextDecoration.none,
                  fontSize: 30),
            ),
    );
  }
}
