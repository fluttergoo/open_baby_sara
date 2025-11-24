import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:open_baby_sara/data/services/firebase/auth_base.dart';

class AuthService implements AuthBase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      // Start Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled Google Sign-In
        return null;
      }

      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In Firebase Error: ${e.toString()}');
      // Re-throw FirebaseAuthException so it can be handled in the bloc
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In Error: ${e.toString()}');
      // Check if it's a platform channel error
      if (e.toString().contains('channel-error') || 
          e.toString().contains('Unable to establish connection')) {
        throw Exception(
          'Google Sign-In is not properly configured. Please rebuild the app and ensure Google Sign-In is enabled in Firebase Console.',
        );
      }
      // Re-throw other exceptions so they can be handled in the bloc
      rethrow;
    }
  }
}
