import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Splash screen displaying ClientTrack branding.
/// Conforms to visily-01-splash.png.
/// Shows logo and tagline for 3 seconds before smoothly revealing the action controls.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _logoAnimController;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;

  bool _showActions = false;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();

    // Smooth logo entrance animation
    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoFadeAnimation = CurvedAnimation(
      parent: _logoAnimController,
      curve: Curves.easeOut,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoAnimController.forward();

    // Display only logo, title, and subtitle for 3 seconds before revealing actions
    _revealTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showActions = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _logoAnimController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    context.go(AppRoutes.onboarding);
  }

  void _onLogIn() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Top flexible space
                const Spacer(flex: 3),

                // Centered Branding: Logo, App Name, Subtitle
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo
                        Image.asset(
                          AppConstants.logoAsset,
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),

                        // App Name
                        const Text(
                          'ClientTrack',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle
                        const Text(
                          'Get paid faster.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryForest,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom flexible space
                const Spacer(flex: 3),

                // Bottom Action Controls: Animated appearance after 3 seconds
                AnimatedOpacity(
                  opacity: _showActions ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  child: AnimatedSlide(
                    offset: _showActions ? Offset.zero : const Offset(0.0, 0.25),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    child: IgnorePointer(
                      ignoring: !_showActions,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // "Get Started" Button with right chevron
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _onGetStarted,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF26522B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // "Already have an account? Log In"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: _onLogIn,
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryForest,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Subtle divider dash
                          Container(
                            width: 38,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Footer Caption
                          const Text(
                            'FREELANCE MANAGEMENT SIMPLIFIED',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
