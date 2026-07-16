import 'package:flutter/material.dart';

import '../models/piggy.dart';
import '../widgets/piggy_pet_card.dart';

class PiggyPetScreen extends StatelessWidget {
  final Piggy piggy;

  const PiggyPetScreen({
    super.key,
    required this.piggy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heo đất ảo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: PiggyPetCard(piggy: piggy),
      ),
    );
  }
}
