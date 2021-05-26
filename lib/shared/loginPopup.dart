import 'package:flutter/material.dart';
import 'package:test_proj/screens/authenticate/authenticate.dart';
import 'package:test_proj/shared/constants.dart';

class LoginPopup extends StatelessWidget {
  final String to;
  LoginPopup({this.to});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      content: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          //close button
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () => Navigator.of(context).pop(),
              child: CircleAvatar(
                  child: Icon(Icons.close), backgroundColor: Colors.red),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You need to login to $to.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: size.width * 0.05),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: BS(size.width * 0.3, size.height * 0.06),
                child: Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white, fontSize: size.width * 0.05),
                ),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Authenticate())),
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
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      content: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          //close button
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () => Navigator.of(context).pop(),
              child: CircleAvatar(
                  child: Icon(Icons.close), backgroundColor: Colors.red),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: Text(
                  'You need to verify your email to $to. If you have not recieved the verification email you can resend it from settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: size.width * 0.05),
                ),
                height: 70,
                width: 500,
              ),
              SizedBox(height: 15),
              ElevatedButton(
                style: BS(size.width * 0.4, size.height * 0.06),
                child: Text(
                  'I Understand',
                  style: TextStyle(
                      color: Colors.white, fontSize: size.width * 0.05),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
