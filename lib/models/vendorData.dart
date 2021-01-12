import 'package:test_proj/models/Review.dart';

class VendorData {
  String id;
  List<String> images;
  String description;
  List<Review> reviews;
  VendorData({this.id, this.images, this.description});

  factory VendorData.fromJson(Map<String, dynamic> json) {
    List<String> temp = [];
    for (var item in json['images']) {
      temp.add(item.toString());
    }
    return VendorData(
      id: json['_id'],
      images: temp,
      description: json['description'],
    );
  }
}
