import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_proj/models/customUser.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //custom user based on firebase user
  CustomUser _userFromFirebaseUser(User user) {
    if (user != null) {
      return CustomUser(uid: user.uid);
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

  //sign in email pass

  //register email pass

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
