import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/user_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  @override
  Future<void> createUserInFireStore(UserModel user) async {
    await _firestore.collection('users').doc(user.userID).set(user.toMap());
  }

  @override
  Future<void> signInEmailAndPassword(String email, String password) async{
  await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserModel?> getCurrentUser() async{
    final user=_firebaseAuth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }


}
