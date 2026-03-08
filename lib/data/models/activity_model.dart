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

  final bool isSynced;

  /// true = marked for deletion locally, pending sync to Firestore
  final bool isPendingDelete;

  /// timestamp when this record was soft-deleted locally
  final DateTime? deletedAt;

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
    this.isPendingDelete = false,
    this.deletedAt,
  });

  ActivityModel copyWith({
    String? activityID,
    String? activityType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? activityDateTime,
    Map<String, dynamic>? data,
    bool? isSynced,
    bool? isPendingDelete,
    DateTime? deletedAt,
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
      isPendingDelete: isPendingDelete ?? this.isPendingDelete,
      deletedAt: deletedAt ?? this.deletedAt,
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
      data: Map<String, dynamic>.from(map['data']),
      createdBy: map['createdBy'],
      babyID: map['babyID'],
      isSynced: true,
      isPendingDelete: false,
      deletedAt: null,
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
      'isPendingDelete': isPendingDelete ? 1 : 0,
      'deletedAt': deletedAt?.toIso8601String(),
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
      isPendingDelete: (map['isPendingDelete'] ?? 0) == 1,
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
    );
  }
}
