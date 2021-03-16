import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:test_proj/shared/my_flutter_app_icons.dart';
import 'package:test_proj/screens/add_vendor/name_description.dart';
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
  List<String> selectedFilters = [];
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
    if (filtersHaveChanged) {
      filtersHaveChanged = false;
      vendorMarkers.clear();
      vendors.clear();
    }
    List<Vendor> temp;
    if (selectedFilters.isEmpty)
      temp = await VendorDBService.getAllVendorsInScreen(controller.bounds);
    else
      temp = await VendorDBService.filterVendorsInScreen(
          controller.bounds, selectedFilters);

    for (Vendor vendor in temp)
      if (!vendors.contains(vendor)) vendors.add(vendor);

    for (Vendor vendor in vendors) {
      Marker marker = Marker(
        width: 45.0,
        height: 45.0,
        point: vendor.coordinates,
        builder: (_) => IconButton(
          icon: vendor.tags.contains('Food')
              ? Icon(Cusicon.food)
              : vendor.tags.contains('repair')
                  ? Icon(Cusicon.repair)
                  : Icon(Icons.location_on),
          iconSize: 40.0,
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => VendorDetails(vendor: vendor))),
        ),
      );
      if (!vendorMarkers.contains(marker)) vendorMarkers.add(marker);
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
    final user = Provider.of<User>(context);
    // vendors.forEach((element) {
    //   print(element.id);
    //   print(element.name);
    //   print(element.coordinates.toString());
    //   print(element.tags.toString());
    // });
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                child: Text(user.isAnonymous
                    ? "Guest"
                    : user.displayName != null
                        ? user.displayName
                        : user.uid),
                decoration: BoxDecoration(color: Colors.blue)),
            ListTile(
                title: Text('Settings'),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => SettingsPage()))),
            ListTile(
                title: Text(user.isAnonymous ? 'Sign In' : 'Logout'),
                onTap: () async {
                  await _auth.signOut();
                }),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          //map
          FlutterMap(
              mapController: controller,
              options: MapOptions(
                  maxZoom: 18.45,
                  onPositionChanged: (position, hasGesture) async {
                    if (!loadingMarkers &&
                        controller.zoom > 16.5 &&
                        selectedFilters.isEmpty)
                      updateMarkers();
                    else if (!loadingMarkers &&
                        controller.zoom > 15 &&
                        selectedFilters.isNotEmpty) updateMarkers();
                  },
                  zoom: 18.45,
                  center: mapCenter),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
                MarkerLayerOptions(markers: vendorMarkers)
              ]),
          //search bar
          Positioned(
            top: 60,
            right: 15,
            left: 15,
            child: Container(
              color: Theme.of(context).backgroundColor,
              child: Row(
                children: <Widget>[
                  //drawer
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                  ),
                  //search
                  Expanded(
                    child: TextField(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Search())),
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
                  width: MediaQuery.of(context).size.width, child: filterBar()),
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
                controller.move(mapCenter, 18.45);
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
                if (user.isAnonymous)
                  showDialog<void>(
                      context: context,
                      builder: (_) => LoginPopup(to: "add a vendor"));
                //DONT DELETE
                // else if (!user.emailVerified) {
                //   await user.reload();
                //   if (!user.emailVerified)
                //     showDialog<void>(
                //         context: context,
                //         builder: (_) => VerifyEmailPopup(to: "add a vendor"));
                //   else {
                //     Vendor vendor = Vendor();
                //      if (userLoc != null) vendor.coordinates =
                //         LatLng(userLoc.latitude, userLoc.longitude);
                //     Navigator.of(context).push(MaterialPageRoute(
                //         builder: (_) =>
                //             AddVendorNameDescription(vendor: vendor)));
                //   }
                // }
                else {
                  Vendor vendor = Vendor();
                  if (userLoc != null)
                    vendor.coordinates =
                        LatLng(userLoc.latitude, userLoc.longitude);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          AddVendorNameDescription(vendor: vendor)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
