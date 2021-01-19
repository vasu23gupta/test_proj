import 'package:flutter/material.dart';

class ThemeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Container(
        padding: EdgeInsets.only(right: 15, left: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text('Dark'),
              onPressed: () {
                var appState;
                appState.currentTheme = ThemeData.dark();
              },
            ),
          ],
        ),
      ),
    );
  }
}
