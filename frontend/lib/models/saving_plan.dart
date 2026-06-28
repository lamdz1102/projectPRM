enum SavingPlanStatus {
  notStarted,
  onTrack,
  ahead,
  behind,
  completed,
  expired,
}

class SavingPlan {
  final double remainingAmount;
  final int totalPlanDays;
  final int elapsedDays;
  final int remainingDays;
  final double originalDailyTarget;
  final double requiredPerDay;
  final double requiredPerWeek;
  final double requiredPerMonth;
  final double expectedAmountToday;
  final double differenceFromPlan;
  final double averageSavedPerDay;
  final DateTime? estimatedCompletionDate;
  final SavingPlanStatus status;

  const SavingPlan({
    required this.remainingAmount,
    required this.totalPlanDays,
    required this.elapsedDays,
    required this.remainingDays,
    required this.originalDailyTarget,
    required this.requiredPerDay,
    required this.requiredPerWeek,
    required this.requiredPerMonth,
    required this.expectedAmountToday,
    required this.differenceFromPlan,
    required this.averageSavedPerDay,
    required this.estimatedCompletionDate,
    required this.status,
  });

  bool get isFinished =>
      status == SavingPlanStatus.completed ||
          status == SavingPlanStatus.expired;

  String get statusLabel {
    switch (status) {
      case SavingPlanStatus.notStarted:
        return 'Chưa bắt đầu';
      case SavingPlanStatus.onTrack:
        return 'Đúng tiến độ';
      case SavingPlanStatus.ahead:
        return 'Vượt kế hoạch';
      case SavingPlanStatus.behind:
        return 'Chậm tiến độ';
      case SavingPlanStatus.completed:
        return 'Đã hoàn thành';
      case SavingPlanStatus.expired:
        return 'Đã quá hạn';
    }
  }
}