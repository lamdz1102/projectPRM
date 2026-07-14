import 'dart:math' as math;

import '../models/future_simulation_result.dart';
import '../models/piggy.dart';
import 'piggy_pet_service.dart';
import 'saving_plan_service.dart';

class FutureSimulationService {
  const FutureSimulationService._();

  static FutureSimulationResult simulate({
    required Piggy piggy,
    required double additionalAmount,
    DateTime? now,
  }) {
    final safeAmount = math.max(0.0, additionalAmount).toDouble();
    final currentPlan = SavingPlanService.calculate(piggy, now: now);

    final simulatedPiggy = piggy.copyWith(
      currentAmount: piggy.currentAmount + safeAmount,
    );

    final simulatedPlan = SavingPlanService.calculate(
      simulatedPiggy,
      now: now,
    );

    final oldLevel = PiggyPetService.levelFromProgress(piggy.progress);
    final newLevel = PiggyPetService.levelFromProgress(
      simulatedPiggy.progress,
    );

    int daysSaved = 0;
    final oldDate = currentPlan.estimatedCompletionDate;
    final newDate = simulatedPlan.estimatedCompletionDate;

    if (oldDate != null && newDate != null && newDate.isBefore(oldDate)) {
      daysSaved = oldDate.difference(newDate).inDays;
    }

    return FutureSimulationResult(
      simulatedAmount: safeAmount,
      oldProgress: piggy.progress,
      newProgress: simulatedPiggy.progress,
      currentPlan: currentPlan,
      simulatedPlan: simulatedPlan,
      oldLevel: oldLevel,
      newLevel: newLevel,
      daysSaved: daysSaved,
    );
  }
}
