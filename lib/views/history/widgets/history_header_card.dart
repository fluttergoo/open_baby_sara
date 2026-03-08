import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_baby_sara/blocs/baby/baby_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/data/models/baby_model.dart';
import 'package:open_baby_sara/widgets/baby_profile_header.dart';
import 'package:table_calendar/table_calendar.dart';

enum HistoryDateTab { today, thisWeek, custom }

class HistoryHeaderCard extends StatefulWidget {
  final List<BabyModel> babiesList;
  final Function(DateTime start, DateTime end, String? activityType,
      String? babyID) onFilterChanged;

  const HistoryHeaderCard({
    super.key,
    required this.babiesList,
    required this.onFilterChanged,
  });

  @override
  State<HistoryHeaderCard> createState() => _HistoryHeaderCardState();
}

class _HistoryHeaderCardState extends State<HistoryHeaderCard> {
  HistoryDateTab _selectedTab = HistoryDateTab.today;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emitFilter();
    });
  }

  String? get _babyID {
    final s = context.read<BabyBloc>().state;
    return s is BabyLoaded ? s.selectedBaby?.babyID : null;
  }

  void _emitFilter() {
    final now = DateTime.now();
    final babyID = _babyID;
    DateTime start;
    final DateTime end;

    switch (_selectedTab) {
      case HistoryDateTab.today:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case HistoryDateTab.thisWeek:
        start = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case HistoryDateTab.custom:
        if (_customStart == null || _customEnd == null) return;
        start = _customStart!;
        end = DateTime(
            _customEnd!.year, _customEnd!.month, _customEnd!.day, 23, 59, 59);
        break;
    }

    widget.onFilterChanged(start, end, null, babyID);
  }

  Future<void> _showDateRangeBottomSheet() async {
    DateTime? tempStart = _customStart;
    DateTime? tempEnd = _customEnd;
    DateTime focusedDay = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DateRangeBottomSheet(
        initialStart: tempStart,
        initialEnd: tempEnd,
        focusedDay: focusedDay,
        onApply: (start, end) {
          setState(() {
            _customStart = start;
            _customEnd = end;
          });
          _emitFilter();
        },
      ),
    );
  }

  void _selectTab(HistoryDateTab tab) {
    if (tab == HistoryDateTab.custom) {
      setState(() => _selectedTab = tab);
      _showDateRangeBottomSheet();
      return;
    }
    setState(() => _selectedTab = tab);
    _emitFilter();
  }

  String _formatRange() {
    if (_customStart == null || _customEnd == null) return '';
    final locale = context.locale.toLanguageTag();
    final start = DateFormat('d MMM', locale).format(_customStart!);
    final end = DateFormat('d MMM yyyy', locale).format(_customEnd!);
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BabyBloc, BabyState>(
      listenWhen: (prev, curr) {
        if (prev is BabyLoaded && curr is BabyLoaded) {
          return prev.selectedBaby?.babyID != curr.selectedBaby?.babyID;
        }
        return false;
      },
      listener: (context, state) {
        if (state is BabyLoaded) {
          _emitFilter();
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            BabyProfileHeader(babiesList: widget.babiesList),
            SizedBox(height: 16.h),
            Text(
              context.tr('activity_history'),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: Colors.grey[850],
              ),
            ),
            SizedBox(height: 14.h),
            _DateTabSelector(
              selectedTab: _selectedTab,
              onTabSelected: _selectTab,
            ),
            // Custom range chip — shown only when range is selected
            if (_selectedTab == HistoryDateTab.custom &&
                _customStart != null &&
                _customEnd != null) ...[
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: _showDateRangeBottomSheet,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: AppColors.historyPink
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.historyPink
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13.sp,
                          color: AppColors.historyPink,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _formatRange(),
                          style: TextStyle(
                            color: AppColors.historyPink,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.edit_rounded,
                          size: 12.sp,
                          color: AppColors.historyPink
                              .withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab selector (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────

class _DateTabSelector extends StatelessWidget {
  final HistoryDateTab selectedTab;
  final ValueChanged<HistoryDateTab> onTabSelected;

  const _DateTabSelector({
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.historyChipBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _Tab(
            label: context.tr('today'),
            isSelected: selectedTab == HistoryDateTab.today,
            onTap: () => onTabSelected(HistoryDateTab.today),
          ),
          _Tab(
            label: context.tr('this_week'),
            isSelected: selectedTab == HistoryDateTab.thisWeek,
            onTap: () => onTabSelected(HistoryDateTab.thisWeek),
          ),
          _Tab(
            label: context.tr('custom'),
            isSelected: selectedTab == HistoryDateTab.custom,
            onTap: () => onTabSelected(HistoryDateTab.custom),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.historyPink : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.historyPink.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[500],
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date range bottom sheet with TableCalendar
// ─────────────────────────────────────────────────────────────────────────────

class _DateRangeBottomSheet extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final DateTime focusedDay;
  final void Function(DateTime start, DateTime end) onApply;

  const _DateRangeBottomSheet({
    required this.initialStart,
    required this.initialEnd,
    required this.focusedDay,
    required this.onApply,
  });

  @override
  State<_DateRangeBottomSheet> createState() => _DateRangeBottomSheetState();
}

class _DateRangeBottomSheetState extends State<_DateRangeBottomSheet> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialStart;
    _rangeEnd = widget.initialEnd;
    _focusedDay = widget.focusedDay;
  }

  bool get _canApply => _rangeStart != null && _rangeEnd != null;

  String _formatHeader() {
    if (_rangeStart == null) return context.tr('start_time');
    final locale = context.locale.toLanguageTag();
    final start = DateFormat('d MMM', locale).format(_rangeStart!);
    if (_rangeEnd == null) return '$start → ?';
    final end = DateFormat('d MMM yyyy', locale).format(_rangeEnd!);
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),

            // Title + selected range
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('custom'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[850],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: _canApply
                          ? AppColors.historyPink.withValues(alpha: 0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _formatHeader(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: _canApply
                            ? AppColors.historyPink
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // TableCalendar with range selection
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.now().add(const Duration(days: 1)),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                rangeSelectionMode: RangeSelectionMode.enforced,
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                  leftChevronIcon: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.historyChipBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.grey[700],
                      size: 18.sp,
                    ),
                  ),
                  rightChevronIcon: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.historyChipBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey[700],
                      size: 18.sp,
                    ),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  todayDecoration: BoxDecoration(
                    color: AppColors.historyPink.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: AppColors.historyPink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                  rangeHighlightColor:
                      AppColors.historyPink.withValues(alpha: 0.15),
                  rangeStartDecoration: BoxDecoration(
                    color: AppColors.historyPink,
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: BoxDecoration(
                    color: AppColors.historyPink,
                    shape: BoxShape.circle,
                  ),
                  rangeStartTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  rangeEndTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.historyPink,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[800],
                  ),
                  weekendTextStyle: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.red[300],
                  ),
                  outsideDaysVisible: false,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: Colors.red[300],
                  ),
                ),
                onRangeSelected: (start, end, focusedDay) {
                  setState(() {
                    _rangeStart = start;
                    _rangeEnd = end;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),

            SizedBox(height: 16.h),

            // Apply button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _canApply
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFF6F91),
                              Color(0xFFDCA6F5),
                            ],
                          )
                        : null,
                    color: _canApply ? null : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: _canApply
                        ? [
                            BoxShadow(
                              color: AppColors.historyPink
                                  .withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed: _canApply
                        ? () {
                            Navigator.of(context).pop();
                            widget.onApply(_rangeStart!, _rangeEnd!);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      context.tr('filter'),
                      style: TextStyle(
                        color:
                            _canApply ? Colors.white : Colors.grey[400],
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
