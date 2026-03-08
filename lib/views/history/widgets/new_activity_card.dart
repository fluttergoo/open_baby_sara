import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
import 'package:open_baby_sara/views/history/widgets/delete_activity_bottom_sheet.dart';

/// Maps each activity type to its icon color and background color.
Color _getIconColor(String activityType) {
  switch (activityType) {
    case 'breastFeed':
    case 'bottleFeed':
    case 'solids':
      return AppColors.feedIconColor;
    case 'pumpTotal':
    case 'pumpLeftRight':
      return AppColors.pumpIconColor;
    case 'sleep':
      return AppColors.sleepIconColor;
    case 'diaper':
      return AppColors.diaperIconColor;
    case 'growth':
      return AppColors.growthIconColor;
    case 'babyFirsts':
      return AppColors.babyFirstsIconColor;
    case 'teething':
      return AppColors.teethingIconColor;
    case 'medication':
      return AppColors.medicationIconColor;
    case 'fever':
      return AppColors.feverIconColor;
    case 'vaccination':
      return AppColors.vaccinationIconColor;
    case 'doctorVisit':
      return AppColors.doctorVisitIconColor;
    default:
      return AppColors.historyPink;
  }
}

Color _getIconBg(String activityType) {
  switch (activityType) {
    case 'breastFeed':
    case 'bottleFeed':
    case 'solids':
      return AppColors.feedColor;
    case 'pumpTotal':
    case 'pumpLeftRight':
      return AppColors.pumpColor;
    case 'sleep':
      return AppColors.sleepColor;
    case 'diaper':
      return AppColors.diaperColor;
    case 'growth':
      return AppColors.growthColor;
    case 'babyFirsts':
      return AppColors.babyFirstsColor;
    case 'teething':
      return AppColors.teethingColor;
    case 'medication':
      return AppColors.medicalColor;
    case 'fever':
      return AppColors.feverTrackerColor;
    case 'vaccination':
      return AppColors.vaccineColor;
    case 'doctorVisit':
      return AppColors.doctorVisitColor;
    default:
      return AppColors.historyChipBg;
  }
}

class NewActivityCard extends StatefulWidget {
  final ActivityModel activity;
  final String? summary;
  final String iconPath;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NewActivityCard({
    super.key,
    required this.activity,
    this.summary,
    required this.iconPath,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<NewActivityCard> createState() => _NewActivityCardState();
}

class _NewActivityCardState extends State<NewActivityCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityType = widget.activity.activityType;
    final iconColor = _getIconColor(activityType);
    final iconBg = _getIconBg(activityType);
    final time = DateFormat('h:mm a').format(widget.activity.activityDateTime);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main card row
          GestureDetector(
            onTap: _toggleExpand,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  // Icon box
                  Container(
                    width: 48.sp,
                    height: 48.sp,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.r),
                      child: Image.asset(
                        widget.iconPath,
                        width: 28.sp,
                        height: 28.sp,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(activityType),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: Colors.grey[850],
                          ),
                        ),
                        if (widget.summary != null &&
                            widget.summary!.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          Text(
                            widget.summary!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Time + chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: iconColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      AnimatedRotation(
                        turns: _expanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey[400],
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded section
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: _ExpandedSection(
              iconColor: iconColor,
              iconBg: iconBg,
              summary: widget.summary,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
              context: context,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedSection extends StatelessWidget {
  final Color iconColor;
  final Color iconBg;
  final String? summary;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final BuildContext context;

  const _ExpandedSection({
    required this.iconColor,
    required this.iconBg,
    required this.summary,
    required this.onEdit,
    required this.onDelete,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: iconBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary != null && summary!.isNotEmpty) ...[
            // Render each line of the summary as a separate row for clarity.
            ...summary!.split('\n').where((l) => l.trim().isNotEmpty).map(
              (line) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5.h, right: 6.w),
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line.trim(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
          Row(
            children: [
              // Edit button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_rounded, size: 14.sp),
                  label: Text(
                    buildContext.tr('edit'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Delete button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    DeleteActivityBottomSheet.show(buildContext, () {
                      onDelete?.call();
                    });
                  },
                  icon: Icon(Icons.delete_outline_rounded, size: 14.sp),
                  label: Text(
                    buildContext.tr('delete'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEEEE),
                    foregroundColor: Colors.red[400],
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
