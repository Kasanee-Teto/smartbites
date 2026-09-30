import 'package:budget_bites/app.dart';
import 'package:budget_bites/screens/welcome_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SmartBites placeholder app launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartBitesApp());

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('WelcomeScreen - TODO'), findsOneWidget);
  });
}
