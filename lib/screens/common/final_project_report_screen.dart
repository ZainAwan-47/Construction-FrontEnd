import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/expense.dart';
import '../../models/fund_transfer.dart';
import '../../models/milestone.dart';
import '../../state/app_state.dart';

class FinalProjectReportScreen extends StatelessWidget {
  const FinalProjectReportScreen({super.key});

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Not recorded';
    return '${date.day}/${date.month}/${date.year}';
  }

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

  String _expenseStatus(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.pending:
        return 'Pending review';
      case ExpenseStatus.approved:
        return 'Approved';
      case ExpenseStatus.disputed:
        return 'Disputed';
    }
  }

  String _transferStatus(TransferStatus status) {
    switch (status) {
      case TransferStatus.awaitingConfirmation:
        return 'Awaiting confirmation';
      case TransferStatus.confirmed:
        return 'Confirmed';
    }
  }

  Future<void> _exportPdf(BuildContext context, AppState state) async {
    final document = _buildPdf(state);
    try {
      await Printing.sharePdf(
        bytes: await document.save(),
        filename: 'gulshan-villa-project-report.pdf',
      );
    } on Exception catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to export the report: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  pw.Document _buildPdf(AppState state) {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          pw.Text(
            'Gulshan Villa - Final Project Report',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1A237E'),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Generated ${_dateLabel(DateTime.now())}'),
          pw.SizedBox(height: 16),
          pw.Text(
            'Completion: ${state.isProjectCompleted ? 'Complete' : 'In progress'}',
          ),
          pw.Text('Handover date: ${_dateLabel(state.projectCompletedDate)}'),
          pw.Text('Final inspection: ${_inspectionStatus(state)}'),
          if (state.latestFinalInspection?.feedback.isNotEmpty == true)
            pw.Text(
              'Latest inspection feedback: ${state.latestFinalInspection!.feedback}',
            ),
          pw.SizedBox(height: 16),
          pw.Text('Financial Summary', style: _pdfSectionStyle),
          _pdfTable(
            ['Metric', 'Amount'],
            [
              ['Project budget', formatPkrCurrency(state.totalProjectBudget)],
              [
                'Approved expenses',
                formatPkrCurrency(state.totalApprovedExpenses),
              ],
              [
                'Pending expenses',
                formatPkrCurrency(state.totalPendingExpenses),
              ],
              [
                'Disputed expenses',
                formatPkrCurrency(state.totalDisputedExpenses),
              ],
              [
                'Remaining budget',
                formatPkrCurrency(state.remainingProjectBudget),
              ],
              [
                'Confirmed transfers',
                formatPkrCurrency(state.totalConfirmedTransfers),
              ],
              [
                'Unconfirmed transfers',
                formatPkrCurrency(state.unconfirmedIncomingFunds),
              ],
              [
                'Contractor cash-in-hand',
                formatPkrCurrency(state.contractorCashInHand),
              ],
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Text('Milestone Outcomes', style: _pdfSectionStyle),
          _pdfTable(
            ['Phase', 'Milestone', 'Status', 'Completed'],
            state.allMilestones
                .map(
                  (milestone) => [
                    '${milestone.id}',
                    milestone.title,
                    _milestoneStatus(milestone.status),
                    _dateLabel(milestone.completedDate),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 14),
          pw.Text('Expense Records', style: _pdfSectionStyle),
          _pdfTable(
            ['Date', 'Category / Description', 'Amount', 'Status'],
            state.allExpenses
                .map(
                  (expense) => [
                    _dateLabel(expense.date),
                    '${expense.category}: ${expense.description}',
                    formatPkrCurrency(expense.amount),
                    _expenseStatus(expense.status),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 14),
          pw.Text('Fund Transfer Records', style: _pdfSectionStyle),
          _pdfTable(
            ['Date', 'Reference', 'Amount', 'Status', 'Proof'],
            state.allTransfers
                .map(
                  (transfer) => [
                    _dateLabel(transfer.date),
                    transfer.reference,
                    formatPkrCurrency(transfer.amount),
                    _transferStatus(transfer.status),
                    transfer.proofAttached ? 'Demo attached' : 'None',
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 14),
          pw.Text('Final Inspection History', style: _pdfSectionStyle),
          if (state.finalInspectionRecords.isEmpty)
            pw.Text('No final inspection decision has been recorded.')
          else
            ...state.finalInspectionRecords.map(
              (record) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Text(
                  '${_dateLabel(record.date)} - ${record.approved ? 'Approved' : 'Needs work'}'
                  '${record.feedback.isEmpty ? '' : ': ${record.feedback}'}',
                ),
              ),
            ),
          pw.SizedBox(height: 18),
          pw.Text(
            'This report contains local frontend records. Demo attachments are placeholders and are not verified real-world evidence.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    return document;
  }

  static final _pdfSectionStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColor.fromHex('#1A237E'),
  );

  pw.Widget _pdfTable(List<String> headers, List<List<String>> rows) =>
      pw.TableHelper.fromTextArray(
        headers: headers,
        data: rows,
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        headerDecoration: const pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF1A237E),
        ),
        cellStyle: const pw.TextStyle(fontSize: 8),
        cellPadding: const pw.EdgeInsets.all(5),
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      );

  String _inspectionStatus(AppState state) {
    final latest = state.latestFinalInspection;
    if (latest == null) return 'Not started';
    return latest.approved ? 'Approved' : 'Needs work';
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AppState(),
    builder: (context, _) {
      final state = AppState();
      final latestInspection = state.latestFinalInspection;

      return Scaffold(
        backgroundColor: AppColors.surfaceWarmGray,
        appBar: AppBar(
          title: const Text('Final Project Report'),
          actions: [
            IconButton(
              tooltip: 'Export PDF',
              onPressed: () => _exportPdf(context, state),
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Gulshan Villa',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Local project summary',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                title: 'Project completion',
                value: state.isProjectCompleted ? 'Complete' : 'In progress',
                detail: state.isProjectCompleted
                    ? 'Handover recorded ${_dateLabel(state.projectCompletedDate)}'
                    : '${state.completedMilestoneCount} of ${state.allMilestones.length} milestones completed',
                icon: state.isProjectCompleted
                    ? Icons.verified_outlined
                    : Icons.construction,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: 'Final inspection',
                value: _inspectionStatus(state),
                detail: latestInspection == null
                    ? 'No decision recorded'
                    : '${_dateLabel(latestInspection.date)}${latestInspection.feedback.isEmpty ? '' : ' · ${latestInspection.feedback}'}',
                icon: Icons.fact_check_outlined,
              ),
              const SizedBox(height: 20),
              _ReportSection(
                title: 'Financial Summary',
                children: [
                  _ReportAmountRow(
                    label: 'Project budget',
                    amount: state.totalProjectBudget,
                  ),
                  _ReportAmountRow(
                    label: 'Approved expenses',
                    amount: state.totalApprovedExpenses,
                  ),
                  _ReportAmountRow(
                    label: 'Pending expenses',
                    amount: state.totalPendingExpenses,
                    status: 'Excluded from approved expenses',
                  ),
                  _ReportAmountRow(
                    label: 'Disputed expenses',
                    amount: state.totalDisputedExpenses,
                    status: 'Excluded from approved expenses',
                  ),
                  _ReportAmountRow(
                    label: 'Remaining budget',
                    amount: state.remainingProjectBudget,
                  ),
                  _ReportAmountRow(
                    label: 'Confirmed transfers',
                    amount: state.totalConfirmedTransfers,
                  ),
                  _ReportAmountRow(
                    label: 'Unconfirmed transfers',
                    amount: state.unconfirmedIncomingFunds,
                    status: 'Excluded from confirmed funds',
                  ),
                  _ReportAmountRow(
                    label: 'Contractor cash-in-hand',
                    amount: state.contractorCashInHand,
                  ),
                ],
              ),
              _ReportSection(
                title: 'Milestone Outcomes',
                children: state.allMilestones
                    .map(
                      (milestone) => _ReportRecord(
                        title: 'Phase ${milestone.id}: ${milestone.title}',
                        detail:
                            '${_milestoneStatus(milestone.status)} · Completed ${_dateLabel(milestone.completedDate)}',
                        complete: milestone.status == MilestoneStatus.completed,
                      ),
                    )
                    .toList(),
              ),
              _ReportSection(
                title: 'Expense Records',
                children: state.allExpenses
                    .map(
                      (expense) => _ReportRecord(
                        title: '${expense.category}: ${expense.description}',
                        detail:
                            '${_dateLabel(expense.date)} · ${_expenseStatus(expense.status)} · ${formatPkrCurrency(expense.amount)}',
                        complete: expense.status == ExpenseStatus.approved,
                      ),
                    )
                    .toList(),
              ),
              _ReportSection(
                title: 'Fund Transfer Records',
                children: state.allTransfers
                    .map(
                      (transfer) => _ReportRecord(
                        title: transfer.reference,
                        detail:
                            '${_dateLabel(transfer.date)} · ${_transferStatus(transfer.status)} · ${formatPkrCurrency(transfer.amount)}${transfer.proofAttached ? ' · Demo proof attached' : ''}',
                        complete: transfer.status == TransferStatus.confirmed,
                      ),
                    )
                    .toList(),
              ),
              _ReportSection(
                title: 'Final Inspection History',
                children: state.finalInspectionRecords.isEmpty
                    ? const [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('No inspection decision recorded'),
                        ),
                      ]
                    : state.finalInspectionRecords.reversed
                          .map(
                            (record) => _ReportRecord(
                              title: record.approved
                                  ? 'Inspection approved'
                                  : 'Needs work',
                              detail:
                                  '${_dateLabel(record.date)}${record.feedback.isEmpty ? '' : ' · ${record.feedback}'}',
                              complete: record.approved,
                            ),
                          )
                          .toList(),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 20),
                child: Text(
                  'This report contains local frontend records. Demo attachments are placeholders and are not verified real-world evidence.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _exportPdf(context, state),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Export PDF Report'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String detail;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppColors.primaryOrangeForeground, size: 30),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      subtitle: Text(detail),
      trailing: Text(
        value,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w800,
        ),
      ),
      isThreeLine: true,
    ),
  );
}

class _ReportSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ReportSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
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
        const SizedBox(height: 8),
        ...children,
      ],
    ),
  );
}

class _ReportAmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final String? status;

  const _ReportAmountRow({
    required this.label,
    required this.amount,
    this.status,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (status != null)
                Text(
                  status!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
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

class _ReportRecord extends StatelessWidget {
  final String title;
  final String detail;
  final bool complete;

  const _ReportRecord({
    required this.title,
    required this.detail,
    required this.complete,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 6),
    child: ListTile(
      dense: true,
      leading: Icon(
        complete ? Icons.check_circle_outline : Icons.pending_outlined,
        color: complete ? AppColors.success : AppColors.textPrimary,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(detail),
    ),
  );
}
