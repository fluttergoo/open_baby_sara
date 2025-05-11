import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/app_router.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/theme/app_themes.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/breasfeed_left_side_timer/breasfeed_left_side_timer_bloc.dart'
    as leftBreastfeed;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/breastfeed_right_side_timer/breastfeed_right_side_timer_bloc.dart'
    as rightBreastfeed;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/pump_left_side_timer/pump_left_side_timer_bloc.dart'
    as leftPump;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/pump_right_side_timer/pump_right_side_timer_bloc.dart'
    as rightPump;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/pump_total_timer/pump_total_timer_bloc.dart'
    as totalPump;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/sleep_timer/sleep_timer_bloc.dart'
    as sleep;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/auth/auth_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/caregiver/caregiver_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/milestone/milestone_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/theme/theme_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/services/local_database/milestone_service.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/onboarding/welcome_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupLocator();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US')],
      path: 'lib/l10n',
      fallbackLocale: Locale('en', 'US'),
      child: ScreenUtilInit(
        designSize: Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return child!;
        },
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BabyBloc>(create: (_) => BabyBloc()..add(LoadBabies())),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
        BlocProvider<BottomNavBloc>(create: (_) => BottomNavBloc()),
        BlocProvider<CaregiverBloc>(create: (_) => CaregiverBloc()),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AppStarted()),
        ),

        BlocProvider<sleep.SleepTimerBloc>(
          create:
              (_) =>
                  sleep.SleepTimerBloc()..add(
                    sleep.LoadTimerFromLocalDatabase(
                      activityType: 'sleepTimer',
                    ),
                  ),
        ),
        BlocProvider<leftPump.PumpLeftSideTimerBloc>(
          create:
              (_) =>
                  leftPump.PumpLeftSideTimerBloc()..add(
                    leftPump.LoadTimerFromLocalDatabase(
                      activityType: 'leftPumpTimer',
                    ),
                  ),
        ),
        BlocProvider<rightPump.PumpRightSideTimerBloc>(
          create:
              (_) =>
                  rightPump.PumpRightSideTimerBloc()..add(
                    rightPump.LoadTimerFromLocalDatabase(
                      activityType: 'rightPumpTimer',
                    ),
                  ),
        ),
        BlocProvider<rightBreastfeed.BreastfeedRightSideTimerBloc>(
          create:
              (_) =>
                  rightBreastfeed.BreastfeedRightSideTimerBloc()..add(
                    rightBreastfeed.LoadTimerFromLocalDatabase(
                      activityType: 'rightBreastfeedTimer',
                    ),
                  ),
        ),
        BlocProvider<leftBreastfeed.BreasfeedLeftSideTimerBloc>(
          create:
              (_) =>
                  leftBreastfeed.BreasfeedLeftSideTimerBloc()..add(
                    leftBreastfeed.LoadTimerFromLocalDatabase(
                      activityType: 'leftBreastfeedTimer',
                    ),
                  ),
        ),

        BlocProvider<totalPump.PumpTotalTimerBloc>(
          create:
              (_) =>
                  totalPump.PumpTotalTimerBloc()..add(
                    totalPump.LoadTimerFromLocalDatabase(
                      activityType: 'pumpTotalTimer',
                    ),
                  ),
        ),

        BlocProvider<ActivityBloc>(
          create: (context) => ActivityBloc()..add(StartAutoSync()),
        ),
        BlocProvider(
          create: (context) => MilestoneBloc()..add(LoadMilestones()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: 'Sara Baby Tracker and Sound',
            debugShowCheckedModeBanner: false,
            onGenerateRoute: generateRoute,
            theme:
                (state is ThemeInitial) ? state.themeData : AppThemes.girlTheme,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return NavigationWrapper();
                } else if (state is Unauthenticated) {
                  return WelcomePage();
                } else {
                  return WelcomePage();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
