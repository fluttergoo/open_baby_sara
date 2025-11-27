import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service.dart';
import 'package:open_baby_sara/widgets/custom_show_flush_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_baby_sara/blocs/auth/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:open_baby_sara/views/auth/baby_sign_up_page.dart';
import 'package:open_baby_sara/views/auth/sign_in_page.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView('SignUpPage');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        showCustomFlushbar(
          context,
          context.tr('passwords_do_not_match'),
          '',
          Icons.warning_outlined,
        );
        return;
      }

      context.read<AuthBloc>().add(
        RegisterUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          firstname: _firstNameController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          /// If user registered successfully
          if (state is Authenticated) {
            showCustomFlushbar(
              context,
              context.tr('successfully_you_created'),
              context.tr('successfully_login'),
              Icons.check_circle_outline,
            );

            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => BabySignUpPage()));
          } else if (state is AuthFailure) {
            showCustomFlushbar(
              context,
              context.tr('error'),
              state.message,
              Icons.warning_outlined,
            );
          }
        },
        builder: (context, state) {
          return Container(
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
            child: Stack(
              children: [
                Positioned(
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
                Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: size.width * 0.85,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 24.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(15.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.tr("create_an_account"),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  context.tr("lets_sign_up"),
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 20.h),

                                // Google Sign-In Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50.h,
                                  child: ElevatedButton(
                                    onPressed: state is AuthLoading
                                        ? null
                                        : () {
                                            debugPrint('Google Sign-In button pressed');
                                            context.read<AuthBloc>().add(
                                                  SignInWithGoogle(),
                                                );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        side: const BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/google.png',
                                          width: 24.sp,
                                          height: 24.sp,
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          context.tr("continue_with_google") ??
                                              'Continue with Google',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                      ),
                                      child: Text(
                                        context.tr("or"),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium?.copyWith(
                                              color: Colors.grey.shade600,
                                              fontSize: 14.sp,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                CustomTextFormField(
                                  hintText: context.tr("first_name"),
                                  controller: _firstNameController,
                                  isPassword: false,
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? context.tr("required")
                                              : null,
                                ),
                                SizedBox(height: 7.h),
                                CustomTextFormField(
                                  hintText: "Email",
                                  controller: _emailController,
                                  isPassword: false,
                                  validator:
                                      (value) =>
                                          value != null && value.contains('@')
                                              ? null
                                              : context.tr("invalid_email"),
                                ),
                                SizedBox(height: 7.h),
                                CustomTextFormField(
                                  hintText: context.tr("password"),
                                  controller: _passwordController,
                                  isPassword: true,
                                  validator:
                                      (value) =>
                                          value != null && value.length > 5
                                              ? null
                                              : context.tr("min_6_characters"),
                                ),
                                SizedBox(height: 7.h),
                                CustomTextFormField(
                                  hintText: context.tr("confirm_password"),
                                  controller: _confirmPasswordController,
                                  isPassword: true,
                                  validator:
                                      (value) =>
                                          value == _passwordController.text
                                              ? null
                                              : context.tr(
                                                "passwords_do_not_match",
                                              ),
                                ),
                                SizedBox(height: 20.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 45.h,
                                  child: ElevatedButton(
                                    onPressed:
                                        state is AuthLoading
                                            ? null
                                            : () => _onSignUpPressed(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    child:
                                        state is AuthLoading
                                            ? CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                            : Text(
                                              context.tr("sign_up"),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const SignInPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    context.tr(
                                      "already_have_an_account_sign_in",
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontSize: 16.sp,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Stroller
                        Positioned(
                          top: -100,
                          right: -50,
                          child: Image.asset(
                            'assets/images/stroller.png',
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
