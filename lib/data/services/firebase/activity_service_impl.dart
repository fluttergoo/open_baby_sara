import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/services/firebase/activity_service.dart';

class ActivityServiceImpl extends ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> uploadActivity(ActivityModel activityModel) async {
    try {
      await _firestore
          .collection('babies')
          .doc(activityModel.babyID)
          .collection('activities')
          .doc(activityModel.activityID)
          .set(activityModel.toFirestore());
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<ActivityModel?> getActivity(String babyID, String activityID) async {
    final doc =
        await _firestore
            .collection('babies')
            .doc(babyID)
            .collection('activities')
            .doc(activityID)
            .get();
    if (!doc.exists) return null;
    return ActivityModel.fromFirestore(doc.data()!);
  }
}
