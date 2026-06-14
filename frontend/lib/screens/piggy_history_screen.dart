import 'package:flutter/material.dart';
import '../models/piggy.dart';
import '../models/piggy_deposit.dart';
import '../services/piggy_api_service.dart';

class PiggyHistoryScreen extends StatefulWidget {
  final Piggy piggy;

  const PiggyHistoryScreen({
    super.key,
    required this.piggy,
  });

  @override
  State<PiggyHistoryScreen> createState() => _PiggyHistoryScreenState();
}

class _PiggyHistoryScreenState extends State<PiggyHistoryScreen> {
  final PiggyApiService apiService = PiggyApiService();

  List<PiggyDeposit> deposits = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDeposits();
  }

  Future<void> loadDeposits() async {
    try {
      final data = await apiService.getDeposits(widget.piggy.id);

      setState(() {
        deposits = data;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử bỏ tiền'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.piggy.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Tổng đã tiết kiệm: ${formatMoney(widget.piggy.currentAmount)}',
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

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
                  : deposits.isEmpty
                  ? const Center(
                child: Text(
                  'Chưa có lịch sử bỏ tiền nào.',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              )
                  : RefreshIndicator(
                onRefresh: loadDeposits,
                child: ListView.builder(
                  itemCount: deposits.length,
                  itemBuilder: (context, index) {
                    final deposit = deposits[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      color: const Color(0xFFFFEEF3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFD6E5),
                          child: Icon(
                            Icons.add,
                            color: Colors.pinkAccent,
                          ),
                        ),
                        title: Text(
                          '+${formatMoney(deposit.amount)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
            ),
          ],
        ),
      ),
    );
  }
}