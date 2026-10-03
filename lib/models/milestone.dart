enum MilestoneStatus {
  locked,
  inProgress,
  awaitingSignOff,
  completed,
}

class Milestone {
  final int id;
  final String title;
  final String description;
  MilestoneStatus status;
  DateTime? completedDate;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    this.status = MilestoneStatus.locked,
    this.completedDate,
  });
}