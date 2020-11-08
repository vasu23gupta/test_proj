import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_proj/models/appUser.dart';
import 'package:latlong/latlong.dart';

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

  Future updateVendorData(String name) async {
    return await vendorCollection.doc(id).set({
      'name': name,
      //'coordinates': coord,
    });
  }
}
