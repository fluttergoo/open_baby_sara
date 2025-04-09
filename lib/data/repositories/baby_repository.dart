import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';

abstract class BabyRepository{
  Future<void> createBaby(BabyModel baby);
}