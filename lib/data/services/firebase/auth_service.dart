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
      debugPrint('AuthService: Starting Google Sign-In flow...');
      
      // Ensure we start fresh by signing out from Google Sign-In first
      // This prevents issues with cached accounts after logout
      try {
        await _googleSignIn.signOut();
        debugPrint('AuthService: Cleared previous Google Sign-In session');
      } catch (e) {
        debugPrint('AuthService: Error clearing Google Sign-In session (non-critical): ${e.toString()}');
        // Continue anyway, this is not critical
      }
      
      // Start Google Sign-In flow
      debugPrint('AuthService: Calling Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled Google Sign-In
        debugPrint('AuthService: User cancelled Google Sign-In');
        return null;
      }

      debugPrint('AuthService: Google Sign-In account obtained: ${googleUser.email}');
      
      // Get authentication details from Google
      debugPrint('AuthService: Getting authentication details...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      debugPrint('AuthService: Signing in to Firebase...');
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      debugPrint('AuthService: Firebase sign-in successful, user ID: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: FirebaseAuthException: ${e.code} - ${e.message}');
      // Re-throw FirebaseAuthException so it can be handled in the bloc
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('AuthService: Google Sign-In Error: ${e.toString()}');
      debugPrint('AuthService: Stack trace: $stackTrace');
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
