import 'package:flutter/material.dart';

class MedicationModel {
  final int? id;
  final String name;
  String amount;
  String unit;
  TextEditingController? controller;

  MedicationModel({
    this.id,
    required this.name,
    this.amount = '',
    this.unit = 'mg',
    this.controller,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(id: map['id'] as int, name: map['name'] as String);
  }
}
