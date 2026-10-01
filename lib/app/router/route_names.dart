/// Central registry of route path and name constants.
/// Matches docs/TECHNICAL_ARCHITECTURE.md Section 5.
class AppRoutes {
  AppRoutes._();

  // Public / Auth routes
  static const String splash = '/splash';
  static const String splashName = 'splash';

  static const String onboarding = '/onboarding';
  static const String onboardingName = 'onboarding';

  static const String login = '/auth/login';
  static const String loginName = 'login';

  static const String signup = '/auth/signup';
  static const String signupName = 'signup';

  static const String forgotPassword = '/auth/forgot-password';
  static const String forgotPasswordName = 'forgotPassword';

  static const String profileSetup = '/profile-setup';
  static const String profileSetupName = 'profileSetup';

  // 5 Tab Shell Routes
  static const String dashboard = '/dashboard';
  static const String dashboardName = 'dashboard';

  static const String clients = '/clients';
  static const String clientsName = 'clients';

  static const String projects = '/projects';
  static const String projectsName = 'projects';

  static const String invoices = '/invoices';
  static const String invoicesName = 'invoices';

  static const String settings = '/settings';
  static const String settingsName = 'settings';

  // Client Sub-routes
  static const String addClient = '/clients/add';
  static const String addClientName = 'addClient';

  static const String clientDetail = '/clients/:id';
  static const String clientDetailName = 'clientDetail';

  static const String editClient = '/clients/:id/edit';
  static const String editClientName = 'editClient';

  // Project Sub-routes
  static const String addProject = '/projects/add';
  static const String addProjectName = 'addProject';

  static const String projectDetail = '/projects/:id';
  static const String projectDetailName = 'projectDetail';

  static const String editProject = '/projects/:id/edit';
  static const String editProjectName = 'editProject';

  // Invoice Sub-routes
  static const String createInvoice = '/invoices/create';
  static const String createInvoiceName = 'createInvoice';

  static const String invoiceDetail = '/invoices/:id';
  static const String invoiceDetailName = 'invoiceDetail';

  static const String pdfPreview = '/invoices/:id/pdf';
  static const String pdfPreviewName = 'pdfPreview';

  // Payment Chaser Routes
  static const String needsFollowUp = '/chaser/needs-follow-up';
  static const String needsFollowUpName = 'needsFollowUp';

  static const String reminderComposer = '/chaser/compose/:id';
  static const String reminderComposerName = 'reminderComposer';

  // Modals & Settings Sub-routes
  static const String paywall = '/paywall';
  static const String paywallName = 'paywall';

  static const String businessProfile = '/settings/business';
  static const String businessProfileName = 'businessProfile';
}
