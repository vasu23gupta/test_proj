import 'dart:collection';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_proj/models/appUser.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/models/vendor.dart';

class UserDatabaseService {
  final String uid;
  UserDatabaseService({this.uid});

  //collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name) async {
    return await userCollection.doc(uid).set({
      'name': name,
    });
  }

  //user list from snapshot
  List<AppUser> _userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return AppUser(
        name: doc.data()['name'] ?? '',
      );
    }).toList();
  }

  //get users stream
  Stream<List<AppUser>> get users {
    return userCollection.snapshots().map(_userListFromSnapshot);
  }
}

class VendorDatabaseService {
  final String id;
  VendorDatabaseService({this.id});

  //collection reference
  final CollectionReference vendorCollection =
      FirebaseFirestore.instance.collection('vendors');

  Future updateVendorData(
      String name, LatLng coordinates, HashSet<String> tags) async {
    await vendorCollection.doc(id).set({
      'name': name,
      'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
      'tags': tags.toString(),
    });

    return vendorCollection.doc(id);
  }

  //vendor list from snapshot
  List<Vendor> _vendorListFromSnapshot(QuerySnapshot snapshot) {
    //List list;
    return snapshot.docs.map((doc) {
      return Vendor(
        name: doc.data()['name'] ?? '',
        id: doc.id,
        coordinates: LatLng(doc.data()['coordinates'].latitude,
            doc.data()['coordinates'].longitude),
        tags: HashSet.from(doc.data()['tags'].split("(.*?)")),
      );
    }).toList();
  }

  //get vendors stream
  Stream<List<Vendor>> get vendors {
    return vendorCollection.snapshots().map(_vendorListFromSnapshot);
  }

  Future<Vendor> get vendor async {
    DocumentReference documentReference = vendorCollection.doc(id);
    DocumentSnapshot doc = await documentReference.get();
    return Vendor(
      name: doc.data()['name'] ?? '',
      id: doc.id,
      coordinates: LatLng(doc.data()['coordinates'].latitude,
          doc.data()['coordinates'].longitude),
      tags: HashSet.from(doc.data()['tags'].split("(.*?)")),
    );
  }
}

class VendorDBService {
  String baseUrl = "http://10.0.2.2:3000/vendors/";

  Future<http.Response> addVendor(
      String name, LatLng coordinates, HashSet<String> tags) async {
    var body = jsonEncode({
      'name': name,
      'lat': coordinates.latitude.toString(),
      'lng': coordinates.longitude.toString(),
      'tags': tags.toString(),
    });
    final response = await http.post(
      baseUrl,
      headers: {'content-type': 'application/json'},
      body: body,
    );
    return response;
  }

  Future<Vendor> getVendor(String id) async {
    final response = await http.get(baseUrl + id);
    //print('response: ' + response.statusCode.toString());
    return Vendor.fromJson(jsonDecode(response.body));
  }

  Future<List<Vendor>> vendorsInScreen(LatLngBounds bounds) async {
    String neLat = bounds.northEast.latitude.toString();
    String neLng = bounds.northEast.longitude.toString();
    String swLat = bounds.southWest.latitude.toString();
    String swLng = bounds.southWest.longitude.toString();
    final response = await http.get(
        baseUrl + neLat + '/' + neLng + '/' + swLat + '/' + swLng,
        headers: {
          'content-type': 'application/json',
        });

    // Iterable jsonList = json.decode(response.body);
    // List<Vendor> vendors =
    //     List<Vendor>.from(jsonList.map((i) => Vendor.fromJson(i)));
    //print(baseUrl + neLat + '/' + neLng + '/' + swLat + '/' + swLng);
    //print(response.statusCode);
    //print(json.decode(response.body));

    List<Vendor> vendors = (json.decode(response.body) as List)
        .map((i) => Vendor.fromJson(i))
        .toList();
    return vendors;
  }

  // fetchVendorList() async {
  //   final response = await http.get(baseUrl, headers: {
  //     'Content-Type': 'application/json',
  //   });

  //   print(response.body);
  //
}
