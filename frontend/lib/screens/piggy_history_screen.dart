import 'package:flutter/material.dart';
import '../models/piggy.dart';
import '../models/piggy_deposit.dart';

class PiggyHistoryScreen extends StatelessWidget {
  final Piggy piggy;

  PiggyHistoryScreen({
    super.key,
    required this.piggy,
  });

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

  String formatMoney(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    )}đ';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final piggyDeposits = deposits
        .where((deposit) => deposit.piggyId == piggy.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử bỏ tiền'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              piggy.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Tổng đã tiết kiệm: ${formatMoney(piggy.currentAmount)}',
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: piggyDeposits.length,
                itemBuilder: (context, index) {
                  final deposit = piggyDeposits[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFE4EF),
                        child: Icon(
                          Icons.add,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      title: Text(
                        '+${formatMoney(deposit.amount)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${formatDate(deposit.date)}\n${deposit.note}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}