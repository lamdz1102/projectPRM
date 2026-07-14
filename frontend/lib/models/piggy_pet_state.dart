class PiggyAchievement {
  final String id;
  final String icon;
  final String title;
  final String description;
  final bool isUnlocked;

  const PiggyAchievement({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });
}

class PiggyPetState {
  final int level;
  final String stageName;
  final String stageEmoji;
  final double levelProgress;
  final String mood;
  final String moodEmoji;
  final String moodLabel;
  final String message;
  final int currentStreak;
  final int longestStreak;
  final int? daysSinceLastDeposit;
  final List<PiggyAchievement> achievements;

  const PiggyPetState({
    required this.level,
    required this.stageName,
    required this.stageEmoji,
    required this.levelProgress,
    required this.mood,
    required this.moodEmoji,
    required this.moodLabel,
    required this.message,
    required this.currentStreak,
    required this.longestStreak,
    required this.daysSinceLastDeposit,
    required this.achievements,
  });

  int get unlockedAchievementCount =>
      achievements.where((item) => item.isUnlocked).length;
}
