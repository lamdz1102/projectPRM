import 'package:flutter/material.dart';
import '../models/piggy.dart';
import '../widgets/piggy_card.dart';
import 'create_piggy_screen.dart';
import 'piggy_detail_screen.dart';
import '../models/activity_log.dart';
import '../models/piggy_deposit.dart';
import '../services/piggy_api_service.dart';

class PiggyDashboardScreen extends StatefulWidget {
  const PiggyDashboardScreen({super.key});

  @override
  State<PiggyDashboardScreen> createState() => _PiggyDashboardScreenState();
}

class _PiggyDashboardScreenState extends State<PiggyDashboardScreen> {
  List<Piggy> piggies = [];
  bool isLoading = true;
  String? errorMessage;

  final PiggyApiService apiService = PiggyApiService();

  List<ActivityLog> recentActivities = [];

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
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
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
      MaterialPageRoute(
        builder: (_) => CreatePiggyScreen(
          nextId: piggies.isEmpty ? 1 : piggies.last.id + 1,
        ),
      ),
    );

    if (newPiggy != null) {
      try {
        final createdPiggy = await apiService.createPiggy(
          name: newPiggy.name,
          targetAmount: newPiggy.targetAmount,
          startDate: newPiggy.startDate,
          endDate: newPiggy.endDate,
          note: newPiggy.note,
        );

        setState(() {
          piggies.add(createdPiggy);
        });

        await loadActivities();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tạo Piggy thất bại: $e'),
          ),
        );
      }
    }
  }

  void showRecentActivities() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          getActivityColor(activity.type).withOpacity(0.15),
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
                        subtitle: Text(formatActivityTime(activity.time)),
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

  void showDeletePiggyDialog(Piggy piggy) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Xóa Piggy'),
          content: Text(
            'Bạn có chắc muốn xóa "${piggy.name}" không?\n\n'
                'Thao tác này sẽ xóa Piggy khỏi danh sách.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await apiService.deletePiggy(piggy.id);

                  setState(() {
                    piggies.removeWhere((item) => item.id == piggy.id);
                  });

                  await loadActivities();

                  Navigator.pop(context);
                } catch (e) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Xóa Piggy thất bại: $e'),
                    ),
                  );
                }
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  piggies.removeWhere((item) => item.id == piggy.id);
                });

                addActivity(
                  type: 'delete_piggy',
                  piggyName: piggy.name,
                  message: 'Bạn đã xóa ${piggy.name}',
                );

                Navigator.pop(context);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

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

  Future<void> openPiggyDetail(Piggy piggy) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PiggyDetailScreen(
          piggy: piggy,
          deposits: deposits.where((deposit) => deposit.piggyId == piggy.id).toList(),
        ),
      ),
    );

    if (result is Piggy) {
      final oldPiggy = piggies.firstWhere((item) => item.id == result.id);

      setState(() {
        final index = piggies.indexWhere((item) => item.id == result.id);
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
        piggies.removeWhere((item) => item.id == result['id']);
      });

      addActivity(
        type: 'delete_piggy',
        piggyName: deletedPiggy.name,
        message: 'Bạn đã xóa ${deletedPiggy.name}',
      );
    }

    if (result is Map && result['action'] == 'add_money') {
      final piggyId = result['piggyId'] as int;
      final updatedPiggy = result['piggy'] as Piggy;

      setState(() {
        final index = piggies.indexWhere((item) => item.id == piggyId);
        if (index != -1) {
          piggies[index] = updatedPiggy;
        }
      });

      await loadActivities();
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
          Stack(
            children: [
              IconButton(
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
            onPressed: () {},
            icon: const Icon(Icons.person_outline),
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
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
                  : piggies.isEmpty
                  ? const Center(
                child: Text(
                  'Chưa có Piggy nào.\nHãy tạo Piggy đầu tiên của bạn!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
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

  @override
  void initState() {
    super.initState();
    loadPiggies();
    loadActivities();
  }

  Future<void> loadPiggies() async {
    try {
      final data = await apiService.getPiggies();

      setState(() {
        piggies = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> loadActivities() async {
    try {
      final data = await apiService.getRecentActivities();

      setState(() {
        recentActivities = data;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}