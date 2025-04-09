import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/auth/auth_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/baby_sign_up_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/sign_in_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          SnackBar(content: Text(context.tr('password_do_not_match'))),
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
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
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => BabySignUpPage()));
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Container(
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
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 40.h),
                            Text(
                              context.tr("create_an_account"),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            SizedBox(height: 40.h),
                            Text(
                              context.tr("lets_sign_up"),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            SizedBox(height: 7.h),
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
                            SizedBox(height: 7.h),
                            CustomTextFormField(
                              hintText: context.tr("confirm_password"),
                              isPassword: true,
                              controller: _confirmPasswordController,
                              validator:
                                  (value) =>
                                      value == _passwordController.text
                                          ? null
                                          : context.tr("passwords_do_not_match"),
                            ),
                            SizedBox(height: 15.h),
                            ElevatedButton(
                              onPressed:
                                  state is AuthLoading
                                      ? null
                                      : () => _onSignUpPressed(context),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 40.h),
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
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                            ),
                            SizedBox(height: 10.h),
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
}
