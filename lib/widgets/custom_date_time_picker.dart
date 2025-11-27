import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CustomDateTimePicker extends StatefulWidget {
  final String initialText;
  final Function(DateTime) onDateTimeSelected;
  final DateTime? initialDateTime;
  final bool enabled;
  final DateTime? maxDate;
  final DateTime? minDate;

  const CustomDateTimePicker({
    super.key,
    required this.initialText,
    required this.onDateTimeSelected,
    this.initialDateTime,
    this.enabled = true,
    this.maxDate,
    this.minDate,
  });

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  DateTime? selectedDateTime;
  String? displayText;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
    displayText = selectedDateTime != null
        ? formatDateTime(selectedDateTime!)
        : null;
  }

  @override
  void didUpdateWidget(CustomDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDateTime != oldWidget.initialDateTime) {
      setState(() {
        selectedDateTime = widget.initialDateTime;
        displayText = selectedDateTime != null
            ? formatDateTime(selectedDateTime!)
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.enabled ? () {
        // currentTime'ı belirle - minDate varsa ve currentTime minDate'den önceyse, minDate'i kullan
        DateTime currentTime = selectedDateTime ?? DateTime.now();
        if (widget.minDate != null && currentTime.isBefore(widget.minDate!)) {
          currentTime = widget.minDate!;
        }
        // maxDate varsa ve currentTime maxDate'den sonraysa, maxDate'i kullan
        if (widget.maxDate != null && currentTime.isAfter(widget.maxDate!)) {
          currentTime = widget.maxDate!;
        }
        
        DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onConfirm: (date) {
            setState(() {
              selectedDateTime = date;
              displayText = formatDateTime(date);
            });

            widget.onDateTimeSelected(date);
          },
          currentTime: currentTime,
          maxTime: widget.maxDate,
          minTime: widget.minDate,
        );
      } : null,
      child: Text(
        displayText ?? 'Add',
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: widget.enabled 
              ? Theme.of(context).primaryColor 
              : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String formatDateTime(DateTime datetime) {
    final now = DateTime.now();
    final isToday =
        datetime.day == now.day &&
        datetime.month == now.month &&
        datetime.year == now.year;

    final formattedHour = datetime.hour.toString().padLeft(2, '0');
    final formattedMinute = datetime.minute.toString().padLeft(2, '0');

    if (isToday) {
      return 'Today $formattedHour:$formattedMinute';
    } else {
      final formattedDate = DateFormat('MMMM d').format(datetime);
      return '$formattedDate $formattedHour:$formattedMinute';
    }
  }
}
