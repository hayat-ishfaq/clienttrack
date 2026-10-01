/// Global application constants and limits.
class AppConstants {
  AppConstants._();

  static const String appName = 'ClientTrack';
  static const String appTagline = 'Get paid on time, every time.';

  // Free Tier Usage Limits
  static const int freeMaxClients = 3;
  static const int freeMaxInvoices = 5;
  static const int freeMaxReminderSharesLifetime = 3;
  static const int freeMaxReminderHistory = 3;

  // Local Notifications Capacity Limits (iOS max 64)
  static const int maxScheduledInvoiceNotifications = 40;
  static const int maxScheduledProjectNotifications = 10;

  // Asset paths
  static const String logoAsset = 'assets/app-logo.png';

  // Default values
  static const String defaultCurrency = 'USD';
  static const String defaultCurrencySymbol = '\$';
}
