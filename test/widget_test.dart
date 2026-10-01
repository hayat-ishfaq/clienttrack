import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clienttrack/app/app.dart';

void main() {
  testWidgets('Complete flow: Splash -> 3 Onboarding slides -> Sign Up navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ClientTrackApp(),
      ),
    );

    // Initial frame at Splash
    await tester.pump();
    expect(find.text('ClientTrack'), findsOneWidget);
    expect(find.text('Get paid faster.'), findsOneWidget);

    // Fast-forward past 3 seconds to reveal Splash actions
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Tap "Get Started" on Splash to go to Onboarding
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Slide 1
    expect(find.text('Manage Your Clients'), findsOneWidget);
    expect(find.text('Keep all your clients and their information organized in one place.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Advance to Slide 2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify Slide 2
    expect(find.text('Projects to Invoices'), findsOneWidget);
    expect(find.text('Create professional invoices from your projects and keep every payment organized.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Advance to Slide 3
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify Slide 3
    expect(find.text('Never Miss a Payment'), findsOneWidget);
    expect(find.text('Track overdue invoices and send payment reminders in just a few taps.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap "Get Started" on Slide 3 to route to Sign Up
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Sign Up placeholder/screen reached
    expect(find.text('Create Account'), findsWidgets);
  });
}
