import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/piggy.dart';
import '../models/saving_plan.dart';
import '../services/saving_plan_service.dart';

class SavingPlanSummaryCard extends StatelessWidget {
  final Piggy piggy;
  final VoidCallback onTap;

  const SavingPlanSummaryCard({
    super.key,
    required this.piggy,
    required this.onTap,
  });

  String _formatMoney(double value) {
    final String formatted = NumberFormat(
      '#,###',
      'vi_VN',
    ).format(value.round());

    return '${formatted.replaceAll(',', '.')}đ';
  }

  String _formatDate(DateTime value) {
    return DateFormat('dd/MM/yyyy').format(value);
  }

  Color _statusColor(SavingPlanStatus status) {
    switch (status) {
      case SavingPlanStatus.notStarted:
        return Colors.blueGrey;
      case SavingPlanStatus.onTrack:
        return Colors.blue;
      case SavingPlanStatus.ahead:
      case SavingPlanStatus.completed:
        return Colors.green;
      case SavingPlanStatus.behind:
        return Colors.orange;
      case SavingPlanStatus.expired:
        return Colors.redAccent;
    }
  }

  IconData _statusIcon(SavingPlanStatus status) {
    switch (status) {
      case SavingPlanStatus.notStarted:
        return Icons.schedule;
      case SavingPlanStatus.onTrack:
        return Icons.route;
      case SavingPlanStatus.ahead:
        return Icons.trending_up;
      case SavingPlanStatus.behind:
        return Icons.warning_amber_rounded;
      case SavingPlanStatus.completed:
        return Icons.emoji_events_outlined;
      case SavingPlanStatus.expired:
        return Icons.event_busy_outlined;
    }
  }

  String _summary(SavingPlan plan) {
    switch (plan.status) {
      case SavingPlanStatus.notStarted:
        return 'Bắt đầu ngày ${_formatDate(piggy.startDate)}';
      case SavingPlanStatus.completed:
        return 'Bạn đã hoàn thành mục tiêu tiết kiệm';
      case SavingPlanStatus.expired:
        return 'Còn thiếu ${_formatMoney(plan.remainingAmount)}';
      case SavingPlanStatus.onTrack:
      case SavingPlanStatus.ahead:
      case SavingPlanStatus.behind:
        return '${_formatMoney(plan.requiredPerDay)}/ngày'
            '  •  còn ${plan.remainingDays} ngày';
    }
  }

  @override
  Widget build(BuildContext context) {
    final SavingPlan plan = SavingPlanService.calculate(piggy);
    final Color statusColor = _statusColor(plan.status);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: statusColor.withOpacity(0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _statusIcon(plan.status),
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Kế hoạch tiết kiệm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            plan.statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _summary(plan),
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
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
