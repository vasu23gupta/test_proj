import 'dart:collection';
import 'package:latlong/latlong.dart';

class Vendor {
  String id;
  String name;
  LatLng coordinates;
  HashSet<String> tags;

  Vendor({this.id, this.coordinates, this.name, this.tags});
}
