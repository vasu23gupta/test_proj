import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:latlong/latlong.dart';
import 'package:quiver/core.dart';

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
      coordinates: new LatLng(json['location']['coordinates'][1].toDouble(),
          json['location']['coordinates'][0].toDouble()),
      tags: HashSet.from(json['tags'].split("(.*?)")),
    );
  }

  bool operator ==(other) {
    return (other is Vendor &&
        other.id == id &&
        other.name == name &&
        other.coordinates == coordinates &&
        other.tags == tags);
  }

  bool contains(String string) {
    if (tags.contains(string) || name.startsWith(string)) return true;
    return false;
  }

  @override
  int get hashCode =>
      hash4(name.hashCode, id.hashCode, coordinates.hashCode, tags.hashCode);
}
