import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../shared/widgets/navigation/main_scaffold_shell.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/clients/presentation/client_list_screen.dart';
import '../../features/clients/presentation/add_edit_client_screen.dart';
import '../../features/clients/presentation/client_detail_screen.dart';
import '../../features/projects/presentation/project_list_screen.dart';
import '../../features/projects/presentation/new_project_screen.dart';
import '../../features/projects/presentation/project_detail_screen.dart';
import '../../features/invoices/presentation/create_invoice_screen.dart';
import '../../features/invoices/presentation/invoice_detail_screen.dart';
import '../../features/invoices/presentation/pdf_preview_screen.dart';
import '../../features/invoices/presentation/invoices_screen.dart';
import '../../features/chaser/presentation/needs_follow_up_screen.dart';
import '../../features/chaser/presentation/send_reminder_screen.dart';
import '../../features/settings/presentation/business_profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/paywall/presentation/paywall_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _clientsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'clients');
final GlobalKey<NavigatorState> _projectsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'projects');
final GlobalKey<NavigatorState> _invoicesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'invoices');

/// Riverpod provider for GoRouter.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // 01 Splash
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      // 02 Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // 03 Sign Up
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signupName,
        builder: (context, state) => const SignUpScreen(),
      ),
      // 04 Login
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      // 05 Forgot Password
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // 06 Profile Setup
      GoRoute(
        path: AppRoutes.profileSetup,
        name: AppRoutes.profileSetupName,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // 4-Tab Persistent Navigation Shell (visily-07-dashboard.png)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffoldShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Dashboard
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: AppRoutes.dashboardName,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Tab 2: Clients
          StatefulShellBranch(
            navigatorKey: _clientsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.clients,
                name: AppRoutes.clientsName,
                builder: (context, state) => const ClientListScreen(),
              ),
            ],
          ),
          // Tab 3: Projects
          StatefulShellBranch(
            navigatorKey: _projectsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.projects,
                name: AppRoutes.projectsName,
                builder: (context, state) => const ProjectListScreen(),
              ),
            ],
          ),
          // Tab 4: Invoices
          StatefulShellBranch(
            navigatorKey: _invoicesNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.invoices,
                name: AppRoutes.invoicesName,
                builder: (context, state) => const InvoicesScreen(),
              ),
            ],
          ),
        ],
      ),

      // Client Sub-routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.addClient,
        name: AppRoutes.addClientName,
        builder: (context, state) => const AddEditClientScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.clientDetail,
        name: AppRoutes.clientDetailName,
        builder: (context, state) => ClientDetailScreen(
          clientId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.editClient,
        name: AppRoutes.editClientName,
        builder: (context, state) => AddEditClientScreen(
          clientId: state.pathParameters['id'],
        ),
      ),

      // Project Sub-routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.addProject,
        name: AppRoutes.addProjectName,
        builder: (context, state) => const NewProjectScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.projectDetail,
        name: AppRoutes.projectDetailName,
        builder: (context, state) => ProjectDetailScreen(
          projectId: state.pathParameters['id'] ?? 'p1',
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.editProject,
        name: AppRoutes.editProjectName,
        builder: (context, state) => NewProjectScreen(
          projectId: state.pathParameters['id'],
        ),
      ),

      // Invoice Sub-routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.createInvoice,
        name: AppRoutes.createInvoiceName,
        builder: (context, state) => const CreateInvoiceScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.invoiceDetail,
        name: AppRoutes.invoiceDetailName,
        builder: (context, state) => InvoiceDetailScreen(
          invoiceId: state.pathParameters['id'] ?? '1023',
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.pdfPreview,
        name: AppRoutes.pdfPreviewName,
        builder: (context, state) => PdfPreviewScreen(
          invoiceId: state.pathParameters['id'] ?? 'INV-2024-001',
        ),
      ),

      // Payment Chaser Routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.needsFollowUp,
        name: AppRoutes.needsFollowUpName,
        builder: (context, state) => const NeedsFollowUpScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.reminderComposer,
        name: AppRoutes.reminderComposerName,
        builder: (context, state) => SendReminderScreen(
          invoiceId: state.pathParameters['id'] ?? '1023',
        ),
      ),

      // Modals & Settings Sub-routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.paywall,
        name: AppRoutes.paywallName,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.businessProfile,
        name: AppRoutes.businessProfileName,
        builder: (context, state) => const BusinessProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
