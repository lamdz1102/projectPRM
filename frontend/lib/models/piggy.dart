class Piggy {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String note;

  Piggy({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
    required this.note,
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
    if (isLocked && !isCompleted) return 'Đã khóa';
    if (isCompleted) return 'Hoàn thành';
    return 'Đang tiết kiệm';
  }
}