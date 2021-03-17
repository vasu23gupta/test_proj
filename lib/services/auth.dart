import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:test_proj/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //custom user based on firebase user
  // CustomUser _userFromFirebaseUser(User user) {
  //   if (user != null) {
  //     user.getIdToken().then((value) => print(value));
  //     return CustomUser(
  //         uid: user.uid, name: user.displayName, isAnon: user.isAnonymous);
  //   } else {
  //     return null;
  //   }
  // }

  //auth change user stream
  Stream<User> get user {
    //return _auth.authStateChanges().map(_userFromFirebaseUser);
    return _auth.authStateChanges();
  }

  //sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return user;
      //return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  //sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return user;
      //return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign in with google
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //register email pass
  Future<User> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      user.sendEmailVerification();
      await user.updateProfile(displayName: username);
      await user.reload();

      //create a new document for the user with the uid
      //await UserDatabaseService(uid: user.uid).updateUserName(user.displayName);
      Response response =
          await UserDBService(jwt: await user.getIdToken()).addUser(username);
      if (response.statusCode == 200) {
        return user;
        //return _userFromFirebaseUser(user);
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
