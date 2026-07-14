import 'saving_plan.dart';

class FutureSimulationResult {
  final double simulatedAmount;
  final double oldProgress;
  final double newProgress;
  final SavingPlan currentPlan;
  final SavingPlan simulatedPlan;
  final int oldLevel;
  final int newLevel;
  final int daysSaved;

  const FutureSimulationResult({
    required this.simulatedAmount,
    required this.oldProgress,
    required this.newProgress,
    required this.currentPlan,
    required this.simulatedPlan,
    required this.oldLevel,
    required this.newLevel,
    required this.daysSaved,
  });

  bool get reachesGoal => newProgress >= 1;

  bool get levelsUp => newLevel > oldLevel;

  bool get statusChanges =>
      currentPlan.status != simulatedPlan.status;
}
