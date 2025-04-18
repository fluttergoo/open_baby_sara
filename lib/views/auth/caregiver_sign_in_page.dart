import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/app_router.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/caregiver/caregiver_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/sign_in_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CaregiverSignInPage extends StatefulWidget {
  const CaregiverSignInPage({super.key});

  @override
  State<CaregiverSignInPage> createState() => _CaregiverSignInPageState();
}

class _CaregiverSignInPageState extends State<CaregiverSignInPage> {
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();

  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CaregiverBloc, CaregiverState>(
  listener: (context, state) {
    if (state is CaregiverSignedUp) {
      ScaffoldMessenger.of(context).showSnackBar(buildCustomSnackBar(state.message));
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>NavigationWrapper()));
    }
  },
  child: BlocBuilder<CaregiverBloc, CaregiverState>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFFFF9C4),
                  Color(0xFFFFE0B2),
                  Color(0xFFFFCDD2),
                ],
              ),
            ),
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Column(
                children: [
                  Positioned(
                    child: Positioned(
                      top: -30.sp,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/images/cloud.png',
                        fit: BoxFit.fitWidth,
                        width: 1.sw,
                        height: 150.h,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            "Join a Family",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            'To join a family, use the email address you were invited with',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              color: Colors.grey.shade700,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                CustomTextFormField(
                                  hintText: context.tr("first_name"),
                                  isPassword: false,
                                  controller: _firstNameController,
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? context.tr("required")
                                              : null,
                                ),
                                SizedBox(height: 7.h),
                                CustomTextFormField(
                                  hintText: 'Email',
                                  isPassword: false,
                                  controller: _emailController,
                                  validator:
                                      (value) =>
                                          value != null && value.contains('@')
                                              ? null
                                              : context.tr("invalid_email"),
                                ),
                                SizedBox(height: 7.h),
                                CustomTextFormField(
                                  hintText: context.tr("password"),
                                  isPassword: true,
                                  controller: _passwordController,
                                  validator:
                                      (value) =>
                                          value != null && value.length > 5
                                              ? null
                                              : context.tr("min_6_characters"),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _onPressedSignIn();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 40.h),
                            ),
                            child: Text(
                              "Join Family",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          SizedBox(height: 20.h),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SignInPage(),
                                ),
                              );
                            },
                            child: Text(
                              context.tr("already_have_an_account_sign_in"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
);
  }

  void _onPressedSignIn() {
    context.read<CaregiverBloc>().add(
      CaregiverSignUp(
        firstName: _firstNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
