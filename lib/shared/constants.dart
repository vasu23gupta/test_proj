import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
      width: 2.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.pink,
      width: 2.0,
    ),
  ),
);

Icon appBarIcon = Icon(Icons.search);
dynamic appBarTitle = Text('Map');
String stringToSearch;

AppBar homeAppBar(
    Icon appBarIcon, dynamic appBarTitle, String stringToSearch, State state) {
  return AppBar(
    title: appBarTitle,
    backgroundColor: Colors.brown[400],
    elevation: 0.0,
    actions: <Widget>[
      IconButton(
        icon: appBarIcon,
        onPressed: () {
          state.setState(
            () {
              if (appBarIcon.icon == Icons.search) {
                appBarIcon = Icon(Icons.close);
                appBarTitle = TextField(
                  onChanged: (value) {
                    state.setState(() {
                      stringToSearch = value;
                    });
                  },
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Colors.white)),
                );
              } else {
                appBarIcon = Icon(Icons.search);
                appBarTitle = Text("AppBar Title");
              }
            },
          );
        },
      ),
    ],
  );
}

FlutterMap defaultMap(MapController controller, LatLng userLoc) {
  return new FlutterMap(
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
  );
}
