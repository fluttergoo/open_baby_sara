import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:open_baby_sara/data/models/invite_model.dart';
import 'package:open_baby_sara/data/models/user_model.dart';
import 'package:open_baby_sara/data/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<void> createUserInFireStore(UserModel user) async {
    await _firestore.collection('users').doc(user.userID).set(user.toMap());
  }

  @override
  Future<void> signInEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      } else {
        print(
          'Firestore document does not exist or has no data for user: ${user.uid}',
        );
        return null;
      }
    }

    return null;
  }

  @override
  Future<void> signOut() async {
    // Sign out from Firebase Auth
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firebaseAuth.signOut();
    }
    // Also sign out from Google Sign-In to clear cached account
    await _googleSignIn.signOut();
  }

  @override
  Future<void> addCaregiverInUser(InviteModel caregiver) async {
    final user = _firebaseAuth.currentUser;
    await _firestore.collection('users').doc(user!.uid).update({
      'caregivers': FieldValue.arrayUnion([caregiver.toMap()]),
    });
  }

  @override
  Future<void> changePassword(String password) async {
    final user = _firebaseAuth.currentUser;
    try {
      await user!.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      throw e.toString();
    } catch (e) {
      e.toString();
    }
  }

  @override
  Future<void> deleteUser() async {
    final user = _firebaseAuth.currentUser;
    try {
      await user!.delete();
    } on FirebaseAuthException catch (e) {
      throw e.toString();
    } catch (e) {
      e.toString();
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
