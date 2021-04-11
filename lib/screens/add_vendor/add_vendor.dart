import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/add_vendor/location_address.dart';
import 'package:test_proj/screens/add_vendor/name_description.dart';
import 'package:test_proj/screens/add_vendor/tags_images.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/loading.dart';

class AddVendor extends StatefulWidget {
  final Vendor vendor;
  final LocationData userLoc;
  final String mapApiKey;
  AddVendor({this.vendor, this.userLoc, this.mapApiKey});
  @override
  _AddVendorState createState() => _AddVendorState();
}

class _AddVendorState extends State<AddVendor>
    with SingleTickerProviderStateMixin {
  Vendor _vendor;
  bool _loading = true;
  LocationService _locSer = LocationService();
  LocationData _userLoc;
  String _loadingText = "";
  double _h = 0;
  double _w = 0;
  int _screen = 0;
  User _user;

  void _nextPage() => _screen < 2 ? setState(() => _screen++) : null;

  void _previousPage() => _screen > 0 ? setState(() => --_screen) : null;

  Future<bool> _onWillPop() async {
    if (_screen == 0)
      return true;
    else {
      setState(() => --_screen);
      return false;
    }
  }

  Future<bool> _getLocation() async {
    _userLoc = await _locSer.getLocation();
    if (_userLoc == null) {
      setState(() =>
          _loadingText += "You need to enable your location to add a vendor. ");
      return false;
    } else
      return true;
  }

  Future<bool> _getUser() async {
    Response response =
        await UserDBService(jwt: await _user.getIdToken()).getUserByJWT();
    var json = jsonDecode(response.body);
    if (json['addsRemaining'] > 0) {
      return true;
    } else {
      setState(
          () => _loadingText += "You cannot add more vendors this month. ");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _vendor = widget.vendor;
    _userLoc = widget.userLoc;
    _user = Provider.of<User>(context, listen: false);
    List<Future> _futures = [];
    if (_userLoc == null)
      _futures.add(_getLocation());
    else
      _futures.add(Future.value(true));
    _futures.add(_getUser());
    Future.wait(_futures).then((value) =>
        (value[0] && value[1]) ? setState(() => _loading = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    _h = MediaQuery.of(context).size.height;
    _w = MediaQuery.of(context).size.width;
    return _loading
        ? Loading(data: _loadingText)
        : WillPopScope(
            onWillPop: _onWillPop,
            child: Stack(
              children: [
                Offstage(
                    offstage: _screen != 0,
                    child: SizedBox(
                        child: AddVendorNameDescription(vendor: _vendor))),
                Offstage(
                    offstage: _screen != 1,
                    child: SizedBox(
                        child: AddVendorLocationAddress(
                      vendor: _vendor,
                      userLoc: LatLng(_userLoc.latitude, _userLoc.longitude),
                      mapApiKey: widget.mapApiKey,
                    ))),
                Offstage(
                    offstage: _screen != 2,
                    child:
                        SizedBox(child: AddVendorTagsImages(vendor: _vendor))),
                _screen == 2
                    ? Container()
                    : Positioned(
                        bottom: 0.02 * _h,
                        right: 0.04 * _w,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: BS(_w * 0.3, _h * 0.06),
                          child: Text("Next",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: _w * 0.045)),
                        ),
                      ),
                _screen == 0
                    ? Container()
                    : Positioned(
                        bottom: 0.02 * _h,
                        left: 0.04 * _w,
                        child: ElevatedButton(
                            style: BS(_w * 0.3, _h * 0.06),
                            child: Text("Previous",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _w * 0.045)),
                            onPressed: _previousPage)),
              ],
            ),
          );
  }
}
