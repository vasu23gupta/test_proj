import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_proj/models/appUser.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/screens/add_vendor.dart';
//import 'package:test_proj/screens/home/home_search_bar.dart';
import 'package:test_proj/services/auth.dart';
import 'package:test_proj/services/database.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/screens/vendor_details.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/Search/Search.dart';
import 'package:test_proj/settings/settings.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => updateMarkers().whenComplete(() => setState(() {})));
    //updateMarkers().whenComplete(() => setState(() {}));
  }

  void delayUpdate() async {
    loadingMarkers = true;
    await Future.delayed(Duration(milliseconds: 1000), () {});
    loadingMarkers = false;
  }

  Future<void> updateMarkers() async {
    delayUpdate();
    //vendorMarkers.clear();
    //vendors.clear();
    for (Vendor vendor
        in await VendorDBService.vendorsInScreen(controller.bounds)) {
      if (!vendors.contains(vendor)) vendors.add(vendor);
    }
    for (Vendor vendor in vendors) {
      Marker marker = new Marker(
        //anchorPos: AnchorPos.align(AnchorAlign.center),
        width: 45.0,
        height: 45.0,
        point: vendor.coordinates,
        builder: (context) => IconButton(
          //alignment: Alignment.bottomRight,
          icon: Icon(Icons.circle),
          iconSize: 40.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorDetails(
                  vendor: vendor,
                ),
              ),
            );
          },
        ),
      );
      if (!vendorMarkers.contains(marker)) {
        vendorMarkers.add(marker);
      }
    }
    // for (var item in vendorMarkers) {
    //   print(item.anchor.hashCode);
    // }
    //print(vendors.length);
    //print(vendorMarkers.length);
  }

  bool loadingMarkers = false;
  final AuthService _auth = AuthService();
  MapController controller = new MapController();
  LatLng userLoc = new LatLng(28.612757, 77.230445);
  List<String> selectedFilters = new List();
  List<String> filters = [
    "Food",
    "Repair",
    "Crafts",
    "Daily essentials",
    "rehrhrh",
    "ju65u65w"
  ];
  List<Vendor> vendors = [];
  List<Marker> vendorMarkers = [];
  // Icon appBarIcon = Icon(Icons.search);
  // dynamic appBarTitle = Text('Map');
  // String stringToSearch;
  @override
  Widget build(BuildContext context) {
    //updateMarkers().whenComplete(() => setState(() {}));
    //LatLng middlePoint = controller.center;
    //controller.
    final user = Provider.of<CustomUser>(context);
    // vendors.forEach((element) {
    //   print(element.id);
    //   print(element.name);
    //   print(element.coordinates.toString());
    //   print(element.tags.toString());
    // });
    LocationService locSer = new LocationService();
    Future<LatLng> userLocFut = locSer.getLocation();
    return Scaffold(
      backgroundColor: Colors.brown[50],
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(user.uid),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
                title: Text('Settings'),
                onTap: () {
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => settingspage()),
                    );
                  }
                  ;
                }),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Map'),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Search()));
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: controller,
            options: new MapOptions(
              onPositionChanged: (position, hasGesture) async {
                if (!loadingMarkers && controller.zoom > 16.5) {
                  updateMarkers().whenComplete(() => setState);
                }
                //print(controller.bounds.northEast.longitude);
              },
              zoom: 18.45,
              center: userLoc,
              //center: new LatLng(userLoc.latitude, userLoc.longitude),
            ),
            layers: [
              new TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              new MarkerLayerOptions(
                markers: vendorMarkers,
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
          Positioned(
            top: 10.0,
            child: ListView.builder(
              itemCount: filters.length,
              itemBuilder: (context, index) {
                return Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(5),
                      child: VendorFilter(
                        text: filters[index],
                        selectedFilters: selectedFilters,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
              scrollDirection: Axis.horizontal,
            ),
            height: 60.0,
            width: MediaQuery.of(context).size.width,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.location_searching),
              onPressed: () {
                userLocFut.then(
                  (value) => setState(
                    () {
                      userLoc = new LatLng(value.latitude, value.longitude);
                      print("ye rha mai " + userLoc.toSexagesimal());
                      controller.move(
                        userLoc,
                        18.45,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVendor(
                      userLoc: controller.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
