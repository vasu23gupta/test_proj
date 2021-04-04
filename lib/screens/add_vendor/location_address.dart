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
     Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Location & Address",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2661FA),
                  fontSize: 36
                ),
                textAlign: TextAlign.left,
              ),
            ),
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
                     SizedBox(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child:   TextField(
            controller: _addressController,
            decoration: textInputDecoration.copyWith(hintText: 'Address'),
          ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),

           SizedBox(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child:  Text(errorText, style: TextStyle(color: Colors.red)),
                      ),
                    ),
                     SizedBox(height: size.height * 0.05),
                     Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: RaisedButton(
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                textColor: Colors.white,
                padding: const EdgeInsets.all(0),
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  width: size.width * 0.5,
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.circular(80.0),
                    gradient: new LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 136, 34),
                        Color.fromARGB(255, 255, 177, 41)
                      ]
                    )
                  ),
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    "Next",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
                    /*  SizedBox(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child:   TextField(
            controller: _addressController,
            decoration: textInputDecoration.copyWith(hintText: 'Address'),
          ),
                      ),
                    ),
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
          ),*/
        ],
      ),
    );
  }
}
