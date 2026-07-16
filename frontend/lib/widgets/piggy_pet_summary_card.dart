import 'package:flutter/material.dart';

import '../models/piggy.dart';
import '../models/piggy_deposit.dart';
import '../models/piggy_pet_state.dart';
import '../services/piggy_api_service.dart';
import '../services/piggy_pet_service.dart';

class PiggyPetSummaryCard extends StatefulWidget {
  final Piggy piggy;
  final VoidCallback onTap;

  const PiggyPetSummaryCard({
    super.key,
    required this.piggy,
    required this.onTap,
  });

  @override
  State<PiggyPetSummaryCard> createState() =>
      _PiggyPetSummaryCardState();
}

class _PiggyPetSummaryCardState extends State<PiggyPetSummaryCard> {
  final PiggyApiService _apiService = PiggyApiService();
  late Future<List<PiggyDeposit>> _depositsFuture;

  @override
  void initState() {
    super.initState();
    _loadDeposits();
  }

  @override
  void didUpdateWidget(covariant PiggyPetSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.piggy.id != widget.piggy.id ||
        oldWidget.piggy.currentAmount != widget.piggy.currentAmount) {
      _loadDeposits();
    }
  }

  void _loadDeposits() {
    _depositsFuture = _apiService.getDeposits(widget.piggy.id);
  }

  void _retry() {
    setState(_loadDeposits);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PiggyDeposit>>(
      future: _depositsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingSummaryCard();
        }

        if (snapshot.hasError) {
          return Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: const CircleAvatar(
                child: Icon(Icons.pets_outlined),
              ),
              title: const Text('Heo đất ảo'),
              subtitle: const Text('Không thể tải trạng thái'),
              trailing: IconButton(
                onPressed: _retry,
                tooltip: 'Thử lại',
                icon: const Icon(Icons.refresh),
              ),
            ),
          );
        }

        final PiggyPetState state = PiggyPetService.calculate(
          piggy: widget.piggy,
          deposits: snapshot.data ?? const [],
        );

        return Card(
          margin: EdgeInsets.zero,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      state.stageEmoji,
                      style: const TextStyle(fontSize: 30),
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
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Cấp ${state.level} • ${state.stageName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.moodEmoji} ${state.moodLabel}'
                              '  •  🔥 ${state.currentStreak} ngày',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingSummaryCard extends StatelessWidget {
  const _LoadingSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(width: 14),
            Text('Đang tải trạng thái Heo đất ảo...'),
          ],
        ),
      ),
    );
  }
}
