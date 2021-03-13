import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class SearchResults extends StatelessWidget {
  SearchResults({this.markers, this.mapCenter});

  final List<Marker> markers;
  final MapController controller = MapController();
  final LatLng mapCenter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: <Widget>[
            FlutterMap(
              mapController: controller,
              options: MapOptions(
                //zoom: 18.45,
                center: mapCenter,
              ),
              layers: [
                new TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                new MarkerLayerOptions(
                  markers: this.markers,
                )
              ],
            ),
          ],
        ));
  }
}
