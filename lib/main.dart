import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/app_router.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/theme/app_themes.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/auth/auth_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/caregiver/caregiver_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/theme/theme_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/onboarding/welcome_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  setupLocator();

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
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BabyBloc>(create: (_) => BabyBloc()..add(LoadBabies())),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
        BlocProvider<BottomNavBloc>(create: (_) => BottomNavBloc()),
        BlocProvider<CaregiverBloc>(create: (_)=>CaregiverBloc()),
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()..add(AppStarted())),
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
