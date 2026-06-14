import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/piggy.dart';
import '../models/piggy_deposit.dart';
import '../models/activity_log.dart';

class PiggyApiService {
  // Nếu chạy bằng Android Emulator thì dùng 10.0.2.2
  // static const String baseUrl = 'http://10.0.2.2:8080/api/piggies';

  // Nếu chạy bằng Chrome web thì đổi thành:
  static const String baseUrl = 'http://localhost:8080/api/piggies';

  Future<List<Piggy>> getPiggies() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Piggy.fromJson(item)).toList();
    }

    throw Exception('Không thể lấy danh sách Piggy');
  }

  Future<Piggy> createPiggy({
    required String name,
    required String avatar,
    required double targetAmount,
    required DateTime startDate,
    required DateTime endDate,
    required String note,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'avatar': avatar,
        'targetAmount': targetAmount,
        'startDate': startDate.toIso8601String().split('T').first,
        'endDate': endDate.toIso8601String().split('T').first,
        'note': note,
      }),
    );

    if (response.statusCode == 200) {
      return Piggy.fromJson(jsonDecode(response.body));
    }

    final errorMessage = utf8.decode(response.bodyBytes);

    throw Exception(
      errorMessage.isEmpty ? 'Không thể tạo Piggy' : errorMessage,
    );
  }

  Future<Piggy> addMoney({
    required int piggyId,
    required double amount,
    required String note,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$piggyId/deposit'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'note': note,
      }),
    );

    if (response.statusCode == 200) {
      return Piggy.fromJson(jsonDecode(response.body));
    }

    throw Exception('Không thể bỏ tiền vào Piggy');
  }

  Future<List<PiggyDeposit>> getDeposits(int piggyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$piggyId/deposits'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => PiggyDeposit.fromJson(item)).toList();
    }

    throw Exception('Không thể lấy lịch sử bỏ tiền');
  }

  Future<Piggy> breakPiggy(int piggyId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$piggyId/break'),
    );

    if (response.statusCode == 200) {
      return Piggy.fromJson(jsonDecode(response.body));
    }

    throw Exception('Không thể đập Piggy');
  }

  Future<void> deletePiggy(int piggyId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$piggyId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa Piggy');
    }
  }

  Future<List<ActivityLog>> getRecentActivities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/activities/recent'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ActivityLog.fromJson(item)).toList();
    }

    throw Exception('Không thể lấy hoạt động gần nhất');
  }
}