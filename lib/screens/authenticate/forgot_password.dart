import 'package:flutter/material.dart';
import 'package:test_proj/services/auth.dart';
import 'package:test_proj/shared/constants.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final AuthService _auth = AuthService();
  TextEditingController _emailController = TextEditingController();
  double _h = 0;
  double _w = 0;
  String _error = '';

  Padding _buildErrorText() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_error, style: ERROR_TEXT_STYLE(_w)));
  }

  Widget _buildsendemailButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ButtonStyle(
          minimumSize:
              MaterialStateProperty.all<Size>(Size(_w * 0.4, _h * 0.06)),
          backgroundColor: MaterialStateProperty.all<Color>(TEXT_COLOR),
          shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
        ),
        onPressed: () async {
          if (_emailController.text.isNotEmpty) {
            try {
              await _auth.forgotPassword(_emailController.text);
              setState(() => _error = "");
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Password recovery email sent!'),
                duration: Duration(seconds: 3),
              ));
            } catch (err) {
              print(err);
              setState(() => _error = "Please enter a valid email address");
            }
          } else
            setState(() => _error = "Please enter a valid email address");
        },
        child: Text("Send password reset email"),
      ),
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: Container(
            width: _w * 0.8,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildEmailRow(_emailController),
                _buildsendemailButton(),
                _error.isNotEmpty ? _buildErrorText() : Container()
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _h = MediaQuery.of(context).size.height;
    _w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            Container(
              height: _h * 0.7,
              width: _w,
              child: Container(
                decoration: BoxDecoration(
                  color: BACKGROUND_COLOR,
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(70),
                    bottomRight: const Radius.circular(70),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                buildLogo(_h),
                SizedBox(height: _h * 0.13),
                _buildContainer(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
