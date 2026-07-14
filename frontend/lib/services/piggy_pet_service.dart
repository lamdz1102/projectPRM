import '../models/piggy.dart';
import '../models/piggy_deposit.dart';
import '../models/piggy_pet_state.dart';
import '../models/saving_plan.dart';
import 'saving_plan_service.dart';

class PiggyPetService {
  const PiggyPetService._();

  static PiggyPetState calculate({
    required Piggy piggy,
    required List<PiggyDeposit> deposits,
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final depositDays = deposits
        .map((item) => _dateOnly(item.date))
        .toSet()
        .toList()
      ..sort();

    final currentStreak = _calculateCurrentStreak(
      depositDays,
      today,
    );
    final longestStreak = _calculateLongestStreak(depositDays);

    final DateTime? lastDepositDate =
    depositDays.isEmpty ? null : depositDays.last;
    final int? daysSinceLastDeposit = lastDepositDate == null
        ? null
        : today.difference(lastDepositDate).inDays;

    final level = levelFromProgress(piggy.progress);
    final savingPlan = SavingPlanService.calculate(piggy, now: today);
    final moodData = _resolveMood(
      piggy: piggy,
      deposits: deposits,
      currentStreak: currentStreak,
      daysSinceLastDeposit: daysSinceLastDeposit,
      savingPlanStatus: savingPlan.status,
    );

    return PiggyPetState(
      level: level,
      stageName: stageNameForLevel(level),
      stageEmoji: stageEmojiForLevel(level),
      levelProgress: levelProgress(piggy.progress),
      mood: moodData.mood,
      moodEmoji: moodData.emoji,
      moodLabel: moodData.label,
      message: moodData.message,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      daysSinceLastDeposit: daysSinceLastDeposit,
      achievements: _buildAchievements(
        piggy: piggy,
        deposits: deposits,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      ),
    );
  }

  static int levelFromProgress(double progress) {
    if (progress >= 1) return 5;
    if (progress >= 0.6) return 4;
    if (progress >= 0.3) return 3;
    if (progress >= 0.1) return 2;
    return 1;
  }

  static String stageNameForLevel(int level) {
    switch (level) {
      case 5:
        return 'Piggy huyền thoại';
      case 4:
        return 'Piggy hoàng gia';
      case 3:
        return 'Piggy trưởng thành';
      case 2:
        return 'Piggy con';
      default:
        return 'Trứng Piggy';
    }
  }

  static String stageEmojiForLevel(int level) {
    switch (level) {
      case 5:
        return '🏆';
      case 4:
        return '👑';
      case 3:
        return '🐖';
      case 2:
        return '🐷';
      default:
        return '🥚';
    }
  }

  static double levelProgress(double progress) {
    final normalized = progress.clamp(0.0, 1.0).toDouble();

    if (normalized >= 1) return 1;
    if (normalized >= 0.6) {
      return ((normalized - 0.6) / 0.4).clamp(0.0, 1.0).toDouble();
    }
    if (normalized >= 0.3) {
      return ((normalized - 0.3) / 0.3).clamp(0.0, 1.0).toDouble();
    }
    if (normalized >= 0.1) {
      return ((normalized - 0.1) / 0.2).clamp(0.0, 1.0).toDouble();
    }
    return (normalized / 0.1).clamp(0.0, 1.0).toDouble();
  }

  static int _calculateCurrentStreak(
      List<DateTime> depositDays,
      DateTime today,
      ) {
    if (depositDays.isEmpty) return 0;

    final latestDay = depositDays.last;
    final gapFromToday = today.difference(latestDay).inDays;

    // Cho phép giao dịch gần nhất là hôm qua để chuỗi chưa bị mất
    // trước khi ngày hôm nay kết thúc.
    if (gapFromToday > 1) return 0;

    int streak = 1;
    DateTime expectedPreviousDay = latestDay.subtract(
      const Duration(days: 1),
    );

    for (int index = depositDays.length - 2; index >= 0; index--) {
      final day = depositDays[index];

      if (day.isAtSameMomentAs(expectedPreviousDay)) {
        streak++;
        expectedPreviousDay = expectedPreviousDay.subtract(
          const Duration(days: 1),
        );
      } else if (day.isBefore(expectedPreviousDay)) {
        break;
      }
    }

    return streak;
  }

  static int _calculateLongestStreak(List<DateTime> depositDays) {
    if (depositDays.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int index = 1; index < depositDays.length; index++) {
      final difference = depositDays[index]
          .difference(depositDays[index - 1])
          .inDays;

      if (difference == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }

    return longest;
  }

  static _MoodData _resolveMood({
    required Piggy piggy,
    required List<PiggyDeposit> deposits,
    required int currentStreak,
    required int? daysSinceLastDeposit,
    required SavingPlanStatus savingPlanStatus,
  }) {
    if (piggy.isBroken || piggy.status == 'BROKEN') {
      return const _MoodData(
        mood: 'broken',
        emoji: '💥',
        label: 'Đã kết thúc',
        message: 'Piggy đã được đập và kết thúc hành trình tiết kiệm.',
      );
    }

    if (piggy.progress >= 1 || piggy.status == 'COMPLETED') {
      return const _MoodData(
        mood: 'celebrating',
        emoji: '🥳',
        label: 'Đang ăn mừng',
        message: 'Tuyệt vời! Piggy đã hoàn thành mục tiêu của mình.',
      );
    }

    if (deposits.isEmpty) {
      return const _MoodData(
        mood: 'hungry',
        emoji: '🥺',
        label: 'Đang chờ bạn',
        message: 'Piggy đang đói. Hãy cho Piggy ăn khoản tiền đầu tiên!',
      );
    }

    if (currentStreak >= 7) {
      return _MoodData(
        mood: 'excited',
        emoji: '🔥',
        label: 'Cực kỳ hào hứng',
        message: 'Bạn đã duy trì chuỗi $currentStreak ngày. Đừng dừng lại nhé!',
      );
    }

    if (daysSinceLastDeposit != null && daysSinceLastDeposit >= 7) {
      return _MoodData(
        mood: 'sad',
        emoji: '😢',
        label: 'Đang buồn',
        message: 'Đã $daysSinceLastDeposit ngày Piggy chưa được cho ăn.',
      );
    }

    if (daysSinceLastDeposit != null && daysSinceLastDeposit >= 3) {
      return _MoodData(
        mood: 'sleepy',
        emoji: '😴',
        label: 'Đang buồn ngủ',
        message: 'Piggy nhớ bạn rồi. Hãy tiếp tục mục tiêu tiết kiệm nhé!',
      );
    }

    if (savingPlanStatus == SavingPlanStatus.behind ||
        savingPlanStatus == SavingPlanStatus.expired) {
      return const _MoodData(
        mood: 'worried',
        emoji: '😟',
        label: 'Đang lo lắng',
        message: 'Tiến độ đang chậm hơn kế hoạch. Cùng Piggy cố gắng thêm nhé!',
      );
    }

    if (currentStreak >= 3) {
      return _MoodData(
        mood: 'happy',
        emoji: '😊',
        label: 'Đang vui vẻ',
        message: 'Chuỗi $currentStreak ngày rất tuyệt. Piggy đang lớn lên từng ngày!',
      );
    }

    return const _MoodData(
      mood: 'happy',
      emoji: '😊',
      label: 'Đang vui vẻ',
      message: 'Piggy rất vui vì bạn vẫn đang kiên trì tiết kiệm.',
    );
  }

  static List<PiggyAchievement> _buildAchievements({
    required Piggy piggy,
    required List<PiggyDeposit> deposits,
    required int currentStreak,
    required int longestStreak,
  }) {
    final completionDate = _findCompletionDate(
      deposits: deposits,
      targetAmount: piggy.targetAmount,
    );

    return [
      PiggyAchievement(
        id: 'first_deposit',
        icon: '🌱',
        title: 'Khởi đầu tốt',
        description: 'Thực hiện lần gửi tiền đầu tiên',
        isUnlocked: deposits.isNotEmpty,
      ),
      PiggyAchievement(
        id: 'streak_3',
        icon: '🔥',
        title: 'Kiên trì 3 ngày',
        description: 'Tiết kiệm liên tiếp ít nhất 3 ngày',
        isUnlocked: longestStreak >= 3 || currentStreak >= 3,
      ),
      PiggyAchievement(
        id: 'streak_7',
        icon: '⚡',
        title: 'Kiên trì 7 ngày',
        description: 'Tiết kiệm liên tiếp ít nhất 7 ngày',
        isUnlocked: longestStreak >= 7 || currentStreak >= 7,
      ),
      PiggyAchievement(
        id: 'halfway',
        icon: '🎯',
        title: 'Nửa chặng đường',
        description: 'Hoàn thành 50% mục tiêu',
        isUnlocked: piggy.progress >= 0.5,
      ),
      PiggyAchievement(
        id: 'almost_done',
        icon: '💎',
        title: 'Gần cán đích',
        description: 'Hoàn thành 80% mục tiêu',
        isUnlocked: piggy.progress >= 0.8,
      ),
      PiggyAchievement(
        id: 'completed',
        icon: '🏆',
        title: 'Chinh phục mục tiêu',
        description: 'Hoàn thành 100% mục tiêu',
        isUnlocked: piggy.progress >= 1,
      ),
      PiggyAchievement(
        id: 'early_finish',
        icon: '⏰',
        title: 'Về đích sớm',
        description: 'Hoàn thành mục tiêu trước hoặc đúng hạn',
        isUnlocked: completionDate != null &&
            !_dateOnly(completionDate).isAfter(_dateOnly(piggy.endDate)),
      ),
    ];
  }

  static DateTime? _findCompletionDate({
    required List<PiggyDeposit> deposits,
    required double targetAmount,
  }) {
    if (targetAmount <= 0 || deposits.isEmpty) return null;

    final sortedDeposits = [...deposits]
      ..sort((a, b) => a.date.compareTo(b.date));

    double total = 0;
    for (final deposit in sortedDeposits) {
      total += deposit.amount;
      if (total >= targetAmount) return deposit.date;
    }

    return null;
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class _MoodData {
  final String mood;
  final String emoji;
  final String label;
  final String message;

  const _MoodData({
    required this.mood,
    required this.emoji,
    required this.label,
    required this.message,
  });
}
