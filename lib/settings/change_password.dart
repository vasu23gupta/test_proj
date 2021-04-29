import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_proj/services/auth.dart';
import 'package:test_proj/shared/constants.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword();
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var _passwordController = TextEditingController();
  var _newPasswordController = TextEditingController();
  var _repeatPasswordController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  bool checkCurrentPasswordValid = true;
  AuthService _auth = AuthService();

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: BACKGROUND_COLOR,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Flexible(
                  child: Form(
                      key: _formKey,
                      child: Column(children: <Widget>[
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Current Password",
                            errorText: checkCurrentPasswordValid
                                ? null
                                : "Please double check your current password",
                          ),
                          controller: _passwordController,
                        ),
                        TextFormField(
                          decoration: InputDecoration(hintText: "New Password"),
                          controller: _newPasswordController,
                          obscureText: true,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: "Repeat Password",
                          ),
                          obscureText: true,
                          controller: _repeatPasswordController,
                          validator: (value) {
                            return _newPasswordController.text == value
                                ? null
                                : "Please validate your entered password";
                          },
                        )
                      ]))),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  //var userController = locator.get<UserController>();
                  checkCurrentPasswordValid =
                      await _auth.validatePassword(_passwordController.text);
                  setState(() {});
                  if (_formKey.currentState.validate() &&
                      checkCurrentPasswordValid) {
                    _auth.updatePassword(_newPasswordController.text);
                    Navigator.pop(context);
                  }
                },
                child: Text("Save Profile"),
              )
            ])),
      ),
    );
  }
}
