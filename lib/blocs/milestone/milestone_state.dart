part of 'milestone_bloc.dart';

@immutable
sealed class MilestoneState {}

final class MilestoneInitial extends MilestoneState {}
class MilestoneLoading extends MilestoneState {}

class MilestoneLoaded extends MilestoneState {
  final List<MonthlyMilestonesModel> milestones;
  MilestoneLoaded(this.milestones);
}

class MilestoneError extends MilestoneState {
  final String message;
  MilestoneError(this.message);
}
