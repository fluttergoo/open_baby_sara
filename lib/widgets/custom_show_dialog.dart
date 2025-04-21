import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

AlertDialog buildCustomAlertDialog({
  required BuildContext context,
  String title = 'Are you sure?',
  String content = 'Do you really want to perform this action?',
  String cancelButtonText = 'Cancel',
  required VoidCallback cancelButtonTap,
  String yesButtonText = 'Yes',
  required VoidCallback yesButtonTap,
}) {
  return AlertDialog(
    title: Text(title, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
    content: Text(content, style: Theme.of(context).textTheme.bodyMedium),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    actions: [
      TextButton(
        onPressed: cancelButtonTap,
        child: Text(
          cancelButtonText,
          style: Theme.of(
            context,
          ).textTheme.titleSmall!.copyWith(fontSize: 14.sp, color: Colors.grey),
        ), // just close
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: yesButtonTap,
        child: Text(
          yesButtonText,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
