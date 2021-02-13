import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //custom user based on firebase user
  CustomUser _userFromFirebaseUser(User user) {
    if (user != null) {
      return CustomUser(
          uid: user.uid, name: user.displayName, isAnon: user.isAnonymous);
    } else {
      return null;
    }
  }

  //auth change user stream
  Stream<CustomUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //register email pass
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;

      //create a new document for the user with the uid
      //await UserDatabaseService(uid: user.uid).updateUserName(user.displayName);
      Response response = await UserDBService(uid: user.uid).addUser();
      if (response.statusCode == 200) {
        return _userFromFirebaseUser(user);
      } else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
