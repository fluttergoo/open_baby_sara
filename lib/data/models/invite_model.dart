import 'package:cloud_firestore/cloud_firestore.dart';

class InviteModel {
  final String senderID;
  final String caregiverID;
  final String receiverEmail;
  final String status;
  final String firstName;
  final String parentID;
  final DateTime createdAt;

  InviteModel({
    required this.senderID,
    required this.receiverEmail,
    required this.status,
    required this.firstName,
    required this.parentID,
    required this.createdAt,
    required this.caregiverID,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'firstName': firstName,
      'receiverEmail': receiverEmail,
      'parentID': parentID,
      'status': status,
      'caregiverID': caregiverID,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory InviteModel.fromMap(Map<String, dynamic> map) {
    return InviteModel(
      senderID: map['senderID'] as String,
      receiverEmail: map['receiverEmail'] as String,
      status: map['status'] as String,
      parentID: map['parentID'] as String,
      firstName: map['firstName'] as String,
      caregiverID: map['caregiverID'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
