import 'package:flutter/material.dart';
import '../models/piggy.dart';
import '../widgets/piggy_card.dart';
import 'create_piggy_screen.dart';
import 'piggy_detail_screen.dart';

class PiggyDashboardScreen extends StatefulWidget {
  const PiggyDashboardScreen({super.key});

  @override
  State<PiggyDashboardScreen> createState() => _PiggyDashboardScreenState();
}

class _PiggyDashboardScreenState extends State<PiggyDashboardScreen> {
  final List<Piggy> piggies = [
    Piggy(
      id: 1,
      name: 'Heo mua laptop',
      targetAmount: 15000000,
      currentAmount: 5000000,
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 9, 1),
      note: 'Tiết kiệm để mua laptop học Flutter',
      isBroken: false,
    ),
    Piggy(
      id: 2,
      name: 'Heo du lịch Đà Lạt',
      targetAmount: 3000000,
      currentAmount: 3000000,
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 7, 1),
      note: 'Du lịch cùng bạn bè',
      isBroken: false,
    ),
    Piggy(
      id: 3,
      name: 'Heo quỹ khẩn cấp',
      targetAmount: 5000000,
      currentAmount: 2000000,
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 5, 1),
      note: 'Dự phòng khi cần thiết',
      isBroken: false,
    ),
  ];

  String formatMoney(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    )}đ';
  }

  Future<void> showBreakAnimation(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Break Piggy',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Opacity(
          opacity: animation.value,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1.2),
              duration: const Duration(milliseconds: 800),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
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
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    final totalSaving = piggies.fold<double>(
      0,
          (sum, piggy) => sum + piggy.currentAmount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Piggy Bank'),
        actions: [
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePiggyScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo mới'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: piggies.length,
                itemBuilder: (context, index) {
                  final piggy = piggies[index];

                  return PiggyCard(
                    piggy: piggy,
                    onTap: () async {
                      final updatedPiggy = await Navigator.push<Piggy>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PiggyDetailScreen(
                            piggy: piggy,
                          ),
                        ),
                      );

                      if (updatedPiggy != null) {
                        setState(() {
                          final index = piggies.indexWhere((item) => item.id == updatedPiggy.id);
                          if (index != -1) {
                            piggies[index] = updatedPiggy;
                          }
                        });
                      }
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePiggyScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}