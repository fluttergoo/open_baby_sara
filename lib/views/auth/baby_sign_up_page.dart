import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/request_notification_permission.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_birthdate_picker.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_gender_selector.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:gender_picker/source/enums.dart';
import 'package:intl/intl.dart';

class BabySignUpPage extends StatefulWidget {
  const BabySignUpPage({super.key});

  @override
  State<BabySignUpPage> createState() => _BabySignUpPageState();
}

class _BabySignUpPageState extends State<BabySignUpPage> {
  final List<Map<String, dynamic>> babies = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    addNewBaby();
  }

  void addNewBaby() {
    setState(() {
      babies.add({
        'nameController': TextEditingController(),
        'birthController': TextEditingController(),
        'gender': null,
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onRegisterBabyPressed(BuildContext context) {
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
    if (_formKey.currentState!.validate()) {
      final babiesData =
          babies.map((baby) {
            return {
              'name': baby['nameController'].text,
              'birthDate': baby['birthController'].text,
              'gender': baby['gender'],
            };
          }).toList();
      final dateFormat = DateFormat('d/M/yyyy');
      for (var baby in babiesData) {
        final parsedDate = dateFormat.parse(baby['birthDate']);
        context.read<BabyBloc>().add(
          RegisterBaby(
            firstName: baby['name'].toString(),
            gender: getGenderString(baby['gender']),
            dateTime: parsedDate,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BabyBloc, BabyState>(
      listener: (context, state) {
        if (state is BabySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline, // Success için uygun ikon
                    color: Colors.white,
                  ),
                  SizedBox(width: 10), // İkon ile metin arasına boşluk ekle
                  Expanded(
                    child: Text(
                      context.tr('successfully_you_created'),
                      style: TextStyle(
                        color: Colors.white, // Yazı rengi
                        fontSize: 16.sp, // Yazı boyutu
                        fontWeight: FontWeight.bold, // Yazı kalınlık
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Metin taşarsa '...' ekle
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              // SnackBar arka plan rengi
              behavior: SnackBarBehavior.floating,
              // SnackBar'ı ekranın üstünde sabit bırak
              shape: RoundedRectangleBorder(
                // Köşeleri yuvarla
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(16.r),
              // Kenar boşluğu
              duration: Duration(
                seconds: 3,
              ), // SnackBar'ın ne kadar süre görüneceği
            ),
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RequestNotificationPermission(),
            ),
          );
        } else if (state is BabyFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFFFF9C4),
                  Color(0xFFFFE0B2),
                  Color(0xFFFFCDD2),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          Text(
                            context.tr("you_are_almost_there"),
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            context.tr("lets_fill_in_your_baby_information"),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(height: 24.h),

                          ...babies.asMap().entries.map((entry) {
                            final index = entry.key;
                            final baby = entry.value;

                            return Card(
                              color: const Color(0xFFFFF8E1),
                              margin: EdgeInsets.only(bottom: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: EdgeInsets.all(16.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${context.tr("baby")} ${index + 1}',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.headlineSmall,
                                        ),
                                        if (index != 0)
                                          Row(
                                            children: [
                                              Text(
                                                context.tr("delete"),
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    babies.removeAt(index);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    CustomTextFormField(
                                      controller: baby['nameController'],
                                      hintText: context.tr("baby_first_name"),
                                      isPassword: false,
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? context.tr('required')
                                                  : null,
                                    ),
                                    SizedBox(height: 7.h),
                                    BirthdayField(
                                      controller: baby['birthController'],
                                    ),
                                    SizedBox(height: 7.h),
                                    GenderSelector(
                                      selectedGender: baby['gender'],
                                      onGenderSelected: (gender) {
                                        setState(() {
                                          baby['gender'] = gender;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          Align(
                            alignment: Alignment.center,
                            child: TextButton.icon(
                              onPressed: addNewBaby,
                              icon: const Icon(Icons.add_circle_outline),
                              label: Text(context.tr("add_another_baby")),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.pinkAccent,
                                textStyle: TextStyle(fontSize: 16.sp),
                              ),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          ElevatedButton(
                            onPressed:
                                state is BabyLoading
                                    ? null
                                    : () => _onRegisterBabyPressed(context),

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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
