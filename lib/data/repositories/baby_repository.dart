import 'dart:io';

import 'package:open_baby_sara/data/models/baby_model.dart';

abstract class BabyRepository {
  Future<void> createBaby(BabyModel baby);
  Future<BabyModel?> getSelectedBaby(String? babyID);
  Future<List<BabyModel>> getBabies();
  Future<String?> uploadBabyImage(String babyID);
  Future<String?> saveBabyImageLocally(String babyID, String originalImagePath);
  Future<void> updateBaby(String babyID, Map<String, dynamic> updatedFields);
  Future<void> deleteBaby(String babyID);
  Future<String?> uploadBabyImageToFile(String babyID, File file);
  Future<File?> getLocalBabyImage(String babyID);
}
