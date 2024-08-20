import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuntServices {
  // for storing data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // for authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

// for sign up

  Future<String> signUpUser(
      {required String email,
      required String password,
      required String name}) async {
    String res = " Some error occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        // register user in firebase aunt
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // adding user to cloud firestore
        await _firestore.collection("users").doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'uid': credential.user!.uid,
        });
        res = "success";
      } else {
        res = "Pls enter all the field";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = " Some error occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Pls enter all the field";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  Future<void> signout() async {
    await _auth.signOut();
  }
}
