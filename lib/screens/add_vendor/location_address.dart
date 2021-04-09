import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/shared/constants.dart';

class AddVendorLocationAddress extends StatefulWidget {
  final Vendor vendor;
  final LatLng userLoc;
  final String mapApiKey;
  AddVendorLocationAddress({this.vendor, this.userLoc, this.mapApiKey});
  @override
  _AddVendorLocationAddressState createState() =>
      _AddVendorLocationAddressState();
}

class _AddVendorLocationAddressState extends State<AddVendorLocationAddress> {
  TextEditingController _addressController = TextEditingController();
  MapController _controller = MapController();
  LatLng _userLoc;
  Marker _marker = Marker();
  Vendor _vendor;
  String _errorText = '';
  //bool _darkModeOn;
  String _mapApiKey = '';

  @override
  void initState() {
    super.initState();
    _mapApiKey = widget.mapApiKey;
    _vendor = widget.vendor;
    _userLoc = widget.userLoc;
    // _darkModeOn =
    //     SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
  }

  Future<void> _putMarkerOnMap(LatLng point) async {
    setState(
      () {
        _vendor.coordinates = point;
        _marker = Marker(
          width: 45.0,
          height: 45.0,
          point: point,
          builder: (context) => Icon(Icons.location_on, size: 40),
        );
      },
    );
    String address =
        await VendorDBService.getAddress(point.latitude, point.longitude);
    setState(() {
      _addressController.text = address;
      _vendor.address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Location & Address",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2661FA),
                      fontSize: 36),
                ),
              ),
              SizedBox(
                height: size.height * 0.4,
                width: size.width * 0.9,
                child: FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    nePanBoundary: HardcoreMath.toBounds(_userLoc).northEast,
                    swPanBoundary: HardcoreMath.toBounds(_userLoc).southWest,
                    zoom: 18.45,
                    maxZoom: 18.45,
                    minZoom: 17.45,
                    center: _userLoc,
                    onTap: _putMarkerOnMap,
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate:
                            "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
                        additionalOptions: {
                          'subscriptionKey': _mapApiKey,
                          //'theme': _darkModeOn ? 'dark' : 'main'
                        }),
                    MarkerLayerOptions(markers: [_marker]),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                    maxLines: 3,
                    maxLength: 300,
                    controller: _addressController,
                    onChanged: (value) =>
                        setState(() => _vendor.address = value),
                    decoration: textInputDecoration.copyWith(
                        hintText:
                            'Just tap on the map to enter vendor\'s location, its address will be updated automatically. You can still update the address.')),
              ),
              Text(_errorText, style: TextStyle(color: Colors.red)),
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
        ),
      ),
    );
  }
}
