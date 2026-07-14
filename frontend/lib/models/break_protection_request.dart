class BreakProtectionRequest {
  final int piggyId;
  final String reason;
  final DateTime requestedAt;
  final DateTime availableAt;

  const BreakProtectionRequest({
    required this.piggyId,
    required this.reason,
    required this.requestedAt,
    required this.availableAt,
  });

  bool get isReady => !DateTime.now().isBefore(availableAt);

  Map<String, dynamic> toJson() {
    return {
      'piggyId': piggyId,
      'reason': reason,
      'requestedAt': requestedAt.toIso8601String(),
      'availableAt': availableAt.toIso8601String(),
    };
  }

  factory BreakProtectionRequest.fromJson(Map<String, dynamic> json) {
    return BreakProtectionRequest(
      piggyId: json['piggyId'] as int,
      reason: json['reason'] as String? ?? '',
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      availableAt: DateTime.parse(json['availableAt'] as String),
    );
  }
}
