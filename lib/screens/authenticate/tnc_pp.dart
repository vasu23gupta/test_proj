import 'package:flutter/material.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TnC extends StatefulWidget {
  @override
  _TnCState createState() => _TnCState();
}

class _TnCState extends State<TnC> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BACKGROUND_COLOR,
        title: Text("Terms and Conditions"),
      ),
      body: WebView(initialUrl: VendorDBService.utilsUrl + 'tnc'),
    );
  }
}

class PP extends StatefulWidget {
  @override
  _PPState createState() => _PPState();
}

class _PPState extends State<PP> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BACKGROUND_COLOR,
        title: Text("Privacy Policy"),
      ),
      body: WebView(initialUrl: VendorDBService.utilsUrl + 'pp'),
    );
  }
}
