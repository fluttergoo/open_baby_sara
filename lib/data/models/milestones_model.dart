
class MilestonesModel {
  final String titleKey;
  final String descriptionKey;

  MilestonesModel({required this.titleKey, required this.descriptionKey});

  Map<String, dynamic> toMap() {
    return {
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
    };
  }

  factory MilestonesModel.fromMap(Map<String, dynamic> map) {
    return MilestonesModel(
      titleKey: map['titleKey'] as String,
      descriptionKey: map['descriptionKey'] as String,
    );
  }
}

class MonthlyMilestonesModel {
  final int month;
  final List<MilestonesModel> milestones;

  MonthlyMilestonesModel({required this.month, required this.milestones});

  factory MonthlyMilestonesModel.fromMap(Map<String, dynamic> map) {
    final List<dynamic> milestoneList = map['milestones'];
    return MonthlyMilestonesModel(
      month: map['month'] as int,
      milestones: milestoneList
          .map((e) => MilestonesModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
