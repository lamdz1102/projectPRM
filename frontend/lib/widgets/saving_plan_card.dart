import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/piggy.dart';
import '../models/saving_plan.dart';
import '../services/saving_plan_service.dart';

class SavingPlanCard extends StatelessWidget {
  final Piggy piggy;
  final bool isPreview;

  const SavingPlanCard({
    super.key,
    required this.piggy,
    this.isPreview = false,
  });

  String _formatMoney(double value) {
    final formatted = NumberFormat(
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
        return Colors.green;
      case SavingPlanStatus.behind:
        return Colors.orange;
      case SavingPlanStatus.completed:
        return Colors.green;
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
        return Icons.emoji_events;
      case SavingPlanStatus.expired:
        return Icons.event_busy;
    }
  }

  String _buildMessage(SavingPlan plan) {
    switch (plan.status) {
      case SavingPlanStatus.notStarted:
        return 'Kế hoạch sẽ bắt đầu từ '
            '${_formatDate(piggy.startDate)}. '
            'Bạn có ${plan.totalPlanDays} ngày '
            'để hoàn thành mục tiêu.';

      case SavingPlanStatus.onTrack:
        return 'Bạn đang bám sát kế hoạch. '
            'Hãy duy trì mức tiết kiệm đề xuất.';

      case SavingPlanStatus.ahead:
        return 'Bạn đang vượt kế hoạch '
            '${_formatMoney(plan.differenceFromPlan.abs())}. '
            'Tiếp tục duy trì nhé!';

      case SavingPlanStatus.behind:
        return 'Bạn đang chậm hơn kế hoạch '
            '${_formatMoney(plan.differenceFromPlan.abs())}. '
            'Mức đề xuất bên dưới đã được tự động tính lại.';

      case SavingPlanStatus.completed:
        return 'Chúc mừng! Bạn đã hoàn thành '
            'mục tiêu tiết kiệm này.';

      case SavingPlanStatus.expired:
        return 'Mục tiêu đã quá hạn và còn thiếu '
            '${_formatMoney(plan.remainingAmount)}. '
            'Hãy cân nhắc gia hạn deadline.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = SavingPlanService.calculate(piggy);
    final statusColor = _statusColor(plan.status);

    return Card(
      elevation: isPreview ? 0 : 2,
      color: isPreview ? Colors.blue.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: statusColor.withOpacity(0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _statusIcon(plan.status),
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPreview
                            ? 'Kế hoạch dự kiến'
                            : 'Kế hoạch tiết kiệm tự động',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tự cập nhật theo số tiền '
                            'và thời gian còn lại',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plan.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _buildMessage(plan),
              style: const TextStyle(height: 1.4),
            ),
            if (!plan.isFinished) ...[
              const SizedBox(height: 16),
              const Text(
                'Để đạt mục tiêu đúng hạn, '
                    'bạn nên tiết kiệm:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PlanMetric(
                      label: 'Mỗi ngày',
                      value: _formatMoney(
                        plan.requiredPerDay,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PlanMetric(
                      label: 'Mỗi tuần',
                      value: _formatMoney(
                        plan.requiredPerWeek,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PlanMetric(
                      label: 'Mỗi tháng',
                      value: _formatMoney(
                        plan.requiredPerMonth,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Divider(
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 6),
            _PlanRow(
              label: 'Còn thiếu',
              value: _formatMoney(
                plan.remainingAmount,
              ),
            ),
            const SizedBox(height: 8),
            _PlanRow(
              label: 'Thời gian còn lại',
              value: plan.remainingDays > 0
                  ? '${plan.remainingDays} ngày'
                  : 'Không còn',
            ),
            if (plan.elapsedDays > 0 && !isPreview) ...[
              const SizedBox(height: 8),
              _PlanRow(
                label: 'Theo kế hoạch hôm nay',
                value: _formatMoney(
                  plan.expectedAmountToday,
                ),
              ),
            ],
            if (plan.estimatedCompletionDate != null &&
                plan.status !=
                    SavingPlanStatus.completed &&
                !isPreview) ...[
              const SizedBox(height: 8),
              _PlanRow(
                label: 'Dự kiến hoàn thành',
                value: _formatDate(
                  plan.estimatedCompletionDate!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanMetric extends StatelessWidget {
  final String label;
  final String value;

  const _PlanMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final String label;
  final String value;

  const _PlanRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}