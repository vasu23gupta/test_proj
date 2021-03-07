import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class Addtheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Themes'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xff8c52ff),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(20),
                child: LiteRollingSwitch(
                  value: true,
                  textOn: "Dark",
                  textOff: "Light",
                  colorOn: Colors.greenAccent,
                  colorOff: Colors.redAccent,
                  iconOn: Icons.done,
                  iconOff: Icons.alarm_off,
                  textSize: 18.0,
                  onChanged: (bool position) {
                    print("$position");
                  },
                )),
          ],
        ),
      ),
    );
  }
}
