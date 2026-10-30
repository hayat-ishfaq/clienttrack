import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme/app_colors.dart';
import '../../features/invoices/domain/models/invoice_model.dart';
import '../../features/projects/domain/models/project_model.dart';

// ---------------------------------------------------------------------------
// Provider & Singleton Service
// ---------------------------------------------------------------------------

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Phase 4: Local Notification Service & Permission Orchestrator (FT-016, FT-017)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Maximum notification cap to respect iOS limit (64 max; we prune to <= 40)
  static const int kMaxActiveNotifications = 40;

  // ── Channel IDs ────────────────────────────────────────────────────────────
  static const String channelInvoicesId = 'clienttrack_invoices';
  static const String channelProjectsId = 'clienttrack_projects';
  static const String channelGeneralId = 'clienttrack_general';

  /// Initializes the local notification plugin and timezones.
  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTapped,
  }) async {
    if (_isInitialized || kIsWeb) return;

    try {
      // 1. Initialize timezone database
      tz.initializeTimeZones();

      // 2. Android Initialization Settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      // 3. Darwin (iOS/macOS) Initialization Settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      // 4. Initialize plugin
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: onNotificationTapped ??
            (response) {
              debugPrint('[Notification] Tapped payload: ${response.payload}');
            },
      );

      // 5. Create Android Notification Channels
      if (Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImpl != null) {
          await androidImpl.createNotificationChannel(
            const AndroidNotificationChannel(
              channelInvoicesId,
              'Invoice Due & Overdue Alerts',
              description:
                  'Automated reminders for pending and overdue client invoices.',
              importance: Importance.high,
              enableVibration: true,
            ),
          );

          await androidImpl.createNotificationChannel(
            const AndroidNotificationChannel(
              channelProjectsId,
              'Project Deadline Alerts',
              description:
                  'Milestone alerts and delivery reminders for active client projects.',
              importance: Importance.defaultImportance,
            ),
          );

          await androidImpl.createNotificationChannel(
            const AndroidNotificationChannel(
              channelGeneralId,
              'General Reminders',
              description: 'General system announcements and payment follow-ups.',
              importance: Importance.defaultImportance,
            ),
          );
        }
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Initialized successfully.');
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  // ── Permission Orchestrator (FT-016) ───────────────────────────────────────

  /// Checks if notification permissions have been granted.
  Future<bool> isPermissionGranted() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        return await androidImpl?.areNotificationsEnabled() ?? false;
      } else if (Platform.isIOS) {
        final iosImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final permissions = await iosImpl?.checkPermissions();
        return permissions?.isEnabled ?? false;
      }
    } catch (_) {}
    return false;
  }

  /// Direct OS permission request (Android 13+ & iOS).
  Future<bool> requestDirectPermissions() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidImpl?.requestNotificationsPermission();
        return granted ?? false;
      } else if (Platform.isIOS) {
        final iosImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] requestPermissions error: $e');
    }
    return false;
  }

  /// Educational Pre-Permission Sheet (FT-016 requirement)
  /// Displays an explainer sheet educating the user on the value of invoice chaser reminders
  /// before popping up the OS system prompt.
  Future<bool> showNotificationPrePrompt(BuildContext context) async {
    final bool? userAgreed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  size: 36,
                  color: AppColors.primaryForest,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Never Miss an Overdue Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enable notifications so ClientTrack can alert you 2 days before an invoice is due, on the due date, and when follow-up chasing is required.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(
                        'Not Now',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primaryForest,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Enable Alerts',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (userAgreed == true) {
      return await requestDirectPermissions();
    }
    return false;
  }

  // ── Notification Scheduling Engine (FT-017) ────────────────────────────────

  /// Deterministic ID generator for an invoice schedule slot:
  /// slot 1: Due Date - 2 days (9 AM)
  /// slot 2: Due Date (9 AM)
  /// slot 3: Due Date + 1 day (10 AM)
  int _invoiceNotificationId(String invoiceId, int slot) {
    final base = (invoiceId.hashCode & 0x7FFFFFFF) % 100000;
    return base * 10 + slot;
  }

  /// Deterministic ID generator for project deadlines:
  /// slot 4: Deadline - 2 days (9 AM)
  /// slot 5: Deadline (9 AM)
  int _projectNotificationId(String projectId, int slot) {
    final base = (projectId.hashCode & 0x7FFFFFFF) % 100000;
    return base * 10 + slot;
  }

  /// Schedules alerts for an invoice:
  /// - Due Date - 2 days (9:00 AM)
  /// - Due Date (9:00 AM)
  /// - Due Date + 1 day (10:00 AM)
  Future<void> scheduleInvoiceReminders(InvoiceModel invoice) async {
    if (kIsWeb || !_isInitialized) return;

    // Do not schedule notifications for paid or draft invoices
    if (invoice.status == InvoiceStatus.paid) {
      await cancelInvoiceReminders(invoice.id);
      return;
    }

    final dueDate = invoice.dueDate;
    final now = DateTime.now();
    final clientName = invoice.clientName;
    final invoiceNumber = invoice.invoiceNumber;
    final balance = '\$${invoice.balanceDue.toStringAsFixed(2)}';

    // 1. Due Date - 2 Days at 9:00 AM
    final minus2Days = DateTime(dueDate.year, dueDate.month, dueDate.day - 2, 9, 0);
    if (minus2Days.isAfter(now)) {
      await _zonedSchedule(
        id: _invoiceNotificationId(invoice.id, 1),
        title: 'Upcoming Invoice: $invoiceNumber',
        body: 'Invoice $invoiceNumber for $clientName ($balance) is due in 2 days.',
        scheduledDate: minus2Days,
        channelId: channelInvoicesId,
        channelName: 'Invoice Due & Overdue Alerts',
        payload: '/invoices/${invoice.id}',
      );
    }

    // 2. Due Date at 9:00 AM
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day, 9, 0);
    if (dueDay.isAfter(now)) {
      await _zonedSchedule(
        id: _invoiceNotificationId(invoice.id, 2),
        title: 'Invoice Due Today: $invoiceNumber',
        body: '$clientName is scheduled to pay $balance today for invoice $invoiceNumber.',
        scheduledDate: dueDay,
        channelId: channelInvoicesId,
        channelName: 'Invoice Due & Overdue Alerts',
        payload: '/invoices/${invoice.id}',
      );
    }

    // 3. Due Date + 1 Day at 10:00 AM (Overdue Follow-up alert)
    final plus1Day = DateTime(dueDate.year, dueDate.month, dueDate.day + 1, 10, 0);
    if (plus1Day.isAfter(now)) {
      await _zonedSchedule(
        id: _invoiceNotificationId(invoice.id, 3),
        title: 'Payment Overdue: Follow Up with $clientName',
        body: 'Invoice $invoiceNumber for $balance is past due. Tap to send a payment reminder.',
        scheduledDate: plus1Day,
        channelId: channelInvoicesId,
        channelName: 'Invoice Due & Overdue Alerts',
        payload: '/invoices/${invoice.id}',
      );
    }

    await pruneOldNotifications();
  }

  /// Cancels all scheduled reminder alerts for a specific invoice.
  Future<void> cancelInvoiceReminders(String invoiceId) async {
    if (kIsWeb || !_isInitialized) return;
    try {
      await _notificationsPlugin.cancel(id: _invoiceNotificationId(invoiceId, 1));
      await _notificationsPlugin.cancel(id: _invoiceNotificationId(invoiceId, 2));
      await _notificationsPlugin.cancel(id: _invoiceNotificationId(invoiceId, 3));
    } catch (_) {}
  }

  /// Schedules alerts for project deadlines:
  /// - Deadline - 2 days (9:00 AM)
  /// - Deadline Date (9:00 AM)
  Future<void> scheduleProjectDeadlineReminder(ProjectModel project) async {
    if (kIsWeb || !_isInitialized) return;

    if (project.status == ProjectStatus.completed) {
      await cancelProjectReminders(project.id);
      return;
    }

    final deadline = project.deadline;
    if (deadline == null) return;

    final now = DateTime.now();
    final title = project.title;
    final clientName = project.clientName;

    // 1. Deadline - 2 Days at 9:00 AM
    final minus2Days =
        DateTime(deadline.year, deadline.month, deadline.day - 2, 9, 0);
    if (minus2Days.isAfter(now)) {
      await _zonedSchedule(
        id: _projectNotificationId(project.id, 4),
        title: 'Upcoming Project Deadline: $title',
        body: 'Project "$title" for $clientName is due in 2 days.',
        scheduledDate: minus2Days,
        channelId: channelProjectsId,
        channelName: 'Project Deadline Alerts',
        payload: '/projects/${project.id}',
      );
    }

    // 2. Deadline Date at 9:00 AM
    final deadlineDay =
        DateTime(deadline.year, deadline.month, deadline.day, 9, 0);
    if (deadlineDay.isAfter(now)) {
      await _zonedSchedule(
        id: _projectNotificationId(project.id, 5),
        title: 'Project Deadline Today: $title',
        body: 'Milestone delivery for "$title" ($clientName) is due today.',
        scheduledDate: deadlineDay,
        channelId: channelProjectsId,
        channelName: 'Project Deadline Alerts',
        payload: '/projects/${project.id}',
      );
    }

    await pruneOldNotifications();
  }

  /// Cancels all reminders for a given project.
  Future<void> cancelProjectReminders(String projectId) async {
    if (kIsWeb || !_isInitialized) return;
    try {
      await _notificationsPlugin.cancel(id: _projectNotificationId(projectId, 4));
      await _notificationsPlugin.cancel(id: _projectNotificationId(projectId, 5));
    } catch (_) {}
  }

  /// Internal helper to invoke `zonedSchedule` with error-tolerance.
  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    required String channelName,
    String? payload,
  }) async {
    try {
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] _zonedSchedule notice: $e');
    }
  }

  /// Prunes pending notifications to maintain <= 40 active alerts,
  /// strictly adhering to the iOS 64-notification cap (FT-017).
  Future<void> pruneOldNotifications() async {
    if (kIsWeb || !_isInitialized) return;
    try {
      final pending =
          await _notificationsPlugin.pendingNotificationRequests();
      if (pending.length > kMaxActiveNotifications) {
        // Cancel excess oldest requests to stay within budget
        final excessCount = pending.length - kMaxActiveNotifications;
        for (int i = 0; i < excessCount; i++) {
          await _notificationsPlugin.cancel(id: pending[i].id);
        }
        debugPrint(
            '[NotificationService] Pruned $excessCount excess scheduled alerts.');
      }
    } catch (e) {
      debugPrint('[NotificationService] Prune notice: $e');
    }
  }

  /// Shows an instant test notification for developer verification or settings test.
  Future<void> showInstantTestNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_isInitialized) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        channelGeneralId,
        'General Reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        id: 999999,
        title: title,
        body: body,
        notificationDetails: details,
        payload: '/dashboard',
      );
    } catch (e) {
      debugPrint('[NotificationService] showInstantTestNotification notice: $e');
    }
  }

  /// Mass syncs notifications for active invoices and ongoing projects.
  Future<void> syncAllNotifications({
    required List<InvoiceModel> invoices,
    required List<ProjectModel> projects,
  }) async {
    if (kIsWeb || !_isInitialized) return;

    // Schedule up to 15 most recent open invoices
    final pendingInvoices = invoices
        .where((inv) => inv.status != InvoiceStatus.paid)
        .take(15);
    for (final inv in pendingInvoices) {
      await scheduleInvoiceReminders(inv);
    }

    // Schedule up to 10 in-progress projects
    final activeProjects = projects
        .where((p) => p.status != ProjectStatus.completed && p.deadline != null)
        .take(10);
    for (final proj in activeProjects) {
      await scheduleProjectDeadlineReminder(proj);
    }
  }
}
