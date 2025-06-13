import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class ActivityCardDetails extends StatefulWidget {
  final ActivityModel activity;
  final String? summary;
  final String iconPath;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;



  const ActivityCardDetails({
    super.key,
    required this.activity,
    this.summary,
    required this.iconPath,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onEdit,
    this.onDelete,
    this.onTap,

  });

  @override
  State<ActivityCardDetails> createState() => _ActivityCardDetailsState();
}

class _ActivityCardDetailsState extends State<ActivityCardDetails>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  Widget _buildEditAction() {
    return SlidableAction(
      onPressed: (_) => widget.onEdit?.call(),
      backgroundColor: Colors.green.shade100,
      foregroundColor: Colors.green,
      icon: Icons.edit_rounded,
      label: 'Edit',
      borderRadius: BorderRadius.circular(16.r),
    );
  }

  Widget _buildDeleteAction() {
    return SlidableAction(
      onPressed: (_) => _showDeleteConfirmation(),
      backgroundColor: Colors.red.shade100,
      foregroundColor: Colors.red,
      icon: Icons.delete_rounded,
      label: 'Delete',
      borderRadius: BorderRadius.circular(16.r),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          contentPadding: EdgeInsets.all(20.w),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
               context.tr('delete_activity'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                context.tr('delete_activity_body'),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        context.tr('cancel'),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onDelete?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.tr('delete'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityDay = widget.activity.activityDateTime;
    final formattedDate = DateFormat('MMM d').format(activityDay);
    final formattedTime = DateFormat('h:mm a').format(activityDay);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Slidable(
          key: ValueKey(widget.activity.activityID),
          enabled: !widget.isSelectionMode,
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.6,
            children: [
              _buildEditAction(),
              _buildDeleteAction(),
            ],
          ),
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: 80.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: widget.isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade200,
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: widget.isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                    spreadRadius: widget.isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Date Column with enhanced styling
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 11.sp,
                                color: Theme.of(context).primaryColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 16.w),

                      // Icon with enhanced styling
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          widget.iconPath,
                          height: 32.sp,
                          width: 32.sp,
                        ),
                      ),

                      SizedBox(width: 16.w),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              toBeginningOfSentenceCase(widget.activity.activityType) ??
                                  widget.activity.activityType,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: Colors.grey[800],
                              ),
                            ),
                            if (widget.summary != null && widget.summary!.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  widget.summary!,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Slide indicator
                      if (!widget.isSelectionMode)
                        Container(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.keyboard_arrow_left,
                            color: Colors.grey.shade400,
                            size: 20.sp,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}