import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final String saveText;
  final Color backgroundColor;

  const CustomSheetHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onSave,
    required this.saveText,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(Icons.arrow_back, color: Colors.deepPurple),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          TextButton(
            onPressed: onSave,
            child: Text(
              saveText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
