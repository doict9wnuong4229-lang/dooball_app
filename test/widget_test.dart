import 'package:flutter_test/flutter_test.dart';
import 'package:dooball_app/main.dart';

void main() {
  testWidgets('DooballApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DooballApp());
    expect(find.text('DOOBALL'), findsOneWidget);
  });
}
