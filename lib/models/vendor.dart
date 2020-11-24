import 'dart:collection';
import 'package:latlong/latlong.dart';

class Vendor {
  String id;
  String name;
  LatLng coordinates;
  HashSet<String> tags;

  Vendor({this.id, this.coordinates, this.name, this.tags});

  bool contains(String string) {
    if (tags.contains(string) || name.contains(string)) return true;
    return false;
  }
}
