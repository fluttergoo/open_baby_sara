import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAvatar extends StatefulWidget {
  String? imageUrl;
  VoidCallback? onTap;
  final double size;
  final File? localFile;


  CustomAvatar({super.key, this.imageUrl, this.onTap, this.size = 100, this.localFile});

  @override
  State<CustomAvatar> createState() => _CustomAvatarState();
}

class _CustomAvatarState extends State<CustomAvatar> {
  bool _isLoading = true;
  late ImageProvider imageProvider;


  @override
  Widget build(BuildContext context) {

    if (widget.localFile != null) {
      imageProvider = FileImage(widget.localFile!);
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(widget.imageUrl!);
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
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 3.w,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// Resim
            ClipOval(
              child: Image(
                image: imageProvider,
                fit: BoxFit.cover,
                width: widget.size,
                height: widget.size,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    if (_isLoading) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      });
                    }
                    return child;
                  } else {
                    return Container();
                  }
                },
              ),
            ),

            if (_isLoading)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.purple,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
