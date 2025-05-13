part of 'milestone_bloc.dart';

@immutable
sealed class MilestoneEvent {}
class LoadMilestones extends MilestoneEvent {}
class LoadMilestonesTitleFromDB extends MilestoneEvent{
  final String babyID;
  LoadMilestonesTitleFromDB({required this.babyID});
}

