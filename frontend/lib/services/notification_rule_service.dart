import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/piggy.dart';
import 'notification_service.dart';

typedef ContextNotificationCallback = Future<void> Function({
required int piggyId,
required String piggyName,
required String title,
required String body,
});

class NotificationRuleService {
  static const String _enabledKey = 'context_notifications_enabled';
  static const double _progress50Milestone = 0.5;
  static const double _progress80Milestone = 0.8;
  static const int _deadlineReminderDays = 3;
  static ContextNotificationCallback? onContextNotificationSent;

  static int _progress50NotificationId(int piggyId) => 500000 + piggyId;
  static int _progress80NotificationId(int piggyId) => 100000 + piggyId;
  static int _completedNotificationId(int piggyId) => 200000 + piggyId;
  static int _deadlineNotificationId(int piggyId) => 300000 + piggyId;
  static int _scheduledDeadlineNotificationId(int piggyId) => 400000 + piggyId;
  static int _slowProgressNotificationId(int piggyId) => 600000 + piggyId;
  static int _overdueNotificationId(int piggyId) => 700000 + piggyId;
  static int _noStartNotificationId(int piggyId) => 800000 + piggyId;
  static const int dailyReminderNotificationId = 900001;

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);

    if (!value) {
      await NotificationService.instance.cancelAll();
    }
  }

  static Future<void> checkPiggies(List<Piggy> piggies) async {
    if (!await isEnabled()) return;

    for (final piggy in piggies) {
      await checkPiggy(piggy);
      await scheduleDeadlineReminder(piggy);
    }
  }

  static Future<void> checkPiggy(Piggy piggy) async {
    if (!await isEnabled()) return;
    if (_isInactive(piggy)) return;

    // 1. Hoàn thành 100%
    if (piggy.progress >= 1) {
      await _sendOnce(
        key: 'piggy_${piggy.id}_completed',
        notificationId: _completedNotificationId(piggy.id),
        piggyId: piggy.id,
        piggyName: piggy.name,
        title: 'Chúc mừng hoàn thành mục tiêu 🎉',
        body: 'Bạn đã hoàn thành Piggy "${piggy.name}" rồi!',
      );
      return;
    }

    // 2. Quá hạn nhưng chưa hoàn thành
    if (piggy.daysLeft < 0 && piggy.progress < 1) {
      await _sendOnce(
        key: 'piggy_${piggy.id}_overdue',
        notificationId: _overdueNotificationId(piggy.id),
        piggyId: piggy.id,
        piggyName: piggy.name,
        title: 'Piggy đã quá hạn ⚠️',
        body: 'Mục tiêu "${piggy.name}" đã quá hạn nhưng chưa hoàn thành.',
      );
      return;
    }

    // 3. Đã tạo Piggy nhưng chưa bắt đầu tiết kiệm
    if (_hasNotStartedAfterOneDay(piggy)) {
      await _sendOnce(
        key: 'piggy_${piggy.id}_not_started',
        notificationId: _noStartNotificationId(piggy.id),
        piggyId: piggy.id,
        piggyName: piggy.name,
        title: 'Piggy chưa được bắt đầu 🐷',
        body: 'Bạn đã tạo "${piggy.name}" nhưng chưa bỏ tiền vào mục tiêu này.',
      );
    }

    // 4. Gần deadline
    if (piggy.daysLeft >= 0 && piggy.daysLeft <= _deadlineReminderDays) {
      if (piggy.progress < _progress50Milestone) {
        await _sendOnce(
          key: 'piggy_${piggy.id}_slow_near_deadline',
          notificationId: _slowProgressNotificationId(piggy.id),
          piggyId: piggy.id,
          piggyName: piggy.name,
          title: 'Mục tiêu đang chậm tiến độ ⚠️',
          body:
          'Còn ${piggy.daysLeft} ngày nhưng "${piggy.name}" mới đạt ${(piggy.progress * 100).toStringAsFixed(0)}%.',
        );
      } else {
        await _sendOnce(
          key: 'piggy_${piggy.id}_deadline_3_days',
          notificationId: _deadlineNotificationId(piggy.id),
          piggyId: piggy.id,
          piggyName: piggy.name,
          title: 'Piggy sắp đến hạn ⏰',
          body:
          'Còn ${piggy.daysLeft} ngày để hoàn thành mục tiêu "${piggy.name}".',
        );
      }
    } else if (_isBehindSchedule(piggy)) {
      // 5. Đã qua hơn nửa thời gian nhưng tiến độ dưới 50%
      await _sendOnce(
        key: 'piggy_${piggy.id}_behind_schedule',
        notificationId: _slowProgressNotificationId(piggy.id),
        piggyId: piggy.id,
        piggyName: piggy.name,
        title: 'Bạn đang chậm hơn kế hoạch 📉',
        body:
        'Mục tiêu "${piggy.name}" đã đi qua hơn nửa thời gian nhưng mới đạt ${(piggy.progress * 100).toStringAsFixed(0)}%.',
      );
    }

    // 6. Đạt 80%
    if (piggy.progress >= _progress80Milestone) {
      await _sendOnce(
        key: 'piggy_${piggy.id}_progress_80',
        notificationId: _progress80NotificationId(piggy.id),
        piggyId: piggy.id,
        piggyName: piggy.name,
        title: 'Sắp đạt mục tiêu rồi 🐷',
        body:
        'Piggy "${piggy.name}" đã đạt ${(piggy.progress * 100).toStringAsFixed(0)}%. Cố thêm chút nữa nhé!',
      );
    } else if (piggy.progress >= _progress50Milestone) {
      // 7. Đạt 50%
      await _sendOnce(
        key: 'piggy_${piggy.id}_progress_50',
        notificationId: _progress50NotificationId(piggy.id),
        piggyId: piggy.id,
        piggyName: piggy.name,
        title: 'Bạn đã đi được nửa chặng đường 💪',
        body: 'Piggy "${piggy.name}" đã đạt 50% mục tiêu tiết kiệm.',
      );
    }
  }

  static Future<void> checkAfterDeposit({
    required Piggy oldPiggy,
    required Piggy newPiggy,
  }) async {
    if (!await isEnabled()) return;
    if (_isInactive(newPiggy)) return;

    final oldProgress = oldPiggy.progress;
    final newProgress = newPiggy.progress;

    if (oldProgress < 1 && newProgress >= 1) {
      await _sendOnce(
        key: 'piggy_${newPiggy.id}_completed',
        notificationId: _completedNotificationId(newPiggy.id),
        piggyId: newPiggy.id,
        piggyName: newPiggy.name,
        title: 'Chúc mừng hoàn thành mục tiêu 🎉',
        body: 'Bạn đã hoàn thành Piggy "${newPiggy.name}" rồi!',
      );
      return;
    }

    if (oldProgress < _progress80Milestone &&
        newProgress >= _progress80Milestone) {
      await _sendOnce(
        key: 'piggy_${newPiggy.id}_progress_80',
        notificationId: _progress80NotificationId(newPiggy.id),
        piggyId: newPiggy.id,
        piggyName: newPiggy.name,
        title: 'Bạn đã đạt mốc 80% 🐷',
        body: 'Piggy "${newPiggy.name}" đã đạt 80% mục tiêu tiết kiệm.',
      );
    } else if (oldProgress < _progress50Milestone &&
        newProgress >= _progress50Milestone) {
      await _sendOnce(
        key: 'piggy_${newPiggy.id}_progress_50',
        notificationId: _progress50NotificationId(newPiggy.id),
        piggyId: newPiggy.id,
        piggyName: newPiggy.name,
        title: 'Bạn đã đạt mốc 50% 💪',
        body: 'Piggy "${newPiggy.name}" đã đi được nửa chặng đường.',
      );
    }

    await checkPiggy(newPiggy);
  }

  static Future<void> scheduleDeadlineReminder(Piggy piggy) async {
    if (!await isEnabled()) return;
    if (_isInactive(piggy)) return;

    final reminderDate = DateTime(
      piggy.endDate.year,
      piggy.endDate.month,
      piggy.endDate.day,
      9,
      0,
    ).subtract(const Duration(days: _deadlineReminderDays));

    await NotificationService.instance.schedulePiggyNotification(
      notificationId: _scheduledDeadlineNotificationId(piggy.id),
      title: 'Piggy sắp đến hạn ⏰',
      body:
      'Còn $_deadlineReminderDays ngày để hoàn thành mục tiêu "${piggy.name}".',
      piggyId: piggy.id,
      scheduledAt: reminderDate,
    );
  }

  static Future<void> scheduleDailySavingReminder({
    int hour = 20,
    int minute = 0,
  }) async {
    if (!await isEnabled()) return;

    await NotificationService.instance.scheduleDailySavingReminder(
      notificationId: dailyReminderNotificationId,
      hour: hour,
      minute: minute,
    );
  }

  static Future<void> cancelPiggySchedules(int piggyId) async {
    await NotificationService.instance.cancel(_progress50NotificationId(piggyId));
    await NotificationService.instance.cancel(_progress80NotificationId(piggyId));
    await NotificationService.instance.cancel(_completedNotificationId(piggyId));
    await NotificationService.instance.cancel(_deadlineNotificationId(piggyId));
    await NotificationService.instance.cancel(_scheduledDeadlineNotificationId(piggyId));
    await NotificationService.instance.cancel(_slowProgressNotificationId(piggyId));
    await NotificationService.instance.cancel(_overdueNotificationId(piggyId));
    await NotificationService.instance.cancel(_noStartNotificationId(piggyId));
  }

  static Future<void> clearPiggyFlags(int piggyId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('piggy_${piggyId}_progress_50');
    await prefs.remove('piggy_${piggyId}_progress_80');
    await prefs.remove('piggy_${piggyId}_completed');
    await prefs.remove('piggy_${piggyId}_deadline_3_days');
    await prefs.remove('piggy_${piggyId}_slow_near_deadline');
    await prefs.remove('piggy_${piggyId}_behind_schedule');
    await prefs.remove('piggy_${piggyId}_overdue');
    await prefs.remove('piggy_${piggyId}_not_started');
  }

  static Future<void> _sendOnce({
    required String key,
    required int notificationId,
    required int piggyId,
    required String piggyName,
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySent = prefs.getBool(key) ?? false;

    if (alreadySent) return;

    try {
      await NotificationService.instance.showPiggyNotification(
        notificationId: notificationId,
        title: title,
        body: body,
        piggyId: piggyId,
      );

      await prefs.setBool(key, true);

      await onContextNotificationSent?.call(
        piggyId: piggyId,
        piggyName: piggyName,
        title: title,
        body: body,
      );
    } catch (e) {
      debugPrint('Không thể gửi notification: $e');
    }
  }

  static bool _hasNotStartedAfterOneDay(Piggy piggy) {
    final daysSinceStart = DateTime.now().difference(piggy.startDate).inDays;
    return piggy.currentAmount <= 0 && daysSinceStart >= 1 && piggy.daysLeft >= 0;
  }

  static bool _isBehindSchedule(Piggy piggy) {
    return _elapsedRatio(piggy) >= 0.5 && piggy.progress < _progress50Milestone;
  }

  static double _elapsedRatio(Piggy piggy) {
    final totalSeconds = piggy.endDate.difference(piggy.startDate).inSeconds;
    if (totalSeconds <= 0) return 1;

    final elapsedSeconds = DateTime.now().difference(piggy.startDate).inSeconds;
    return (elapsedSeconds / totalSeconds).clamp(0, 1).toDouble();
  }

  static bool _isInactive(Piggy piggy) {
    return piggy.isBroken || piggy.status == 'BROKEN';
  }
}
