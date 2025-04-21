import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/app_router.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/auth/auth_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/sign_up_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _onSignInPressed(BuildContext context){
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SignInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text));
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
            context.read<AuthBloc>().add(GetUserModel());
            Navigator.pushReplacementNamed(context, AppRoutes.home);
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
              height: size.height,
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
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: size.width * 0.85,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    //color: Colors.white,
                                    color: Color(0xFFFFF8E1),

                                    borderRadius: BorderRadius.circular(15.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        context.tr("sign_in"),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                      ),
                                      SizedBox(height: 20.h),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          minimumSize: Size(
                                            double.infinity,
                                            50,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/google.png',
                                              width: 24.sp,
                                              height: 24.sp,
                                            ),
                                            SizedBox(width: 70.w),
                                            Text(
                                              'Google',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              thickness: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                            ),
                                            child: Text(
                                              context.tr("or"),
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              thickness: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),

                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            CustomTextFormField(
                                              hintText: 'Email',
                                              isPassword: false,
                                              controller: _emailController,
                                              validator:
                                                  (value) =>
                                                      value != null &&
                                                              value.contains(
                                                                '@',
                                                              )
                                                          ? null
                                                          : context.tr(
                                                            "invalid_email",
                                                          ),
                                            ),
                                            SizedBox(height: 7.h),
                                            CustomTextFormField(
                                              hintText: context.tr("password"),
                                              isPassword: true,
                                              controller: _passwordController,
                                              validator:
                                                  (value) =>
                                                      value != null &&
                                                              value.length > 5
                                                          ? null
                                                          : context.tr(
                                                            "min_6_characters",
                                                          ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            context.tr("forgot_password"),
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12.sp,color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      ElevatedButton(
                                        onPressed: state is AuthLoading
                                            ? null
                                            : () => _onSignInPressed(context),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(
                                            double.infinity,
                                            40.h,
                                          ),
                                        ),
                                        child: Text(
                                          context.tr("sign_in"),
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
                                              builder:
                                                  (context) => SignUpPage(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          context.tr("have_an_account",),
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900, fontSize: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 🍼 Bottle - Positioned top right
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
                          ],
                        ),
                      ),
                    ),
                  ),
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
            ),
          );
        },
      ),
    );
  }
}
