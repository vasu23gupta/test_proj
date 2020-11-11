import 'dart:collection';

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
    List list;
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
}
