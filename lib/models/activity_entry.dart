enum ActivityType {
  expenseSubmitted,
  expenseApproved,
  expenseDisputed,
  expenseResubmitted,
  transferConfirmed,
  milestoneSignedOff,
  inspectionRecorded,
  projectCompleted,
}

class ActivityEntry {
  final ActivityType type;
  final String title;
  final String description;
  final DateTime occurredAt;

  const ActivityEntry({
    required this.type,
    required this.title,
    required this.description,
    required this.occurredAt,
  });
}
