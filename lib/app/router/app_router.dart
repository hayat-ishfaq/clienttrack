import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../shared/widgets/navigation/main_scaffold_shell.dart';
import '../../shared/widgets/navigation/placeholder_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _clientsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'clients');
final GlobalKey<NavigatorState> _projectsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'projects');
final GlobalKey<NavigatorState> _invoicesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'invoices');
final GlobalKey<NavigatorState> _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

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
        builder: (context, state) => const PlaceholderScreen(
          title: 'Welcome to ClientTrack',
          subtitle: 'Manage clients, projects, and invoices with ease.',
          icon: Icons.auto_awesome,
        ),
      ),
      // 03 Sign Up
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signupName,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Create Account',
          subtitle: 'Sign up to sync your invoices and clients securely.',
          icon: Icons.person_add_outlined,
        ),
      ),
      // 04 Login
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Welcome Back',
          subtitle: 'Log in with your email and password.',
          icon: Icons.login_outlined,
        ),
      ),
      // 05 Forgot Password
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Reset Password',
          subtitle: 'Enter your email to receive a password reset link.',
          icon: Icons.lock_reset_outlined,
        ),
      ),
      // 06 Profile Setup
      GoRoute(
        path: AppRoutes.profileSetup,
        name: AppRoutes.profileSetupName,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Profile Setup',
          subtitle: 'Set up your business name and default currency.',
          icon: Icons.badge_outlined,
        ),
      ),

      // 5-Tab Persistent Navigation Shell
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
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Dashboard',
                  subtitle: 'Daily operational overview & cashflow tracking.',
                  icon: Icons.grid_view_rounded,
                ),
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
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Clients',
                  subtitle: 'Client directory and payment history ratings.',
                  icon: Icons.people_outline_rounded,
                ),
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
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Projects',
                  subtitle: 'Active deliverables, milestones, and deadlines.',
                  icon: Icons.folder_outlined,
                ),
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
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Invoices',
                  subtitle: 'Ledger of all draft, sent, and paid invoices.',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ],
          ),
          // Tab 5: Settings
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: AppRoutes.settingsName,
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Settings',
                  subtitle: 'Subscription, business profile, and preferences.',
                  icon: Icons.settings_outlined,
                ),
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
        builder: (context, state) => const PlaceholderScreen(
          title: 'Add Client',
          subtitle: 'Create a new client profile.',
          icon: Icons.person_add_alt_1_outlined,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.clientDetail,
        name: AppRoutes.clientDetailName,
        builder: (context, state) => PlaceholderScreen(
          title: 'Client Details',
          subtitle: 'Client: ${state.pathParameters['id']}',
          icon: Icons.person_outline,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.editClient,
        name: AppRoutes.editClientName,
        builder: (context, state) => PlaceholderScreen(
          title: 'Edit Client',
          subtitle: 'Edit client: ${state.pathParameters['id']}',
          icon: Icons.edit_outlined,
        ),
      ),

      // Project Sub-routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.addProject,
        name: AppRoutes.addProjectName,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Add Project',
          subtitle: 'Create a new project scope.',
          icon: Icons.create_new_folder_outlined,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.projectDetail,
        name: AppRoutes.projectDetailName,
        builder: (context, state) => PlaceholderScreen(
          title: 'Project Details',
          subtitle: 'Project: ${state.pathParameters['id']}',
          icon: Icons.folder_open_outlined,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.editProject,
        name: AppRoutes.editProjectName,
        builder: (context, state) => PlaceholderScreen(
          title: 'Edit Project',
          subtitle: 'Edit project: ${state.pathParameters['id']}',
          icon: Icons.edit_note_outlined,
        ),
      ),

      // Invoice Sub-routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.createInvoice,
        name: AppRoutes.createInvoiceName,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Create Invoice',
          subtitle: 'Draft a new invoice with itemized line items.',
          icon: Icons.post_add_outlined,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.invoiceDetail,
        name: AppRoutes.invoiceDetailName,
        builder: (context, state) => PlaceholderScreen(
          title: 'Invoice Details',
          subtitle: 'Invoice: ${state.pathParameters['id']}',
          icon: Icons.receipt_outlined,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.pdfPreview,
        name: AppRoutes.pdfPreviewName,
        builder: (context, state) => PlaceholderScreen(
          title: 'Invoice PDF Preview',
          subtitle: 'Preview invoice: ${state.pathParameters['id']}',
          icon: Icons.picture_as_pdf_outlined,
        ),
      ),

      // Payment Chaser Routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.needsFollowUp,
        name: AppRoutes.needsFollowUpName,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Needs Follow-up',
          subtitle: 'Overdue and due-today invoices requiring attention.',
          icon: Icons.notification_important_outlined,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.reminderComposer,
        name: AppRoutes.reminderComposerName,
        builder: (context, state) => PlaceholderScreen(
          title: 'Reminder Composer',
          subtitle: 'Compose reminder for invoice: ${state.pathParameters['id']}',
          icon: Icons.outgoing_mail,
        ),
      ),

      // Modals & Settings Sub-routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.paywall,
        name: AppRoutes.paywallName,
        builder: (context, state) => const PlaceholderScreen(
          title: 'ClientTrack Pro',
          subtitle: 'Unlock unlimited invoices, clients, and payment chasing.',
          icon: Icons.auto_awesome,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.businessProfile,
        name: AppRoutes.businessProfileName,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Business Profile',
          subtitle: 'Manage your business address and invoice header details.',
          icon: Icons.storefront_outlined,
        ),
      ),
    ],
  );
});
