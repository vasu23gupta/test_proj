import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:test_proj/shared/constants.dart';

class AboutUsPage extends StatefulWidget {
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUsPage> {
  Size _size;

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: BACKGROUND_COLOR,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Text(
              "Authors",
              style: TextStyle(fontSize: _size.width * 0.1),
            ),
            ListTile(
              title: Text(
                "Vasu Gupta",
                style: TextStyle(fontSize: _size.width * 0.05),
              ),
              onTap: () async {
                const String url =
                    "https://www.linkedin.com/in/vasu-gupta-677454194";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw "cannot load url";
                }
              },
            ),
            ListTile(
              title: Text(
                "Divit Goel",
                style: TextStyle(fontSize: _size.width * 0.05),
              ),
              onTap: () async {
                const String url = "https://www.linkedin.com/in/divit-goel";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw "cannot load url";
                }
              },
            ),
            ListTile(
              title: Text(
                "Swayam Gupta",
                style: TextStyle(fontSize: _size.width * 0.05),
              ),
              onTap: () async {
                const String url = "https://www.linkedin.com/in/swayam221";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw "cannot load url";
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
