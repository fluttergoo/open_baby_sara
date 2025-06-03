import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/constant/activity_constants.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/shared_prefs_helper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_avatar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomBabyTimelineHeaderCard extends StatefulWidget {
  final List<BabyModel> babiesList;
  final Function(DateTime?, DateTime?, String?, String?) onFilterChanged;

  const CustomBabyTimelineHeaderCard({
    super.key,
    required this.babiesList,
    required this.onFilterChanged,
  });

  @override
  State<CustomBabyTimelineHeaderCard> createState() =>
      _CustomBabyTimelineHeaderCardState();
}

class _CustomBabyTimelineHeaderCardState
    extends State<CustomBabyTimelineHeaderCard> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  String? _selectedActivityType = 'All Activities';
  String _selectedRangeLabel = 'Last 7 Days';
  String? _customRangeLabel;

  final activityTypes = activityTypeMap.keys.toList();


  final List<String> staticRanges = [
    'Last 1 Day',
    'Last 7 Days',
    'Last 14 Day',
    'Last 30 Days',
  ];

  List<String> get totalDropdownItems {
    final items = {...staticRanges};

    if (_customRangeLabel != null && !staticRanges.contains(_customRangeLabel)) {
      items.add(_customRangeLabel!);
    }

    items.add('Custom Range');

    return items.toList();
  }

  String calculateBabyAge(DateTime birthDate) {
    final now = DateTime.now();
    if (birthDate.isAfter(now)) return "0 day";
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;
    if (days < 0) {
      final lastDay = DateTime(now.year, now.month, 0).day;
      days += lastDay;
      months--;
    }
    if (months < 0) {
      months += 12;
      years--;
    }
    int totalMonths = years * 12 + months;
    String age = '';
    if (totalMonths > 0) {
      age += '$totalMonths ${context.tr('month')}${totalMonths > 1 ? 's' : ''}';
    }
    if (days > 0) {
      if (age.isNotEmpty) age += ' ';
      age += '$days ${context.tr('day')}${days > 1 ? 's' : ''}';
    }
    return age.isEmpty ? context.tr('0_day') : age;
  }

  void _onPredefinedRangeSelected(String? value) {
    if (value == null) return;
    final now = DateTime.now();
    DateTime start;
    switch (value) {
      case 'Last 1 Day':
        start = now.subtract(Duration(days: 1));
        break;
      case 'Last 7 Days':
        start = now.subtract(Duration(days: 7));
        break;
      case 'Last 14 Days':
        start = now.subtract(Duration(days: 14));
        break;
      case 'Last 30 Days':
        start = now.subtract(Duration(days: 30));
        break;
      default:
        return;
    }
    setState(() {
      _rangeStart = start;
      _rangeEnd = now;
      _focusedDay = now;
      _selectedRangeLabel = value;
      _customRangeLabel = null;
    });
  }

  Future<void> _showDateRangeDialog(BuildContext context) async {
    DateTime? tempStart = _rangeStart;
    DateTime? tempEnd = _rangeEnd;
    DateTime tempFocusedDay = _focusedDay;

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                content: SizedBox(
                  height: 320.h,
                  width: 320.w,
                  child: TableCalendar(
                    focusedDay: tempFocusedDay,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    calendarFormat: CalendarFormat.month,
                    rangeSelectionMode: RangeSelectionMode.enforced,
                    rangeStartDay: tempStart,
                    rangeEndDay: tempEnd,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.deepPurple,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.deepPurple,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      isTodayHighlighted: true,
                      todayDecoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      rangeHighlightColor: Colors.deepPurple.withOpacity(0.2),
                      rangeStartDecoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(fontSize: 14.sp),
                      weekendTextStyle: TextStyle(color: Colors.redAccent),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                      weekendStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                    onRangeSelected: (start, end, focusedDay) {
                      setStateDialog(() {
                        tempStart = start;
                        tempEnd = end;
                        tempFocusedDay = focusedDay;
                      });
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (tempStart != null && tempEnd != null) {
                        final formatter = DateFormat('MMM dd');
                        final label =
                            '${formatter.format(tempStart!)} - ${formatter.format(tempEnd!)}';

                        setState(() {
                          _rangeStart = tempStart;
                          _rangeEnd = tempEnd;
                          _focusedDay = tempFocusedDay;
                          _customRangeLabel = label;
                          _selectedRangeLabel = '';
                        });

                      }
                      Navigator.pop(context);
                    },
                    child: Text('Done'),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  void initState() {
    final now = DateTime.now();
    _rangeStart = now.subtract(Duration(days: 1));
    _rangeEnd = now;
    _focusedDay = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyID = context.read<BabyBloc>().state is BabyLoaded
          ? (context.read<BabyBloc>().state as BabyLoaded).selectedBaby?.babyID
          : null;

      widget.onFilterChanged(
        _rangeStart,
        _rangeEnd,
        _selectedActivityType,
        babyID,
      );
    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BabyBloc>().state;
    final selectedBaby = state is BabyLoaded ? state.selectedBaby : null;
    final primaryColor = Theme.of(context).primaryColor;

    return BlocBuilder<BabyBloc, BabyState>(
  builder: (context, state) {
    String? imagePath;
    if (state is BabyImagePathLoaded) {
      imagePath = state.imagePath;
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            children: [
              CustomAvatar(size: 50.sp, imagePath: imagePath),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<BabyModel>(
                        key: ValueKey(selectedBaby?.babyID),
                        value: selectedBaby,
                        icon: const SizedBox.shrink(),

                        isExpanded: false,
                        selectedItemBuilder: (context) {
                          return widget.babiesList.map((baby) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  baby.firstName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: primaryColor,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: primaryColor,
                                ),
                              ],
                            );
                          }).toList();
                        },
                        items:
                            widget.babiesList.map((baby) {
                              return DropdownMenuItem<BabyModel>(
                                value: baby,
                                child: Text(
                                  baby.firstName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (newBaby) async {
                          if (newBaby != null) {
                            context.read<BabyBloc>().add(
                              SelectBaby(selectBabyModel: newBaby),
                            );
                            await SharedPrefsHelper.saveSelectedBabyID(
                              newBaby.babyID,
                            );
                          }
                        },
                      ),
                    ),

                    Row(
                      children: [
                        Text(
                          'Age:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          state is BabyLoaded
                              ? calculateBabyAge(state.selectedBaby!.dateTime)
                              : 'unknown',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// Date Filter
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.summaryHeader,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              /// Activity dropdown (esnek)
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedActivityType ?? 'All Activities',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                    isExpanded: true,
                    icon: const SizedBox.shrink(),
                    selectedItemBuilder: (context) {
                      return activityTypes.map((type) {
                        return Row(
                          children: [
                            Text(type),
                            Icon(Icons.arrow_drop_down, color: primaryColor),
                          ],
                        );
                      }).toList();
                    },
                    items: activityTypes.map((activity) {
                      return DropdownMenuItem<String>(
                        value: activity,
                        child: Row(
                          children: [
                            Text(
                              activity,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedActivityType =
                            value == 'All Activities' ? 'All Activities' : value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              /// Date range dropdown (esnek)
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _customRangeLabel ?? _selectedRangeLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                    isExpanded: true,
                    items: totalDropdownItems.map((range) {
                      return DropdownMenuItem<String>(
                        value: range,
                        child: Text(range),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val == 'Custom Range') {
                        _showDateRangeDialog(context);
                      } else {
                        _onPredefinedRangeSelected(val);
                      }
                    },
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              /// Set DateTime button (sabitle)
              ElevatedButton.icon(
                onPressed: () {
                  if (_rangeStart != null && _rangeEnd != null) {
                    widget.onFilterChanged(_rangeStart, _rangeEnd, _selectedActivityType,selectedBaby?.babyID);
                  }
                },
                icon: Icon(Icons.filter_alt_outlined, size: 16.sp),
                label: Text('Filter', style: TextStyle(fontSize: 12.sp)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  },
);
  }
}
