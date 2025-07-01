import 'package:flutter/material.dart';
import 'package:open_baby_sara/widgets/custom_date_time_picker.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
import 'package:open_baby_sara/widgets/formula_breastmilk_selector.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottlerFeedTracker extends StatefulWidget {
  const CustomBottlerFeedTracker({super.key});

  @override
  State<CustomBottlerFeedTracker> createState() => _CustomBottlerFeedTrackerState();
}

class _CustomBottlerFeedTrackerState extends State<CustomBottlerFeedTracker> {
  String selectedMainActivity='';
  DateTime selectedDatetime=DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.only(
          left: 16.r,
          right: 16.r,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 16,
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/widgets/build_custom_snack_bar.dart';
import 'package:open_baby_sara/widgets/custom_bottle_feed_tracker.dart';
import 'package:open_baby_sara/widgets/custom_date_time_picker.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
import 'package:open_baby_sara/widgets/formula_breastmilk_selector.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class CustomFeedTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;

  const CustomFeedTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
  });

  @override
  State<CustomFeedTrackerBottomSheet> createState() =>
      _CustomFeedTrackerBottomSheetState();
}

class _CustomFeedTrackerBottomSheetState
    extends State<CustomFeedTrackerBottomSheet>
    with SingleTickerProviderStateMixin {
  TextEditingController notesController = TextEditingController();
  late final TabController _tabController;
  String selectedMainActivity = '';
  DateTime selectedDatetime = DateTime.now();
  final FocusNode _amountFocusNode = FocusNode();
  final TextEditingController _amountController = TextEditingController();
  String _selectedUnit = 'oz';

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityBloc, ActivityState>(
      listener: (context, state) {
        if (state is ActivityAdded) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(buildCustomSnackBar(state.message));
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),

        child: Container(
          height: 600.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.r,
                    vertical: 12.r,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.feedColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.arrow_back, color: Colors.deepPurple),
                      ),
                      Text(
                        'Feed Tracker',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: onPressedSave,
                        child: Text(
                          'Save',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TabBar.secondary(
                  controller: _tabController,

                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                  indicatorColor: Colors.deepPurple,
                  tabs: const <Widget>[
                    Tab(text: 'Breastfeed'),
                    Tab(text: 'Bottle Feed'),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    physics: BouncingScrollPhysics(),
                    controller: _tabController,
                    children: <Widget>[
                      customBottlerFeedTracker(),
                      customBottlerFeedTracker(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onPressedSave() {}

  _onPressedDelete(BuildContext context) async {}

  Widget customBottlerFeedTracker() {
    return KeyboardActions(
      config: _buildKeyboardConfig(context),
      child: FocusScope(
        node: FocusScopeNode(),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.r,
            right: 16.r,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Time'),
                  CustomDateTimePicker(
                    initialText: 'initialText',
                    onDateTimeSelected: (selected) {
                      selectedDatetime = selected;
                    },
                  ),
                ],
              ),
              Divider(color: Colors.grey.shade300),
              FormulaBreastmilkSelector(
                onChanged: (selectedValue) {
                  setState(() {
                    selectedMainActivity = selectedValue;
                  });
                },
              ),
              Divider(color: Colors.grey.shade300),
              Text('Amount'),
              TextFormField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  suffixText: _selectedUnit,
                ),
              ),
              SizedBox(height: 10.h),
              Text('Notes:', style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.sp)),
              CustomTextFormField(
                hintText: '',
                isNotes: true,
                controller: notesController,
              ),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  'Created by ${widget.firstName}',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: () => _onPressedDelete(context),
                child: Text(
                  'Reset',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  KeyboardActionsConfig _buildKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardBarColor: Colors.grey.shade100,
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      actions: [
        KeyboardActionsItem(
          focusNode: _amountFocusNode,
          toolbarButtons: [
            (node) {
              return Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedUnit = 'oz';
                      });
                    },
                    child: Text('oz'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedUnit = 'lb';
                      });
                    },
                    child: Text('lb'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      node.unfocus();
                    },
                    child: Text('Done'),
                  ),
                ],
              );
            },
          ],
        ),
      ],
    );
  }
}


 */
