import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showCustomFlushbar(BuildContext context,String title, String message, IconData icon) {
  Flushbar(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(16),
    backgroundColor: Colors.red.shade400,
    titleText: Text(
      title,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    messageText: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    icon: Icon(icon,color: Colors.white,),
    duration: Duration(seconds: 3),
  ).show(context);
}