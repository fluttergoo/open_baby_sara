import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/sign_in_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BabySignUpPage extends StatefulWidget {
  const BabySignUpPage({super.key});

  @override
  State<BabySignUpPage> createState() => _BabySignUpPageState();
}

class _BabySignUpPageState extends State<BabySignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFFFF9C4), Color(0xFFFFE0B2), Color(0xFFFFCDD2)],
          ),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
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
                            'You are Almost There! Your Account Is Being Created',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          SizedBox(height: 40.h),
                          Text(
                            'Let’s Fill in Your Baby’s Information',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(height: 7.h),
                          CustomTextFormField(
                            hintText: 'First Name',
                            isPassword: false,
                          ),
                          SizedBox(height: 7.h),
                          CustomTextFormField(
                            hintText: 'Email',
                            isPassword: false,
                          ),
                          SizedBox(height: 7.h),
                          CustomTextFormField(
                            hintText: 'Password',
                            isPassword: true,
                          ),
                          SizedBox(height: 7.h),
                          CustomTextFormField(
                            hintText: 'Confirm Password',
                            isPassword: true,
                          ),
                          SizedBox(height: 15.h),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text(
                              "Sign Up",
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
                              "Already have an account? Sign In",
                            ),
                          ),

                        ],
                      )

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
