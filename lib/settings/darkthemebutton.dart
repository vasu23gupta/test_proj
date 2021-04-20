import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/services/preferences.dart';
import 'package:test_proj/settings/app.dart';
import 'package:test_proj/shared/loading.dart';

enum SingingCharacter { usesystemtheme, light, dark }

class ThemeButton extends StatefulWidget{
ThemeButtonState createState() => ThemeButtonState();
}


class ThemeButtonState extends State<ThemeButton> {
  SingingCharacter _character = SingingCharacter.usesystemtheme;
  bool loading = true;
  Preferences preferences = Preferences();
  @override
  void initState()
  {
    super.initState();
    checkTheme();
  }
  @override
  Widget build(BuildContext context) {
    var theme=Provider.of<AppProvider>(context);
    return loading ? Loading():new Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Container(
        padding: EdgeInsets.only(right: 15, left: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RadioListTile<SingingCharacter>(
              title: const Text('Use System Theme'),
              value: SingingCharacter.usesystemtheme,
              groupValue: _character,
              onChanged: (SingingCharacter value)async {
                await theme.useSystemThem();
                setState(() {
                  _character = value;
                });
              },
            ),
            RadioListTile<SingingCharacter>(
              title: const Text('Light'),
              value: SingingCharacter.light,
              groupValue: _character,
              onChanged: (SingingCharacter value) async {
                await theme.useLightTheme();
                setState(() {
                  _character = value;
                });
              },
            ),
            RadioListTile<SingingCharacter>(
              title: const Text('Dark'),
              value: SingingCharacter.dark,
              groupValue: _character,
              onChanged: (SingingCharacter value) async {
                await theme.useDarkTheme();
                setState(() {
                  _character = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void checkTheme() async
  {
    setState(() {
      loading=true;
    });
    var sysTheme = await preferences.getSystemTheme();
    if(sysTheme=="t")
    setState(() {
      _character=SingingCharacter.usesystemtheme;
      loading=false;
    });
    else{
      var theme= await preferences.getTheme();
      if(theme=="t")
      {
        setState(() {
          _character=SingingCharacter.dark;
          loading = false;
        });
      }
      else
      {
        setState(() {
          _character=SingingCharacter.light;
          loading = false;
        });
      }
    }
  }
}
