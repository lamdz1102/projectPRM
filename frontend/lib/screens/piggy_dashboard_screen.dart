import 'package:flutter/material.dart';

import '../models/activity_log.dart';
import '../models/piggy.dart';
import '../models/piggy_deposit.dart';
import '../services/notification_rule_service.dart';
import '../services/notification_service.dart';
import '../services/piggy_api_service.dart';
import '../widgets/piggy_card.dart';
import 'crash_demo_screen.dart';
import 'create_piggy_screen.dart';
import 'piggy_detail_screen.dart';

class PiggyDashboardScreen extends StatefulWidget {
  const PiggyDashboardScreen({super.key});

  @override
  State<PiggyDashboardScreen> createState() =>
      _PiggyDashboardScreenState();
}

class _PiggyDashboardScreenState extends State<PiggyDashboardScreen> {
  final PiggyApiService apiService = PiggyApiService();

  List<Piggy> piggies = [];
  List<ActivityLog> recentActivities = [];

  bool isLoading = true;
  String? errorMessage;

  final List<PiggyDeposit> deposits = [
    PiggyDeposit(
      id: 1,
      piggyId: 1,
      amount: 200000,
      date: DateTime(2026, 5, 28),
      note: 'Tiền tiết kiệm tuần này',
    ),
    PiggyDeposit(
      id: 2,
      piggyId: 1,
      amount: 500000,
      date: DateTime(2026, 5, 20),
      note: 'Tiền làm thêm',
    ),
    PiggyDeposit(
      id: 3,
      piggyId: 1,
      amount: 100000,
      date: DateTime(2026, 5, 15),
      note: 'Bớt ăn vặt',
    ),
  ];

  @override
  void initState() {
    super.initState();

    NotificationService.instance.onPiggyNotificationTap =
        openPiggyFromNotification;

    NotificationRuleService.onContextNotificationSent = ({
      required int piggyId,
      required String piggyName,
      required String title,
      required String body,
    }) async {
      if (!mounted) return;

      addActivity(
        type: 'context_notification',
        piggyName: piggyName,
        message: '$title\n$body',
      );
    };

    loadPiggies();
  }

  @override
  void dispose() {
    NotificationService.instance.onPiggyNotificationTap = null;
    NotificationRuleService.onContextNotificationSent = null;
    super.dispose();
  }

  Piggy? findPiggyById(int piggyId) {
    for (final piggy in piggies) {
      if (piggy.id == piggyId) {
        return piggy;
      }
    }

    return null;
  }

