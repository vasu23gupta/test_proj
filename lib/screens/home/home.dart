import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/screens/add_vendor.dart';
import 'package:test_proj/services/auth.dart';
import 'package:test_proj/services/database.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/screens/vendorDetails/vendor_details.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/Search/Search.dart';
import 'package:test_proj/settings/settings.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/loginPopup.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool loadingMarkers = false;
  final AuthService _auth = AuthService();
  MapController controller = MapController();
  LatLng mapCenter = LatLng(28.612757, 77.230445);
  LocationData userLoc;
  List<String> selectedFilters = List();
  String mainSelectedFilter = '';
  bool filtersHaveChanged = false;
  List<Vendor> vendors = [];
  List<Marker> vendorMarkers = [];
  LocationService locSer = LocationService();

  ListView filterBar() {
    if (mainSelectedFilter.isEmpty) {
      List<String> filtersKeys = FILTERS.keys.toList();
      return ListView.builder(
        itemCount: FILTERS.length,
        itemBuilder: (context, index) {
          String fil = filtersKeys[index];
          return Container(
            margin: EdgeInsets.all(5),
            child: FilterChip(
              labelPadding: EdgeInsets.all(5),
              label: Text(fil),
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(5),
              selected: isSelected[fil],
              selectedColor: Colors.blue,
              onSelected: (val) {
                filtersHaveChanged = true;
                selectedFilters.add(fil);
                mainSelectedFilter = fil;
                isSelected[mainSelectedFilter] = val;
                updateMarkers();
                setState(() {});
              },
            ),
          );
        },
        scrollDirection: Axis.horizontal,
      );
    } else {
      return ListView.builder(
        itemCount: FILTERS[mainSelectedFilter].length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: EdgeInsets.all(5),
              child: FilterChip(
                labelPadding: EdgeInsets.all(5),
                label: Text(mainSelectedFilter),
                backgroundColor: Colors.white,
                padding: EdgeInsets.all(5),
                selected: isSelected[mainSelectedFilter],
                selectedColor: Colors.red,
                onSelected: (val) {
                  isSelected[mainSelectedFilter] = val;
                  for (int i = 0; i < FILTERS[mainSelectedFilter].length; i++) {
                    String subFilter = FILTERS[mainSelectedFilter][i];
                    areSelected[mainSelectedFilter][i] = false;
                    selectedFilters.removeWhere((String name) {
                      return name == subFilter;
                    });
                  }
                  filtersHaveChanged = true;
                  selectedFilters.removeWhere((String name) {
                    return name == mainSelectedFilter;
                  });
                  mainSelectedFilter = '';
                  updateMarkers();
                  setState(() {});
                  // String filters = '';
                  // for (var item in widget.selectedFilters) {
                  //   filters += item;
                  // }
                  // print(filters);
                },
              ),
            );
          } else {
            int ind = index - 1;
            String fil = FILTERS[mainSelectedFilter][ind];
            if (fil != null)
              return Container(
                margin: EdgeInsets.all(5),
                child: FilterChip(
                  labelPadding: EdgeInsets.all(5),
                  label: Text(fil),
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.all(5),
                  selected: areSelected[mainSelectedFilter][ind],
                  selectedColor: Colors.blue,
                  onSelected: (val) {
                    areSelected[mainSelectedFilter][ind] = val;
                    filtersHaveChanged = true;
                    if (val) {
                      selectedFilters.add(fil);
                    } else {
                      selectedFilters.removeWhere((String name) {
                        return name == fil;
                      });
                    }
                    updateMarkers();
                    setState(() {});
                    // String filters = '';
                    // for (var item in widget.selectedFilters) {
                    //   filters += item;
                    // }
                    // print(filters);
                  },
                ),
              );
          }
        },
        scrollDirection: Axis.horizontal,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => updateMarkers().whenComplete(() => setState(() {})));
    locSer.getLocation().then((value) {
      if (value != null) {
        userLoc = value;
        mapCenter = LatLng(value.latitude, value.longitude);
      }
    });
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
    if (filtersHaveChanged) {
      filtersHaveChanged = false;
      vendorMarkers.clear();
      vendors.clear();
    }
    List<Vendor> temp;
    if (selectedFilters.isEmpty) {
      temp = await VendorDBService.getAllVendorsInScreen(controller.bounds);
    } else {
      temp = await VendorDBService.filterVendorsInScreen(
          controller.bounds, selectedFilters);
    }
    for (Vendor vendor in temp) {
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
    setState(() {});
    // for (var item in vendorMarkers) {
    //   print(item.anchor.hashCode);
    // }
    //print(vendors.length);
    //print(vendorMarkers.length);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    // vendors.forEach((element) {
    //   print(element.id);
    //   print(element.name);
    //   print(element.coordinates.toString());
    //   print(element.tags.toString());
    // });
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.brown[50],
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(user.isAnon ? "Guest" : user.uid),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
                title: Text('Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                }),
            ListTile(
              title: Text(user.isAnon ? 'Sign In' : 'Logout'),
              onTap: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
      ),
      // appBar: AppBar(
      //   title: Text('Map'),
      //   elevation: 0.0,
      //   actions: <Widget>[
      //     IconButton(
      //       icon: Icon(Icons.search),
      //       onPressed: () {
      //         Navigator.push(
      //             context, MaterialPageRoute(builder: (context) => Search()));
      //       },
      //     )
      //   ],
      // ),
      body: Stack(
        children: <Widget>[
          //map
          FlutterMap(
            mapController: controller,
            options: MapOptions(
              onPositionChanged: (position, hasGesture) async {
                if (!loadingMarkers && controller.zoom > 16.5) {
                  updateMarkers();
                }
                //print(controller.bounds.northEast.longitude);
              },
              zoom: 18.45,
              center: mapCenter,
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
          //search bar
          Positioned(
            top: 60,
            right: 15,
            left: 15,
            child: Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  //drawer
                  IconButton(
                    splashColor: Theme.of(context).splashColor,
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                  ),
                  //search
                  Expanded(
                    child: TextField(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Search()));
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          hintText: "Search"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //filter bar
          Positioned(
            top: 110.0,
            left: 10,
            child: Row(children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: filterBar(),
              ),
            ]),
            height: 60.0,
            width: MediaQuery.of(context).size.width,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //move to location
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.location_searching),
              onPressed: () async {
                userLoc = await locSer.getLocation();
                if (userLoc != null)
                  setState(() =>
                      mapCenter = LatLng(userLoc.latitude, userLoc.longitude));
                controller.move(
                  mapCenter,
                  18.45,
                );
              },
            ),
          ),
          //add vendor
          Padding(
            padding: EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.add),
              onPressed: () async {
                if (user.isAnon) {
                  showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return LoginPopup(
                          to: "add a vendor",
                        );
                      });
                } else {
                  if (userLoc == null) {
                    userLoc = await locSer.getLocation();
                    if (userLoc == null) return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddVendor(
                        userLoc: LatLng(userLoc.latitude, userLoc.longitude),
                      ),
                    ),
                  );
                }
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
