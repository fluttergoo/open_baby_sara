
import 'package:cloud_firestore/cloud_firestore.dart';


class BabyModel {
  final String firstName;

  final String gender;
  final String userID;
  final String babyID;
  final DateTime dateTime;



  BabyModel({
    required this.firstName,
    required this.gender,
    required this.userID,
    required this.babyID,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'gender': gender,
      'userID': userID,
      'babyID': babyID,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  factory BabyModel.fromMap(Map<String, dynamic> map) {
    return BabyModel(
      firstName: map['firstName'] ?? "",
      gender: map['gender'] ?? "",
      userID: map['userID'] ?? "",
      babyID: map['babyID'] ?? "",
      dateTime: (map['dateTime'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() {
    return 'BabyModel{firstName: $firstName, gender: $gender, userID: $userID, babyID: $babyID, dateTime: $dateTime}';
  }
}
