import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/caregiver/caregiver_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditCaregiverPage extends StatefulWidget {
  final String caregiverID;
  final String caregiverName;

  const EditCaregiverPage({
    super.key,
    required this.caregiverID,
    required this.caregiverName,
  });

  @override
  State<EditCaregiverPage> createState() => _EditCaregiverPageState();
}

class _EditCaregiverPageState extends State<EditCaregiverPage> {
  @override
  void initState() {
    firstNameController.text = widget.caregiverName;
    super.initState();
  }

  TextEditingController firstNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Caregiver Details',
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: Colors.deepPurpleAccent),
        ),
        iconTheme: IconThemeData(color: Colors.purple),
        elevation: 2,
      ),
      body: BlocListener<CaregiverBloc, CaregiverState>(
  listener: (context, state) {
    if (state is CaregiverDeleted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(buildCustomSnackBar(state.message));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => NavigationWrapper()),
      );
    }  },
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /// Caregiver First Name
                    RichText(
                      text: TextSpan(
                        text: 'Caregiver First Name:',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
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

                    ///Delete Button
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          _onPressedDelete();
                        },

                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 40.h),
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),
                    Text(
                      'Removing this caregiver will revoke their access to your family. They will no longer be able to view baby-related data.',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.grey.shade700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
),
    );
  }

  void _onPressedDelete() {
    context.read<CaregiverBloc>().add(
      DeleteCaregiver(caregiverID: widget.caregiverID),
    );
  }
}
