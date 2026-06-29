import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class CrashDemoScreen extends StatelessWidget {
  const CrashDemoScreen({super.key});

  Future<void> _writeCustomLog(BuildContext context) async {
    await FirebaseCrashlytics.instance.setCustomKey(
      'current_screen',
      'crash_demo',
    );

    await FirebaseCrashlytics.instance.setCustomKey(
      'demo_mode',
      true,
    );

    FirebaseCrashlytics.instance.log(
      'Người dùng đã mở màn hình Crash Monitoring Demo',
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đã ghi custom log và custom key.',
        ),
      ),
    );
  }

  Future<void> _createNonFatalError(BuildContext context) async {
    await FirebaseCrashlytics.instance.setCustomKey(
      'current_screen',
      'crash_demo',
    );

    await FirebaseCrashlytics.instance.setCustomKey(
      'demo_action',
      'create_non_fatal',
    );

    FirebaseCrashlytics.instance.log(
      'Người dùng bấm nút tạo lỗi non-fatal',
    );

    try {
      // Cố tình tạo lỗi chuyển chuỗi thành số.
      int.parse('khong-phai-so');
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: false,
        reason: 'Demo nhập sai số tiền Piggy',
        information: const [
          'Screen: Crash Monitoring Demo',
          'Feature: Add money to Piggy',
          'Input: khong-phai-so',
        ],
      );
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đã ghi nhận lỗi non-fatal. Ứng dụng vẫn tiếp tục chạy.',
        ),
      ),
    );
  }

  Future<void> _createFatalCrash(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận tạo crash'),
          content: const Text(
            'Ứng dụng sẽ bị đóng ngay lập tức để kiểm tra '
                'Firebase Crashlytics.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Tạo crash'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await FirebaseCrashlytics.instance.setCustomKey(
      'current_screen',
      'crash_demo',
    );

    await FirebaseCrashlytics.instance.setCustomKey(
      'demo_action',
      'create_fatal_crash',
    );

    await FirebaseCrashlytics.instance.setCustomKey(
      'piggy_id',
      1,
    );

    await FirebaseCrashlytics.instance.setCustomKey(
      'network_status',
      'online',
    );

    FirebaseCrashlytics.instance.log(
      'Người dùng xác nhận tạo fatal crash',
    );

    // Cố tình làm ứng dụng crash để kiểm tra Crashlytics.
    FirebaseCrashlytics.instance.crash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crash Monitoring Demo'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.bug_report_outlined,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              'Firebase Crashlytics',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Màn hình này mô phỏng quá trình thu thập log, '
                  'lỗi non-fatal và fatal crash.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '1. Custom log',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Ghi lại màn hình và hành động của người dùng '
                          'trước khi xảy ra lỗi.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            FilledButton.icon(
              onPressed: () => _writeCustomLog(context),
              icon: const Icon(Icons.notes),
              label: const Text('Ghi custom log'),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '2. Non-fatal error',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tạo lỗi FormatException nhưng ứng dụng '
                          'vẫn tiếp tục hoạt động.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: () => _createNonFatalError(context),
              icon: const Icon(Icons.warning_amber),
              label: const Text('Tạo lỗi non-fatal'),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '3. Fatal crash',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tạo lỗi nghiêm trọng làm ứng dụng bị đóng. '
                          'Sau đó cần mở lại ứng dụng.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            FilledButton.icon(
              onPressed: () => _createFatalCrash(context),
              icon: const Icon(Icons.dangerous_outlined),
              label: const Text('Tạo fatal crash'),
            ),
            const SizedBox(height: 24),

            const Text(
              'Lưu ý: Chỉ sử dụng màn hình này để kiểm thử và demo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}