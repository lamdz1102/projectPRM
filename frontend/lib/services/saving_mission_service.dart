import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/piggy.dart';
import '../models/piggy_deposit.dart';
import '../models/saving_mission.dart';
import 'saving_plan_service.dart';

class SavingMissionService {
  const SavingMissionService._();

  static String _completedKey(int piggyId) =>
      'saving_missions_completed_$piggyId';

  static String _xpKey(int piggyId) =>
      'saving_missions_xp_$piggyId';

  static String _activeDaysKey(int piggyId) =>
      'saving_missions_active_days_$piggyId';

  static List<SavingMission> buildDailyMissions({
    required Piggy piggy,
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final dateKey = _dateKey(today);
    final plan = SavingPlanService.calculate(piggy, now: today);

    final suggestedAmount = math.min(
      100000.0,
      math.max(10000.0, plan.requiredPerDay),
    ).toDouble();

    return [
      SavingMission(
        id: '${piggy.id}_${dateKey}_no_spend',
        dateKey: dateKey,
        icon: '🛡️',
        title: 'Ngày không chi tiêu',
        description: 'Không mua một món không cần thiết trong hôm nay.',
        xpReward: 30,
        type: SavingMissionType.noSpend,
        targetAmount: null,
        isCompleted: false,
      ),
      SavingMission(
        id: '${piggy.id}_${dateKey}_deposit',
        dateKey: dateKey,
        icon: '🍎',
        title: 'Cho Piggy ăn',
        description: 'Bỏ ít nhất ${_formatMoney(suggestedAmount)} vào Piggy hôm nay.',
        xpReward: 50,
        type: SavingMissionType.deposit,
        targetAmount: suggestedAmount,
        isCompleted: false,
      ),
      SavingMission(
        id: '${piggy.id}_${dateKey}_reflection',
        dateKey: dateKey,
        icon: '🎯',
        title: 'Nhìn lại mục tiêu',
        description: 'Đọc lại lý do bạn tạo Piggy và cam kết tiếp tục.',
        xpReward: 20,
        type: SavingMissionType.reflection,
        targetAmount: null,
        isCompleted: false,
      ),
    ];
  }

  static Future<List<SavingMission>> loadDailyMissions({
    required Piggy piggy,
    required List<PiggyDeposit> deposits,
    DateTime? now,
  }) async {
    final today = _dateOnly(now ?? DateTime.now());
    final missions = buildDailyMissions(piggy: piggy, now: today);
    final preferences = await SharedPreferences.getInstance();
    final completedIds = preferences
        .getStringList(_completedKey(piggy.id))
        ?.toSet() ??
        <String>{};

    final todayDepositTotal = deposits
        .where((deposit) => _isSameDay(deposit.date, today))
        .fold<double>(0, (sum, deposit) => sum + deposit.amount);

    for (final mission in missions) {
      if (mission.requiresDeposit &&
          todayDepositTotal >= (mission.targetAmount ?? 0) &&
          !completedIds.contains(mission.id)) {
        await completeMission(
          piggyId: piggy.id,
          mission: mission,
        );
        completedIds.add(mission.id);
      }
    }

    return missions
        .map(
          (mission) => mission.copyWith(
        isCompleted: completedIds.contains(mission.id),
      ),
    )
        .toList();
  }

  static Future<bool> completeMission({
    required int piggyId,
    required SavingMission mission,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final completedIds = preferences
        .getStringList(_completedKey(piggyId))
        ?.toSet() ??
        <String>{};

    if (completedIds.contains(mission.id)) return false;

    completedIds.add(mission.id);
    await preferences.setStringList(
      _completedKey(piggyId),
      completedIds.toList(),
    );

    final currentXp = preferences.getInt(_xpKey(piggyId)) ?? 0;
    await preferences.setInt(
      _xpKey(piggyId),
      currentXp + mission.xpReward,
    );

    final activeDays = preferences
        .getStringList(_activeDaysKey(piggyId))
        ?.toSet() ??
        <String>{};
    activeDays.add(mission.dateKey);
    await preferences.setStringList(
      _activeDaysKey(piggyId),
      activeDays.toList(),
    );

    return true;
  }

  static Future<int> getTotalXp(int piggyId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_xpKey(piggyId)) ?? 0;
  }

  static Future<int> getCurrentMissionStreak(
      int piggyId, {
        DateTime? now,
      }) async {
    final preferences = await SharedPreferences.getInstance();
    final activeDays = preferences
        .getStringList(_activeDaysKey(piggyId))
        ?.toSet() ??
        <String>{};

    if (activeDays.isEmpty) return 0;

    var cursor = _dateOnly(now ?? DateTime.now());

    if (!activeDays.contains(_dateKey(cursor))) {
      final yesterday = cursor.subtract(const Duration(days: 1));
      if (!activeDays.contains(_dateKey(yesterday))) return 0;
      cursor = yesterday;
    }

    var streak = 0;
    while (activeDays.contains(_dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static String _formatMoney(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    )}đ';
  }

  static bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
