import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/auth/sign_in_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => SignInPage()));
  }

  Widget _buildImage(String assetName, [double width = 250]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  final pageDecoration = PageDecoration(
    titleTextStyle: GoogleFonts.dancingScript(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Color(0xFFE91E63),
    ),
    bodyTextStyle: GoogleFonts.poppins(fontSize: 24, color: Colors.black87),
    bodyPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
    imagePadding: EdgeInsets.only(top: 24.0),
    pageColor: Colors.transparent,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFFFF9C4), // Açık sarı
              Color(0xFFFFE0B2), // Peach (şeftali ton)
              Color(0xFFFFCDD2), // Baby pink],
            ],
          ),
        ),
        child: SafeArea(
          child: IntroductionScreen(
            key: introKey,
            globalBackgroundColor: Colors.transparent,
            allowImplicitScrolling: true,
            showBackButton: false,
            showSkipButton: true,
            skip: Text(
              context.tr("skip"),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
            next: const Icon(
              Icons.arrow_forward,
              color: Color(0xFFE91E63),
              size: 24,
            ),
            done: Text(
              context.tr("start"),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            onDone: () => _onIntroEnd(context),
            onSkip: () => _onIntroEnd(context),
            dotsDecorator: const DotsDecorator(
              size: Size(10.0, 10.0),
              color: Color(0xFFBDBDBD),
              activeSize: Size(22.0, 10.0),
              activeColor: Color(0xFFE91E63),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
            pages: [
              PageViewModel(
                title: context.tr('welcome_title'),
                body: context.tr('welcome_body'),
                image: _buildImage('logo.png'),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: context.tr('feeding_tracking'),
                body: context.tr('feeding_tracking_body'),
                image: _buildImage('feeding.png'),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: context.tr('sleep_schedule'),
                body: context.tr('sleep_schedule_body'),
                image: _buildImage('sleep.png'),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: context.tr('development_tracking'),
                body: context.tr('development_tracking_body'),
                image: _buildImage('development.png'),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: context.tr('relaxing_sounds_and_recipes'),
                body: context.tr('relaxing_sounds_and_recipes_body'),
                image: _buildImage('relaxing.png'),
                decoration: pageDecoration,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
