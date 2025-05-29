import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/account/add_baby_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/account/add_caregiver.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/account/change_password_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/account/edit_baby_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/account/edit_caregiver_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/account/faq_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/account/legal_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/account/my_account_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/caregiver_sign_in_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/forgot_password.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/sign_in_options_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/sign_in_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/sign_up_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/onboarding/welcome_page.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String signin = '/signin';
  static const String signout = '/signout';
  static const String home = '/home';
  static const String editBaby = '/editBaby';
  static const String addBaby = '/addBaby';
  static const String addCaregiver = '/addCaregiver';
  static const String caregiverSignin = '/caregiverSignin';
  static const String signinOptions = '/signinOptions';
  static const String signup = '/signup';
  static const String myAccount='/myAccount';
  static const String caregiverEdit = '/caregiverEdit';
  static const String changePassword='/changePassword';
  static const String forgotPassword = '/forgotPassword';
  static const String faq = '/faqPage';
  static const String legalPage = '/legalPage';

}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => WelcomePage());
    case AppRoutes.signin:
      return MaterialPageRoute(builder: (_) => SignInPage());
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => NavigationWrapper());
    case AppRoutes.editBaby:
      final String babyID = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => EditBabyPage(babyID: babyID));
    case AppRoutes.addBaby:
      return MaterialPageRoute(builder: (_) => AddBabyPage());
    case AppRoutes.caregiverSignin:
      return MaterialPageRoute(builder: (_) => CaregiverSignInPage());
    case AppRoutes.signinOptions:
      return MaterialPageRoute(builder: (_) => SignInOptionsPage());
    case AppRoutes.addCaregiver:
      return MaterialPageRoute(builder: (_) => AddCaregiver());
    case AppRoutes.signup:
      return MaterialPageRoute(builder: (_) => SignUpPage());
    case AppRoutes.forgotPassword:
      return MaterialPageRoute(builder: (_) => ForgotPassword());
    case AppRoutes.caregiverEdit:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder:
            (_) => EditCaregiverPage(
              caregiverID: args['caregiverID'],
              caregiverName: args['caregiverName'],
            ),
      );
    case AppRoutes.myAccount:
      return MaterialPageRoute(builder: (_) => MyAccountPage());
    case AppRoutes.changePassword:
      return MaterialPageRoute(builder: (_)=>ChangePasswordPage());
    case AppRoutes.faq:
      return MaterialPageRoute(builder: (_)=>FaqPage());
    case AppRoutes.legalPage:
      return MaterialPageRoute(builder: (_)=>LegalPage());
    default:
      return MaterialPageRoute(
        builder:
            (_) =>
                const Scaffold(body: Center(child: Text('404 Page Not Found'))),
      );
  }
}
