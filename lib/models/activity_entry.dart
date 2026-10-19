import 'user_role.dart';

enum ActivityType {
  expenseSubmitted,
  expenseApproved,
  expenseDisputed,
  expenseResubmitted,
  transferCreated,
  transferConfirmed,
  milestoneReady,
  milestoneSignedOff,
  inspectionRecorded,
  projectCompleted,
}

class ActivityEntry {
  final int id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime occurredAt;
  final UserRole recipientRole;
  bool isRead;

  ActivityEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.occurredAt,
    required this.recipientRole,
    this.isRead = false,
  });
}
