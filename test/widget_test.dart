import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clienttrack/app/app.dart';
import 'package:clienttrack/app/router/app_router.dart';
import 'package:clienttrack/app/router/route_names.dart';

void main() {
  testWidgets('End-to-End Flow: Splash -> Onboarding -> SignUp -> Profile Setup -> Dashboard', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: ClientTrackApp(),
      ),
    );

    // Initial Splash
    await tester.pump();
    expect(find.text('ClientTrack'), findsOneWidget);
    expect(find.text('Get paid faster.'), findsOneWidget);

    // Fast forward past 3 seconds to reveal actions
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Tap "Get Started" to go to Onboarding
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Onboarding Slide 1: Tap Skip to go directly to SignUp
    expect(find.text('Manage Your Clients'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Verify SignUp Screen elements
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Start managing your freelance business today'), findsOneWidget);

    // Fill valid registration fields
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'alex@example.com');
    await tester.enterText(fields.at(1), 'SecurePass123!');
    await tester.enterText(fields.at(2), 'SecurePass123!');

    // Submit SignUp
    await tester.ensureVisible(find.text('Create Free Account'));
    await tester.tap(find.text('Create Free Account'));
    await tester.pumpAndSettle();

    // Verify Screen 06: Profile Setup (visily-06-profile-setup.png)
    expect(find.text("Let's set up your profile"), findsOneWidget);
    expect(find.textContaining('Help us personalize your workspace'), findsOneWidget);
    expect(find.text('Your Name'), findsOneWidget);
    expect(find.text('Business Name (Optional)'), findsOneWidget);
    expect(find.text('Preferred Currency'), findsOneWidget);
    expect(find.textContaining('Account Settings'), findsOneWidget);
    expect(find.text('Complete Setup'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
    expect(find.text('STEP 3 OF 3 • PROFESSIONAL IDENTITY'), findsOneWidget);

    // Test validation: Empty name
    await tester.ensureVisible(find.text('Complete Setup'));
    await tester.tap(find.text('Complete Setup'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name.'), findsOneWidget);

    // Fill Name and Business
    final profileInputs = find.byType(TextFormField);
    await tester.enterText(profileInputs.at(0), 'Alex Rivera');
    await tester.enterText(profileInputs.at(1), 'Rivera Design Studio');

    // Tap "Complete Setup" -> routes to Dashboard
    await tester.tap(find.text('Complete Setup'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsAtLeast(1));
  });

  testWidgets('Authentication Flow: Login -> Forgot Password validation & recovery', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ClientTrackApp(),
      ),
    );

    // Navigate directly to Login
    container.read(appRouterProvider).go(AppRoutes.login);
    await tester.pumpAndSettle();

    // Verify Login Screen
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);

    // Tap "Forgot password?"
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    // Verify Screen 05: Forgot Password (visily-05-forgot-password.png)
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.textContaining('Enter your registered email address'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);

    // Empty validation
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email address.'), findsOneWidget);

    // Invalid format
    await tester.enterText(find.byType(TextFormField).first, 'bademail');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);

    // Valid reset submission
    await tester.enterText(find.byType(TextFormField).first, 'alex@example.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    // Verify Success View
    expect(find.text('Reset Link Sent!'), findsOneWidget);
    expect(find.textContaining('alex@example.com'), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);

    // Return to Login
    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
