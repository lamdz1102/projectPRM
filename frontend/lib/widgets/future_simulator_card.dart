import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/future_simulation_result.dart';
import '../models/piggy.dart';
import '../services/future_simulation_service.dart';
import '../services/saving_plan_service.dart';

class FutureSimulatorCard extends StatefulWidget {
  final Piggy piggy;
  final ValueChanged<double> onDepositRequested;

  const FutureSimulatorCard({
    super.key,
    required this.piggy,
    required this.onDepositRequested,
  });

  @override
  State<FutureSimulatorCard> createState() => _FutureSimulatorCardState();
}

class _FutureSimulatorCardState extends State<FutureSimulatorCard> {
  late double _simulatedAmount;

  double get _remainingAmount => math.max(
    0,
    widget.piggy.targetAmount - widget.piggy.currentAmount,
  ).toDouble();

  double get _sliderMaximum => math.max(1, _remainingAmount).toDouble();

  @override
  void initState() {
    super.initState();
    _simulatedAmount = _initialAmount();
  }

  @override
  void didUpdateWidget(covariant FutureSimulatorCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.piggy.id != widget.piggy.id ||
        oldWidget.piggy.currentAmount != widget.piggy.currentAmount ||
        oldWidget.piggy.targetAmount != widget.piggy.targetAmount) {
      _simulatedAmount = _initialAmount();
    }
  }

  double _initialAmount() {
    final plan = SavingPlanService.calculate(widget.piggy);
    final remaining = math.max(
      0,
      widget.piggy.targetAmount - widget.piggy.currentAmount,
    ).toDouble();

    if (remaining <= 0) return 0;

    final suggested = plan.requiredPerDay > 0
        ? plan.requiredPerDay
        : remaining * 0.1;

    return _roundAmount(math.min(remaining, suggested).toDouble());
  }

  double _roundAmount(double value) {
    if (value <= 0) return 0;
    if (value < 10000) return value.roundToDouble();
    return (value / 1000).round() * 1000.0;
  }

  String _formatMoney(double value) {
    return '${NumberFormat('#,###', 'vi_VN').format(value).replaceAll(',', '.')}đ';
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Chưa đủ dữ liệu';
    return DateFormat('dd/MM/yyyy').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final result = FutureSimulationService.simulate(
      piggy: widget.piggy,
      additionalAmount: _simulatedAmount,
    );

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
            const Row(
              children: [
                CircleAvatar(
                  child: Icon(Icons.science_outlined),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phòng thí nghiệm tương lai',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Thử trước kết quả mà không làm thay đổi dữ liệu thật.',
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
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Nếu bỏ thêm ${_formatMoney(_simulatedAmount)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.pinkAccent,
                ),
              ),
            ),
            Slider(
              min: 0,
              max: _sliderMaximum,
              divisions: 20,
              value: _simulatedAmount.clamp(0, _sliderMaximum).toDouble(),
              label: _formatMoney(_simulatedAmount),
              onChanged: _remainingAmount <= 0
                  ? null
                  : (value) {
                setState(() {
                  _simulatedAmount = _roundAmount(value).clamp(
                    0,
                    _remainingAmount,
                  ).toDouble();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0đ', style: TextStyle(color: Colors.black54)),
                Text(
                  _formatMoney(_remainingAmount),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ComparisonRow(
              icon: Icons.trending_up,
              title: 'Tiến độ',
              before: '${(result.oldProgress * 100).round()}%',
              after: '${(result.newProgress * 100).round()}%',
            ),
            _ComparisonRow(
              icon: Icons.savings_outlined,
              title: 'Cần tiết kiệm mỗi ngày',
              before: _formatMoney(result.currentPlan.requiredPerDay),
              after: _formatMoney(result.simulatedPlan.requiredPerDay),
            ),
            _ComparisonRow(
              icon: Icons.calendar_month_outlined,
              title: 'Dự kiến hoàn thành',
              before: _formatDate(result.currentPlan.estimatedCompletionDate),
              after: _formatDate(result.simulatedPlan.estimatedCompletionDate),
            ),
            _ComparisonRow(
              icon: Icons.auto_awesome,
              title: 'Cấp độ Piggy',
              before: 'Cấp ${result.oldLevel}',
              after: 'Cấp ${result.newLevel}',
            ),
            if (result.daysSaved > 0 || result.levelsUp || result.reachesGoal)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _buildHighlight(result),
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _simulatedAmount <= 0 || _remainingAmount <= 0
                    ? null
                    : () => widget.onDepositRequested(_simulatedAmount),
                icon: const Icon(Icons.add_card),
                label: const Text('Bỏ đúng số tiền này'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildHighlight(FutureSimulationResult result) {
    if (result.reachesGoal) {
      return '🎉 Khoản tiền này đủ để hoàn thành mục tiêu ngay hôm nay.';
    }

    final highlights = <String>[];
    if (result.daysSaved > 0) {
      highlights.add('về đích sớm hơn khoảng ${result.daysSaved} ngày');
    }
    if (result.levelsUp) {
      highlights.add('Piggy tiến hóa lên cấp ${result.newLevel}');
    }
    if (result.statusChanges) {
      highlights.add(
        'trạng thái chuyển thành “${result.simulatedPlan.statusLabel}”',
      );
    }

    if (highlights.isEmpty) {
      return 'Khoản tiền này giúp giảm áp lực tiết kiệm cho các ngày còn lại.';
    }

    return '✨ Bạn có thể ${highlights.join(', ')}.';
  }
}

class _ComparisonRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String before;
  final String after;

  const _ComparisonRow({
    required this.icon,
    required this.title,
    required this.before,
    required this.after,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(before, style: const TextStyle(color: Colors.black54)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, size: 16),
          ),
          Text(
            after,
            style: const TextStyle(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
