class Piggy {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String note;
  final bool isBroken;

  Piggy({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
    required this.note,
    this.isBroken = false,
  });

  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0, 1);
  }

  int get daysLeft {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  bool get isLocked {
    return DateTime.now().isAfter(endDate);
  }

  bool get isCompleted {
    return currentAmount >= targetAmount;
  }

  String get status {
    if (isBroken) return 'Đã đập';
    if (isLocked && !isCompleted) return 'Đã khóa';
    if (isCompleted) return 'Hoàn thành';
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
    );
  }
}