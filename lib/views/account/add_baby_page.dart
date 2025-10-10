import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/app/routes/navigation_wrapper.dart';
import 'package:open_baby_sara/blocs/baby/baby_bloc.dart';
import 'package:open_baby_sara/core/constant/message_constants.dart';
import 'package:open_baby_sara/widgets/custom_avatar.dart';
import 'package:open_baby_sara/widgets/custom_birthdate_picker.dart';
import 'package:open_baby_sara/widgets/custom_gender_selector.dart';
import 'package:open_baby_sara/widgets/build_custom_snack_bar.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gender_picker/source/enums.dart';
import 'package:image_picker/image_picker.dart';

class AddBabyPage extends StatefulWidget {
  const AddBabyPage({super.key});

  @override
  State<AddBabyPage> createState() => _EditBabyPageState();
}

class _EditBabyPageState extends State<AddBabyPage> {
  @override
  void initState() {
    super.initState();
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
  File? newFile;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('add_baby'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: Colors.deepPurpleAccent),
        ),
        iconTheme: IconThemeData(color: Colors.purple),
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
                  if (state is onGenderSelectedState) {
                    //TODO: BLoC listener, consumer, builder,
                    setState(() {
                      babyGenderGenerate = state.newGender;
                    });
                  } else if (state is GotBabyInfo) {
                    setState(() {
                      imgUrl = state.babyModel.imageUrl;
                    });
                  }
                  if (state is AddedBaby) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(buildCustomSnackBar(state.message));
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => NavigationWrapper()),
                    );
                  }
                },
                child: BlocBuilder<BabyBloc, BabyState>(
                  builder: (context, state) {
                    String? imagePath;
                    if (state is BabyImagePathLoaded) {
                      imagePath = state.imagePath;
                    }

                    /// Edit Profile
                    return Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: CustomAvatar(
                                  imagePath: imagePath,
                                  onTap: () {
                                    _getFileImage();
                                  },
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  context.tr('tap_to_upload_your_baby_photo'),
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
                                  text: context.tr('first_name:'),
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
                                  text: context.tr('birthday:'),
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
                                  context.tr('nighttime_hours'),
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
                                  text: context.tr('gender'),
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
                              SizedBox(height: 10.h),

                              // Save Button
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _onPressedSave();
                                  },

                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 40.h),
                                    backgroundColor: Colors.pinkAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    context.tr("save"),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  /// Convert a [Gender] enum into a [String] for saving to Firestore
  ///
  /// This helpful because Firestore does not support enum types directly.
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

  /// Sets nighttime range and defines the related variables.
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

  Future<File?> _getFileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;
    setState(() {
      newFile = File(pickedFile.path);
    });
  }

  void _onPressedSave() {
    if (_formKey.currentState!.validate()) {
      nightStart ??= const TimeOfDay(hour: 20, minute: 0);
      nightEnd ??= const TimeOfDay(hour: 7, minute: 0);

      final newNighttimeHours = {
        'from':
            '${nightStart!.hour}:${nightStart!.minute.toString().padLeft(2, '0')}',
        'to':
            '${nightEnd!.hour}:${nightEnd!.minute.toString().padLeft(2, '0')}',
      };
      final parsedDate = DateFormat('M/d/yyyy').parse(babyDOBController.text);

      //TODO: Check duplicated code
      if (newFile != null) {
        context.read<BabyBloc>().add(
          AddBaby(
            firstName: firstNameController.text.trim(),
            gender: getGenderString(babyGenderGenerate),
            dateTime: parsedDate,
            nighttimeHours: newNighttimeHours,
            file: newFile!,
          ),
        );
      } else {
        context.read<BabyBloc>().add(
          AddBaby(
            firstName: firstNameController.text.trim(),
            gender: getGenderString(babyGenderGenerate),
            dateTime: parsedDate,
            nighttimeHours: newNighttimeHours,
          ),
        );
      }
      //TODO: Check if you not validated put first
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        buildCustomSnackBar(
          MessageConstants.requiredFields,
          icon: Icons.warning_amber_outlined,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
