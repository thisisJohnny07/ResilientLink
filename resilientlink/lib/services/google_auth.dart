import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  // for storing data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // for authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        print("========================================================");
        print(googleSignInAccount);
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in the user with the obtained credentials
        UserCredential userCredential =
            await _auth.signInWithCredential(authCredential);

        // Get user information from the credential
        User? user = userCredential.user;

        if (user != null) {
          // Check if the user already exists in Firestore
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(user.uid).get();

          if (!userDoc.exists) {
            // If the user doesn't exist in Firestore, add them
            await _firestore.collection('users').doc(user.uid).set({
              'name': user.displayName,
              'email': user.email,
              'uid': user.uid,
            });
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
  }

  googleSignOut() async {
    await googleSignIn.signOut();
  }
}
