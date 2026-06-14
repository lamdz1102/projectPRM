import 'package:flutter/material.dart';
import '../models/piggy.dart';

class CreatePiggyScreen extends StatefulWidget {
  final int nextId;

  const CreatePiggyScreen({
    super.key,
    required this.nextId,
  });

  @override
  State<CreatePiggyScreen> createState() => _CreatePiggyScreenState();
}

class _CreatePiggyScreenState extends State<CreatePiggyScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController targetAmountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  String selectedAvatar = '🐷';

  final List<String> avatarOptions = [
    '🐷',
    '🐽',
    '🐖',
    '💰',
    '🎯',
    '🏦',
    '💎',
    '🧸',
  ];

  Future<void> pickStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selectedDate != null) {
      setState(() {
        startDate = selectedDate;
      });
    }
  }

  Future<void> pickEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (selectedDate != null) {
      setState(() {
        endDate = selectedDate;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  void createPiggy() {
    final name = nameController.text.trim();
    final targetText = targetAmountController.text.trim();
    final note = noteController.text.trim();

    if (name.isEmpty || targetText.isEmpty || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin Piggy'),
        ),
      );
      return;
    }

    final targetAmount = double.tryParse(targetText);

    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số tiền mục tiêu không hợp lệ'),
        ),
      );
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngày kết thúc phải sau ngày bắt đầu'),
        ),
      );
      return;
    }

    final newPiggy = Piggy(
      id: widget.nextId,
      name: name,
      avatar: selectedAvatar,
      targetAmount: targetAmount,
      currentAmount: 0,
      startDate: startDate!,
      endDate: endDate!,
      note: note,
      isBroken: false,
      status: 'ACTIVE',
    );

    Navigator.pop(context, newPiggy);
  }

  @override
  void dispose() {
    nameController.dispose();
    targetAmountController.dispose();
    noteController.dispose();
    super.dispose();
  }

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
            const Text(
              'Chọn avatar Piggy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: avatarOptions.map((avatar) {
                final isSelected = selectedAvatar == avatar;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAvatar = avatar;
                    });
                  },
                  child: Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.pinkAccent : Colors.pink.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.pinkAccent : Colors.pink.shade100,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      avatar,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
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
              controller: targetAmountController,
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
              readOnly: true,
              onTap: pickStartDate,
              decoration: InputDecoration(
                labelText: 'Ngày bắt đầu',
                hintText: startDate == null ? 'Chọn ngày bắt đầu' : formatDate(startDate),
                suffixIcon: const Icon(Icons.calendar_month),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              onTap: pickEndDate,
              decoration: InputDecoration(
                labelText: 'Ngày kết thúc',
                hintText: endDate == null ? 'Chọn ngày kết thúc' : formatDate(endDate),
                suffixIcon: const Icon(Icons.calendar_month),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
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
                onPressed: createPiggy,
                child: const Text('Tạo Piggy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}