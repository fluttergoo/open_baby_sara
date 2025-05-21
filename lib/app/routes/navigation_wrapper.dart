import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/account/account_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/activities/activity_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/history/history_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/food_recipes/recipes_page.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/background_sounds/baby_relaxing_sounds_page.dart';

class NavigationWrapper extends StatelessWidget {
  const NavigationWrapper({super.key});

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
            state is BottomNavNext ? state.selectedIndex : 0;

        return Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: ConvexAppBar(
            initialActiveIndex:
                state is BottomNavNext ? state.selectedIndex : 0,
            onTap: (int index) {
              context.read<BottomNavBloc>().add(NavItemSelected(index));
            },
            backgroundColor: Colors.deepPurpleAccent,
            style: TabStyle.reactCircle,
            activeColor: Colors.white,
            color: Colors.white70,
            items: [
              TabItem(icon: Icons.history_outlined, title: 'History',),
              TabItem(icon: Icons.surround_sound_outlined, title: 'Sounds'),
              TabItem(icon: Icons.local_activity_outlined, title: 'Activity'),
              TabItem(icon: Icons.receipt_long_outlined, title: 'Recipes'),
              TabItem(icon: Icons.account_circle_outlined, title: 'Profile'),
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
