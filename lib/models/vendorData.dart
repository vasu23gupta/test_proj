import 'package:flutter/cupertino.dart';
import 'package:test_proj/models/Review.dart';

class VendorData {
  String id;
  List<String> imageIDs;
  //List<NetworkImage> images;
  String description;
  List<Review> reviews;
  VendorData({this.id, this.imageIDs, this.description});

  factory VendorData.fromJson(Map<String, dynamic> json) {
    List<String> temp = [];
    for (var item in json['images']) {
      temp.add(item.toString());
    }
    return VendorData(
      id: json['_id'],
      imageIDs: temp,
      description: json['description'],
    );
  }
}
