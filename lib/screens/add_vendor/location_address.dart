import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/add_vendor/tags_images.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:latlong/latlong.dart';
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
  var _brightness;
  bool _darkModeOn;

  @override
  void initState() {
    super.initState();
    vendor = widget.vendor;
    userLoc = vendor.coordinates;
    vendor.coordinates = null;
    _brightness = SchedulerBinding.instance.window.platformBrightness;
    _darkModeOn = _brightness == Brightness.dark;
  }

  Future<void> _putMarkerOnMap(LatLng point) async {
    String address =
        await VendorDBService.getAddress(point.latitude, point.longitude);
    print(address);
    setState(
      () {
        vendor.coordinates = point;
        _addressController.text = address;
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
                onTap: (val) async => await _putMarkerOnMap(val),
                //center: new LatLng(userLoc.latitude, userLoc.longitude),
              ),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style={theme}&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
                    additionalOptions: {
                      'subscriptionKey':
                          '6QKwOYYBryorrSaUj2ZqHEdWd3b4Ey_8ZFo6VOj_7xw',
                      'theme': _darkModeOn ? 'dark' : 'main'
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
