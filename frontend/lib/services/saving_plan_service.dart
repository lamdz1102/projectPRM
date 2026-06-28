import 'dart:math' as math;

import '../models/piggy.dart';
import '../models/saving_plan.dart';

class SavingPlanService {
  const SavingPlanService._();

  static SavingPlan calculate(
      Piggy piggy, {
        DateTime? now,
      }) {
    final today = _dateOnly(now ?? DateTime.now());
    final startDate = _dateOnly(piggy.startDate);
    final endDate = _dateOnly(piggy.endDate);

    final double targetAmount = math.max(
      0.0,
      piggy.targetAmount,
    ).toDouble();

    final double currentAmount = math.max(
      0.0,
      piggy.currentAmount,
    ).toDouble();

    final double remainingAmount = math.max(
      0.0,
      targetAmount - currentAmount,
    ).toDouble();

    final int totalPlanDays = math.max(
      1,
      _inclusiveDays(startDate, endDate),
    ).toInt();

    late final int elapsedDays;
    late final int remainingDays;

    if (today.isBefore(startDate)) {
      elapsedDays = 0;
      remainingDays = totalPlanDays;
    } else if (today.isAfter(endDate)) {
      elapsedDays = totalPlanDays;
      remainingDays = 0;
    } else {
      elapsedDays = _inclusiveDays(
        startDate,
        today,
      ).clamp(0, totalPlanDays).toInt();

      remainingDays = _inclusiveDays(
        today,
        endDate,
      ).clamp(0, totalPlanDays).toInt();
    }

    final originalDailyTarget = targetAmount / totalPlanDays;

    final requiredPerDay = remainingDays > 0
        ? remainingAmount / remainingDays
        : 0.0;

    final double requiredPerWeek = math.min(
      remainingAmount,
      requiredPerDay * 7,
    ).toDouble();

    final double requiredPerMonth = math.min(
      remainingAmount,
      requiredPerDay * 30,
    ).toDouble();

    final double expectedAmountToday = elapsedDays == 0
        ? 0.0
        : math.min(
      targetAmount,
      targetAmount * elapsedDays / totalPlanDays,
    ).toDouble();

    final differenceFromPlan =
        currentAmount - expectedAmountToday;

    final averageSavedPerDay = elapsedDays > 0
        ? currentAmount / elapsedDays
        : 0.0;

    final status = _resolveStatus(
      today: today,
      startDate: startDate,
      endDate: endDate,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      differenceFromPlan: differenceFromPlan,
      originalDailyTarget: originalDailyTarget,
    );

    DateTime? estimatedCompletionDate;

    if (remainingAmount <= 0) {
      estimatedCompletionDate = today;
    } else if (!today.isBefore(startDate) &&
        averageSavedPerDay > 0) {
      final estimatedRemainingDays =
      (remainingAmount / averageSavedPerDay).ceil();

      estimatedCompletionDate = today.add(
        Duration(days: estimatedRemainingDays),
      );
    }

    return SavingPlan(
      remainingAmount: remainingAmount,
      totalPlanDays: totalPlanDays,
      elapsedDays: elapsedDays,
      remainingDays: remainingDays,
      originalDailyTarget: originalDailyTarget,
      requiredPerDay: requiredPerDay,
      requiredPerWeek: requiredPerWeek,
      requiredPerMonth: requiredPerMonth,
      expectedAmountToday: expectedAmountToday,
      differenceFromPlan: differenceFromPlan,
      averageSavedPerDay: averageSavedPerDay,
      estimatedCompletionDate: estimatedCompletionDate,
      status: status,
    );
  }

  static SavingPlanStatus _resolveStatus({
    required DateTime today,
    required DateTime startDate,
    required DateTime endDate,
    required double targetAmount,
    required double currentAmount,
    required double differenceFromPlan,
    required double originalDailyTarget,
  }) {
    if (targetAmount > 0 &&
        currentAmount >= targetAmount) {
      return SavingPlanStatus.completed;
    }

    if (today.isAfter(endDate)) {
      return SavingPlanStatus.expired;
    }

    if (today.isBefore(startDate)) {
      return SavingPlanStatus.notStarted;
    }

    final double tolerance = math.max(
      originalDailyTarget * 2,
      targetAmount * 0.05,
    ).toDouble();

    if (differenceFromPlan > tolerance) {
      return SavingPlanStatus.ahead;
    }

    if (differenceFromPlan < -tolerance) {
      return SavingPlanStatus.behind;
    }

    return SavingPlanStatus.onTrack;
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
    );
  }

  static int _inclusiveDays(
      DateTime from,
      DateTime to,
      ) {
    if (to.isBefore(from)) {
      return 0;
    }

    return to.difference(from).inDays + 1;
  }
}