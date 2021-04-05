import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:test_proj/models/Review.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserDBService {
  final String jwt;
  UserDBService({this.jwt});

  static String url = "https://localpediabackend.herokuapp.com/";
  static String usersUrl = url + "users/";

  Future<http.Response> addUser(String username) async {
    var body = jsonEncode({'username': username});
    final response = await http.post(usersUrl,
        headers: {'content-type': 'application/json', 'authorisation': jwt},
        body: body);
    return response;
  }

  Future<http.Response> googleLogin(String username) async {
    var body = jsonEncode({'username': username});
    final response = await http.post(usersUrl + 'google',
        headers: {'content-type': 'application/json', 'authorisation': jwt},
        body: body);
    return response;
  }

  Future<http.Response> getUserByJWT() async {
    final response = await http.get(usersUrl+"getUserByJWT/",
        headers: {'content-type': 'application/json', 'authorisation': jwt},);
    return response;
  }
}

class VendorDBService {
  //static String url = "https://localpediabackend.herokuapp.com/";
  static String url = "http://10.0.2.2:3000/";
  static String vendorsUrl = url + "vendors/";
  static String reportsUrl = url + "reports/";
  static String imagesUrl = url + "images/";
  static String reviewsUrl = url + "reviews/";
  static String utilsUrl = url + "utils/";
  static Dio dio = Dio();

  static Future<http.Response> addVendor(
    String name,
    LatLng coordinates,
    List<String> tags,
    List<Asset> images,
    String description,
    String jwt,
    String address,
  ) async {
    var body = jsonEncode({
      'name': name,
      'lat': coordinates.latitude.toString(),
      'lng': coordinates.longitude.toString(),
      'tags': tags,
      'description': description,
      'address': address,
    });
    final response = await http.post(
      vendorsUrl,
      headers: {'content-type': 'application/json', 'authorisation': jwt},
      body: body,
    );
    await addImages(images, jsonDecode(response.body)['_id']);
    return response;
  }

  static Future addImages(List<Asset> images, String vendorId) async {
    List<Future> _futures = [];
    if (images.isNotEmpty)
      for (var img in images) {
        String path = await FlutterAbsolutePath.getAbsolutePath(img.identifier);
        _futures.add(VendorDBService.addImage(path, vendorId));
      }
    return Future.wait(_futures);
  }

  static Future<http.Response> updateVendor(
    String jwt,
    String id,
    String name,
    LatLng coordinates,
    List<String> tags,
    List<String> imgs,
    List<String> removedImageIds,
    List<Asset> newImages,
    String description,
    String address,
  ) async {
    List<Future> _futures = [];

    var body = jsonEncode({
      'name': name,
      'lat': coordinates.latitude.toString(),
      'lng': coordinates.longitude.toString(),
      'tags': tags,
      'images': imgs,
      'description': description,
      'address': address,
    });

    final resFut = http.patch(
      vendorsUrl + "edit/" + id,
      headers: {'content-type': 'application/json','authorisation': jwt},
      body: body,
    );
    _futures.add(resFut);

    var body2 = jsonEncode({'imageIds': removedImageIds});

    _futures.add(addImages(newImages, id));
    _futures.add(http.patch(imagesUrl + 'deleteImages',
        headers: {'content-type': 'application/json'}, body: body2));

    return (await Future.wait(_futures))[0];
  }

  static Future<http.Response> addVendorReview(
      Review review, Vendor vendor, String jwt) async {
    var body = jsonEncode({
      'review': review.review,
      'stars': review.stars,
      'vendorId': vendor.id,
    });

    final reviewResponse = await http.post(
      reviewsUrl,
      headers: {'content-type': 'application/json', 'authorisation': jwt},
      body: body,
    );
    return reviewResponse;
  }

  static Future<http.Response> reportVendor(
      String report, Vendor vendor, String jwt) async {
    var body = jsonEncode({'report': report, 'vendorId': vendor.id});
    final reportResponse = await http.post(
      reportsUrl,
      headers: {'content-type': 'application/json', 'authorisation': jwt},
      body: body,
    );

    return reportResponse;
  }

  static Future<Response> addImage(String path, String vendorId) async {
    FormData formData = FormData.fromMap({
      "vendorImg": await MultipartFile.fromFile(path),
      "vendorId": vendorId
    });

    final response = await dio.post(
      imagesUrl,
      data: formData,
    );
    return response;
  }

