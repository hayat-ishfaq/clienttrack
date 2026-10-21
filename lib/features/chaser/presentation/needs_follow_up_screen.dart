import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Model for Follow-up Items (mapped to Firestore in FT-009)
// ---------------------------------------------------------------------------

class _FollowUpItem {
  final String id;
  final String clientName;
  final String invoiceNumber;
  final int daysOverdue;
  final double amountDue;
  final String dueDate;
  final String? lastChased;
  final IconData avatarIcon;

  const _FollowUpItem({
    required this.id,
    required this.clientName,
    required this.invoiceNumber,
    required this.daysOverdue,
    required this.amountDue,
    required this.dueDate,
    this.lastChased,
    this.avatarIcon = Icons.business_outlined,
  });
}

// ---------------------------------------------------------------------------
// Screen: Follow-up / Needs Follow-up
// Conforms to Visily Mockup — Needs Follow-Up
// ---------------------------------------------------------------------------

class NeedsFollowUpScreen extends ConsumerStatefulWidget {
  const NeedsFollowUpScreen({super.key});

  @override
  ConsumerState<NeedsFollowUpScreen> createState() =>
      _NeedsFollowUpScreenState();
}

class _NeedsFollowUpScreenState extends ConsumerState<NeedsFollowUpScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Demo dataset matching Visily mockup exactly
  final List<_FollowUpItem> _items = const [
    _FollowUpItem(
      id: 'inv-042',
      clientName: 'Design Studio X',
      invoiceNumber: 'INV-2024-042',
      daysOverdue: 14,
      amountDue: 1250.00,
      dueDate: 'Oct 12, 2024',
      lastChased: 'Last chased: 3 days ago',
      avatarIcon: Icons.image_outlined,
    ),
    _FollowUpItem(
      id: 'inv-045',
      clientName: 'Sarah Jenkins',
      invoiceNumber: 'INV-2024-045',
      daysOverdue: 6,
      amountDue: 450.00,
      dueDate: 'Oct 20, 2024',
      lastChased: 'No reminders sent',
      avatarIcon: Icons.person_outline_rounded,
    ),
    _FollowUpItem(
      id: 'inv-039',
      clientName: 'Acme Corp',
      invoiceNumber: 'INV-2024-039',
      daysOverdue: 28,
      amountDue: 3400.00,
      dueDate: 'Sep 28, 2024',
      lastChased: 'Last chased: Oct 15',
      avatarIcon: Icons.apartment_rounded,
    ),
    _FollowUpItem(
      id: 'inv-048',
      clientName: 'Michael Chen',
      invoiceNumber: 'INV-2024-048',
      daysOverdue: 4,
      amountDue: 920.00,
      dueDate: 'Oct 22, 2024',
      lastChased: 'No reminders sent',
      avatarIcon: Icons.person_outline_rounded,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FollowUpItem> get _filteredItems {
    if (_searchQuery.trim().isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items.where((item) {
      return item.clientName.toLowerCase().contains(q) ||
          item.invoiceNumber.toLowerCase().contains(q);
    }).toList();
  }

  double get _totalOutstanding =>
      _filteredItems.fold(0.0, (sum, item) => sum + item.amountDue);

  // ── Pro Upgrade Modal ──────────────────────────────────────────────────────

  void _showProUpgradeModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
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
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.goldProBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.goldPro.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.goldPro,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unlimited Follow-up Chasing',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Free accounts can send up to 3 automatic reminders per month. Upgrade to ClientTrack PRO for unlimited WhatsApp, SMS, and email payment chases.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PRO subscription activated for demo!'),
                        backgroundColor: AppColors.primaryForest,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryForest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Upgrade to PRO — \$9/mo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  // ── More Menu ──────────────────────────────────────────────────────────────

  Future<void> _showMoreMenu(TapDownDetails details) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      details.globalPosition & const Size(40, 40),
      Offset.zero & overlay.size,
    );

    final value = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        const PopupMenuItem(
          value: 'batch_chase',
          child: Row(
            children: [
              Icon(Icons.send_rounded, size: 20, color: AppColors.primaryForest),
              SizedBox(width: 12),
              Text('Chase All (Batch)', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.file_download_outlined, size: 20, color: AppColors.textPrimary),
              SizedBox(width: 12),
              Text('Export Overdue List', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
            ],
          ),
        ),
      ],
    );

    if (value == null || !mounted) return;
    if (value == 'batch_chase') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batch reminder composer queued for 4 clients'),
          backgroundColor: AppColors.primaryForest,
        ),
      );
    } else if (value == 'export') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Overdue report exported to CSV'),
          backgroundColor: AppColors.primaryForest,
        ),
      );
    }
  }

  // ── Chase Action ───────────────────────────────────────────────────────────

  void _onChaseItem(_FollowUpItem item) {
    HapticFeedback.lightImpact();
    context.pushNamed(
      AppRoutes.reminderComposerName,
      pathParameters: {'id': item.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFB),
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        children: [
          // Pro limit warning banner
          _buildLimitWarningBanner(),
          const SizedBox(height: 16),
          // Search input field
          _buildSearchBar(),
          const SizedBox(height: 16),
          // Stats row
          _buildStatsHeader(filtered.length),
          const SizedBox(height: 12),
          // List of cards
          if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildFollowUpCard(item),
                )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Follow-up',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      actions: [
        GestureDetector(
          onTapDown: _showMoreMenu,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.more_vert, color: AppColors.textPrimary),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Limit Warning Banner ───────────────────────────────────────────────────

  Widget _buildLimitWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F1), // Soft mint green
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD3EAD9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primaryForest,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Follow-up limit reached',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryForest,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'You have 2 automated reminders left this month. Upgrade to Pro for unlimited chasing.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _showProUpgradeModal,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Upgrade now',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryForest,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: AppColors.primaryForest,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search clients or invoices...',
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textTertiary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  // ── Stats Header ───────────────────────────────────────────────────────────

  Widget _buildStatsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count outstanding items',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          'Total: \$${_totalOutstanding.toStringAsFixed(2)}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryForest,
          ),
        ),
      ],
    );
  }

  // ── Follow-Up Card ─────────────────────────────────────────────────────────

  Widget _buildFollowUpCard(_FollowUpItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Open invoice detail
          context.pushNamed(
            AppRoutes.invoiceDetailName,
            pathParameters: {'id': item.id},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Name/Invoice + Overdue pill badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1F5), // Muted grey/blue
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.avatarIcon,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.clientName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.invoiceNumber,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Overdue badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E8), // Light red
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.daysOverdue}D OVERDUE',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
              // Middle Row: Amount Due & Due Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AMOUNT DUE',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '\$${item.amountDue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryForest,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'DUE DATE',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.dueDate,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Bottom Row: Clock/Last chased + Chase button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.lastChased ?? 'No reminders sent',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Chase Pill Button
                  ElevatedButton(
                    onPressed: () => _onChaseItem(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryForest,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 0,
                      ),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Chase',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 28,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No matching follow-ups',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try searching by another client name or invoice number.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
