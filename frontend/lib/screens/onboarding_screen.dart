import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              const Icon(
                Icons.savings_outlined,
                size: 130,
                color: Colors.pinkAccent,
              ),

              const SizedBox(height: 30),

              const Text(
                'Tạo heo tiết kiệm cho từng mục tiêu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Bạn có thể tạo nhiều Piggy Bank khác nhau, đặt số tiền mục tiêu, thời gian tiết kiệm và theo dõi tiến độ mỗi ngày.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Đăng nhập'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Đăng ký'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}