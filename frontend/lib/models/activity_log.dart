class ActivityLog {
  final String type; // add_money, break_piggy, delete_piggy, create_piggy
  final String piggyName;
  final double? amount;
  final DateTime time;
  final String message;

  ActivityLog({
    required this.type,
    required this.piggyName,
    this.amount,
    required this.time,
    required this.message,
  });
}