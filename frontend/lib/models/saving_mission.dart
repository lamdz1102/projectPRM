enum SavingMissionType {
  noSpend,
  deposit,
  reflection,
}

class SavingMission {
  final String id;
  final String dateKey;
  final String icon;
  final String title;
  final String description;
  final int xpReward;
  final SavingMissionType type;
  final double? targetAmount;
  final bool isCompleted;

  const SavingMission({
    required this.id,
    required this.dateKey,
    required this.icon,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.type,
    required this.targetAmount,
    required this.isCompleted,
  });

  bool get requiresDeposit => type == SavingMissionType.deposit;

  SavingMission copyWith({
    bool? isCompleted,
  }) {
    return SavingMission(
      id: id,
      dateKey: dateKey,
      icon: icon,
      title: title,
      description: description,
      xpReward: xpReward,
      type: type,
      targetAmount: targetAmount,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
