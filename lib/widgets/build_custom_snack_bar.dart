import 'package:flutter/material.dart';

SnackBar buildCustomSnackBar(String textMessage,
    {Color backgroundColor = Colors.green,
      IconData icon = Icons.check_circle_outline}) {
  return SnackBar(
    content: Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 10),
        Expanded(child: Text(textMessage)),
      ],
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.all(16),
    duration: Duration(seconds: 3),
  );
}
