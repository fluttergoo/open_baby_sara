import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/app_router.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/theme/app_themes.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/auth/auth_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/caregiver/caregiver_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/invite_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/onboarding/welcome_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<BabyModel> babies = [];
  List<InviteModel> caregivers = [];

  @override
  void initState() {
    super.initState();
  }

  bool _isInitialized = false;
  String userFirstName = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      context.read<BabyBloc>().add(LoadBabies());
      context.read<CaregiverBloc>().add(GetCaregivers());
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSignOut) {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => WelcomePage()));
        }
        if (state is Authenticated) {
          userFirstName = state.userModel.firstName;
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            userFirstName = state.userModel.firstName;
          }

          return BlocBuilder<CaregiverBloc, CaregiverState>(
            builder: (context, state) {
              if (state is GetCaregiverList) {
                caregivers = state.caregiverList;
              }
              return Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Welcome
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Welcome, ',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.headlineLarge,
                                      ),
                                      Text(
                                        capitalize(userFirstName),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineLarge?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: AppThemes.girlTheme.primaryColor,
                                ),

                                /// Baby Section
                                SizedBox(height: 10.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Baby Info',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                        minimumSize: Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.addBaby,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'Add Baby',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall!.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                BlocBuilder<BabyBloc, BabyState>(
                                  builder: (context, state) {
                                    if (state is BabyLoaded) {
                                      babies = state.babies;
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: babies.length,
                                      itemBuilder: (context, index) {
                                        final baby = babies[index];
                                        return _buildInfoCard(
                                          title: baby.firstName,
                                          icon:
                                              Icons
                                                  .baby_changing_station_outlined,
                                          trailingText: 'Settings',
                                          onTap: () {
                                            String babyID = baby.babyID;
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.editBaby,
                                              arguments: babyID,
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),

                                /// Caregiver Section
                                SizedBox(height: 20.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Caregivers',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                        minimumSize: Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.addCaregiver,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'Add Caregiver',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall!.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),

                                caregivers.isNotEmpty
                                    ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: caregivers.length,
                                      itemBuilder: (context, index) {
                                        final caregiver = caregivers[index];
                                        return _buildInfoCard(
                                          title: caregiver.firstName,
                                          icon: Icons.person_outline,
                                          trailingText: 'caregiver',
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              AppRoutes.caregiverEdit,
                                              arguments: {
                                                'caregiverID':
                                                    caregiver.caregiverID,
                                                'caregiverName':
                                                    caregiver.firstName,
                                              },
                                            );
                                          },
                                        );
                                      },
                                    )
                                    : ListTile(
                                      leading: Icon(
                                        Icons.add_outlined,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      title: Text(
                                        'You haven\'t added any caregivers yet.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontSize: 14.sp),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.addCaregiver,
                                        );
                                      },
                                    ),
                                //_buildCaregiversCard(),

                                /// Settings
                                SizedBox(height: 20.h),
                                Text(
                                  'Settings',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                ListTile(
                                  leading: Icon(Icons.settings_outlined),
                                  title: Text(
                                    'My Account',
                                    style:
                                        Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                                  ),
                                  trailing: Icon(
                                    Icons.keyboard_arrow_right_outlined,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(AppRoutes.myAccount);
                                  },
                                ),

                                /// Share & More
                                SizedBox(height: 20.h),
                                Text(
                                  'Share and More',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                ListTile(
                                  leading: Icon(Icons.share_outlined),
                                  title: Text(
                                    'Share Sara Baby with Your Friends',
                                    style:
                                        Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                                  ),
                                  onTap: () {},
                                ),
                                ListTile(
                                  leading: Icon(Icons.star_border_outlined),
                                  title: Text(
                                    'Rate Sara Baby on the App Store',style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                                  ),
                                  onTap: () {},
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.logout_outlined,
                                    color: Colors.redAccent,
                                  ),
                                  title: Text(
                                    'LogOut!',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                                  ),
                                  onTap: () {
                                    _onPressedSignOut();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// Footer
                        Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Center(
                            child: Text(
                              '© 2025 Sara Baby',
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 16.sp),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings_outlined, size: 16.sp,),
            SizedBox(width: 4),
            Text(trailingText, style: Theme.of(context).textTheme.titleSmall,),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _onPressedSignOut() {
    context.read<AuthBloc>().add(SignOut());
  }

  /// Converts the input [string] so that the first letter is uppercase
  /// and the remaining letters are lowercase.
  String capitalize(String input) {
    if (input.isEmpty) return '';
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}
