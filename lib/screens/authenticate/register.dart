import 'package:flutter/material.dart';
import 'package:test_proj/screens/authenticate/tnc_pp.dart';
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
  bool _loading = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _reenterController = TextEditingController();
  String _error = '';
  bool _checkboxvalue = false;
  double _h = 0;
  double _w = 0;

  Widget _buildUsernameRow() => Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextFormField(
          maxLength: 50,
          controller: _usernameController,
          decoration: InputDecoration(
              counterText: "",
              prefixIcon: Icon(
                Icons.account_box,
                color: TEXT_COLOR,
              ),
              hintText: 'Username',
              hintStyle: TextStyle(color: ThemeData.light().hintColor)),
          validator: (val) => (val.length < 2)
              ? 'Please enter a username greater than 2 characters'
              : (val.length > 30)
                  ? 'Please enter a username smaller than 30 characters'
                  : null,
        ),
      );

  Widget _buildPasswordRow() => Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextFormField(
          controller: _passwordController,
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

  Widget _buildRegisterButton() => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: ElevatedButton(
          style: BS(_w * 0.4, _h * 0.06),
          onPressed: () async {
            if (_checkboxvalue) {
              setState(() => _error = "");
              if (_formKey.currentState.validate()) {
                setState(() => _loading = true);
                dynamic result = await _auth.registerWithEmailAndPassword(
                    _emailController.text,
                    _passwordController.text,
                    _usernameController.text.trim());
                if (result == null) {
                  setState(() {
                    _error = 'Please enter a valid email';
                    _loading = false;
                  });
                }
              }
            } else
              setState(() => _error =
                  "You need to accept Privacy Policy and Terms and Conditions to Register.");
          },
          child: Text(
            "Register",
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.5,
              fontSize: _h * 0.025,
            ),
          ),
        ),
      );

  ClipRRect _buildContainer() => ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          width: _w * 0.8,
          decoration: BoxDecoration(color: Colors.white),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  buildEmailRow(_emailController),
                  _buildUsernameRow(),
                  _buildPasswordRow(),
                  _buildReEnterPassword(),
                  _buildCheckboxRow(),
                  _buildRegisterButton(),
                ],
              ),
            ),
          ),
        ),
      );

  Wrap _buildCheckboxRow() {
    TextStyle _ts = TextStyle(
      color: TEXT_COLOR,
      fontSize: _h * 0.019,
      fontWeight: FontWeight.bold,
    );
    void goToPP() =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PP()));

    void goToTnC() =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => TnC()));

    return Wrap(
      runSpacing: -20,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Checkbox(
          value: _checkboxvalue,
          onChanged: (v) => setState(() => _checkboxvalue = v),
        ),
        Text(
          'I have read and agree to the',
          style: TextStyle(
            fontSize: _h / 53,
            color: ThemeData.light().textTheme.bodyText2.color,
          ),
        ),
        TextButton(
          onPressed: goToPP,
          child: Text('Privacy', style: _ts),
        ),
        TextButton(
          onPressed: goToPP,
          child: Text('Policy', style: _ts),
        ),
        Text('and',
            style: TextStyle(
              fontSize: _h / 53,
              color: ThemeData.light().textTheme.bodyText2.color,
            )),
        TextButton(
          onPressed: goToTnC,
          child: Text('Terms', style: _ts),
        ),
        TextButton(
          onPressed: goToTnC,
          child: Text('and', style: _ts),
        ),
        TextButton(
          onPressed: goToTnC,
          child: Text('Conditions.', style: _ts),
        ),
      ],
    );
  }

  Padding _buildReEnterPassword() => Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextFormField(
          controller: _reenterController,
          obscureText: true,
          validator: (val) =>
              _passwordController.text != val ? 'Passwords do not match' : null,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.lock,
                color: TEXT_COLOR,
              ),
              hintText: 'Re-Enter Password',
              hintStyle: TextStyle(color: ThemeData.light().hintColor)),
        ),
      );

  Widget _buildSigninBtn() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: TextButton(
              onPressed: widget.toggleView,
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Already Have an Account? ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: _h * 0.025,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      color: TEXT_COLOR,
                      fontSize: _h * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ]),
              ),
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
        : WillPopScope(
            onWillPop: () {
              widget.toggleView();
              return Future.value(false);
            },
            child: Theme(
              data: ThemeData.light(),
              child: SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  backgroundColor: Color(0xfff2f3f7),
                  body: SingleChildScrollView(
                    child:Stack(
                      children: <Widget>[
                        Container(
                          height: _h * 0.68,
                          width: _w,
                          decoration: BoxDecoration(
                            color: BACKGROUND_COLOR,
                            borderRadius: BorderRadius.only(
                                bottomLeft: const Radius.circular(70),
                                bottomRight: const Radius.circular(70)),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildLogo(_h),
                            _buildContainer(),
                            _buildErrorText(),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, _h*0.03, 8, 8),
                              child: _buildSigninBtn(),
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

  Padding _buildErrorText() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_error, style: ERROR_TEXT_STYLE(_w)));
  }
}
