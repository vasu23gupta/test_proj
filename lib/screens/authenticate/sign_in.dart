import 'package:flutter/material.dart';
import 'package:test_proj/screens/authenticate/forgot_password.dart';
import 'package:test_proj/services/auth.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/loading.dart';

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
  double _h = 0;
  double _w = 0;

  Padding _buildErrorText() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_error, style: ERROR_TEXT_STYLE(_w)));
  }

  Padding _buildPasswordRow() => Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: TextFormField(
          controller: _passwordController,
          keyboardType: TextInputType.text,
          obscureText: true,
          validator: (val) =>
              val.length < 6 ? 'Enter a password 6+ characters long' : null,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.lock,
                color: TEXT_COLOR,
              ),
              hintText: 'Password',
              hintStyle: TextStyle(color: ThemeData.light().hintColor)),
        ),
      );

  ElevatedButton _buildLoginButton() => ElevatedButton(
        style: BS(_w * 0.3, _h * 0.065),
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            setState(() => _loading = true);
            dynamic result = await _auth.signInWithEmailAndPassword(
                _emailController.text, _passwordController.text);
            if (result == null)
              setState(() {
                _loading = false;
                _error = 'Could not sign in with those credentials.';
              });
          }
        },
        child: Text(
          "Login",
          style: TextStyle(
            letterSpacing: 1.5,
            fontSize: _h * 0.028,
          ),
        ),
      );

  Padding _buildOrRow() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Or',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: ThemeData.light().textTheme.bodyText2.color,
          ),
        ),
      );

  Padding _buildOrGoogleRow() => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'Or sign in with',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: ThemeData.light().textTheme.bodyText2.color,
          ),
        ),
      );

  GestureDetector _buildGoogleBtn() => GestureDetector(
        onTap: () async {
          dynamic result = await _auth.signInWithGoogle();
          if (result == null) print('error signing in');
        },
        child: Container(
          height: 60,
          width: 60,
          child: CircleAvatar(backgroundImage: AssetImage('assets/google.png')),
        ),
      );

  ClipRRect _buildContainer() => ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          width: _w * 0.8,
          decoration: BoxDecoration(color: Colors.white),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildEmailRow(_emailController),
                _buildPasswordRow(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                        child: _buildLoginButton()),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: _buildforgotpassword()),
                  ],
                ),
                _buildOrGoogleRow(),
                _buildGoogleBtn(),
                _buildOrRow(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: _buildContinueWithoutBtn(),
                ),
              ],
            ),
          ),
        ),
      );

  ElevatedButton _buildContinueWithoutBtn() => ElevatedButton(
        child: Text('Continue without signing in'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(TEXT_COLOR),
          shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
        ),
        onPressed: () async {
          dynamic result = await _auth.signInAnon();
          if (result == null) print('error signing in');
        },
      );

  TextButton _buildforgotpassword() => TextButton(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(TEXT_COLOR)),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ForgotPassword())),
        child: Text(
          "Forgot password?",
          style: TextStyle(fontSize: _h / 60),
        ),
      );

  Row _buildSignUpBtn() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextButton(
            onPressed: widget.toggleView,
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Dont have an account? ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: _h / 40,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                    color: TEXT_COLOR,
                    fontSize: _h * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ]),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    _h = MediaQuery.of(context).size.height;
    _w = MediaQuery.of(context).size.width;
    return _loading
        ? Loading()
        : Theme(
            data: ThemeData.light(),
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: Color(0xfff2f3f7),
                body: SingleChildScrollView(
                  child: Center(
                    child: Stack(
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildLogo(_h),
                            _buildContainer(),
                            _buildErrorText(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildSignUpBtn(),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
