import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/bottom_nav/bottom_nav_bloc.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFFD1C4E9), // pastel mor
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex:(state is BottomNavNext)? state.selectedIndex : 0,
                onTap: (index){
                  context.read<BottomNavBloc>().add(NavItemSelected(index));
                },
                backgroundColor: Colors.deepPurpleAccent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white60,
                items: const[
                  BottomNavigationBarItem(
                      icon: Icon(Icons.local_activity_outlined),
                      label: 'Activity'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.history_outlined), label: 'History'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.surround_sound_outlined),
                      label: 'Sounds'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.receipt_long_outlined),
                      label: 'Recipes'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      label: 'Account'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
