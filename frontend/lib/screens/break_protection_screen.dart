import 'dart:async';

import 'package:flutter/material.dart';

import '../models/break_protection_request.dart';
import '../models/piggy.dart';
import '../services/break_protection_service.dart';

class BreakProtectionScreen extends StatefulWidget {
  final Piggy piggy;

  const BreakProtectionScreen({
    super.key,
    required this.piggy,
  });

  @override
  State<BreakProtectionScreen> createState() =>
      _BreakProtectionScreenState();
}

class _BreakProtectionScreenState extends State<BreakProtectionScreen> {
  static const List<String> _reasons = [
    'Chi phí khẩn cấp',
    'Thay đổi mục tiêu',
    'Mua sắm ngoài kế hoạch',
    'Không muốn tiếp tục',
    'Lý do khác',
  ];

  BreakProtectionRequest? _request;
  Timer? _timer;
  String _selectedReason = _reasons.first;
  bool _loading = true;
  bool _saving = false;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRequest() async {
    final request = await BreakProtectionService.getRequest(widget.piggy.id);

    if (!mounted) return;

    setState(() {
      _request = request;
      _selectedReason = request?.reason ?? _reasons.first;
      _loading = false;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _updateRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final request = _request;
    if (request == null) {
      if (mounted) {
        setState(() => _remaining = Duration.zero);
      }
      return;
    }

    final difference = request.availableAt.difference(DateTime.now());
    final remaining = difference.isNegative ? Duration.zero : difference;

    if (!mounted) return;

    setState(() {
      _remaining = remaining;
    });

    if (remaining == Duration.zero) {
      _timer?.cancel();
    }
  }

  Future<void> _createRequest() async {
    setState(() => _saving = true);

    final request = await BreakProtectionService.createRequest(
      piggyId: widget.piggy.id,
      reason: _selectedReason,
    );

    if (!mounted) return;

    setState(() {
      _request = request;
      _saving = false;
    });

    _startTimer();
  }

  Future<void> _cancelRequest() async {
    await BreakProtectionService.clearRequest(widget.piggy.id);

    if (!mounted) return;

    _timer?.cancel();
    setState(() {
      _request = null;
      _remaining = Duration.zero;
    });
  }

  Future<void> _confirmBreak() async {
    await BreakProtectionService.clearRequest(widget.piggy.id);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String _formatMoney(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    )}đ';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final missingAmount = (widget.piggy.targetAmount -
        widget.piggy.currentAmount)
        .clamp(0, double.infinity)
        .toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảo vệ mục tiêu'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Text('🧘', style: TextStyle(fontSize: 54)),
                SizedBox(height: 10),
                Text(
                  'Đừng quyết định khi đang bốc đồng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ứng dụng tạo một khoảng dừng ngắn để bạn nhìn lại '
                      'mục tiêu trước khi đập heo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nếu đập Piggy hôm nay',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ConsequenceRow(
                    icon: Icons.pie_chart_outline,
                    text:
                    'Bạn sẽ dừng ở ${(widget.piggy.progress * 100).round()}% mục tiêu.',
                  ),
                  _ConsequenceRow(
                    icon: Icons.money_off,
                    text: 'Bạn còn thiếu ${_formatMoney(missingAmount)}.',
                  ),
                  const _ConsequenceRow(
                    icon: Icons.local_fire_department_outlined,
                    text: 'Chuỗi tiết kiệm hiện tại có thể bị gián đoạn.',
                  ),
                  const _ConsequenceRow(
                    icon: Icons.emoji_events_outlined,
                    text: 'Bạn sẽ chưa mở được huy hiệu hoàn thành mục tiêu.',
                  ),
                ],
              ),
            ),
          ),
          if (widget.piggy.note.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lời nhắn khi bạn tạo mục tiêu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“${widget.piggy.note}”',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (_request == null) _buildRequestForm() else _buildCountdown(),
        ],
      ),
    );
  }

  Widget _buildRequestForm() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vì sao bạn muốn đập heo?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _reasons
                  .map(
                    (reason) => DropdownMenuItem(
                  value: reason,
                  child: Text(reason),
                ),
              )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedReason = value);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _createRequest,
                icon: const Icon(Icons.hourglass_bottom),
                label: Text(
                  _saving
                      ? 'Đang tạo yêu cầu...'
                      : 'Bắt đầu thời gian bình tĩnh',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chế độ demo hiện đặt thời gian chờ là 1 phút.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final ready = _remaining == Duration.zero;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              ready ? 'Bạn đã hết thời gian chờ' : 'Thời gian bình tĩnh còn lại',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              ready ? '00:00' : _formatDuration(_remaining),
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: ready ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lý do: ${_request?.reason ?? ''}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            if (ready)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _confirmBreak,
                  icon: const Icon(Icons.gavel),
                  label: const Text('Tôi vẫn muốn đập heo'),
                ),
              )
            else
              const Text(
                'Bạn có thể quay lại sau. Đồng hồ vẫn tiếp tục chạy.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _cancelRequest,
              icon: const Icon(Icons.favorite_outline),
              label: const Text('Hủy yêu cầu và tiếp tục tiết kiệm'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsequenceRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ConsequenceRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
