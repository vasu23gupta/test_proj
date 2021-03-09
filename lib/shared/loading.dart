import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String data;
  Loading({this.data});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      data == null
          ? Text('')
          : Text(
              data,
              style: TextStyle(
                  color: Colors.red,
                  decoration: TextDecoration.none,
                  fontSize: 30),
            ),
      if (data == null) Center(child: CircularProgressIndicator()),
    ]);
  }
}
