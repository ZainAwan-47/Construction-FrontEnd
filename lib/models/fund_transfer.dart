enum TransferStatus {
  awaitingConfirmation,
  confirmed,
}

class FundTransfer {
  final String id;
  final double amount;
  final DateTime date;
  final String reference;
  final bool proofAttached;
  TransferStatus status;

  FundTransfer({
    required this.id,
    required this.amount,
    required this.date,
    required this.reference,
    required this.proofAttached,
    required this.status,
  });
}