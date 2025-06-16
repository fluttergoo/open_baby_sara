import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CustomAvatar extends StatefulWidget {
  final String? imagePath;
  final String? babyID;
  final VoidCallback? onTap;
  final double size;

  const CustomAvatar({
    super.key,
    this.imagePath,
    this.babyID,
    this.onTap,
    this.size = 100,
  });

  @override
  State<CustomAvatar> createState() => _CustomAvatarState();
}

class _CustomAvatarState extends State<CustomAvatar> {
  File? localImageFile;

  @override
  void initState() {
    super.initState();
    if (widget.imagePath == null && widget.babyID != null) {
      _loadLocalImage(widget.babyID!);
    }
  }

  @override
  void didUpdateWidget(covariant CustomAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath == null &&
        widget.babyID != null &&
        oldWidget.babyID != widget.babyID) {
      _loadLocalImage(widget.babyID!);
    }
  }

  Future<void> _loadLocalImage(String babyID) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, '$babyID.jpg');
    final file = File(path);
    if (await file.exists()) {
      setState(() {
        localImageFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (widget.imagePath != null && File(widget.imagePath!).existsSync()) {
      imageProvider = FileImage(File(widget.imagePath!));
    } else if (localImageFile != null) {
      imageProvider = FileImage(localImageFile!);
    } else {
      imageProvider = const AssetImage('assets/images/default_baby.png');
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
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
            width: widget.size,
            height: widget.size,
          ),
        ),
      ),
    );
  }
}
