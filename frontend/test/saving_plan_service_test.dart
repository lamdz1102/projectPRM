import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/piggy.dart';
import 'package:frontend/models/saving_plan.dart';
import 'package:frontend/services/saving_plan_service.dart';

Piggy buildPiggy({
  double targetAmount = 1000000,
  double currentAmount = 0,
  required DateTime startDate,
  required DateTime endDate,
}) {
  return Piggy(
    id: 1,
    name: 'Heo test',
    targetAmount: targetAmount,
    currentAmount: currentAmount,
    startDate: startDate,
    endDate: endDate,
    note: '',
    isBroken: false,
    status: 'ACTIVE',
    avatar: '🐷',
  );
}

void main() {
  group('SavingPlanService', () {
    test(
      'tự tính lại mức tiết kiệm mỗi ngày '
          'theo số ngày còn lại',
          () {
        final piggy = buildPiggy(
          targetAmount: 1000000,
          currentAmount: 200000,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 10),
        );

        final plan = SavingPlanService.calculate(
          piggy,
          now: DateTime(2026, 1, 5),
        );

        expect(plan.remainingAmount, 800000);
        expect(plan.remainingDays, 6);
        expect(
          plan.requiredPerDay,
          closeTo(133333.33, 0.01),
        );
        expect(
          plan.status,
          SavingPlanStatus.behind,
        );
      },
    );

    test('nhận diện mục tiêu chưa bắt đầu', () {
      final piggy = buildPiggy(
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 10),
      );

      final plan = SavingPlanService.calculate(
        piggy,
        now: DateTime(2026, 1, 25),
      );

      expect(
        plan.status,
        SavingPlanStatus.notStarted,
      );
      expect(plan.remainingDays, 10);
      expect(plan.requiredPerDay, 100000);
    });

    test('nhận diện mục tiêu đã hoàn thành', () {
      final piggy = buildPiggy(
        targetAmount: 1000000,
        currentAmount: 1000000,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );

      final plan = SavingPlanService.calculate(
        piggy,
        now: DateTime(2026, 1, 20),
      );

      expect(
        plan.status,
        SavingPlanStatus.completed,
      );
      expect(plan.remainingAmount, 0);
      expect(plan.requiredPerDay, 0);
    });

    test('nhận diện mục tiêu quá hạn', () {
      final piggy = buildPiggy(
        targetAmount: 1000000,
        currentAmount: 600000,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 10),
      );

      final plan = SavingPlanService.calculate(
        piggy,
        now: DateTime(2026, 1, 11),
      );

      expect(
        plan.status,
        SavingPlanStatus.expired,
      );
      expect(plan.remainingDays, 0);
      expect(plan.remainingAmount, 400000);
    });
  });
}