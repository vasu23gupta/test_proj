import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/add_vendor/tags_images.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:test_proj/shared/constants.dart';

class AddVendorLocationAddress extends StatefulWidget {
  final Vendor vendor;
  AddVendorLocationAddress({this.vendor});
  @override
  _AddVendorLocationAddressState createState() =>
      _AddVendorLocationAddressState();
}

class _AddVendorLocationAddressState extends State<AddVendorLocationAddress> {
  TextEditingController _addressController = TextEditingController();
  MapController controller = MapController();
  LatLng userLoc;
  Marker marker = Marker();
  Vendor vendor;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    vendor = widget.vendor;
    userLoc = vendor.coordinates;
    vendor.coordinates = null;
  }

  void _putMarkerOnMap(LatLng point) {
    setState(
      () {
        vendor.coordinates = point;
        http
            .get(
          "http://apis.mapmyindia.com/advancedmaps/v1/6vt1tkshzvlqpibaoyklfn4lxiqpit2n/rev_geocode?lat=${point.latitude}&lng=${point.longitude}",
        )
            .then((value) {
          var json = jsonDecode(value.body);
          if ((json['responseCode']) == 200) {
            //address = json['results'][0]['formatted_address'];
            _addressController.text = json['results'][0]['formatted_address'];
          } else
            print(json['responseCode']);
        });
        marker = Marker(
          width: 45.0,
          height: 45.0,
          point: point,
          builder: (context) => Icon(
            Icons.location_on,
            size: 40,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //map
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
                        "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
                    additionalOptions: {
                      'subscriptionKey':
                          '6QKwOYYBryorrSaUj2ZqHEdWd3b4Ey_8ZFo6VOj_7xw'
                    }),
                MarkerLayerOptions(
                  markers: [marker],
                ),
              ],
            ),
          ),
          //address
          TextField(
            controller: _addressController,
            decoration: textInputDecoration.copyWith(hintText: 'Address'),
          ),
          //errortext
          Text(errorText, style: TextStyle(color: Colors.red)),
          //next button
          RaisedButton(
            color: Colors.pink[400],
            child: Text('Next >', style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (_addressController.text.isNotEmpty &&
                  vendor.coordinates != null) {
                errorText = '';
                vendor.address = _addressController.text;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddVendorTagsImages(
                      vendor: vendor,
                    ),
                  ),
                );
              } else {
                setState(() {
                  errorText =
                      "Please make sure address is not empty and location is selected.";
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
