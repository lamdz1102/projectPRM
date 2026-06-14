import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/piggy.dart';
import 'piggy_history_screen.dart';
import '../models/piggy_deposit.dart';
import '../services/piggy_api_service.dart';
import 'package:intl/intl.dart';

class PiggyDetailScreen extends StatelessWidget {
  final Piggy piggy;
  final List<PiggyDeposit> deposits;
  final PiggyApiService apiService = PiggyApiService();

  PiggyDetailScreen({
    super.key,
    required this.piggy,
    required this.deposits,
  });

  String formatMoney(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    )}đ';
  }

  void showAddMoneyDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final List<int> quickAmounts = [
      10000,
      50000,
      100000,
      200000,
      500000,
    ];

    String formatQuickAmount(int amount) {
      return NumberFormat('#,###', 'vi_VN').format(amount).replaceAll(',', '.');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Bỏ tiền vào Piggy',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Chọn nhanh số tiền',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickAmounts.map((amount) {
                  return ActionChip(
                    label: Text('${formatQuickAmount(amount)}đ'),
                    onPressed: () {
                      amountController.text = formatQuickAmount(amount);
                      amountController.selection = TextSelection.collapsed(
                        offset: amountController.text.length,
                      );
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  MoneyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  hintText: 'Ví dụ: 200.000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: noteController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
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
                  onPressed: () async {
                    final amountText =
                    amountController.text.replaceAll('.', '').trim();
                    final amount = double.tryParse(amountText);
                    final note = noteController.text.trim();

                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Số tiền không hợp lệ'),
                        ),
                      );
                      return;
                    }

                    try {
                      final updatedPiggy = await apiService.addMoney(
                        piggyId: piggy.id,
                        amount: amount,
                        note: note,
                      );

                      if (context.mounted) {
                        Navigator.pop(context); // đóng bottom sheet

                        Navigator.pop(context, {
                          'action': 'add_money',
                          'piggyId': piggy.id,
                          'amount': amount,
                          'note': note,
                          'piggy': updatedPiggy,
                        });
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Bỏ tiền thất bại: $e'),
                          ),
                        );
                      }
                    }
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

  Future<void> showBreakAnimation(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.2),
              duration: const Duration(milliseconds: 700),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '💥🐷',
                        style: TextStyle(fontSize: 64),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Piggy đã được đập!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    if (context.mounted) {
      Navigator.pop(context);
    }
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
              onPressed: () async {
                Navigator.pop(context); // đóng dialog xác nhận

                await showBreakAnimation(context);

                if (context.mounted) {
                  final brokenPiggy = piggy.copyWith(isBroken: true);
                  Navigator.pop(context, brokenPiggy); // quay về Dashboard
                }
              },
              child: const Text('Đập heo'),
            ),
          ],
        );
      },
    );
  }

  void showDeletePiggyFromDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Xóa Piggy'),
          content: Text(
            'Bạn có chắc muốn xóa "${piggy.name}" không?\n\n'
                'Sau khi xóa, Piggy này sẽ không còn hiển thị trên Dashboard.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context); // đóng dialog

                Navigator.pop(context, {
                  'action': 'delete',
                  'id': piggy.id,
                }); // quay về Dashboard và báo xóa
              },
              child: const Text('Xóa'),
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
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: piggy.isBroken
                    ? Colors.red.shade100
                    : Colors.pink.shade50,
                shape: BoxShape.circle,
              ),
              child: Text(
                piggy.isBroken ? '💥' : piggy.avatar,
                style: const TextStyle(fontSize: 64),
              ),
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

            if (piggy.isBroken)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Piggy này đã được đập. Bạn không thể tiếp tục bỏ tiền vào nữa.',
                  textAlign: TextAlign.center,
                ),
              )
            else if (piggy.isLocked)
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
                onPressed: (piggy.isLocked || piggy.isBroken)
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
                onPressed: piggy.isBroken
                    ? null
                    : () {
                  showBreakPiggyDialog(context);
                },
                icon: const Icon(Icons.celebration),
                label: Text(piggy.isBroken ? 'Piggy đã được đập' : 'Đập heo'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                ),
                onPressed: () {
                  showDeletePiggyFromDetailDialog(context);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Xóa Piggy'),
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

class MoneyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat("#,###", "vi_VN");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    String formatted =
    formatter.format(int.parse(digits)).replaceAll(',', '.');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}