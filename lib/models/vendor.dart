import 'dart:collection';
import 'package:latlong/latlong.dart';

class Vendor {
  String id;
  String name;
  LatLng coordinates;
  HashSet<String> tags;

  Vendor({this.id, this.coordinates, this.name, this.tags});

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['_id'],
      name: json['name'],
      // coordinates:
      //     new LatLng(double.parse(json['lat']), double.parse(json['lng'])),
      coordinates: new LatLng(json['location']['coordinates'][1],
          json['location']['coordinates'][0]),
      tags: HashSet.from(json['tags'].split("(.*?)")),
    );
  }

  bool contains(String string) {
    if (tags.contains(string) || name.contains(string)) return true;
    return false;
  }
}
