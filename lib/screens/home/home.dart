import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_proj/models/appUser.dart';
import 'package:test_proj/screens/home/add_vendor.dart';
import 'package:test_proj/services/auth.dart';
import 'package:test_proj/services/database.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:test_proj/services/location_service.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

//Location location = new Location();
//Future<LocationData> ld= location.getLocation();

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  MapController controller = new MapController();
  LatLng userLoc = new LatLng(28.612757, 77.230445);
  @override
  Widget build(BuildContext context) {
    LocationService locSer = new LocationService();
    Future<LatLng> userLocFut = locSer.getLocation();
    return StreamProvider<List<AppUser>>.value(
      value: UserDatabaseService().users,
      child: Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text('Map'),
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('logout'),
              onPressed: () async {
                await _auth.signOut();
              },
            )
          ],
        ),
        body: new FlutterMap(
          mapController: controller,
          options: new MapOptions(
            zoom: 13.0,
            center: userLoc,
            //center: new LatLng(userLoc.latitude, userLoc.longitude),
          ),
          layers: [
            new TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            // new MarkerLayerOptions(
            //   markers: [
            //     new Marker(
            //       width: 45.0,
            //       height: 45.0,
            //       //point: new LatLng(28.612757, 77.230445),
            //       point: userLoc,
            //       builder: (ctx) => new Container(
            //         child: new FlutterLogo(),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: () {
            // userLocFut.then((value) => setState(() {
            //       userLoc = new LatLng(value.latitude, value.longitude);
            //       controller.move(userLoc, 13.0);
            //       print(userLoc.latitude.toString());
            //     }));

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddVendor()),
            );
          },
        ),
      ),
    );
  }
}

// class Home extends StatelessWidget {
//   final AuthService _auth = AuthService();
//   @override
//   Widget build(BuildContext context) {
//     return StreamProvider<List<AppUser>>.value(
//       value: DatabaseService().users,
//       child: Scaffold(
//         backgroundColor: Colors.brown[50],
//         appBar: AppBar(
//           title: Text('Map'),
//           backgroundColor: Colors.brown[400],
//           elevation: 0.0,
//           actions: <Widget>[
//             FlatButton.icon(
//               icon: Icon(Icons.person),
//               label: Text('logout'),
//               onPressed: () async {
//                 await _auth.signOut();
//               },
//             )
//           ],
//         ),
//         body: new FlutterMap(
//           mapController: controller,
//           options: new MapOptions(
//             zoom: 13.0,
//             center: new LatLng(28.612757, 77.230445),
//           ),
//           layers: [
//             new TileLayerOptions(
//               urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//               subdomains: ['a', 'b', 'c'],
//             ),
//             // new MarkerLayerOptions(
//             //   markers: [
//             //     new Marker(
//             //       width: 45.0,
//             //       height: 45.0,
//             //       point: new LatLng(28.612757, 77.230445),
//             //       builder: (ctx) => new Container(
//             //         child: new FlutterLogo(),
//             //       ),
//             //     ),
//             //   ],
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
