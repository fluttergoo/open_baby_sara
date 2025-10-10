import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthBase {
  Future<User?> registerWithEmailAndPassword(String email, String password);
}
