import 'package:flutter_sara_baby_tracker_and_sound/data/models/invite_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/user_model.dart';

abstract class UserRepository{

  Future<void> createUserInFireStore(UserModel user);
  Future<void> signInEmailAndPassword(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
  Future<void> addCaregiverInUser(InviteModel caregiver);
  Future<void> changePassword(String password);
  Future<void>deleteUser();
  Future<void>forgotPassword(String email);
}