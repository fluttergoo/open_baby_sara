import 'package:cloud_firestore/cloud_firestore.dart';

class BabyModel {
  final String firstName;

  final String gender;
  final String userID;
  final String? parentID;
  final String babyID;
  final DateTime dateTime;
  final String? imageUrl;
  final Map<String, dynamic>? nighttimeHours;

  BabyModel({
    required this.firstName,
    required this.gender,
    required this.userID,
    required this.babyID,
    required this.dateTime,
    this.parentID,
    this.imageUrl,
    this.nighttimeHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'gender': gender,
      'userID': userID,
      'babyID': babyID,
      'parentID': parentID,
      'imageUrl': imageUrl ?? '',
      'nighttimeHours': nighttimeHours,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  factory BabyModel.fromMap(Map<String, dynamic> map) {
    return BabyModel(
      firstName: map['firstName'] ?? "",
      gender: map['gender'] ?? "",
      userID: map['userID'] ?? "",
      babyID: map['babyID'] ?? "",
      parentID: map['parentID'] ?? "",
      imageUrl: map['imageUrl'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      nighttimeHours: map['nighttimeHours'],
    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BabyModel && runtimeType == other.runtimeType && babyID == other.babyID;

  @override
  int get hashCode => babyID.hashCode;

  @override
  String toString() => firstName;
}
