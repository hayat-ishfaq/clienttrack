import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Demo data model (replaces real Firestore until FT-007 is wired)
// ---------------------------------------------------------------------------

enum _ClientStatus { active, pending, inactive }

class _DemoClient {
  final String id;
  final String name;
  final String role;
  final String company;
  final _ClientStatus status;
  final int projectCount;
  final String timeAgo;
  final bool hasStar;
  final Color presenceDot;

  const _DemoClient({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.status,
    required this.projectCount,
    required this.timeAgo,
    this.hasStar = false,
    required this.presenceDot,
  });
}

const _kDemoClients = <_DemoClient>[
  _DemoClient(
    id: 'c1',
    name: 'Alex Rivera',
    role: 'Creative Director',
    company: 'Studio Arc',
    status: _ClientStatus.active,
    projectCount: 3,
    timeAgo: '2 days ago',
    hasStar: true,
    presenceDot: Color(0xFF22C55E),
  ),
  _DemoClient(
    id: 'c2',
    name: 'Sarah Chen',
    role: 'Product Manager',
    company: 'TechFlow Inc.',
    status: _ClientStatus.pending,
    projectCount: 1,
    timeAgo: '5 hours ago',
    hasStar: false,
    presenceDot: Color(0xFFE0A030),
  ),
  _DemoClient(
    id: 'c3',
    name: 'Marcus Thorne',
    role: 'Founder',
    company: 'Green Horizon',
    status: _ClientStatus.active,
    projectCount: 5,
    timeAgo: '1 week ago',
    hasStar: true,
    presenceDot: Color(0xFF22C55E),
  ),
  _DemoClient(
    id: 'c4',
    name: 'Elena Rodriguez',
    role: 'Marketing Lead',
    company: 'Vibe Media',
    status: _ClientStatus.inactive,
    projectCount: 0,
    timeAgo: '2 weeks ago',
    hasStar: false,
    presenceDot: Color(0xFFD64545),
  ),
];

