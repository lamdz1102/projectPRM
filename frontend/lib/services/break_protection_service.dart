import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/break_protection_request.dart';

class BreakProtectionService {
  const BreakProtectionService._();

  // Chế độ demo: đợi 1 phút. Khi đưa vào sử dụng thật có thể đổi thành:
  // static const Duration cooldownDuration = Duration(hours: 24);
  static const Duration cooldownDuration = Duration(minutes: 1);

  static String _requestKey(int piggyId) =>
      'break_protection_request_$piggyId';

  static Future<BreakProtectionRequest?> getRequest(int piggyId) async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_requestKey(piggyId));

    if (rawValue == null || rawValue.isEmpty) return null;

    try {
      final json = jsonDecode(rawValue) as Map<String, dynamic>;
      return BreakProtectionRequest.fromJson(json);
    } catch (_) {
      await preferences.remove(_requestKey(piggyId));
      return null;
    }
  }

  static Future<BreakProtectionRequest> createRequest({
    required int piggyId,
    required String reason,
    DateTime? now,
  }) async {
    final requestTime = now ?? DateTime.now();
    final request = BreakProtectionRequest(
      piggyId: piggyId,
      reason: reason,
      requestedAt: requestTime,
      availableAt: requestTime.add(cooldownDuration),
    );

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _requestKey(piggyId),
      jsonEncode(request.toJson()),
    );

    return request;
  }

  static Future<void> clearRequest(int piggyId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_requestKey(piggyId));
  }
}
