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

      if (googleSignInAccount == null) {
        print("Sign-in process was aborted.");
        return; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      if (googleSignInAuthentication.accessToken == null ||
          googleSignInAuthentication.idToken == null) {
        print("Error: Missing Google Auth Token");
        return;
      }

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(authCredential);

      User? user = userCredential.user;
      if (user != null) {
        DocumentReference userRef =
            _firestore.collection('users').doc(user.uid);
        DocumentSnapshot userSnapshot = await userRef.get();

        if (!userSnapshot.exists) {
          await userRef.set({
            'name': user.displayName,
            'email': user.email,
            'uid': user.uid,
          });

          print("User data saved to Firestore");
        } else {
          print("User already exists in Firestore");
        }
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth error: ${e.message}");
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  googleSignOut() async {
    await googleSignIn.signOut();
  }
}
