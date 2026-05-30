import 'package:flutter/material.dart';

class CreatePiggyScreen extends StatelessWidget {
  const CreatePiggyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Piggy mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.savings,
              size: 90,
              color: Colors.pinkAccent,
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                labelText: 'Tên Piggy',
                hintText: 'Ví dụ: Heo mua laptop',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số tiền mục tiêu',
                hintText: 'Ví dụ: 15000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: InputDecoration(
                labelText: 'Ngày bắt đầu',
                hintText: '01/06/2026',
                suffixIcon: const Icon(Icons.calendar_month),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: InputDecoration(
                labelText: 'Ngày kết thúc',
                hintText: '01/09/2026',
                suffixIcon: const Icon(Icons.calendar_month),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                hintText: 'Mục tiêu tiết kiệm của bạn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Tạo Piggy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}