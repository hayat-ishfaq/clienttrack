import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clienttrack/app/app.dart';

void main() {
  testWidgets('End-to-End Flow: Splash -> Onboarding -> SignUp -> Login validation', (WidgetTester tester) async {
    // Set standard mobile device resolution
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
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.textContaining('Terms of Service'), findsOneWidget);
    expect(find.textContaining('Privacy Policy'), findsOneWidget);
    expect(find.text('Create Free Account'), findsOneWidget);
    expect(find.text('Sign up with Google'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Validate form error triggers when submitting empty
    await tester.ensureVisible(find.text('Create Free Account'));
    await tester.tap(find.text('Create Free Account'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email address.'), findsOneWidget);

    // Tap "Sign In" to navigate to Login Screen
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Verify Login Screen elements
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue managing your freelance business.'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Remember me on this device'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Validate login form error triggers when submitting empty
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email address.'), findsOneWidget);

    // Tap "Sign Up" to return back to SignUp screen
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsOneWidget);
  });
}
