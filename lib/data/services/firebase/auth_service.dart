
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/services/firebase/auth_base.dart';

class AuthService implements AuthBase{

  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
  @override
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try{
    final result= await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user;
    }catch(e){
      debugPrint(e.toString());
      return null;
    }
  }

}