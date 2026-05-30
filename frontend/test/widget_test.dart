import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PiggyBankApp());

    expect(find.text('Piggy Bank'), findsWidgets);
  });
}