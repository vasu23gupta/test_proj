import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';

class LocationService {
  LatLng _currentLocation;

  Location location = Location();

  Future<LatLng> getLocation() async {
    try {
      LocationData userLocation = await location.getLocation();
      _currentLocation = LatLng(userLocation.latitude, userLocation.longitude);
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }

    return _currentLocation;
  }
}
