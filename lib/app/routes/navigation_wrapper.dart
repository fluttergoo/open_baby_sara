import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/blocs/baby/baby_bloc.dart';
import 'package:open_baby_sara/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:open_baby_sara/core/utils/check_for_update.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service.dart';
import 'package:open_baby_sara/data/services/firebase/update_service.dart';
import 'package:open_baby_sara/views/account/account_page.dart';
import 'package:open_baby_sara/views/activities/activity_page.dart';
import 'package:open_baby_sara/views/history/history_page.dart';
import 'package:open_baby_sara/views/food_recipes/recipes_page.dart';
import 'package:open_baby_sara/views/background_sounds/baby_relaxing_sounds_page.dart';

class NavigationWrapper extends StatefulWidget {

  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView('ActivityPage');
    checkAppUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HistoryPage(),
      BabyRelaxingSoundsPage(),
      ActivityPage(),
      RecipesPage(),
      AccountPage(),
    ];
    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        final int currentIndex =
            state is BottomNavNext ? state.selectedIndex : 2;

        return Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: ConvexAppBar(
            initialActiveIndex:
                state is BottomNavNext ? state.selectedIndex : 2,
            onTap: (int index) {
              context.read<BottomNavBloc>().add(NavItemSelected(index));
              final screenNames = [
                'HistoryPage',
                'BabyRelaxingSoundsPage',
                'ActivityPage',
                'RecipesPage',
                'AccountPage',
              ];
              getIt<AnalyticsService>().logScreenView(screenNames[index]);
            },
            backgroundColor: Colors.deepPurpleAccent,
            style: TabStyle.reactCircle,
            activeColor: Colors.white,
            color: Colors.white70,
            items: [
              TabItem(icon: Icons.history_outlined, title: context.tr('history')),
              TabItem(icon: Icons.surround_sound_outlined, title: context.tr('sounds')),
              TabItem(icon: Icons.local_activity_outlined, title: context.tr('activity')),
              TabItem(icon: Icons.receipt_long_outlined, title: context.tr('recipes')),
              TabItem(icon: Icons.account_circle_outlined, title: context.tr('profile')),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5E6E8), Color(0xFFF6F5F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),

            child: SafeArea(child: _pages[currentIndex]),
          ),
        );
      },
    );
  }
}
