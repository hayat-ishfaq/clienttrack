import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/data/auth_repository.dart';
import '../../invoices/data/invoice_repository.dart';
import '../../invoices/domain/models/invoice_model.dart';
import '../../projects/data/project_repository.dart';
import '../../projects/domain/models/project_model.dart';
import '../../settings/data/business_profile_repository.dart';

/// Screen 07: Main Dashboard Screen.
/// Pixel-perfect implementation conforming to visily-07-dashboard.png.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _userName = 'Alex Morgan';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      setState(() {
        _userName = user.displayName!;
      });
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                  title: const Text(
                    'Settings & Preferences',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.settings);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined, color: AppColors.midGreen),
                  title: const Text(
                    'ClientTrack Pro',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  subtitle: const Text('Unlock automated chasing & unlimited clients'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.paywall);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business_outlined, color: AppColors.textPrimary),
                  title: const Text(
                    'Business Profile',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.businessProfile);
                  },
                ),
                const Divider(height: 24),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.overdueRed),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.overdueRed),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF0EF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3 Overdue Invoices',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Invoices require immediate reminders to be sent.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesStreamProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);
    final profileAsync = ref.watch(businessProfileStreamProvider);

    final invoices = invoicesAsync.asData?.value ?? kSeedInvoices;
    final projects = projectsAsync.asData?.value ?? kSeedProjects;
    final profile = profileAsync.asData?.value;

    final userName = (profile != null && profile.fullName.trim().isNotEmpty)
        ? profile.fullName
        : _userName;
    final logoUrl = profile?.logoUrl;

    final openInvoices = invoices.where((i) => i.status != InvoiceStatus.paid).toList();
    final overdueInvoices = invoices.where((i) => i.isOverdue || i.status == InvoiceStatus.overdue).toList();
    final totalBalance = invoices.fold<double>(0.0, (sum, i) => sum + i.balanceDue);
    final activeProjects = projects.where((p) => p.status != ProjectStatus.completed).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Bar (User Avatar, Greeting, Notification, More)
              _buildTopHeader(context, userName, logoUrl, overdueInvoices.length),
              const SizedBox(height: 20),

              // 2. Weekly Balance Hero Card
              _buildWeeklyBalanceCard(context, totalBalance),
              const SizedBox(height: 16),

              // 3. Metric Cards (Active Projects & Open Invoices)
              _buildMetricsRow(
                context,
                activeProjectsCount: activeProjects.length,
                totalProjectsCount: projects.length,
                openInvoicesCount: openInvoices.length,
                overdueInvoicesCount: overdueInvoices.length,
              ),
              const SizedBox(height: 20),

              // 4. Needs Follow-up Alert Card
              _buildNeedsFollowUpCard(context, overdueInvoices.length),
              const SizedBox(height: 24),

              // 5. Deadlines Section
              _buildDeadlinesSection(context, projects),
              const SizedBox(height: 24),

              // 6. Recent Invoices Section
              _buildRecentInvoicesSection(context, invoices),
              const SizedBox(height: 24),

              // 7. Quick Actions Section
              _buildQuickActionsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Top Header Bar
  Widget _buildTopHeader(
    BuildContext context,
    String userName,
    String? logoUrl,
    int overdueCount,
  ) {
    final initials = userName.trim().isNotEmpty
        ? userName
            .trim()
            .split(' ')
            .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
            .take(2)
            .join()
        : 'CT';

    return Row(
      children: [
        // Avatar with Active Indicator
        GestureDetector(
          onTap: () => context.push(AppRoutes.businessProfile),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Greeting & Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        // Notification Button
        Stack(
          clipBehavior: Clip.none,
          children: [
            _buildCircularIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () => _showNotificationSheet(context),
            ),
            if (overdueCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    overdueCount > 9 ? '9+' : '$overdueCount',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),
        // More Options Button
        _buildCircularIconButton(
          icon: Icons.more_vert_rounded,
          onTap: () => _showMoreMenu(context),
        ),
      ],
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1E293B)),
        ),
      ),
    );
  }

  /// 2. Weekly Balance Hero Card
  Widget _buildWeeklyBalanceCard(BuildContext context, double totalBalance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF265A36),
            Color(0xFF1B3E25),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B3E25).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // June Overview Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Live Overview',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Weekly Balance Title
          Text(
            'Outstanding Balance',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          // Large Amount
          Text(
            '\$${totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 14),
          // Trend Row
          Row(
            children: [
              Icon(
                Icons.sync_rounded,
                size: 15,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 4),
              Text(
                'Synced with Cloud Firestore',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. Metric Cards (Active Projects & Open Invoices)
  Widget _buildMetricsRow(
    BuildContext context, {
    required int activeProjectsCount,
    required int totalProjectsCount,
    required int openInvoicesCount,
    required int overdueInvoicesCount,
  }) {
    return Row(
      children: [
        // Left Card: Active Projects
        Expanded(
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.projects),
            child: _buildMetricItemCard(
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xFF0D9488),
              iconBgColor: const Color(0xFFCCFBF1).withValues(alpha: 0.7),
              title: 'Active Projects',
              value: activeProjectsCount.toString().padLeft(2, '0'),
              trendIcon: Icons.trending_up_rounded,
              trendText: '$totalProjectsCount total',
              trendColor: const Color(0xFF0D9488),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Right Card: Open Invoices
        Expanded(
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.invoices),
            child: _buildMetricItemCard(
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF4F46E5),
              iconBgColor: const Color(0xFFEEF2FF),
              title: 'Open Invoices',
              value: openInvoicesCount.toString().padLeft(2, '0'),
              trendIcon: Icons.trending_up_rounded,
              trendText: '$overdueInvoicesCount overdue',
              trendColor: overdueInvoicesCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF0D9488),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItemCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required IconData trendIcon,
    required String trendText,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          // Value
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          // Trend / Subtitle
          Row(
            children: [
              Icon(trendIcon, size: 14, color: trendColor),
              const SizedBox(width: 4),
              Text(
                trendText,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: trendColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 4. Needs Follow-up Alert Card
  Widget _buildNeedsFollowUpCard(BuildContext context, int overdueCount) {
    if (overdueCount == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'All caught up! No overdue invoices need follow-up.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF166534),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3).withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Red Accent Left Strip
              Container(
                width: 4.5,
                color: const Color(0xFFDC2626),
              ),
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Red Icon
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC3535),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Title & Description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Needs Follow-up ($overdueCount)',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You have $overdueCount ${overdueCount == 1 ? "invoice" : "invoices"} overdue. Clients are waiting for reminders.',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF475569),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => context.push(AppRoutes.needsFollowUp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC4742),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Send Reminders',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.north_east_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 5. Deadlines Section
  Widget _buildDeadlinesSection(BuildContext context, List<ProjectModel> projects) {
    final displayProjects = projects.take(2).toList();

    return Column(
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Deadlines',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () => context.go(AppRoutes.projects),
              child: const Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF334155)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (displayProjects.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No active projects with deadlines',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildDeadlineCard(
                  title: displayProjects[0].title,
                  client: displayProjects[0].clientName,
                  date: displayProjects[0].deadline != null
                      ? DateFormat.MMMd().format(displayProjects[0].deadline!)
                      : 'Ongoing',
                  tagLabel: displayProjects[0].status == ProjectStatus.inProgress
                      ? 'SOON'
                      : displayProjects[0].status.label.toUpperCase(),
                  tagBgColor: displayProjects[0].status == ProjectStatus.inProgress
                      ? const Color(0xFFDC3535)
                      : const Color(0xFFF1F5F9),
                  tagTextColor: displayProjects[0].status == ProjectStatus.inProgress
                      ? Colors.white
                      : const Color(0xFF334155),
                  clockBgColor: const Color(0xFFFDE8E8),
                  clockColor: const Color(0xFFDC2626),
                  onTap: () => context.go(AppRoutes.projects),
                ),
              ),
              if (displayProjects.length > 1) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: _buildDeadlineCard(
                    title: displayProjects[1].title,
                    client: displayProjects[1].clientName,
                    date: displayProjects[1].deadline != null
                        ? DateFormat.MMMd().format(displayProjects[1].deadline!)
                        : 'Ongoing',
                    tagLabel: displayProjects[1].status.label.toUpperCase(),
                    tagBgColor: const Color(0xFFF1F5F9),
                    tagTextColor: const Color(0xFF334155),
                    clockBgColor: const Color(0xFFDCFCE7),
                    clockColor: const Color(0xFF16A34A),
                    onTap: () => context.go(AppRoutes.projects),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildDeadlineCard({
    required String title,
    required String client,
    required String date,
    required String tagLabel,
    required Color tagBgColor,
    required Color tagTextColor,
    required Color clockBgColor,
    required Color clockColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Clock & Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: clockBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.access_time_rounded, size: 16, color: clockColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tagLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: tagTextColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 3),
            // Client
            Text(
              client,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            // Date Row
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 5),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 6. Recent Invoices Section
  Widget _buildRecentInvoicesSection(BuildContext context, List<InvoiceModel> invoices) {
    final recentInvoices = invoices.take(3).toList();

    return Column(
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Invoices',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () => context.go(AppRoutes.invoices),
              child: const Row(
                children: [
                  Text(
                    'Invoices',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF275C34),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF275C34)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentInvoices.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No invoices found',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...recentInvoices.map((inv) {
            final isPaid = inv.status == InvoiceStatus.paid;
            final isOver = inv.isOverdue || inv.status == InvoiceStatus.overdue;
            final statusColor = isPaid
                ? const Color(0xFF0D9488)
                : isOver
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFD97706);
            final iconBgColor = isPaid
                ? const Color(0xFFCCFBF1).withValues(alpha: 0.7)
                : isOver
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFFEF3C7);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildInvoiceItemRow(
                context: context,
                client: inv.clientName,
                invCode: '${inv.invoiceNumber} • ${DateFormat.MMMd().format(inv.issueDate)}',
                amount: '\$${inv.totalAmount.toStringAsFixed(2)}',
                status: inv.status.label.toUpperCase(),
                statusColor: statusColor,
                iconBgColor: iconBgColor,
                iconColor: statusColor,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildInvoiceItemRow({
    required BuildContext context,
    required String client,
    required String invCode,
    required String amount,
    required String status,
    required Color statusColor,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.invoices),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Document Icon Box
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.description_outlined, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Client & Code
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    invCode,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            // Amount & Status Tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 7. Quick Actions Section
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Action 1: New Project
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.addProject),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 24,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'New Project',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Action 2: Add Income
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.createInvoice),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            r'$',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Add Income',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
