import 'package:flutter/material.dart';
import '../models/piggy.dart';
import '../models/saving_plan.dart';
import '../services/saving_plan_service.dart';
import '../services/piggy_pet_service.dart';

class PiggyCard extends StatelessWidget {
  final Piggy piggy;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PiggyCard({
    super.key,
    required this.piggy,
    required this.onTap,
    required this.onDelete,
  });

  String formatMoney(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    )}đ';
  }

  Color getStatusColor() {
    if (piggy.isBroken || piggy.status == 'BROKEN') return Colors.redAccent;
    if (piggy.status == 'LOCKED') return Colors.grey;
    if (piggy.status == 'COMPLETED') return Colors.green;
    return Colors.pinkAccent;
  }

  String getPlanSummary(SavingPlan plan) {
    if (piggy.isBroken || piggy.status == 'BROKEN') {
      return 'Piggy đã kết thúc';
    }

    switch (plan.status) {
      case SavingPlanStatus.completed:
        return 'Đã hoàn thành mục tiêu';
      case SavingPlanStatus.expired:
        return 'Đã quá hạn, còn thiếu ${formatMoney(plan.remainingAmount)}';
      default:
        return 'Gợi ý: ${formatMoney(plan.requiredPerDay)}/ngày';
    }
  }

  @override
  Widget build(BuildContext context) {
    final savingPlan = SavingPlanService.calculate(piggy);
    final petLevel = PiggyPetService.levelFromProgress(piggy.progress);
    final petStage = PiggyPetService.stageNameForLevel(petLevel);
    final petEmoji = PiggyPetService.stageEmojiForLevel(petLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: piggy.isBroken
                        ? Colors.red.shade100
                        : const Color(0xFFFFE4EF),
                    child: Text(
                      piggy.isBroken ? '💥' : piggy.avatar,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      piggy.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                  ),

                  Chip(
                    label: Text(
                      piggy.displayStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: getStatusColor(),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$petEmoji Cấp $petLevel • $petStage',
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                '${formatMoney(piggy.currentAmount)} / ${formatMoney(piggy.targetAmount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: piggy.progress,
                minHeight: 9,
                borderRadius: BorderRadius.circular(20),
                backgroundColor: Colors.grey.shade200,
                color: getStatusColor(),
              ),

              const SizedBox(height: 10),

              Text(
                piggy.isLocked
                    ? 'Piggy đã hết thời gian tiết kiệm'
                    : 'Còn ${piggy.daysLeft} ngày',
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.auto_graph,
                    size: 16,
                    color: getStatusColor(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      getPlanSummary(savingPlan),
                      style: TextStyle(
                        color: getStatusColor(),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}