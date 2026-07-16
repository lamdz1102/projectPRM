import 'package:flutter/material.dart';

import '../models/piggy.dart';
import '../models/piggy_deposit.dart';
import '../models/saving_mission.dart';
import '../services/piggy_api_service.dart';
import '../services/saving_mission_service.dart';

class SavingMissionsScreen extends StatefulWidget {
  final Piggy piggy;

  const SavingMissionsScreen({
    super.key,
    required this.piggy,
  });

  @override
  State<SavingMissionsScreen> createState() =>
      _SavingMissionsScreenState();
}

class _SavingMissionsScreenState extends State<SavingMissionsScreen> {
  final PiggyApiService _apiService = PiggyApiService();

  bool _loading = true;
  String? _error;
  List<SavingMission> _missions = const [];
  int _totalXp = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<PiggyDeposit> deposits =
      await _apiService.getDeposits(widget.piggy.id);
      final missions = await SavingMissionService.loadDailyMissions(
        piggy: widget.piggy,
        deposits: deposits,
      );
      final xp = await SavingMissionService.getTotalXp(widget.piggy.id);
      final streak = await SavingMissionService.getCurrentMissionStreak(
        widget.piggy.id,
      );

      if (!mounted) return;

      setState(() {
        _missions = missions;
        _totalXp = xp;
        _streak = streak;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _completeMission(SavingMission mission) async {
    if (mission.requiresDeposit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nhiệm vụ này được xác nhận tự động sau khi bạn bỏ đủ tiền vào Piggy.',
          ),
        ),
      );
      return;
    }

    final completed = await SavingMissionService.completeMission(
      piggyId: widget.piggy.id,
      mission: mission,
    );

    if (!mounted) return;

    if (completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hoàn thành nhiệm vụ! Bạn nhận ${mission.xpReward} XP.',
          ),
        ),
      );
    }

    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount =
        _missions.where((mission) => mission.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhiệm vụ tiết kiệm'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 260),
            Center(child: CircularProgressIndicator()),
          ],
        )
            : _error != null
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 120),
            const Icon(Icons.error_outline, size: 52),
            const SizedBox(height: 12),
            Text(
              'Không thể tải nhiệm vụ: $_error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ),
          ],
        )
            : ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade100,
                    Colors.orange.shade100,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('🏅', style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 8),
                  const Text(
                    'Thử thách mỗi ngày',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hoàn thành $completedCount/${_missions.length} nhiệm vụ hôm nay',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _missions.isEmpty
                        ? 0
                        : completedCount / _missions.length,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryBox(
                          icon: '⭐',
                          label: 'Tổng XP',
                          value: '$_totalXp XP',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryBox(
                          icon: '🔥',
                          label: 'Chuỗi nhiệm vụ',
                          value: '$_streak ngày',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._missions.map(
                  (mission) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _MissionTile(
                  mission: mission,
                  onComplete: () => _completeMission(mission),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                '💡 Nhiệm vụ “Cho Piggy ăn” được kiểm tra tự động từ '
                    'lịch sử bỏ tiền. Hai nhiệm vụ còn lại do bạn tự xác nhận.',
                style: TextStyle(height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  final SavingMission mission;
  final VoidCallback onComplete;

  const _MissionTile({
    required this.mission,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: mission.isCompleted ? 0 : 2,
      color: mission.isCompleted ? Colors.green.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                mission.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mission.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '+${mission.xpReward} XP',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mission.description,
                    style: const TextStyle(
                      color: Colors.black54,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: mission.isCompleted
                        ? const Chip(
                      avatar: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 19,
                      ),
                      label: Text('Đã hoàn thành'),
                    )
                        : OutlinedButton.icon(
                      onPressed: onComplete,
                      icon: Icon(
                        mission.requiresDeposit
                            ? Icons.savings_outlined
                            : Icons.check,
                      ),
                      label: Text(
                        mission.requiresDeposit
                            ? 'Kiểm tra tự động'
                            : 'Đánh dấu hoàn thành',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _SummaryBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
