part of 'bottom_nav_bloc.dart';

@immutable
sealed class BottomNavEvent {}

class NavItemSelected extends BottomNavEvent {
  final int index;
  NavItemSelected(this.index);
}
