import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_proj/models/appUser.dart';
import 'package:test_proj/screens/profile/usercontroller.dart';

import '../../locator.dart';

class ChangePassword extends StatefulWidget{
   AppUser user;

 ChangePassword({this.user});

  @override
   _ChangePasswordState createState() =>
       _ChangePasswordState();
}
class  _ChangePasswordState extends State<ChangePassword>{
 var _displayNameController = TextEditingController();
  var _passwordController = TextEditingController();
  var _newPasswordController = TextEditingController();
  var _repeatPasswordController = TextEditingController();

  var _formKey = GlobalKey<FormState>();

  bool checkCurrentPasswordValid = true;

  @override
  void initState() {
    _displayNameController.text = widget.user.name;
    super.initState();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password'),),
      body: SingleChildScrollView(child: Padding(
 padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
             TextFormField(
              decoration: InputDecoration(hintText: "Username"),
              controller: _displayNameController,
            ),
             SizedBox(height: 20.0),
              Flexible(
                child: Form(
                    key: _formKey,
                     child: Column(
                         children: <Widget>[
                            Text(
                      "Manage Password",
                      style: Theme.of(context).textTheme.display1,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Current Password",
                        errorText: checkCurrentPasswordValid
                            ? null
                            : "Please double check your current password",
                      ),
                      controller: _passwordController,
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(hintText: "New Password"),
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
                         ]
                     )
                )
              ),
                 SizedBox(height: 10),
                  RaisedButton(
                     onPressed: () async{
                         var userController = locator.get<UserController>();

               /* if (widget.user.name !=
                    _displayNameController.text) {
                  var displayName = _displayNameController.text;
                  userController.updateDisplayName(name);
                }*/
                 checkCurrentPasswordValid =
                    await userController.validateCurrentPassword(
                        _passwordController.text);
                              setState(() {});
                               if (_formKey.currentState.validate() &&
                    checkCurrentPasswordValid)
                    {
                  userController.updateUserPassword(
                      _newPasswordController.text);
                  Navigator.pop(context);
                }
                     },
                      child: Text("Save Profile"),
                  )
          ]
        )
     ),),
    );
     
  }
}
 

