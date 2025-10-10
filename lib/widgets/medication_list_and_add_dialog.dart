import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/blocs/medication/medication_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/data/models/medication_model.dart';
import 'package:open_baby_sara/widgets/custom_check_box_tile.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showMedicationDialog({
  required BuildContext buildContext,
  required Function(List<MedicationModel>? medications) onAdd,
}) {
  TextEditingController addMedicationController = TextEditingController();
  final List<String> selectedMedicationNames = [];

  return showDialog(
    context: buildContext,
    builder: (context) {
      return BlocBuilder<MedicationBloc, MedicationState>(
        builder: (context, state) {
          List<MedicationModel> medications =
              state is MedicationLoaded && state.medications != null
                  ? state.medications
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
                        height: 50.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.r,
                          vertical: 12.r,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.teethingColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Medications',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final selectedMeds =
                                    medications
                                        .where(
                                          (e) => selectedMedicationNames
                                              .contains(e.name),
                                        )
                                        .toList();
                                onAdd(selectedMeds);
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
                                    hintText: 'Add a Medication',
                                    isNotes: true,
                                    controller: addMedicationController,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final text =
                                        addMedicationController.text.trim();
                                    if (text.isNotEmpty) {
                                      context.read<MedicationBloc>().add(
                                        InsertMedication(
                                          medicationModel: MedicationModel(
                                            name: text,
                                          ),
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
                                'Medications You’ve Added',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (medications.isEmpty) ...[
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
                                      'No medications yet.',
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
                              ...medications.map((med) {
                                final isSelected = selectedMedicationNames
                                    .contains(med.name);
                                return Row(
                                  children: [
                                    Expanded(
                                      child: customCheckboxTile(
                                        label: med.name,
                                        value: isSelected,
                                        onChanged: (val) {
                                          setState(() {
                                            if (val) {
                                              selectedMedicationNames.add(
                                                med.name,
                                              );
                                            } else {
                                              selectedMedicationNames.remove(
                                                med.name,
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
                                                  'Delete Medication',
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium,
                                                ),
                                                content: Text(
                                                  'Are you sure you want to delete "${med.name}"?',
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
                                                            MedicationBloc
                                                          >()
                                                          .add(
                                                            DeleteMedication(
                                                              id: med.id!,
                                                            ),
                                                          );
                                                      selectedMedicationNames
                                                          .remove(med.name);
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
