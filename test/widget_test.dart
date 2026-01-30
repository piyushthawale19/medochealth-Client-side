import 'package:flutter_test/flutter_test.dart';
import 'package:claim_management/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClaimManagementApp());

    // Verify that dashboard shows up
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
