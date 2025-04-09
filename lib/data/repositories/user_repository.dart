import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/user_model.dart';

abstract class UserRepository{

  Future<void> createUserInFireStore(UserModel user);
  Future<void> signInEmailAndPassword(String email, String password);
  Future<UserModel?> getCurrentUser();
}