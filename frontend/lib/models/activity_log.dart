class ActivityLog {
  final String type;
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

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      type: json['type'] ?? '',
      piggyName: json['piggyName'] ?? '',
      amount: json['amount'] == null ? null : (json['amount'] as num).toDouble(),
      time: DateTime.parse(json['createdAt']),
      message: json['message'] ?? '',
    );
  }
}