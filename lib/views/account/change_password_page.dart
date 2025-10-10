import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/app/routes/navigation_wrapper.dart';
import 'package:open_baby_sara/blocs/auth/auth_bloc.dart';
import 'package:open_baby_sara/widgets/build_custom_snack_bar.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr("Change Password"),
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: Colors.deepPurpleAccent),
        ),
        iconTheme: IconThemeData(color: Colors.purple),
        elevation: 2,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordChanged) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(buildCustomSnackBar(state.message));
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => NavigationWrapper()),
          );
        },
        child: BlocBuilder<AuthBloc, AuthState>(
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
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Text(
                            context.tr("change_password_description"),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

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
                                      : context.tr("passwords_do_not_match"),
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: double.infinity,
                          height: 45.h,
                          child: ElevatedButton(
                            onPressed: () {
                              _onPressedSave();
                            },
                            child: Text(
                              context.tr("save"),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('passwords_do_not_match'))),
        );
        return;
      } else {
        context.read<AuthBloc>().add(
          ChangePassword(password: _passwordController.text),
        );
      }
    } else {
      return;
    }
  }
}
