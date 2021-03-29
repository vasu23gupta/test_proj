import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_proj/services/auth.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/loading.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _reenterController = TextEditingController();
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
          onChanged: (val) {
            setState(() => _emailController.text = val);
          }),
    );
  }

  Widget _buildUsernameRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: _usernameController,
        style: TextStyle(color: Colors.green),
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.email,
              color: AUTH_MAIN_COLOR,
            ),
            hintText: 'Enter Username',
            hintStyle: TextStyle(color: Colors.green),
            labelText: 'Username'),
        validator: (val) => (val.length > 20 && val.length < 1)
            ? 'Username should be less than 20 char'
            : null,
        onChanged: (val) {
          setState(() => _usernameController.text = val);
        },
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
        onChanged: (val) {
          setState(() => _passwordController.text = val);
        },
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

  Widget _buildRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height / 20),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: EdgeInsets.only(bottom: 20),
          child: RaisedButton(
            elevation: 5.0,
            color: AUTH_MAIN_COLOR,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                setState(() => loading = true);
                dynamic result = await _auth.registerWithEmailAndPassword(
                    _emailController.text,
                    _passwordController.text,
                    _usernameController.text);
                if (result == null) {
                  setState(() {
                    error = 'please supply a valid email';
                    loading = false;
                  });
                }
              }
            },
            child: Text(
              "Register",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height / 40,
              ),
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
              height: MediaQuery.of(context).size.height * 0.6,
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
                            validator: (val) =>
                                val.isEmpty ? 'Enter an email' : null,
                            onChanged: (val) {
                              setState(() => _emailController.text = val);
                            }),
                      ),
                    ),
                    SizedBox(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          controller: _usernameController,
                          style: TextStyle(color: Colors.green),
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: AUTH_MAIN_COLOR,
                              ),
                              hintText: 'Enter Username',
                              hintStyle: TextStyle(color: Colors.green),
                              labelText: 'Username'),
                          validator: (val) =>
                              (val.length > 20 && val.length < 1)
                                  ? 'Username should be less than 20 char'
                                  : null,
                          onChanged: (val) {
                            setState(() => _usernameController.text = val);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                        child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: Colors.green),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: (val) => val.length < 6
                            ? 'Enter a password 6+ characters long'
                            : null,
                        onChanged: (val) {
                          setState(() => _passwordController.text = val);
                        },
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
                    )),
                    SizedBox(
                        child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _reenterController,
                        style: TextStyle(color: Colors.green),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: (val) => _passwordController.text != val
                            ? 'Passwords do not match'
                            : null,
                        onChanged: (val) {
                          setState(() => _reenterController.text = val);
                        },
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
                    )),
                    SizedBox(
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
                            setState(() => loading = true);
                            dynamic result =
                                await _auth.registerWithEmailAndPassword(
                                    _emailController.text,
                                    _passwordController.text,
                                    _usernameController.text);
                            if (result == null) {
                              setState(() {
                                error = 'please supply a valid email';
                                loading = false;
                              });
                            }
                          }
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: MediaQuery.of(context).size.height / 40,
                          ),
                        ),
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

  Widget _buildSigninBtn() {
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
                  text: 'Already Have an Account ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Sign In',
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
    return SafeArea(
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
                _buildSigninBtn(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
