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

  factory PiggyDeposit.fromJson(Map<String, dynamic> json) {
    return PiggyDeposit(
      id: json['id'],
      piggyId: json['piggyId'],
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['depositDate']),
      note: json['note'] ?? '',
    );
  }
}