import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/auth/auth_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/baby_sign_up_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/sign_in_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('passwords_do_not_match'))),
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
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('successfully_you_created'),
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                margin: EdgeInsets.all(16.r),
                duration: const Duration(seconds: 3),
              ),
            );
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => BabySignUpPage()));
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFFFF9C4), Color(0xFFFFE0B2), Color(0xFFFFCDD2)],
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
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: size.width * 0.85,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(15.r),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.tr("create_an_account"),
                                  style: Theme.of(context).textTheme.titleLarge
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  context.tr("lets_sign_up"),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 20.h),
                                CustomTextFormField(
                                  hintText: context.tr("first_name"),
                                  controller: _firstNameController,
                                  isPassword: false,
                                  validator: (value) => value == null || value.isEmpty ? context.tr("required") : null,
                                ),
                                SizedBox(height: 7.h),
                                CustomTextFormField(
                                  hintText: "Email",
                                  controller: _emailController,
                                  isPassword: false,
                                  validator: (value) =>
                                  value != null && value.contains('@') ? null : context.tr("invalid_email"),
                                ),
                                SizedBox(height: 7.h),
                                CustomTextFormField(
                                  hintText: context.tr("password"),
                                  controller: _passwordController,
                                  isPassword: true,
                                  validator: (value) =>
                                  value != null && value.length > 5 ? null : context.tr("min_6_characters"),
                                ),
                                SizedBox(height: 7.h),
                                CustomTextFormField(
                                  hintText: context.tr("confirm_password"),
                                  controller: _confirmPasswordController,
                                  isPassword: true,
                                  validator: (value) =>
                                  value == _passwordController.text ? null : context.tr("passwords_do_not_match"),
                                ),
                                SizedBox(height: 20.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 45.h,
                                  child: ElevatedButton(
                                    onPressed: state is AuthLoading ? null : () => _onSignUpPressed(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                    ),
                                    child: state is AuthLoading
                                        ? CircularProgressIndicator(color: Colors.white)
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
                                      MaterialPageRoute(builder: (context) => const SignInPage()),
                                    );
                                  },
                                  child: Text(
                                    context.tr("already_have_an_account_sign_in"),
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

                // Footer logo
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    width: 75.w,
                    height: 75.h,
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
