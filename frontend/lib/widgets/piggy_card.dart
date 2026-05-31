import 'package:flutter/material.dart';
import '../models/piggy.dart';

class PiggyCard extends StatelessWidget {
  final Piggy piggy;
  final VoidCallback onTap;

  const PiggyCard({
    super.key,
    required this.piggy,
    required this.onTap,
  });

  String formatMoney(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    )}đ';
  }

  Color getStatusColor() {
    if (piggy.isBroken) return Colors.red;
    if (piggy.status == 'Đã khóa') return Colors.grey;
    if (piggy.status == 'Hoàn thành') return Colors.green;
    return Colors.pinkAccent;
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Icon(
                      piggy.isBroken ? Icons.delete_forever : Icons.savings,
                      color: piggy.isBroken ? Colors.red : Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      piggy.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      piggy.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: getStatusColor(),
                  ),
                ],
              ),

              const SizedBox(height: 18),

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
            ],
          ),
        ),
      ),
    );
  }
}