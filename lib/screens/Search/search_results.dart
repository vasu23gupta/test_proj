import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/shared/constants.dart';

class SearchResults extends StatelessWidget {
  SearchResults({this.markers, this.mapCenter});

  final List<Marker> markers;
  final LatLng mapCenter;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _buildFlutterMap(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: TEXT_COLOR,
          child: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      );

  FlutterMap _buildFlutterMap() => FlutterMap(
          options: MapOptions(maxZoom: 18.45, center: mapCenter),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
                additionalOptions: {
                  'subscriptionKey': mapApiKey,
                  //'theme': _darkModeOn ? 'dark' : 'main'
                }),
            MarkerLayerOptions(markers: markers)
          ]);
}
