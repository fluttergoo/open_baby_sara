import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/blocs/vaccination/vaccination_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/widgets/custom_check_box_tile.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showDialogAddAndVaccination({
  required BuildContext buildContext,
  required Function(List<String>? vaccinations) onAdd,
}) {
  TextEditingController addMedicationController = TextEditingController();
  final List<String> selectedVaccinationNames = [];

  return showDialog(
    context: buildContext,
    builder: (context) {
      return BlocBuilder<VaccinationBloc, VaccinationState>(
        builder: (context, state) {
          List<String> vaccinations =
              state is VaccinationLoaded && state.vaccinationList != null
                  ? state.vaccinationList
                  : [];
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Container(
                  //padding: EdgeInsets.all(16.r),
                  constraints: BoxConstraints(maxHeight: 600.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //header
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.r,
                          vertical: 12.r,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.vaccineColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Vaccinations',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final selectedVacs =
                                    vaccinations
                                        .where(
                                          (e) => selectedVaccinationNames
                                              .contains(e),
                                        )
                                        .toList();
                                onAdd(selectedVacs);
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Save',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.only(
                            left: 16.r,
                            right: 16.r,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 20,
                            top: 16,
                          ),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    hintText: 'Add a Vaccination',
                                    isNotes: true,
                                    controller: addMedicationController,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final text =
                                        addMedicationController.text.trim();
                                    if (text.isNotEmpty) {
                                      context.read<VaccinationBloc>().add(
                                        InsertVaccination(
                                          vaccinationName: text,
                                        ),
                                      );
                                      addMedicationController.clear();
                                    }
                                  },
                                  child: Text('Add'),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey.shade300),
                            Center(
                              child: Text(
                                'Vaccinations You’ve Added',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (vaccinations.isEmpty) ...[
                              SizedBox(height: 16.h),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.medication_outlined,
                                      size: 48.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'No vaccination yet.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Add one using the field above.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              ...vaccinations.map((med) {
                                final isSelected = selectedVaccinationNames
                                    .contains(med);
                                return Row(
                                  children: [
                                    Expanded(
                                      child: customCheckboxTile(
                                        label: med,
                                        value: isSelected,
                                        onChanged: (val) {
                                          setState(() {
                                            if (val) {
                                              selectedVaccinationNames.add(
                                                med,
                                              );
                                            } else {
                                              selectedVaccinationNames.remove(
                                                med,
                                              );
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (_) => AlertDialog(
                                                title: Text(
                                                  'Delete Vaccination',
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium,
                                                ),
                                                content: Text(
                                                  'Are you sure you want to delete "$med"?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      context
                                                          .read<
                                                            VaccinationBloc
                                                          >()
                                                          .add(
                                                            DeleteVaccination(vaccination: med)
                                                          );
                                                      selectedVaccinationNames
                                                          .remove(med);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                            SizedBox(height: 40.h),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  'Add a medication above, then select it below to include it in the activity.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
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
              );
            },
          );
        },
      );
    },
  );
}