  Future<void> openCrashDemoScreen() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const CrashDemoScreen(),
      ),
    );
  }

  Future<void> openPiggyFromNotification(int piggyId) async {
    var piggy = findPiggyById(piggyId);

    if (piggy == null) {
      await loadPiggies();
      piggy = findPiggyById(piggyId);
    }

    if (!mounted) return;

    if (piggy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy Piggy từ notification'),
        ),
      );
      return;
    }

    final targetPiggy = piggy;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      await openPiggyDetail(targetPiggy);
    });
  }

  Future<void> handleInitialNotificationTap() async {
    final pendingPiggyId =
    NotificationService.instance.consumePendingPiggyId();

    if (pendingPiggyId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      await openPiggyFromNotification(pendingPiggyId);
    });
  }

  Future<void> showNotificationSettings() async {
    var enabled = await NotificationRuleService.isEnabled();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Cài đặt notification'),
              content: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bật notification theo ngữ cảnh'),
                subtitle: const Text(
                  'Nhắc khi Piggy đạt 50%, 80%, hoàn thành, '
                      'sắp đến hạn, chậm tiến độ, quá hạn và '
                      'nhắc tiết kiệm mỗi ngày.',
                ),
                value: enabled,
                onChanged: (value) async {
                  await NotificationRuleService.setEnabled(value);

                  setDialogState(() {
                    enabled = value;
                  });

                  if (value) {
                    await NotificationRuleService.checkPiggies(piggies);
                    await NotificationRuleService
                        .scheduleDailySavingReminder();
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String formatMoney(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    )}đ';
  }

  String formatActivityTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    }

    return '${difference.inDays} ngày trước';
  }

  IconData getActivityIcon(String type) {
    switch (type) {
      case 'add_money':
        return Icons.savings;
      case 'break_piggy':
        return Icons.celebration;
      case 'delete_piggy':
        return Icons.delete_outline;
      case 'create_piggy':
        return Icons.add_circle_outline;
      case 'context_notification':
        return Icons.notifications_active;
      default:
        return Icons.notifications_none;
    }
  }

  Color getActivityColor(String type) {
    switch (type) {
      case 'add_money':
        return Colors.green;
      case 'break_piggy':
        return Colors.orange;
      case 'delete_piggy':
        return Colors.redAccent;
      case 'create_piggy':
        return Colors.pinkAccent;
      case 'context_notification':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  void addActivity({
    required String type,
    required String piggyName,
    double? amount,
    required String message,
  }) {
    if (!mounted) return;

    setState(() {
      recentActivities.insert(
        0,
        ActivityLog(
          type: type,
          piggyName: piggyName,
          amount: amount,
          time: DateTime.now(),
          message: message,
        ),
      );

      if (recentActivities.length > 10) {
        recentActivities.removeLast();
      }
    });
  }

  Future<void> openCreatePiggyScreen() async {
    final newPiggy = await Navigator.push<Piggy>(
      context,
      MaterialPageRoute<Piggy>(
        builder: (_) => CreatePiggyScreen(
          nextId: piggies.isEmpty ? 1 : piggies.last.id + 1,
        ),
      ),
    );

    if (newPiggy == null) return;

    try {
      final createdPiggy = await apiService.createPiggy(
        name: newPiggy.name,
        avatar: newPiggy.avatar,
        targetAmount: newPiggy.targetAmount,
        startDate: newPiggy.startDate,
        endDate: newPiggy.endDate,
        note: newPiggy.note,
      );

      if (!mounted) return;

      setState(() {
        piggies.add(createdPiggy);
      });

      await loadActivities();
      await NotificationRuleService.checkPiggy(createdPiggy);
      await NotificationRuleService.scheduleDeadlineReminder(createdPiggy);
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  void showRecentActivities() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        final displayActivities = recentActivities.take(10).toList();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '10 hoạt động gần nhất',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: displayActivities.isEmpty
                      ? const Center(
                    child: Text(
                      'Chưa có hoạt động nào.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                      : ListView.separated(
                    itemCount: displayActivities.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final activity = displayActivities[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor:
                          getActivityColor(activity.type)
                              .withOpacity(0.15),
                          child: Icon(
                            getActivityIcon(activity.type),
                            color: getActivityColor(activity.type),
                          ),
                        ),
                        title: Text(
                          activity.message,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          formatActivityTime(activity.time),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showDeletePiggyDialog(Piggy piggy) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa Piggy'),
          content: Text(
            'Bạn có chắc muốn xóa "${piggy.name}" không?\n\n'
                'Thao tác này sẽ xóa Piggy khỏi danh sách.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await apiService.deletePiggy(piggy.id);
                  await NotificationRuleService.cancelPiggySchedules(
                    piggy.id,
                  );
                  await NotificationRuleService.clearPiggyFlags(
                    piggy.id,
                  );

                  if (!mounted) return;

                  setState(() {
                    piggies.removeWhere(
                          (item) => item.id == piggy.id,
                    );
                  });

                  Navigator.pop(dialogContext);
                  await loadActivities();
                } catch (error) {
                  if (!mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Xóa Piggy thất bại: $error',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> openPiggyDetail(Piggy piggy) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute<Object?>(
        builder: (_) => PiggyDetailScreen(
          piggy: piggy,
          deposits: deposits
              .where(
                (deposit) => deposit.piggyId == piggy.id,
          )
              .toList(),
        ),
      ),
    );

    if (!mounted) return;

    if (result is Piggy) {
      final oldPiggy = piggies.firstWhere(
            (item) => item.id == result.id,
      );

      setState(() {
        final index = piggies.indexWhere(
              (item) => item.id == result.id,
        );

        if (index != -1) {
          piggies[index] = result;
        }
      });

      if (!oldPiggy.isBroken && result.isBroken) {
        addActivity(
          type: 'break_piggy',
          piggyName: result.name,
          message: 'Bạn đã đập ${result.name}',
        );
      }
    }

    if (result is Map && result['action'] == 'delete') {
      final deletedPiggy = piggies.firstWhere(
            (item) => item.id == result['id'],
      );

      setState(() {
        piggies.removeWhere(
              (item) => item.id == result['id'],
        );
      });

      addActivity(
        type: 'delete_piggy',
        piggyName: deletedPiggy.name,
        message: 'Bạn đã xóa ${deletedPiggy.name}',
      );

      await NotificationRuleService.cancelPiggySchedules(
        deletedPiggy.id,
      );
      await NotificationRuleService.clearPiggyFlags(
        deletedPiggy.id,
      );
    }

    if (result is Map && result['action'] == 'add_money') {
      final piggyId = result['piggyId'] as int;
      final updatedPiggy = result['piggy'] as Piggy;
      final oldPiggy = findPiggyById(piggyId);

      setState(() {
        final index = piggies.indexWhere(
              (item) => item.id == piggyId,
        );

        if (index != -1) {
          piggies[index] = updatedPiggy;
        }
      });

      await loadActivities();

      if (oldPiggy != null) {
        await NotificationRuleService.checkAfterDeposit(
          oldPiggy: oldPiggy,
          newPiggy: updatedPiggy,
        );
      } else {
        await NotificationRuleService.checkPiggy(updatedPiggy);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSaving = piggies
        .where((piggy) => !piggy.isBroken)
        .fold<double>(
      0,
          (sum, piggy) => sum + piggy.currentAmount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Piggy Bank'),
        actions: [
          IconButton(
            tooltip: 'Crash Monitoring Demo',
            onPressed: openCrashDemoScreen,
            icon: const Icon(
              Icons.bug_report_outlined,
            ),
          ),
          Stack(
            children: [
              IconButton(
                tooltip: 'Hoạt động gần đây',
                onPressed: showRecentActivities,
                icon: const Icon(Icons.notifications_none),
              ),
              if (recentActivities.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      recentActivities.length > 9
                          ? '9+'
                          : '${recentActivities.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Cài đặt notification',
            onPressed: showNotificationSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xin chào, Lam 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hôm nay bạn muốn bỏ tiền vào heo nào?',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.pinkAccent,
                    Colors.orangeAccent,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng tiền đã tiết kiệm',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(totalSaving),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${piggies.length} Piggy đang được theo dõi',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách Piggy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: openCreatePiggyScreen,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo mới'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : errorMessage != null
                  ? Center(
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
              )
                  : piggies.isEmpty
                  ? const Center(
                child: Text(
                  'Chưa có Piggy nào.\n'
                      'Hãy tạo Piggy đầu tiên của bạn!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: piggies.length,
                itemBuilder: (context, index) {
                  final piggy = piggies[index];

                  return PiggyCard(
                    piggy: piggy,
                    onTap: () {
                      openPiggyDetail(piggy);
                    },
                    onDelete: () {
                      showDeletePiggyDialog(piggy);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        onPressed: openCreatePiggyScreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> loadPiggies() async {
    try {
      final data = await apiService.getPiggies();

      if (!mounted) return;

      setState(() {
        piggies = data;
        isLoading = false;
        errorMessage = null;
      });

      await loadActivities();
      await NotificationRuleService.checkPiggies(data);
      await NotificationRuleService.scheduleDailySavingReminder();
      await handleInitialNotificationTap();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  Future<void> loadActivities() async {
    try {
      final data = await apiService.getRecentActivities();

      if (!mounted) return;

      setState(() {
        recentActivities = data;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
