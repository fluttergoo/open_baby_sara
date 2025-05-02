import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { breastFeed, bottleFeed, solids, pumpTotal,pumpLeftRight, diaper, sleep }

class ActivityModel {
  final String activityID;
  final String activityType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> data;

  /// All baby activity information will come in here

  final bool isSynced;

  /// compare local storage and firestore

  final String createdBy;
  final String babyID;

  ActivityModel({
    required this.activityID,
    required this.activityType,
    required this.createdAt,
    required this.updatedAt,
    required this.data,
    required this.isSynced,
    required this.createdBy,
    required this.babyID,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'activityID': activityID,
      'activityType': activityType,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'data': data,
      'createdBy': createdBy,
      'babyID': babyID,
      'isSynced': true,
    };
  }

  factory ActivityModel.fromFirestore(Map<String, dynamic> map) {
    return ActivityModel(
      activityID: map['activityID'],
      activityType: map['activityType'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      data: Map<String, dynamic>.from(map['data']),
      createdBy: map['createdBy'],
      babyID: map['babyID'],
      isSynced: map['isSynced'] ?? true,
    );
  }
  Map<String, dynamic> toSqlite() {
    return {
      'activityID': activityID,
      'activityType': activityType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'data': jsonEncode(data),
      'createdBy': createdBy,
      'babyID': babyID,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory ActivityModel.fromSqlite(Map<String, dynamic> map) {
    return ActivityModel(
      activityID: map['activityID'],
      activityType: map['activityType'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      data: jsonDecode(map['data']),
      createdBy: map['createdBy'],
      babyID: map['babyID'],
      isSynced: map['isSynced'] == 1,
    );
  }
}
