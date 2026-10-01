import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clienttrack/app/app.dart';

void main() {
  testWidgets('SplashScreen displays logo & tagline, then reveals action controls after 3 seconds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ClientTrackApp(),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify initial state: Logo text and tagline are shown
    expect(find.text('ClientTrack'), findsOneWidget);
    expect(find.text('Get paid faster.'), findsOneWidget);

    // Actions should initially exist in the tree with 0 opacity
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);

    // Advance clock past 3 seconds to trigger action controls reveal
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify everything is settled and displayed
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('FREELANCE MANAGEMENT SIMPLIFIED'), findsOneWidget);

    // Tap "Get Started" to navigate to Onboarding
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to ClientTrack'), findsWidgets);
  });
}
