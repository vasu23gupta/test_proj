import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:test_proj/shared/constants.dart';

class AboutUsPage extends StatefulWidget {
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUsPage>{

 Size _size;

  @override
  void initState(){

  }

  @override
  Widget build(BuildContext context)
  {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        /*backgroundColor: BACKGROUND_COLOR,*/
      ),
      
    body: SingleChildScrollView(
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
             children: <Widget>[
                Container(
                   padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 2,
              offset: Offset(0, 5), // changes position of shadow
            ),
          ],
        ),child: ListTile(
          tileColor: Theme.of(context).cardColor,
          onTap: () =>{

          },
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
              ),
             /* Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Image(image: AssetImage('assets/vasu.jfif'),
                 fit: BoxFit.cover,
                        height: _size.height * 1,
                        width: _size.width * 1)
                
                ],
              ),*/
            Column(
              children: [
                Row(
                  
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text("     Authors", style: TextStyle(fontSize:_size.width * 0.12, ),)
                 ],
                ),
                 Row(
                 
                 mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child:  RichText(text: TextSpan(children: [TextSpan(text: "      Vasu Gupta",style: TextStyle(fontSize:  _size.width * 0.08,),
                  recognizer: TapGestureRecognizer()..onTap= () async {
                    var url = "https://www.linkedin.com/in/vasu-gupta-677454194";
                    if(await canLaunch(url)){
                      await launch(url);
                    }
                    else{
                      throw "cannot load url";
                    }
                  },
                  ),
                  ])),
                  ),
                ],
              ),
                  
               Row(
               
                 mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child:  RichText(text: TextSpan(children: [TextSpan(text: "     Divit Goel",style: TextStyle(fontSize:  _size.width * 0.08,),
                  recognizer: TapGestureRecognizer()..onTap= () async {
                    var url = "https://www.linkedin.com/in/divit-goel";
                    if(await canLaunch(url)){
                      await launch(url);
                    }
                    else{
                      throw "cannot load url";
                    }
                  },
                  ),
                  ])),
                  ),
                ],
              ),
             
               Row(
                
                 mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child:  RichText(text: TextSpan(children: [TextSpan(text: "      Swayam Gupta",style: TextStyle(fontSize:  _size.width * 0.08),
                  recognizer: TapGestureRecognizer()..onTap= () async {
                    var url = "https://www.linkedin.com/in/swayam221";
                    if(await canLaunch(url)){
                      await launch(url);
                    }
                    else{
                      throw "cannot load url";
                    }
                  },
                  ),
                  ])),
                  ),
                ],
              ),
              
              ],
            ),
           
            ],
          ),
        ),
      )
                
             ]
        )
    )
    );

  }
}