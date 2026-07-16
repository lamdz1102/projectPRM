import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/piggy.dart';
import '../models/piggy_deposit.dart';
import '../services/piggy_api_service.dart';
import '../services/piggy_pet_service.dart';
import '../widgets/piggy_pet_summary_card.dart';
import '../widgets/saving_plan_summary_card.dart';
import 'break_protection_screen.dart';
import 'future_simulator_screen.dart';
import 'piggy_history_screen.dart';
import 'piggy_pet_screen.dart';
import 'saving_missions_screen.dart';
import 'saving_plan_screen.dart';

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

  Future<void> showEvolutionDialog(
      BuildContext context, {
        required int oldLevel,
        required int newLevel,
      }) async {
    final oldEmoji = PiggyPetService.stageEmojiForLevel(oldLevel);
    final newEmoji = PiggyPetService.stageEmojiForLevel(newLevel);
    final newStage = PiggyPetService.stageNameForLevel(newLevel);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉 PIGGY ĐÃ TIẾN HÓA!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$oldEmoji  ➜  $newEmoji',
                  style: const TextStyle(fontSize: 54),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cấp $newLevel • $newStage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Khoản tiết kiệm vừa rồi đã giúp Piggy lớn thêm!',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tuyệt vời'),
            ),
          ],
        );
      },
    );
  }

  void showAddMoneyDialog(
      BuildContext context, {
        double? initialAmount,
      }) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    if (initialAmount != null && initialAmount > 0) {
      amountController.text = NumberFormat(
        '#,###',
        'vi_VN',
      ).format(initialAmount.round()).replaceAll(',', '.');
    }

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
                        final oldLevel = PiggyPetService.levelFromProgress(
                          piggy.progress,
                        );
                        final newLevel = PiggyPetService.levelFromProgress(
                          updatedPiggy.progress,
                        );

                        Navigator.pop(context); // đóng bottom sheet

                        if (newLevel > oldLevel && context.mounted) {
                          await showEvolutionDialog(
                            context,
                            oldLevel: oldLevel,
                            newLevel: newLevel,
                          );
                        }

                        if (!context.mounted) return;

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

  Future<void> _executeBreakPiggy(BuildContext context) async {
    try {
      final brokenPiggy = await apiService.breakPiggy(piggy.id);

      if (!context.mounted) return;

      await showBreakAnimation(context);

      if (!context.mounted) return;
      Navigator.pop(context, brokenPiggy);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đập Piggy thất bại: $error'),
        ),
      );
    }
  }

  Future<void> showBreakPiggyDialog(BuildContext context) async {
    final missingAmount = piggy.targetAmount - piggy.currentAmount;

    // Piggy vẫn còn thời gian và chưa hoàn thành phải đi qua
    // màn hình chống quyết định bốc đồng.
    if (!piggy.isCompleted && !piggy.isLocked) {
      final confirmed = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (_) => BreakProtectionScreen(piggy: piggy),
        ),
      );

      if (confirmed == true && context.mounted) {
        await _executeBreakPiggy(context);
      }
      return;
    }

    final String title;
    final String content;

    if (piggy.isCompleted) {
      title = 'Hoàn thành mục tiêu';
      content =
      'Chúc mừng! Bạn đã đạt mục tiêu tiết kiệm.\n\n'
          'Số tiền đã tiết kiệm: ${formatMoney(piggy.currentAmount)}\n'
          'Mục tiêu: ${formatMoney(piggy.targetAmount)}\n\n'
          'Bạn có muốn đập heo để kết thúc Piggy này không?';
    } else {
      title = 'Piggy đã đến hạn';
      content =
      '${piggy.name} đã hết thời gian tiết kiệm.\n\n'
          'Số tiền đã tiết kiệm: ${formatMoney(piggy.currentAmount)}\n'
          'Mục tiêu: ${formatMoney(piggy.targetAmount)}\n'
          'Còn thiếu: ${formatMoney(missingAmount)}\n\n'
          'Bạn có thể đập heo để kết thúc Piggy này.';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Đập heo'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _executeBreakPiggy(context);
    }
  }

  Future<void> showDeletePiggyFromDetailDialog(
      BuildContext context,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa Piggy'),
          content: Text(
            'Bạn có chắc muốn xóa "${piggy.name}" không?\n\n'
                'Sau khi xóa, Piggy này sẽ không còn hiển thị trên Dashboard.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await apiService.deletePiggy(piggy.id);

      if (!context.mounted) return;

      Navigator.pop(context, {
        'action': 'delete',
        'id': piggy.id,
      });
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xóa Piggy thất bại: $error'),
        ),
      );
    }
  }

  Future<void> _openFutureSimulator(BuildContext context) async {
    final double? amount = await Navigator.push<double>(
      context,
      MaterialPageRoute<double>(
        builder: (_) => FutureSimulatorScreen(piggy: piggy),
      ),
    );

    if (amount != null && amount > 0 && context.mounted) {
      showAddMoneyDialog(
        context,
        initialAmount: amount,
      );
    }
  }

  void _openMissions(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SavingMissionsScreen(piggy: piggy),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PiggyHistoryScreen(piggy: piggy),
      ),
    );
  }

  void _openPiggyPet(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PiggyPetScreen(piggy: piggy),
      ),
    );
  }

  void _openSavingPlan(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SavingPlanScreen(piggy: piggy),
      ),
    );
  }

  Future<void> _showPiggyOptions(BuildContext context) async {
    final _PiggyOption? option = await showModalBottomSheet<_PiggyOption>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    'Tùy chọn Piggy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!piggy.isBroken)
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const CircleAvatar(
                      child: Icon(Icons.celebration_outlined),
                    ),
                    title: const Text('Đập heo'),
                    subtitle: Text(
                      piggy.isLocked || piggy.isCompleted
                          ? 'Kết thúc Piggy và nhận số tiền đã tiết kiệm'
                          : 'Áp dụng thời gian bình tĩnh trước khi đập',
                    ),
                    onTap: () {
                      Navigator.pop(
                        sheetContext,
                        _PiggyOption.breakPiggy,
                      );
                    },
                  ),
                const SizedBox(height: 4),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade50,
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                  ),
                  title: const Text(
                    'Xóa Piggy',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  subtitle: const Text(
                    'Xóa mục tiêu khỏi danh sách của bạn',
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      _PiggyOption.deletePiggy,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || option == null) return;

    switch (option) {
      case _PiggyOption.breakPiggy:
        await showBreakPiggyDialog(context);
        break;
      case _PiggyOption.deletePiggy:
        await showDeletePiggyFromDetailDialog(context);
        break;
    }
  }

  Color _statusColor() {
    if (piggy.isBroken || piggy.status == 'BROKEN') {
      return Colors.redAccent;
    }
    if (piggy.isCompleted) {
      return Colors.green;
    }
    if (piggy.isLocked) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  String _overviewMessage(double missingAmount) {
    if (piggy.isBroken || piggy.status == 'BROKEN') {
      return 'Piggy đã được đập';
    }
    if (piggy.isCompleted || missingAmount <= 0) {
      return 'Bạn đã hoàn thành mục tiêu';
    }
    if (piggy.isLocked) {
      return 'Còn thiếu ${formatMoney(missingAmount)}  •  Đã quá hạn';
    }

    final int days = piggy.daysLeft < 0 ? 0 : piggy.daysLeft;
    return 'Còn thiếu ${formatMoney(missingAmount)}  •  còn $days ngày';
  }

  @override
  Widget build(BuildContext context) {
    final double missingAmount = (piggy.targetAmount - piggy.currentAmount)
        .clamp(0, double.infinity)
        .toDouble();
    final bool canDeposit =
        !piggy.isBroken && !piggy.isLocked && !piggy.isCompleted;
    final Color statusColor = _statusColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Piggy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CompactHeader(
              piggy: piggy,
              statusColor: statusColor,
            ),
            const SizedBox(height: 18),
            _ProgressOverviewCard(
              piggy: piggy,
              message: _overviewMessage(missingAmount),
              formatMoney: formatMoney,
            ),
            if (!piggy.isBroken) ...[
              const SizedBox(height: 14),
              PiggyPetSummaryCard(
                piggy: piggy,
                onTap: () => _openPiggyPet(context),
              ),
              const SizedBox(height: 12),
              SavingPlanSummaryCard(
                piggy: piggy,
                onTap: () => _openSavingPlan(context),
              ),
            ],
            const SizedBox(height: 22),
            const _SectionTitle(title: 'Công cụ hỗ trợ'),
            const SizedBox(height: 10),
            if (canDeposit)
              Row(
                children: [
                  Expanded(
                    child: _ToolTile(
                      icon: Icons.science_outlined,
                      label: 'Mô phỏng',
                      onTap: () => _openFutureSimulator(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ToolTile(
                      icon: Icons.flag_outlined,
                      label: 'Nhiệm vụ',
                      onTap: () => _openMissions(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ToolTile(
                      icon: Icons.history,
                      label: 'Lịch sử',
                      onTap: () => _openHistory(context),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: () => _openHistory(context),
                icon: const Icon(Icons.history),
                label: const Text('Xem lịch sử tiết kiệm'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            const SizedBox(height: 24),
            if (canDeposit) ...[
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => showAddMoneyDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Bỏ tiền vào'),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _showPiggyOptions(context),
                icon: const Icon(Icons.more_horiz),
                label: Text(
                  canDeposit ? 'Tùy chọn Piggy' : 'Xử lý Piggy',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PiggyOption {
  breakPiggy,
  deletePiggy,
}

class _CompactHeader extends StatelessWidget {
  final Piggy piggy;
  final Color statusColor;

  const _CompactHeader({
    required this.piggy,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: piggy.isBroken
                ? Colors.red.shade100
                : Colors.pink.shade50,
            shape: BoxShape.circle,
          ),
          child: Text(
            piggy.isBroken ? '💥' : piggy.avatar,
            style: const TextStyle(fontSize: 48),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          piggy.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            piggy.isLocked ? 'Đã quá hạn' : piggy.displayStatus,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressOverviewCard extends StatelessWidget {
  final Piggy piggy;
  final String message;
  final String Function(double) formatMoney;

  const _ProgressOverviewCard({
    required this.piggy,
    required this.message,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Đã tiết kiệm',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 7),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${formatMoney(piggy.currentAmount)} / '
                    '${formatMoney(piggy.targetAmount)}',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: piggy.progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              color: Colors.pinkAccent,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Tiến độ ${(piggy.progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    message,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.pinkAccent),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoneyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat('#,###', 'vi_VN');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final String digits =
    newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final String formatted =
    formatter.format(int.parse(digits)).replaceAll(',', '.');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}
