class Piggy {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String note;
  final bool isBroken;
  final String status;

  Piggy({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
    required this.note,
    required this.isBroken,
    required this.status,
  });

  factory Piggy.fromJson(Map<String, dynamic> json) {
    return Piggy(
      id: json['id'],
      name: json['name'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      note: json['note'] ?? '',
      isBroken: json['isBroken'] ?? false,
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'startDate': startDate.toIso8601String().split('T').first,
      'endDate': endDate.toIso8601String().split('T').first,
      'note': note,
    };
  }

  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0, 1);
  }

  int get daysLeft {
    return endDate.difference(DateTime.now()).inDays;
  }

  bool get isLocked {
    return status == 'LOCKED';
  }

  bool get isCompleted {
    return status == 'COMPLETED';
  }

  String get displayStatus {
    if (status == 'BROKEN') return 'Đã đập';
    if (status == 'LOCKED') return 'Đã khóa';
    if (status == 'COMPLETED') return 'Hoàn thành';
    return 'Đang tiết kiệm';
  }

  Piggy copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? note,
    bool? isBroken,
    String? status,
  }) {
    return Piggy(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      note: note ?? this.note,
      isBroken: isBroken ?? this.isBroken,
      status: status ?? this.status,
    );
  }
}