  static Future<Vendor> getVendor(String id, String jwt) async {
    final response =
        await http.get(vendorsUrl + id, headers: {'authorisation': jwt});
    return Vendor.fromJson(jsonDecode(response.body));
  }

  static Future<Review> getReviewByReviewId(String id) async {
    final response = await http.get(reviewsUrl + id);
    return Review.fromJson(jsonDecode(response.body));
  }

  static Future<Review> getReviewByUserAndVendorId(
      String vendorId, String jwt) async {
    final response = await http.get(reviewsUrl + 'userAndVendorId/' + vendorId,
        headers: {'authorisation': jwt});
    return Review.fromJson(jsonDecode(response.body));
  }

  static CachedNetworkImageProvider getVendorImage(String imageId) =>
      CachedNetworkImageProvider(imagesUrl + imageId);

  static Future getVendorsFromSearch(
      String query, String searchRadius, LatLng userLoc) async {
    if (searchRadius == '10km' || searchRadius == '15km') {
      searchRadius = searchRadius.substring(0, 2);
      print(searchRadius);
    }
    if (searchRadius == "5km") {
      searchRadius = searchRadius.substring(0, 1);
      print(searchRadius);
    }
    if (searchRadius == 'no limit: default') {
      searchRadius = "0";
    }
    final response = await http.get(vendorsUrl +
        '/search/' +
        query.toLowerCase() +
        '/' +
        searchRadius +
        '/' +
        userLoc.latitude.toString() +
        '/' +
        userLoc.longitude.toString());
    var list = (jsonDecode(response.body))
        .map((json) => Vendor.fromJsonSearch(json))
        .toList();
    return list;
  }

  static Future<List<Vendor>> getAllVendorsInScreen(LatLngBounds bounds) async {
    String neLat = bounds.northEast.latitude.toString();
    String neLng = bounds.northEast.longitude.toString();
    String swLat = bounds.southWest.latitude.toString();
    String swLng = bounds.southWest.longitude.toString();

    final response = await http.get(
        vendorsUrl + neLat + '/' + neLng + '/' + swLat + '/' + swLng,
        headers: {'content-type': 'application/json'});

    List<Vendor> vendors = (json.decode(response.body) as List)
        .map((i) => Vendor.fromJsonCoords(i))
        .toList();
    return vendors;
  }

  static Future<List<Vendor>> filterVendorsInScreen(
      LatLngBounds bounds, List<String> filters) async {
    String neLat = bounds.northEast.latitude.toString();
    String neLng = bounds.northEast.longitude.toString();
    String swLat = bounds.southWest.latitude.toString();
    String swLng = bounds.southWest.longitude.toString();
    final response = await dio.get(
        vendorsUrl +
            "filterOnMap/" +
            neLat +
            '/' +
            neLng +
            '/' +
            swLat +
            '/' +
            swLng,
        queryParameters: {'query': filters});

    List<Vendor> vendors =
        ((response.data) as List).map((i) => Vendor.fromJsonCoords(i)).toList();
    return vendors;
  }

  static Future<http.Response> deleteReview(String reviewId, String jwt) async {
    var res = await http
        .delete(reviewsUrl + reviewId, headers: {'authorisation': jwt});
    return res;
  }

  static Future<String> getAddress(double lat, double lng) async {
    var res = await http
        .get(utilsUrl + 'address/' + lat.toString() + '/' + lng.toString());
    return jsonDecode(res.body)['address'];
  }

  static Future<String> getMapApiKey(User user) async {
    var res = await http.get(
      utilsUrl + 'mapApiKey/',
      headers: {
        'content-type': 'application/json',
        'authorisation': await user.getIdToken()
      },
    );
    String key = jsonDecode(res.body)['key'];
    return key;
  }

  //dont delete
  // Future<Vendor> getVendor(
  //     {String id = "null",
  //     Vendor vendor,
  //     bool name = false,
  //     bool tags = false,
  //     bool coordinates = false,
  //     bool description = false,
  //     bool imageIds = false,
  //     bool reviewIds = false,
  //     bool stars = false}) async {
  //   // if (id != null) {
  //   //   final response = await http.get(vendorsUrl + id);
  //   //   return Vendor.fromJson(jsonDecode(response.body));
  //   // } else {
  //   String url = vendorsUrl +
  //       id +
  //       '/' +
  //       name.toString() +
  //       '/' +
  //       tags.toString() +
  //       '/' +
  //       coordinates.toString() +
  //       '/' +
  //       description.toString() +
  //       '/' +
  //       imageIds.toString() +
  //       '/' +
  //       reviewIds.toString() +
  //       '/' +
  //       stars.toString() +
  //       '/';
  //   final response = await http.get(url);

