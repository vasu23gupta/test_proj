import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loadingMarkers = false;
  final AuthService _auth = AuthService();
  MapController _controller = MapController();
  LatLng _mapCenter = LatLng(28.612757, 77.230445);
  LocationData _userLoc;
  List<String> _selectedFilters = [];
  String _mainSelectedFilter = '';
  bool _filtersHaveChanged = false;
  List<Vendor> _vendors = [];
  List<Marker> _vendorMarkers = [];
  LocationService _locSer = LocationService();
  var brightness;
  bool darkModeOn;

  ListView _filterBar() {
    if (_mainSelectedFilter.isEmpty) {
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
                _filtersHaveChanged = true;
                _selectedFilters.add(fil);
                _mainSelectedFilter = fil;
                isSelected[_mainSelectedFilter] = val;
                _updateMarkers();
                setState(() {});
              },
            ),
          );
        },
        scrollDirection: Axis.horizontal,
      );
    } else {
      return ListView.builder(
        itemCount: FILTERS[_mainSelectedFilter].length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: EdgeInsets.all(5),
              child: FilterChip(
                labelPadding: EdgeInsets.all(5),
                label: Text(_mainSelectedFilter),
                padding: EdgeInsets.all(5),
                selected: isSelected[_mainSelectedFilter],
                selectedColor: Colors.red,
                onSelected: (val) {
                  isSelected[_mainSelectedFilter] = val;
                  for (int i = 0;
                      i < FILTERS[_mainSelectedFilter].length;
                      i++) {
                    String subFilter = FILTERS[_mainSelectedFilter][i];
                    areSelected[_mainSelectedFilter][i] = false;
                    _selectedFilters.removeWhere((String name) {
                      return name == subFilter;
                    });
                  }
                  _filtersHaveChanged = true;
                  _selectedFilters.removeWhere((String name) {
                    return name == _mainSelectedFilter;
                  });
                  _mainSelectedFilter = '';
                  _updateMarkers();
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
            String fil = FILTERS[_mainSelectedFilter][ind];
            if (fil != null)
              return Container(
                margin: EdgeInsets.all(5),
                child: FilterChip(
                  labelPadding: EdgeInsets.all(5),
                  label: Text(fil),
                  padding: EdgeInsets.all(5),
                  selected: areSelected[_mainSelectedFilter][ind],
                  selectedColor: Colors.blue,
                  onSelected: (val) {
                    areSelected[_mainSelectedFilter][ind] = val;
                    _filtersHaveChanged = true;
                    if (val) {
                      _selectedFilters.add(fil);
                    } else {
                      _selectedFilters.removeWhere((String name) {
                        return name == fil;
                      });
                    }
                    _updateMarkers();
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
        (_) => _updateMarkers().whenComplete(() => setState(() {})));
    brightness = SchedulerBinding.instance.window.platformBrightness;
    darkModeOn = brightness == Brightness.dark;
    _moveMapToUserLocation();
  }

  void _moveMapToUserLocation() async {
    _locSer.getLocation().then((value) {
      if (value != null) {
        setState(() {
          _userLoc = value;
          _mapCenter = LatLng(value.latitude, value.longitude);
        });
        _controller.move(_mapCenter, 18.45);
      }
    });
  }

  void _delayUpdate() async {
    _loadingMarkers = true;
    await Future.delayed(Duration(milliseconds: 1000), () {});
    _loadingMarkers = false;
  }

  Future<void> _updateMarkers() async {
    _delayUpdate();
    if (_filtersHaveChanged) {
      _filtersHaveChanged = false;
      _vendorMarkers.clear();
      _vendors.clear();
    }
    List<Vendor> temp;
    if (_selectedFilters.isEmpty)
      temp = await VendorDBService.getAllVendorsInScreen(_controller.bounds);
    else
      temp = await VendorDBService.filterVendorsInScreen(
          _controller.bounds, _selectedFilters);

    for (Vendor vendor in temp)
      if (!_vendors.contains(vendor)) _vendors.add(vendor);

    for (Vendor vendor in _vendors) {
      Marker marker = Marker(
        width: 45.0,
        height: 45.0,
        point: vendor.coordinates,
        builder: (_) => IconButton(
          color: Theme.of(context).iconTheme.color,
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
      if (!_vendorMarkers.contains(marker)) _vendorMarkers.add(marker);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
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
              mapController: _controller,
              options: MapOptions(
                  maxZoom: 18.45,
                  onPositionChanged: (position, hasGesture) async {
                    if (!_loadingMarkers &&
                        _controller.zoom > 16.5 &&
                        _selectedFilters.isEmpty)
                      _updateMarkers();
                    else if (!_loadingMarkers &&
                        _controller.zoom > 15 &&
                        _selectedFilters.isNotEmpty) _updateMarkers();
                  },
                  zoom: 18.45,
                  center: _mapCenter),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style={theme}&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
                    additionalOptions: {
                      'subscriptionKey':
                          '6QKwOYYBryorrSaUj2ZqHEdWd3b4Ey_8ZFo6VOj_7xw',
                      'theme': darkModeOn ? 'dark' : 'main'
                    }),
                MarkerLayerOptions(markers: _vendorMarkers)
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
                  width: MediaQuery.of(context).size.width,
                  child: _filterBar()),
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
              onPressed: _moveMapToUserLocation,
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
                  if (_userLoc != null)
                    vendor.coordinates =
                        LatLng(_userLoc.latitude, _userLoc.longitude);
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
