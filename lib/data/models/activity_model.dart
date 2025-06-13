import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  breastFeed,
  bottleFeed,
  solids,
  pumpTotal,
  pumpLeftRight,
  diaper,
  sleep,
  growth,
  babyFirsts,
  teething,
  medication,
  fever,
  vaccination,
  doctorVisit,
}

class ActivityModel {
  final String activityID;
  final String activityType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime activityDateTime;

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
    required this.activityDateTime,
  });

  ActivityModel copyWith({
    String? activityID,
    String? activityType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? activityDateTime,
    Map<String, dynamic>? data,
    bool? isSynced,
    String? createdBy,
    String? babyID,
  }) {
    return ActivityModel(
      activityID: activityID ?? this.activityID,
      activityType: activityType ?? this.activityType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activityDateTime: activityDateTime ?? this.activityDateTime,
      data: data ?? this.data,
      isSynced: isSynced ?? this.isSynced,
      createdBy: createdBy ?? this.createdBy,
      babyID: babyID ?? this.babyID,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'activityID': activityID,
      'activityType': activityType,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'activityDateTime': activityDateTime,
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
      activityDateTime:
          map['activityDateTime'] is Timestamp
              ? (map['activityDateTime'] as Timestamp).toDate()
              : DateTime.parse(map['activityDateTime']),
      // fallback
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
      'activityDateTime': activityDateTime.toIso8601String(),
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
      activityDateTime:
          map['activityDateTime'] is Timestamp
              ? (map['activityDateTime'] as Timestamp).toDate()
              : DateTime.parse(map['activityDateTime']),
      data: jsonDecode(map['data']),
      createdBy: map['createdBy'],
      babyID: map['babyID'],
      isSynced: map['isSynced'] == 1,
    );
  }
}
