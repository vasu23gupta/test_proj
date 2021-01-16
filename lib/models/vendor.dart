import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/models/vendorData.dart';
import 'Review.dart';

class Vendor {
  String id;
  String name;
  LatLng coordinates;
  List<String> tags;
  //String dataId;
  //List<NetworkImage> images;
  List<String> imageIDs;
  String description;
  List<String> reviewIds;
  List<Review> reviews;
  //VendorData data;

  Vendor(
      {this.id,
      this.coordinates,
      this.name,
      this.tags,
      this.description,
      this.imageIDs});

  factory Vendor.fromJson(Map<String, dynamic> json) {
    List<String> temp = new List<String>();
    List<String> temp2 = new List<String>();
    for (var item in json['tags']) {
      temp.add(item.toString());
    }
    for (var item in json['images']) {
      temp2.add(item.toString());
    }
    return Vendor(
        id: json['_id'],
        name: json['name'],
        // coordinates:
        //     new LatLng(double.parse(json['lat']), double.parse(json['lng'])),
        coordinates: new LatLng(json['location']['coordinates'][1].toDouble(),
            json['location']['coordinates'][0].toDouble()),
        //tags: HashSet.from(json['tags'].split("(.*?)")),
        description: json['description'],
        tags: temp,
        imageIDs: temp2
        //dataId: json['data'],
        );
  }

  bool operator ==(other) {
    return (other is Vendor &&
            other.id == id &&
            other.name == name &&
            other.coordinates == coordinates &&
            listEquals(other.tags, tags)
        //other.dataId == dataId,
        );
  }

  bool contains(String string) {
    if (tags.contains(string) || name.startsWith(string)) return true;
    return false;
  }

  @override
  int get hashCode => hashValues(
      name.hashCode, id.hashCode, coordinates.hashCode, tags.hashCode);
}
