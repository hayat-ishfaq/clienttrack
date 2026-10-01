import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clienttrack/app/app.dart';

void main() {
  testWidgets('ClientTrack smoke test renders shell navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ClientTrackApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Dashboard placeholder renders in Tab 1
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Clients'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
