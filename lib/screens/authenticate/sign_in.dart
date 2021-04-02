import 'package:flutter/material.dart';
import 'package:test_proj/screens/authenticate/forgot_password.dart';
import 'package:test_proj/services/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/loading.dart';

import 'color.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _error = '';
   bool loading = false;

  //text field state
  String email = '';
  String password = '';
  String error = '';

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 70),
          child: Text(
            'LOCALPEDIA',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: _emailController,
        style: TextStyle(color: Colors.green),
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.email,
              color: AUTH_MAIN_COLOR,
            ),
            hintText: 'Enter E-mail',
            hintStyle: TextStyle(color: Colors.green),
            labelText: 'E-mail'),
        validator: (val) => val.isEmpty ? 'Enter an email' : null,
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: _passwordController,
        style: TextStyle(color: Colors.green),
        keyboardType: TextInputType.text,
        obscureText: true,
        validator: (val) =>
            val.length < 6 ? 'Enter a password 6+ characters long' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: AUTH_MAIN_COLOR,
          ),
          hintText: 'Enter Password',
          hintStyle: TextStyle(color: Colors.green),
          labelText: 'Password',
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 1.4 * (MediaQuery.of(context).size.height / 20),
      width: 5 * (MediaQuery.of(context).size.width / 10),
      child: RaisedButton(
        elevation: 5.0,
        color: AUTH_MAIN_COLOR,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            setState(() => _loading = true);
            dynamic result = await _auth.signInWithEmailAndPassword(
                _emailController.text, _passwordController.text);
            if (result == null)
              setState(() {
                _loading = false;
                _error = 'could not sign in with those credentials';
              });
          }
        },
        child: Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: MediaQuery.of(context).size.height / 40,
          ),
        ),
      ),
    );
  }

  Widget _buildOrRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Text(
            '- OR -',
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSocialBtnRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () async {
            dynamic result = await _auth.signInWithGoogle();
            if (result == null) print('error signing in');
          },
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AUTH_MAIN_COLOR,
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0)
              ],
            ),
            child: Icon(
              FontAwesomeIcons.google,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                            style: TextStyle(color: Colors.green),
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: mainColor,
                                ),
                                hintText: 'Enter E-mail',
                                hintStyle: TextStyle(color: Colors.green),
                                labelText: 'E-mail',
                                labelStyle: TextStyle(color: Colors.grey),),
                                
                            validator: (val) =>
                                val.isEmpty ? 'Enter an email' : null,
                            onChanged: (val) {
                              setState(() => email = val);
                            }),
                      ),
                    ),
                    SizedBox(
                        child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        style: TextStyle(color: Colors.green),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: (val) => val.length < 6
                            ? 'Enter a password 6+ characters long'
                            : null,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: mainColor,
                          ),
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(color: Colors.green),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )),
                    SizedBox(
                      height: 1.4 * (MediaQuery.of(context).size.height / 20),
                      width: 5 * (MediaQuery.of(context).size.width / 10),
                      child: RaisedButton(
                        elevation: 5.0,
                        color: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(email, password);
                            if (result == null)
                              setState(() {
                                loading = false;
                                error =
                                    'could not sign in with those credentials';
                              });
                          }
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: MediaQuery.of(context).size.height / 40,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    RaisedButton(
                      child: Text(
                          '(Continue without signing in) Sign in anonimously'),
                      onPressed: () async {
                        dynamic result = await _auth.signInAnon();
                        if (result == null) {
                          print('error signing in');
                        } else {
                          print('signed in');
                        }
                      },
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Text(
                              '- OR -',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              dynamic result = await _auth.signInWithGoogle();
                              if (result == null) {
                                print('error signing in');
                              } else {
                                print('signed in');
                              }
                            },
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: mainColor,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                      blurRadius: 6.0)
                                ],
                              ),
                              child: Icon(
                                FontAwesomeIcons.google,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
              /* Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
               
                _buildRegisterButton(),
              ],
            ),*/
              ),
        ),
      ],
    );
  }

  Widget _buildforgotpassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height / 35),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: EdgeInsets.only(bottom: 20),
          child: RaisedButton(
            elevation: 5.0,
            color: AUTH_MAIN_COLOR,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => ForgotPassword())),
            child: Text(
              "Forgot password",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height / 100,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSignUpBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40),
          child: FlatButton(
            onPressed: () {
              widget.toggleView();
            },
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Dont have an account? ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                    color: AUTH_MAIN_COLOR,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ]),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Color(0xfff2f3f7),
              body: Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AUTH_MAIN_COLOR,
                        borderRadius: BorderRadius.only(
                          bottomLeft: const Radius.circular(70),
                          bottomRight: const Radius.circular(70),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildLogo(),
                      _buildContainer(),
                      _buildforgotpassword(),
                      _buildSignUpBtn(),
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
