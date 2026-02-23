import 'package:flutter_test/flutter_test.dart';
import 'package:task_sharing_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This might still fail in CI because Firebase is not initialized,
    // but it fixes the compilation error you're seeing.
    await tester.pumpWidget(const TaskSharingApp());

    // Verify that we are at least attempting to show the app.
    expect(find.byType(TaskSharingApp), findsOneWidget);
  });
}
