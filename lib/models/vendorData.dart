// import 'package:flutter/cupertino.dart';
// import 'package:test_proj/models/Review.dart';

// class VendorData {
//   String id;
//   List<String> imageIDs;
//   //List<NetworkImage> images;
//   String description;
//   List<String> reviewIds;
//   List<Review> reviews;
//   VendorData({this.id, this.imageIDs, this.description, this.reviewIds});

//   factory VendorData.fromJson(Map<String, dynamic> json) {
//     List<String> temp = [];
//     List<String> temp2 = [];
//     for (var item in json['images']) {
//       temp.add(item.toString());
//     }
//     for (var item in json['reviews']) {
//       temp2.add(item.toString());
//     }
//     return VendorData(
//         id: json['_id'],
//         imageIDs: temp,
//         description: json['description'],
//         reviewIds: temp2);
//   }
// }
