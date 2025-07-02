import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_baby_sara/data/models/invite_model.dart';
import 'package:uuid/uuid.dart';

class UserModel {
  final String userID;
  final String email;
  final String firstName;
  final String? parentID;
  final DateTime createdAt;
  List<InviteModel>? caregivers;

  UserModel({
    required this.userID,
    required this.email,
    required this.firstName,
    DateTime? createdAt,
    this.caregivers,
    this.parentID,
  }) : createdAt = createdAt ?? DateTime.now();

  static UserModel create({
    required String userID,
    required String email,
    required String firstName,
  }) {
    return UserModel(
      userID: userID,
      email: email,
      parentID: Uuid().v4(),
      firstName: firstName,
      caregivers: [],
      createdAt: DateTime.now(),
    );
    ;
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'email': email,
      'firstName': firstName,
      'parentID': parentID,
      'createdAt': createdAt.toIso8601String(),
      'caregivers':
          caregivers == null ? [] : caregivers?.map((e) => e.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      parentID: map['parentID'] ?? '',
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      caregivers:
          (map['caregivers'] as List<dynamic>? ?? []).map((e) {
            return InviteModel.fromMap(e as Map<String, dynamic>);
          }).toList(),
    );
  }
}

/*
class Caregivers {
  final String caregiverID;
  final String email;
  final String firstName;
  final DateTime createdAt;

  Caregivers({
    required this.caregiverID,
    required this.email,
    required this.firstName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'caregiverID': caregiverID,
      'email': email,
      'firstName': firstName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Caregivers.fromMap(Map<String, dynamic> map) {
    return Caregivers(
      caregiverID: map['caregiverID'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}*/
