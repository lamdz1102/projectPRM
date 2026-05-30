class PiggyDeposit {
  final int id;
  final int piggyId;
  final double amount;
  final DateTime date;
  final String note;

  PiggyDeposit({
    required this.id,
    required this.piggyId,
    required this.amount,
    required this.date,
    required this.note,
  });
}