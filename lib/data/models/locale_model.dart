import 'package:flutter/material.dart';

class LocaleModel {
  final String name, flag;
  final Locale locale;

  const LocaleModel({
    required this.name,
    required this.flag,
    required this.locale,
  });
}
