import 'package:flutter/material.dart';
import '../models/piggy.dart';
import 'piggy_history_screen.dart';

class PiggyDetailScreen extends StatelessWidget {
  final Piggy piggy;

  const PiggyDetailScreen({
    super.key,
    required this.piggy,
  });

  String formatMoney(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    )}đ';
  }

  void showAddMoneyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bỏ tiền vào Piggy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  hintText: 'Ví dụ: 200000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Tiền tiết kiệm tuần này',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Xác nhận'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showBreakPiggyDialog(BuildContext context) {
    final missingAmount = piggy.targetAmount - piggy.currentAmount;

    String title;
    String content;

    if (piggy.isCompleted) {
      title = 'Hoàn thành mục tiêu';
      content =
      'Chúc mừng! Bạn đã đạt mục tiêu tiết kiệm.\n\n'
          'Số tiền đã tiết kiệm: ${formatMoney(piggy.currentAmount)}\n'
          'Mục tiêu: ${formatMoney(piggy.targetAmount)}\n\n'
          'Bạn có muốn đập heo để kết thúc Piggy này không?';
    } else if (piggy.isLocked) {
      title = 'Piggy đã đến hạn';
      content =
      '${piggy.name} đã hết thời gian tiết kiệm.\n\n'
          'Số tiền đã tiết kiệm: ${formatMoney(piggy.currentAmount)}\n'
          'Mục tiêu: ${formatMoney(piggy.targetAmount)}\n'
          'Còn thiếu: ${formatMoney(missingAmount)}\n\n'
          'Bạn có thể đập heo để kết thúc Piggy này.';
    } else {
      title = 'Đập heo sớm';
      content =
      'Piggy này vẫn còn thời gian tiết kiệm.\n\n'
          'Số tiền đã tiết kiệm: ${formatMoney(piggy.currentAmount)}\n'
          'Mục tiêu: ${formatMoney(piggy.targetAmount)}\n'
          'Còn thiếu: ${formatMoney(missingAmount)}\n\n'
          'Bạn có chắc muốn đập heo sớm không?';
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Đập heo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final missingAmount = piggy.targetAmount - piggy.currentAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Piggy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.savings,
              size: 110,
              color: Colors.pinkAccent,
            ),

            const SizedBox(height: 16),

            Text(
              piggy.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Chip(
              label: Text(piggy.status),
            ),

            const SizedBox(height: 24),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Text(
                      'Đã tiết kiệm',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${formatMoney(piggy.currentAmount)} / ${formatMoney(piggy.targetAmount)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    LinearProgressIndicator(
                      value: piggy.progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.pinkAccent,
                      backgroundColor: Colors.grey.shade200,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Tiến độ ${(piggy.progress * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _InfoBox(
                    title: 'Còn lại',
                    value: piggy.isLocked
                        ? 'Hết hạn'
                        : '${piggy.daysLeft} ngày',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoBox(
                    title: 'Còn thiếu',
                    value: missingAmount <= 0
                        ? '0đ'
                        : formatMoney(missingAmount),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (piggy.isLocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Piggy đã hết thời gian tiết kiệm. Bạn không thể bỏ thêm tiền vào Piggy này nữa.',
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: piggy.isLocked
                    ? null
                    : () {
                  showAddMoneyDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Bỏ tiền vào'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PiggyHistoryScreen(
                        piggy: piggy,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Xem lịch sử'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton.icon(
                onPressed: () {
                  showBreakPiggyDialog(context);
                },
                icon: const Icon(Icons.celebration),
                label: const Text('Đập heo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}