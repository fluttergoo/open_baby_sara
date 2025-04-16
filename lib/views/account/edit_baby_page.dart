import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/constant/message_constants.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_avatar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_birthdate_picker.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_gender_selector.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_dialog.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gender_picker/source/enums.dart';

class EditBabyPage extends StatefulWidget {
  final String babyID;

  const EditBabyPage({super.key, required this.babyID});

  @override
  State<EditBabyPage> createState() => _EditBabyPageState();
}

class _EditBabyPageState extends State<EditBabyPage> {
  @override
  void initState() {
    super.initState();
    context.read<BabyBloc>().add(GetBabyInfo(babyID: widget.babyID));
  }

  TextEditingController firstNameController = TextEditingController();
  TextEditingController babyDOBController = TextEditingController();

  String babyGender = '';
  DateTime babyDOB = DateTime.now();
  Gender babyGenderGenerate = Gender.Male;
  String? imgUrl;
  TimeOfDay? nightStart;
  TimeOfDay? nightEnd;
  String nightStartText = '20:00';
  String nightEndText = '07:00';
  String userID = '';
  BabyModel? previousBaby;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Baby Details',
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: Colors.deepPurpleAccent),
        ),
        iconTheme: IconThemeData(color: Colors.purple),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _updatedBaby();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: Text(
                'Save',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        elevation: 2,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6E8), Color(0xFFF6F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: BlocListener<BabyBloc, BabyState>(
                listener: (context, state) {
                  if (state is BabyDeleted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(buildCustomSnackBar(state.message));
                  }
                  if (state is onGenderSelectedState) {
                    setState(() {
                      babyGenderGenerate = state.newGender;
                    });
                  } else if (state is GotBabyInfo) {
                    setState(() {
                      imgUrl = state.babyModel.imageUrl;
                    });
                  }

                  if (state is GotBabyInfo) {
                    setState(() {
                      final from = state.babyModel.nighttimeHours?['from'];
                      final to = state.babyModel.nighttimeHours?['to'];

                      if (from != null && from.contains(':')) {
                        final parts = from.split(':');
                        nightStart = TimeOfDay(
                          hour: int.parse(parts[0]),
                          minute: int.parse(parts[1]),
                        );
                        nightStartText = from;
                      }

                      if (to != null && to.contains(':')) {
                        final parts = to.split(':');
                        nightEnd = TimeOfDay(
                          hour: int.parse(parts[0]),
                          minute: int.parse(parts[1]),
                        );
                        nightEndText = to;
                      }

                      imgUrl = state.babyModel.imageUrl;
                      userID = state.babyModel.userID;
                      babyDOBController.text = DateFormat(
                        'M/d/yyyy',
                      ).format(state.babyModel.dateTime);
                      firstNameController.text = state.babyModel.firstName;
                      babyGenderGenerate = _onSetGender(state.babyModel.gender);
                      previousBaby = state.babyModel;
                    });
                  }
                  if (state is BabyUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      buildCustomSnackBar(MessageConstants.updateSuccess),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => NavigationWrapper()),
                    );
                  }
                },
                child: BlocBuilder<BabyBloc, BabyState>(
                  builder: (context, state) {
                    /// Edit Profile
                    return Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Circle Avatar --- Upload Baby Image
                              Align(
                                alignment: Alignment.center,
                                child: CustomAvatar(
                                  onTap: () {
                                    context.read<BabyBloc>().add(
                                      UploadBabyImage(babyID: widget.babyID),
                                    );

                                    if (state is GotBabyInfo) {
                                      imgUrl = state.babyModel.imageUrl;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        buildCustomSnackBar(
                                          MessageConstants.uploadSuccess,
                                        ),
                                      );
                                    }
                                  },
                                  imageUrl: imgUrl,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Tap to Upload Your Baby’s Photo',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),

                              // Baby First Name
                              RichText(
                                text: TextSpan(
                                  text: 'First Name:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              CustomTextFormField(
                                controller: firstNameController,
                                hintText: context.tr("baby_first_name"),
                                isPassword: false,
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? context.tr('required')
                                            : null,
                              ),
                              SizedBox(height: 10.h),

                              // Baby DOB
                              RichText(
                                text: TextSpan(
                                  text: 'Birthday:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              BirthdayField(controller: babyDOBController),
                              SizedBox(height: 10.h),

                              //SelectNightTimeRange
                              ListTile(
                                leading: Icon(
                                  Icons.bedtime_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  'Nighttime Hours',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                subtitle: Text(
                                  '$nightStartText - $nightEndText',
                                ),
                                trailing: Icon(Icons.edit),
                                onTap: () => _selectNighttimeRange(context),
                              ),
                              SizedBox(height: 10.h),

                              // Baby Gender
                              RichText(
                                text: TextSpan(
                                  text: 'Gender:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GenderSelector(
                                selectedGender: babyGenderGenerate,
                                onGenderSelected: (gender) {
                                  context.read<BabyBloc>().add(
                                    onGenderSelectedEvent(gender: gender!),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Or',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),

                        ListTile(
                          leading: Icon(
                            Icons.dashboard_customize_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(
                            'Customize Baby Activity',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          onTap: () {},
                        ),
                        SizedBox(height: 4.h),

                        ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Delete Baby',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(color: Colors.red),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return buildCustomAlertDialog(
                                  context: context,
                                  cancelButtonTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  yesButtonTap: () {
                                    _onPressedDeletedBaby();

                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => NavigationWrapper(),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectNighttimeRange(BuildContext context) async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: nightStart ?? TimeOfDay(hour: 20, minute: 0),
    );
    if (start == null) return;

    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: nightEnd ?? TimeOfDay(hour: 7, minute: 0),
    );
    if (end == null) return;
    setState(() {
      nightStart = start;
      nightEnd = end;
      nightStartText = start.format(context);
      nightEndText = end.format(context);
    });
  }

  void _updatedBaby() {
    if (_formKey.currentState!.validate() && previousBaby != null) {
      final updatedFields = <String, dynamic>{};

      // First Name
      if (firstNameController.text.trim() != previousBaby!.firstName) {
        updatedFields['firstName'] = firstNameController.text.trim();
      }

      // Gender
      final newGender = getGenderString(babyGenderGenerate);
      if (newGender != previousBaby!.gender) {
        updatedFields['gender'] = newGender;
      }

      // Birth Date
      final parsedDate = DateFormat('M/d/yyyy').parse(babyDOBController.text);
      if (parsedDate != previousBaby!.dateTime) {
        updatedFields['dateTime'] = parsedDate;
      }

      // Nighttime Hours
      final newNighttimeHours = {
        'from':
            nightStart != null
                ? '${nightStart!.hour}:${nightStart!.minute.toString().padLeft(2, '0')}'
                : previousBaby!.nighttimeHours?['from'] ?? '20:00',
        'to':
            nightEnd != null
                ? '${nightEnd!.hour}:${nightEnd!.minute.toString().padLeft(2, '0')}'
                : previousBaby!.nighttimeHours?['to'] ?? '07:00',
      };

      if (newNighttimeHours['from'] != previousBaby!.nighttimeHours?['from'] ||
          newNighttimeHours['to'] != previousBaby!.nighttimeHours?['to']) {
        updatedFields['nighttimeHours'] = newNighttimeHours;
      }

      // if have change, you will send
      if (updatedFields.isNotEmpty) {
        context.read<BabyBloc>().add(
          UpdatedBaby(babyID: widget.babyID, updatedFields: updatedFields),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("No changes detected")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        buildCustomSnackBar(
          MessageConstants.requiredFields,
          backgroundColor: Colors.red,
          icon: Icons.warning_outlined,
        ),
      );
    }
  }

  void _onPressedDeletedBaby() {
    context.read<BabyBloc>().add(DeletedBaby(babyID: widget.babyID));
  }

  Gender _onSetGender(String babyGender) {
    switch (babyGender) {
      case 'Female':
        return Gender.Female;
      case 'Male':
        return Gender.Male;
      case 'Other':
        return Gender.Others;
      default:
        return Gender.Others;
    }
  }

  String getGenderString(Gender? gender) {
    switch (gender) {
      case Gender.Male:
        return "Male";
      case Gender.Female:
        return "Female";
      case Gender.Others:
        return "Others";
      default:
        return "";
    }
  }
}
