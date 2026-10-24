import 'package:flutter/material.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/final_inspection.dart';
import '../../models/milestone.dart';
import '../../models/user_role.dart';
import '../../state/app_state.dart';

class FinalInspectionScreen extends StatefulWidget {
  const FinalInspectionScreen({super.key});

  @override
  State<FinalInspectionScreen> createState() => _FinalInspectionScreenState();
}

class _FinalInspectionScreenState extends State<FinalInspectionScreen> {
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _recordInspection(AppState state, {required bool approved}) {
    final recorded = state.recordFinalInspection(
      approved: approved,
      feedback: _feedbackController.text,
    );
    if (!recorded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approved
                ? 'Inspection cannot be approved until all handover requirements are met.'
                : 'Enter inspection feedback before recording that work is needed.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _feedbackController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approved
              ? 'Final inspection approved. The project is ready for handover.'
              : 'Inspection recorded. Outstanding items are available to the Contractor.',
        ),
        backgroundColor: approved ? AppColors.success : AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmHandover(AppState state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete project handover?'),
        content: const Text(
          'This records the project as complete in this app. This frontend-only '
          'record is not a legal or real-world handover document.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Handover'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    if (!state.completeProject()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Handover was not recorded. Recheck readiness and inspection status.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project handover recorded as complete.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _dateLabel(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _milestoneStatus(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.locked:
        return 'Locked';
      case MilestoneStatus.inProgress:
        return 'In progress';
      case MilestoneStatus.awaitingSignOff:
        return 'Awaiting sign-off';
      case MilestoneStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final state = AppState();
        final isOwner = state.activeRole != UserRole.contractor;
        final latestInspection = state.latestFinalInspection;
        final canApproveInspection =
            isOwner &&
            !state.isProjectCompleted &&
            state.isReadyForHandover &&
            latestInspection?.approved != true;
        final canComplete =
            isOwner &&
            !state.isProjectCompleted &&
            state.isReadyForHandover &&
            latestInspection?.approved == true;

        return Scaffold(
          backgroundColor: AppColors.surfaceWarmGray,
          appBar: AppBar(title: const Text('Final Inspection & Handover')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _StatusCard(
                  completed: state.isProjectCompleted,
                  inspection: latestInspection,
                  completionDate: state.projectCompletedDate,
                  dateLabel: _dateLabel,
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Project Readiness',
                  subtitle:
                      '${state.completedMilestoneCount} of ${state.allMilestones.length} milestones completed',
                ),
                const SizedBox(height: 10),
                ...state.allMilestones.map(
                  (milestone) => _ReadinessRow(
                    title: 'Phase ${milestone.id}: ${milestone.title}',
                    detail: _milestoneStatus(milestone.status),
                    complete: milestone.status == MilestoneStatus.completed,
                  ),
                ),
                const SizedBox(height: 12),
                _SectionTitle(
                  title: 'Outstanding Items',
                  subtitle: state.handoverBlockers.isEmpty
                      ? 'No outstanding requirements'
                      : '${state.handoverBlockers.length} requirement(s) remain',
                ),
                const SizedBox(height: 10),
                if (state.handoverBlockers.isEmpty)
                  const _ReadinessRow(
                    title: 'All handover requirements are met',
                    detail: 'Milestones, expenses, and transfers are resolved',
                    complete: true,
                  )
                else
                  ...state.handoverBlockers.map(
                    (item) => _ReadinessRow(
                      title: item,
                      detail: 'Must be resolved before final approval',
                      complete: false,
                    ),
                  ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Financial Summary',
                  subtitle: 'Approved and confirmed amounts only',
                ),
                const SizedBox(height: 10),
                _FinancialRow(
                  label: 'Approved expenses',
                  amount: state.totalApprovedExpenses,
                ),
                _FinancialRow(
                  label: 'Confirmed transfers',
                  amount: state.totalConfirmedTransfers,
                ),
                _FinancialRow(
                  label: 'Remaining budget',
                  amount: state.remainingProjectBudget,
                ),
                _FinancialRow(
                  label: 'Contractor cash-in-hand',
                  amount: state.contractorCashInHand,
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Inspection Decisions',
                  subtitle:
                      'Local frontend record; not a verified inspection certificate',
                ),
                if (state.finalInspectionRecords.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No final inspection decision has been recorded.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...state.finalInspectionRecords.reversed.map(
                    (record) => _InspectionRecordTile(
                      record: record,
                      dateLabel: _dateLabel,
                    ),
                  ),
                if (isOwner && !state.isProjectCompleted) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Inspection feedback or notes',
                      hintText: 'Required when recording work that remains',
                      filled: true,
                      fillColor: AppColors.surfaceWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _recordInspection(state, approved: false),
                    icon: const Icon(Icons.assignment_late_outlined),
                    label: const Text('Record Needs Work'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: canApproveInspection
                        ? () => _recordInspection(state, approved: true)
                        : null,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Approve Final Inspection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.surfaceWhite,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: canComplete
                        ? () => _confirmHandover(state)
                        : null,
                    icon: const Icon(Icons.handshake_outlined),
                    label: const Text('Confirm Project Handover'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ] else if (!isOwner && !state.isProjectCompleted) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'The Owner records inspection decisions and confirms handover. '
                    'Resolve the items above before final approval.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRouter.finalProjectReportRoute,
                  ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('View Final Project Report'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool completed;
  final FinalInspectionRecord? inspection;
  final DateTime? completionDate;
  final String Function(DateTime) dateLabel;

  const _StatusCard({
    required this.completed,
    required this.inspection,
    required this.completionDate,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final status = completed
        ? 'Project complete'
        : inspection == null
        ? 'Final inspection not started'
        : inspection!.approved
        ? 'Inspection approved; handover pending'
        : 'Inspection needs work';
    final color = completed
        ? AppColors.success
        : inspection?.approved == true
        ? AppColors.primaryBlue
        : inspection == null
        ? AppColors.warning
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.verified : Icons.fact_check_outlined,
            color: color,
            size: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                if (completionDate != null)
                  Text(
                    'Handover recorded ${dateLabel(completionDate!)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                if (inspection != null && inspection!.feedback.isNotEmpty)
                  Text(
                    inspection!.feedback,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    ],
  );
}

class _ReadinessRow extends StatelessWidget {
  final String title;
  final String detail;
  final bool complete;

  const _ReadinessRow({
    required this.title,
    required this.detail,
    required this.complete,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(
        complete ? Icons.check_circle_outline : Icons.pending_outlined,
        color: complete ? AppColors.success : AppColors.warning,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(detail),
    ),
  );
}

class _FinancialRow extends StatelessWidget {
  final String label;
  final double amount;

  const _FinancialRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Text(
          formatPkrCurrency(amount),
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _InspectionRecordTile extends StatelessWidget {
  final FinalInspectionRecord record;
  final String Function(DateTime) dateLabel;

  const _InspectionRecordTile({required this.record, required this.dateLabel});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 8),
    child: ListTile(
      leading: Icon(
        record.approved
            ? Icons.verified_outlined
            : Icons.assignment_late_outlined,
        color: record.approved ? AppColors.success : AppColors.error,
      ),
      title: Text(
        record.approved ? 'Inspection approved' : 'Needs work',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        [
          dateLabel(record.date),
          if (record.feedback.isNotEmpty) record.feedback,
        ].join('\n'),
      ),
      isThreeLine: record.feedback.isNotEmpty,
    ),
  );
}
