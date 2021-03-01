import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:test_proj/shared/constants.dart';

class AddVendorLocationAddress extends StatefulWidget {
  @override
  _AddVendorLocationAddressState createState() =>
      _AddVendorLocationAddressState();
}

class _AddVendorLocationAddressState extends State<AddVendorLocationAddress> {
  TextEditingController _addressController = TextEditingController();
  MapController controller = MapController();
  LatLng vendorLatLng;
  LatLng userLoc;
  Marker marker = Marker();
  void _putMarkerOnMap(LatLng point) {
    setState(
      () {
        vendorLatLng = point;
        http
            .get(
          "http://apis.mapmyindia.com/advancedmaps/v1/6vt1tkshzvlqpibaoyklfn4lxiqpit2n/rev_geocode?lat=${point.latitude}&lng=${point.longitude}",
        )
            .then((value) {
          var json = jsonDecode(value.body);
          if ((json['responseCode']) == 200) {
            //address = json['results'][0]['formatted_address'];
            _addressController.text = json['results'][0]['formatted_address'];
            ;
          } else
            print(json['responseCode']);
        });
        marker = Marker(
          width: 45.0,
          height: 45.0,
          point: point,
          builder: (context) => new Container(
            child: IconButton(
              icon: Icon(Icons.location_on),
              iconSize: 80.0,
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 300.0,
            width: 350.0,
            child: FlutterMap(
              mapController: controller,
              options: MapOptions(
                nePanBoundary: HardcoreMath.toBounds(userLoc).northEast,
                swPanBoundary: HardcoreMath.toBounds(userLoc).southWest,
                //bounds: HardcoreMath.toBounds(userLoc),
                zoom: 18.45, center: userLoc,
                onTap: _putMarkerOnMap,
                //center: new LatLng(userLoc.latitude, userLoc.longitude),
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayerOptions(
                  markers: [marker],
                ),
              ],
            ),
          ),
          //address
          SizedBox(
            height: 20.0,
          ),
          TextField(
            controller: _addressController,
            decoration: textInputDecoration.copyWith(hintText: 'Address'),
          ),
        ],
      ),
    );
  }
}
