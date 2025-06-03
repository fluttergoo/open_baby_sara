import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/caregiver/caregiver_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCaregiver extends StatefulWidget {
  const AddCaregiver({super.key});

  @override
  State<AddCaregiver> createState() => _AddCaregiverState();
}

class _AddCaregiverState extends State<AddCaregiver> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String userID = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('add_caregiver'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: Colors.deepPurpleAccent),
        ),
        iconTheme: IconThemeData(color: Colors.purple),
        elevation: 2,
      ),
      body: BlocListener<CaregiverBloc, CaregiverState>(
        listener: (context, state) {
          if (state is CaregiverAdded) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(buildCustomSnackBar(state.message));
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => NavigationWrapper()),
            );
          }
        },
        child: BlocBuilder<CaregiverBloc, CaregiverState>(
          builder: (context, state) {
            return Container(
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Information
                              Text(
                                context.tr('add_caregiver_page_body_info'),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(
                                  color: Colors.grey.shade700,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 16.h),

                              /// Caregiver First Name
                              RichText(
                                text: TextSpan(
                                  text: context.tr('caregiver_first_name'),
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
                                hintText: context.tr("first_name"),
                                isPassword: false,
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? context.tr('required')
                                            : null,
                              ),
                              SizedBox(height: 10.h),

                              /// Caregiver Email
                              RichText(
                                text: TextSpan(
                                  text: context.tr('caregiver_email:'),
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
                                controller: emailController,
                                hintText: 'Email',
                                isPassword: false,
                                validator:
                                    (value) =>
                                        value != null && value.contains('@')
                                            ? null
                                            : context.tr("invalid_email"),
                              ),
                              SizedBox(height: 10.h),

                              ///Save Button
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
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onPressedSave() {
    context.read<CaregiverBloc>().add(
      CreateCaregiver(
        firstName: firstNameController.text,
        email: emailController.text,
      ),
    );
  }
}