// ---------------------------------------------------------------------------
// Screen 08: Client List
// Conforms to visily-08-client-list.png
// ---------------------------------------------------------------------------

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<_DemoClient> _filtered = List.of(_kDemoClients);

  // Free-tier client limit before paywall triggers
  static const int _freeLimit = 3;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _query = q;
      _filtered = q.isEmpty
          ? List.of(_kDemoClients)
          : _kDemoClients
              .where((c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.company.toLowerCase().contains(q) ||
                  c.role.toLowerCase().contains(q))
              .toList();
    });
  }

  void _onFabTap() {
    if (_kDemoClients.length >= _freeLimit) {
      _showLimitBottomSheet();
    } else {
      context.push(AppRoutes.addClient);
    }
  }

  void _showLimitBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _LimitReachedSheet(
        onUpgrade: () {
          Navigator.pop(ctx);
          context.push(AppRoutes.paywall);
        },
      ),
    );
  }

  void _showClientOptions(BuildContext context, _DemoClient client) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ClientOptionsSheet(client: client),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top App Bar ────────────────────────────────────────────────
            _buildAppBar(context),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Search row
                          _buildSearchRow(),
                          const SizedBox(height: 16),
                          // Pro upgrade banner (visible for free-tier users)
                          _buildProBanner(),
                          const SizedBox(height: 24),
                          // Section header
                          _buildSectionHeader(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // Client cards
                  if (_filtered.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: _ClientCard(
                            client: _filtered[i],
                            onTap: () => context.push(
                              '/clients/${_filtered[i].id}',
                            ),
                            onOptions: () =>
                                _showClientOptions(context, _filtered[i]),
                          ),
                        ),
                        childCount: _filtered.length,
                      ),
                    ),

                  // Bottom spacing for nav bar
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: _buildFab(),
    );
  }

  // ── Sub-builders ──────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Clients',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          // Add-client icon button
          _CircleIconButton(
            icon: Icons.person_add_alt_1_rounded,
            onTap: _onFabTap,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        // Search field
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search clients...',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Filter button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.tune_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildProBanner() {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.paywall),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E5D31), Color(0xFF1B3E25)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E5D31).withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grow Your Network',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Unlock unlimited client profiles\nand priority reminders with Pro.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFB7D9BC),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Upgrade button
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Upgrade Now',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E5D31),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Decorative network icon
            Opacity(
              opacity: 0.18,
              child: Transform.scale(
                scale: 1.4,
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _query.isEmpty ? 'Recently Contacted' : 'Results (${_filtered.length})',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        if (_query.isEmpty)
          GestureDetector(
            onTap: () {},
            child: const Text(
              'View All',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryForest,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 36,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _query.isNotEmpty
                  ? 'No clients match "$_query"'
                  : 'No clients yet',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap + to add your first client.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _onFabTap,
      backgroundColor: AppColors.primaryForest,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Client Card
// ─────────────────────────────────────────────────────────────────────────────

class _ClientCard extends StatelessWidget {
  final _DemoClient client;
  final VoidCallback onTap;
  final VoidCallback onOptions;

  const _ClientCard({
    required this.client,
    required this.onTap,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar with star badge + presence dot ──────────────────
              _buildAvatar(),
              const SizedBox(width: 12),

              // ── Info column ────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + time ago
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            client.name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          client.timeAgo,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Role • Company
                    Text(
                      '${client.role} • ${client.company}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 9),
                    // Status chip + project count
                    Row(
                      children: [
                        _StatusPill(status: client.status),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${client.projectCount} '
                          '${client.projectCount == 1 ? 'Project' : 'Projects'}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── 3-dot menu ─────────────────────────────────────────────
              GestureDetector(
                onTap: onOptions,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, top: 2),
                  child: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // Initials fallback
    final initials = client.name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    // Pick a deterministic hue for the avatar background
    final avatarColors = [
      const Color(0xFFD1E7DD),
      const Color(0xFFD0E4FF),
      const Color(0xFFFFE5CC),
      const Color(0xFFE9D5FF),
    ];
    final textColors = [
      const Color(0xFF2E5D31),
      const Color(0xFF1D4ED8),
      const Color(0xFF9A3412),
      const Color(0xFF7C3AED),
    ];
    final idx = client.id.hashCode.abs() % avatarColors.length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar circle
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatarColors[idx],
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColors[idx],
              ),
            ),
          ),
        ),

        // Star badge (top-left)
        if (client.hasStar)
          Positioned(
            top: -2,
            left: -2,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFFD4AF37),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '★',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),

        // Presence dot (bottom-left)
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: client.presenceDot,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Pill (client-specific: Active / Pending / Inactive)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final _ClientStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case _ClientStatus.active:
        bg = AppColors.paidTealBg;
        fg = AppColors.paidTeal;
        label = 'Active';
      case _ClientStatus.pending:
        bg = AppColors.dueSoonAmberBg;
        fg = AppColors.dueSoonAmber;
        label = 'Pending';
      case _ClientStatus.inactive:
        bg = AppColors.draftGreyBg;
        fg = AppColors.draftGrey;
        label = 'Inactive';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular Icon Button (top-right of AppBar)
// ─────────────────────────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Client 3-dot Options Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ClientOptionsSheet extends StatelessWidget {
  final _DemoClient client;
  const _ClientOptionsSheet({required this.client});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grab handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text(
                client.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded,
                  color: AppColors.textPrimary),
              title: const Text(
                'View Profile',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/clients/${client.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppColors.textPrimary),
              title: const Text(
                'Edit Client',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/clients/${client.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined,
                  color: AppColors.primaryForest),
              title: const Text(
                'Create Invoice',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryForest,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.createInvoice);
              },
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline_rounded, color: AppColors.overdueRed),
              title: const Text(
                'Delete Client',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppColors.overdueRed,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, client);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, _DemoClient client) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Client?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Deleting "${client.name}" will remove all linked projects and invoices. This cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.overdueRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Limit Reached Bottom Sheet (Free tier → Paywall)
// ─────────────────────────────────────────────────────────────────────────────

class _LimitReachedSheet extends StatelessWidget {
  final VoidCallback onUpgrade;
  const _LimitReachedSheet({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.goldProBg,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('✦', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "You've hit your 3-client limit",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock unlimited clients with ClientTrack Pro.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryForest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Unlock ClientTrack Pro',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Maybe later',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
