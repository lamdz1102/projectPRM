import 'package:flutter/material.dart';

import '../models/piggy.dart';
import '../models/piggy_deposit.dart';
import '../models/saving_mission.dart';
import '../screens/saving_missions_screen.dart';
import '../services/piggy_api_service.dart';
import '../services/saving_mission_service.dart';

class SavingMissionCard extends StatefulWidget {
  final Piggy piggy;

  const SavingMissionCard({
    super.key,
    required this.piggy,
  });

  @override
  State<SavingMissionCard> createState() => _SavingMissionCardState();
}

class _SavingMissionCardState extends State<SavingMissionCard> {
  final PiggyApiService _apiService = PiggyApiService();

  bool _loading = true;
  List<SavingMission> _missions = const [];
  int _totalXp = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  @override
  void didUpdateWidget(covariant SavingMissionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.piggy.id != widget.piggy.id ||
        oldWidget.piggy.currentAmount != widget.piggy.currentAmount) {
      _loadSummary();
    }
  }

  Future<void> _loadSummary() async {
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
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openMissions() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SavingMissionsScreen(piggy: widget.piggy),
      ),
    );

    await _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final completed =
        _missions.where((mission) => mission.isCompleted).length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Text('🏅', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhiệm vụ tiết kiệm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Biến thói quen nhỏ thành phần thưởng mỗi ngày.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Hôm nay',
                      value: '$completed/${_missions.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      label: 'Tổng XP',
                      value: '$_totalXp',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      label: 'Chuỗi',
                      value: '$_streak ngày',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: _missions.isEmpty ? 0 : completed / _missions.length,
                minHeight: 9,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openMissions,
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Xem nhiệm vụ hôm nay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
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
