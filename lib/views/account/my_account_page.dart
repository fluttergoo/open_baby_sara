import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/app/routes/app_router.dart';
import 'package:open_baby_sara/blocs/auth/auth_bloc.dart';
import 'package:open_baby_sara/widgets/custom_show_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('my_account'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: Colors.deepPurpleAccent),
        ),
        iconTheme: IconThemeData(color: Colors.purple),
        elevation: 2,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
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
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        context.tr('change_password'),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                      ),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.changePassword);
                      },
                    ),
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: 0.8,
                      height: 10,
                    ),
                    ListTile(
                      title: Text(
                        context.tr('faq_title'),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                      ),

                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.faq);
                      },
                    ),
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: 0.8,
                      height: 10,
                    ),
                    ListTile(
                      title: Text(
                        context.tr('language_settings'),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                      ),
                      trailing: Icon(Icons.language_outlined, size: 16.sp),

                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.languageSettings);
                      },
                    ),
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: 0.8,
                      height: 10,
                    ),
                    ListTile(
                      title: Text(
                        context.tr('contact_us'),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                      ),
                      trailing: Text(
                        'support@sarababy.app',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      onTap: () {},
                    ),
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: 0.8,
                      height: 10,
                    ),
                    ListTile(
                      title: Text(
                        context.tr('version'),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                      ),
                      trailing: Text(
                        '1.0.0,',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      onTap: () {},
                    ),
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: 0.8,
                      height: 10,
                    ),
                    ListTile(
                      title: Text(
                        context.tr('legal_title'),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.legalPage);
                      },
                    ),
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: 0.8,
                      height: 10,
                    ),
                    ListTile(
                      title: Text(
                        context.tr('delete_account'),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontSize: 16.sp,
                          color: Colors.redAccent,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return buildCustomAlertDialog(
                              context: context,
                              cancelButtonTap: () {
                                Navigator.of(context).pop();
                              },
                              yesButtonTap: () {
                                context.read<AuthBloc>().add(DeleteUser());
                              },
                            );
                          },
                        );
                      },
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
