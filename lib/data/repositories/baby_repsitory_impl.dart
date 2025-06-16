import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/baby_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


class BabyRepositoryImpl extends BabyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> createBaby(BabyModel baby) async {
    await _firestore.collection("babies").doc(baby.babyID).set(baby.toMap());
  }

  @override
  Future<BabyModel?> getSelectedBaby(String? babyID) async {
    final String? userID = _auth.currentUser?.uid;
    if (userID == null) return null;

    try {
      //TODO: Baby Null check
      if (babyID == null) {
        final querySnapshot =
            await _firestore
                .collection("babies")
                .where('userID', isEqualTo: userID)
                .limit(1)
                .get();

        if (querySnapshot.docs.isEmpty) return null;

        return BabyModel.fromMap(querySnapshot.docs.first.data());
      } else {
        final docSnapshot =
            await _firestore.collection("babies").doc(babyID).get();

        final data = docSnapshot.data();
        if (data == null || data.isEmpty) return null;

        return BabyModel.fromMap(data);
      }
    } catch (e) {
      print("Error fetching baby: $e");
      return null;
    }
  }

  @override
  Future<List<BabyModel>> getBabies() async {
    final String? userID = _auth.currentUser?.uid;
    if (userID == null) return [];
    var userMap=(await FirebaseFirestore.instance.collection('users').doc(userID).get()).data();
    final String parentID=userMap!['parentID'];
    try {
      var snapshot =
          await _firestore
              .collection("babies")
              .where('parentID', isEqualTo: parentID)
              .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BabyModel.fromMap(data);
      }).toList();
    } catch (e) {
      print("Error fetching baby: $e");
      return [];
    }
  }


  /// Upload image to FIRESTORE and Storage !!!
  @override
  Future<String?> uploadBabyImage(String babyID) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;
    final file = File(pickedFile.path);
    final ref = FirebaseStorage.instance.ref().child('baby_image/$babyID.jpg');
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('babies').doc(babyID).update({
      'imageUrl': downloadUrl,
    });
    return downloadUrl;
  }

  Future<void> updateBaby(
    String babyID,
    Map<String, dynamic> updatedFields,
  ) async {
    await _firestore
        .collection('babies')
        .doc(babyID)
        .set(updatedFields, SetOptions(merge: true));
  }

  @override
  Future<void> deleteBaby(String babyID) async {
   await _firestore.collection('babies').doc(babyID).delete();
  }

  /// Upload Image to JUST Storage and get URL LINK!!!
  Future<String?> uploadBabyImageToFile(String babyID, File file) async {

    final ref = FirebaseStorage.instance.ref().child('baby_image/$babyID.jpg');
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String?> saveBabyImageLocally(String babyID, String originalImagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/baby_images';
      final folder = Directory(savePath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final newPath = '$savePath/$babyID.jpg';
      final newFile = await File(originalImagePath).copy(newPath);
      return newFile.path;
    } catch (e) {

      return null;
    }
  }

  Future<File?> getLocalBabyImage(String babyID) async {
    final appDir = await getApplicationDocumentsDirectory();
    final filePath = p.join(appDir.path, '$babyID.jpg');
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    } else {
      return null;
    }
  }

}
