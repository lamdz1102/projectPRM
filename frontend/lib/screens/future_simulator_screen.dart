import 'package:flutter/material.dart';

import '../models/piggy.dart';
import '../widgets/future_simulator_card.dart';

class FutureSimulatorScreen extends StatelessWidget {
  final Piggy piggy;

  const FutureSimulatorScreen({
    super.key,
    required this.piggy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mô phỏng tương lai'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FutureSimulatorCard(
          piggy: piggy,
          onDepositRequested: (amount) {
            Navigator.pop(context, amount);
          },
        ),
      ),
    );
  }
}
