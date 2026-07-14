import 'package:flutter/material.dart';

import '../models/piggy.dart';
import '../models/piggy_deposit.dart';
import '../models/piggy_pet_state.dart';
import '../services/piggy_api_service.dart';
import '../services/piggy_pet_service.dart';

class PiggyPetCard extends StatefulWidget {
  final Piggy piggy;

  const PiggyPetCard({
    super.key,
    required this.piggy,
  });

  @override
  State<PiggyPetCard> createState() => _PiggyPetCardState();
}

class _PiggyPetCardState extends State<PiggyPetCard> {
  final PiggyApiService _apiService = PiggyApiService();
  late Future<List<PiggyDeposit>> _depositsFuture;

  @override
  void initState() {
    super.initState();
    _depositsFuture = _apiService.getDeposits(widget.piggy.id);
  }

  @override
  void didUpdateWidget(covariant PiggyPetCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.piggy.id != widget.piggy.id ||
        oldWidget.piggy.currentAmount != widget.piggy.currentAmount) {
      _depositsFuture = _apiService.getDeposits(widget.piggy.id);
    }
  }

  void _reload() {
    setState(() {
      _depositsFuture = _apiService.getDeposits(widget.piggy.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PiggyDeposit>>(
      future: _depositsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Text(
                    'Không thể tải trạng thái Heo đất ảo.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final state = PiggyPetService.calculate(
          piggy: widget.piggy,
          deposits: snapshot.data ?? const [],
        );

        return _PetContent(state: state);
      },
    );
  }
}

class _PetContent extends StatelessWidget {
  final PiggyPetState state;

  const _PetContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final unlockedAchievements = state.achievements
        .where((item) => item.isUnlocked)
        .toList();

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
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    state.stageEmoji,
                    style: const TextStyle(fontSize: 38),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Heo đất ảo',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cấp ${state.level} • ${state.stageName}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${state.moodEmoji} ${state.moodLabel}',
                        style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '“${state.message}”',
                style: const TextStyle(height: 1.35),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.level >= 5
                      ? 'Đã đạt cấp tối đa'
                      : 'Tiến độ lên cấp ${state.level + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(state.levelProgress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: state.levelProgress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(20),
              color: Colors.orangeAccent,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    icon: '🔥',
                    title: 'Chuỗi hiện tại',
                    value: '${state.currentStreak} ngày',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBox(
                    icon: '🏅',
                    title: 'Kỷ lục',
                    value: '${state.longestStreak} ngày',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Huy hiệu đã mở khóa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${state.unlockedAchievementCount}/${state.achievements.length}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (unlockedAchievements.isEmpty)
              const Text(
                'Chưa có huy hiệu. Hãy thực hiện lần tiết kiệm đầu tiên!',
                style: TextStyle(color: Colors.black54),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: unlockedAchievements.map((achievement) {
                  return Tooltip(
                    message: achievement.description,
                    child: Chip(
                      avatar: Text(achievement.icon),
                      label: Text(achievement.title),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const _StatBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
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
