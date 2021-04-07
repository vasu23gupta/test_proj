import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_proj/models/appUser.dart';

class ProfilePage extends StatelessWidget{
  AppUser user;

  ProfilePage({this.user});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print(user.addsRemainig);
    print(user.editsRemaing);
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: ()=>Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Text(user.name, style:TextStyle(fontSize: 30)),
          Row(
            children: [
              Text('Points : ', style:TextStyle(fontSize: 20,color: Colors.green)),
              SizedBox(width: 10,),
              Text(user.points.toString(), style:TextStyle(fontSize: 20,color: Colors.yellow)),
            ],
          ),
          Row(
            children: [
              Text('Level : ', style:TextStyle(fontSize: 20,color: Colors.green)),
              SizedBox(width: 10,),
              Text(user.level.toString(), style:TextStyle(fontSize: 20,color: Colors.yellow)),
            ],
          ),
          Row(
            children: [
              Text('NextLevelAt : ', style:TextStyle(fontSize: 20,color: Colors.green)),
              SizedBox(width: 10,),
              Text(user.nextLevelAt.toString(), style:TextStyle(fontSize: 20,color: Colors.yellow)),
              SizedBox(width: 10,),
              Text('points',style: TextStyle(fontSize: 20),)
            ],
          ),
          Row(
            children: [
              Text('Remaining Additions: ', style:TextStyle(fontSize: 20,color: Colors.green)),
              SizedBox(width: 10,),
              Text(user.addsRemainig.toString(), style:TextStyle(fontSize: 20,color: Colors.yellow)),
              SizedBox(width: 10,),
              Text(' this month',style: TextStyle(fontSize: 20),)
            ],
          ),
          Row(
            children: [
              Text('Remaining Edits: ', style:TextStyle(fontSize: 20,color: Colors.green)),
              SizedBox(width: 10,),
              Text(user.editsRemaing.toString(), style:TextStyle(fontSize: 20,color: Colors.yellow)),
              SizedBox(width: 10,),
              Text(' this month',style: TextStyle(fontSize: 20),)
            ],
          ),
        ],),
    );
  }}