import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'dart:math';
import 'package:latlong/latlong.dart';

class LocationService {
  // LatLng _currentLocation;

  // Location location = Location();
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Future<LocationData> getLocation() async {
    //   try {
    //     LocationData userLocation = await location.getLocation();
    //     _currentLocation = LatLng(userLocation.latitude, userLocation.longitude);
    //   } catch (e) {
    //     print('Could not get location: ${e.toString()}');
    //   }

    //   return _currentLocation;
    // }

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }
}

class HardcoreMath {
  static num toRadians(num degrees) => degrees / 180.0 * pi;
  static num toDegrees(num rad) => rad * (180.0 / pi);

  static LatLng computeOffset(LatLng from, num distance, num heading) {
    distance /= 6371009.0;
    heading = toRadians(heading);
    final fromLat = toRadians(from.latitude);
    final fromLng = toRadians(from.longitude);
    final cosDistance = cos(distance);
    final sinDistance = sin(distance);
    final sinFromLat = sin(fromLat);
    final cosFromLat = cos(fromLat);
    final sinLat =
        cosDistance * sinFromLat + sinDistance * cosFromLat * cos(heading);
    final dLng = atan2(sinDistance * cosFromLat * sin(heading),
        cosDistance - sinFromLat * sinLat);

    return LatLng(toDegrees(asin(sinLat)).toDouble(),
        toDegrees(fromLng + dLng).toDouble());
  }

  static LatLngBounds toBounds(LatLng center) {
    double distanceFromCenterToCorner = 2000 * sqrt(2.0);
    LatLng southwestCorner =
        computeOffset(center, distanceFromCenterToCorner, 225.0);
    LatLng northeastCorner =
        computeOffset(center, distanceFromCenterToCorner, 45.0);
    return LatLngBounds(southwestCorner, northeastCorner);
  }
}