  //   var json = jsonDecode(response.body);
  //   if (name) vendor.name = json['name'];
  //   if (tags) vendor.tags = List.castFrom<dynamic, String>(json['tags']);
  //   if (coordinates)
  //     vendor.coordinates = new LatLng(
  //         json['location']['coordinates'][1].toDouble(),
  //         json['location']['coordinates'][0].toDouble());
  //   if (description) vendor.description = json['description'];
  //   if (imageIds)
  //     vendor.imageIds = List.castFrom<dynamic, String>(json['images']);
  //   if (reviewIds)
  //     vendor.reviewIds = List.castFrom<dynamic, String>(json['reviews']);
  //   if (stars) vendor.stars = json['rating'];
  //   //List<dynamic> temp = json['tags'];
  //   //temp.cast()
  //   return vendor;
  //   //   }
  // }

  // static Future getVendors() async {
  //   final response = await http.get(vendorsUrl);
  //   var list = (jsonDecode(response.body))
  //       .map((json) => Vendor.fromJson(json))
  //       .toList();
  //   return list;
  // }
}

// class UserDatabaseService {
//   final String uid;
//   UserDatabaseService({this.uid});

//   //collection reference
//   final CollectionReference userCollection =
//       FirebaseFirestore.instance.collection('users');

//   // Future updateUserName(String name) async {
//   //   return await userCollection.doc(uid).set({
//   //     'name': name,
//   //   });
//   // }

//   Future addReportToProfile(String reportId) async {
//     List report = [reportId];
//     return await userCollection
//         .doc(uid)
//         .update({'reports': FieldValue.arrayUnion(report)});
//   }

//   Future addVendorToProfile(String vendorId) async {
//     List vendor = [vendorId];
//     return await userCollection
//         .doc(uid)
//         .update({'vendors': FieldValue.arrayUnion(vendor)});
//   }

//   Future addReviewToProfile(String reveiwId) async {
//     List reveiw = [reveiwId];
//     return await userCollection
//         .doc(uid)
//         .update({'reveiws': FieldValue.arrayUnion(reveiw)});
//   }

//   //user list from snapshot
//   List<AppUser> _userListFromSnapshot(QuerySnapshot snapshot) {
//     return snapshot.docs.map((doc) {
//       return AppUser(
//         name: doc.data()['name'] ?? '',
//       );
//     }).toList();
//   }

//   //get users stream
//   Stream<List<AppUser>> get users {
//     return userCollection.snapshots().map(_userListFromSnapshot);
//   }
// }

// class VendorDatabaseService {
//   final String id;
//   VendorDatabaseService({this.id});

//   //collection reference
//   final CollectionReference vendorCollection =
//       FirebaseFirestore.instance.collection('vendors');

//   Future updateVendorData(
//       String name, LatLng coordinates, HashSet<String> tags) async {
//     await vendorCollection.doc(id).set({
//       'name': name,
//       'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
//       'tags': tags.toString(),
//     });

//     return vendorCollection.doc(id);
//   }

//   //vendor list from snapshot
//   List<Vendor> _vendorListFromSnapshot(QuerySnapshot snapshot) {
//     //List list;
//     return snapshot.docs.map((doc) {
//       return Vendor(
//         name: doc.data()['name'] ?? '',
//         id: doc.id,
//         coordinates: LatLng(doc.data()['coordinates'].latitude,
//             doc.data()['coordinates'].longitude),
//         tags: HashSet.from(doc.data()['tags'].split("(.*?)")),
//       );
//     }).toList();
//   }

//   //get vendors stream
//   Stream<List<Vendor>> get vendors {
//     return vendorCollection.snapshots().map(_vendorListFromSnapshot);
//   }

//   Future<Vendor> get vendor async {
//     DocumentReference documentReference = vendorCollection.doc(id);
//     DocumentSnapshot doc = await documentReference.get();
//     return Vendor(
//       name: doc.data()['name'] ?? '',
//       id: doc.id,
//       coordinates: LatLng(doc.data()['coordinates'].latitude,
//           doc.data()['coordinates'].longitude),
//       tags: HashSet.from(doc.data()['tags'].split("(.*?)")),
//     );
//   }
// }
