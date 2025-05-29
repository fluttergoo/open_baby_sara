import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAvatar extends StatelessWidget {
  final String? imagePath;
  final VoidCallback? onTap;
  final double size;

  const CustomAvatar({
    super.key,
    this.imagePath,
    this.onTap,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (imagePath != null && File(imagePath!).existsSync()) {
      imageProvider = FileImage(File(imagePath!));
    } else {
      imageProvider = const AssetImage('assets/images/default_baby.png');
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(top: 16, right: 16),
        decoration: BoxDecoration(
          color: AppColors.vaccineColor,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4))],
          border: Border.all(color: Colors.white, width: 3.w),
        ),
        child: ClipOval(
          child: Image(
            image: imageProvider,
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }
}

