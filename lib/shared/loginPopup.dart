import 'package:flutter/material.dart';
import 'package:test_proj/screens/authenticate/authenticate.dart';

class LoginPopup extends StatelessWidget {
  final String to;
  LoginPopup({this.to});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          //close button
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                backgroundColor: Colors.red,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: Text(
                  'You need to login to $to',
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.25,
                ),
                height: 70,
                width: 500,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Authenticate(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VerifyEmailPopup extends StatelessWidget {
  final String to;
  VerifyEmailPopup({this.to});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          //close button
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                backgroundColor: Colors.red,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: Text(
                  'You need to verify your email to $to. If you have not recieved the verification email you can resend it from settings.',
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.25,
                ),
                height: 70,
                width: 500,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'I Understand',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
