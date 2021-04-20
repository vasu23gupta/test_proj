import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/shared/constants.dart';

class AddVendorLocationAddress extends StatefulWidget {
  final Vendor vendor;
  final LatLng userLoc;
  AddVendorLocationAddress({this.vendor, this.userLoc});
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
  //bool _darkModeOn;

  @override
  void initState() {
    super.initState();
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
                          'subscriptionKey': mapApiKey,
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
                    maxLength: 500,
                    controller: _addressController,
                    onChanged: (value) =>
                        setState(() => _vendor.address = value),
                    decoration: textInputDecoration.copyWith(
                        hintText:
                            'Just tap on the map to enter vendor\'s location, its address will be updated automatically. You can still update the address.')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
