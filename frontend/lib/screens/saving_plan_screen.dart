import 'package:flutter/material.dart';

import '../models/piggy.dart';
import '../widgets/saving_plan_card.dart';

class SavingPlanScreen extends StatelessWidget {
  final Piggy piggy;

  const SavingPlanScreen({
    super.key,
    required this.piggy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch tiết kiệm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SavingPlanCard(piggy: piggy),
      ),
    );
  }
}
