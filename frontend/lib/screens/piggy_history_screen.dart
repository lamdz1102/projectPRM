import 'package:flutter/material.dart';
import '../models/piggy.dart';
import '../models/piggy_deposit.dart';

class PiggyHistoryScreen extends StatelessWidget {
  final Piggy piggy;
  final List<PiggyDeposit> deposits;

  const PiggyHistoryScreen({
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
              child: piggyDeposits.isEmpty
                  ? const Center(
                child: Text(
                  'Chưa có lịch sử bỏ tiền nào.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
                  : ListView.builder(
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