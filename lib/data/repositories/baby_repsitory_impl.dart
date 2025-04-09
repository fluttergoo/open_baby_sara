import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/baby_repository.dart';

class BabyRepositoryImpl extends BabyRepository{
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  @override
  Future<void> createBaby(BabyModel baby) async{
   await _firestore.collection("babies").doc(baby.babyID).set(baby.toMap());
  }

}