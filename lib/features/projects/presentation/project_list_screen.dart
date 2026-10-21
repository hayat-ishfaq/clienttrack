import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../data/project_repository.dart';
import '../domain/models/project_model.dart';

// ---------------------------------------------------------------------------
// Filter enum
// ---------------------------------------------------------------------------

enum _FilterTab { all, active, completed, planning }

extension _FilterTabLabel on _FilterTab {
  String get label {
    switch (this) {
      case _FilterTab.all:
        return 'All';
      case _FilterTab.active:
        return 'Active';
      case _FilterTab.completed:
        return 'Completed';
      case _FilterTab.planning:
        return 'Planning';
    }
  }
}

// ---------------------------------------------------------------------------
// Screen 11: Project List (Tab 3)
// Conforms to visily-11-project-list.png
// ---------------------------------------------------------------------------

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _FilterTab _activeFilter = _FilterTab.all;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    setState(() => _query = _searchCtrl.text.toLowerCase().trim());
  }

  List<ProjectModel> _filterList(List<ProjectModel> projects) {
    return projects.where((p) {
      final matchesTab = switch (_activeFilter) {
        _FilterTab.all => true,
        _FilterTab.active => p.status == ProjectStatus.inProgress ||
            p.status == ProjectStatus.onHold,
        _FilterTab.completed => p.status == ProjectStatus.completed,
        _FilterTab.planning => p.status == ProjectStatus.planning,
      };

      final matchesQuery = _query.isEmpty ||
          p.title.toLowerCase().contains(_query) ||
          p.clientName.toLowerCase().contains(_query);

      return matchesTab && matchesQuery;
    }).toList();
  }

  int _countFor(_FilterTab tab, List<ProjectModel> projects) => projects.where((p) {
        return switch (tab) {
          _FilterTab.all => true,
          _FilterTab.active => p.status == ProjectStatus.inProgress ||
              p.status == ProjectStatus.onHold,
          _FilterTab.completed => p.status == ProjectStatus.completed,
          _FilterTab.planning => p.status == ProjectStatus.planning,
        };
      }).length;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final allProjects = projectsAsync.asData?.value ?? kSeedProjects;
    final results = _filterList(allProjects);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top App Bar ─────────────────────────────────────────────
            _buildAppBar(),

            // ── Scrollable content ──────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        children: [
                          _buildSearchRow(),
                          const SizedBox(height: 14),
                          _buildFilterChips(allProjects),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Project cards
                  if (projectsAsync.isLoading && allProjects.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(color: AppColors.primaryForest),
                        ),
                      ),
                    )
                  else if (results.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: _ProjectCard(
                            project: results[i],
                            onTap: () =>
                                context.push('/projects/${results[i].id}'),
                          ),
                        ),
                        childCount: results.length,
                      ),
                    ),

                  // Bottom spacing for FAB + nav bar
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── Sub-builders ──────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          // Icon + title
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryForest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              size: 20,
              color: AppColors.primaryForest,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Projects',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          // Add project button
          _CircleIconButton(
            icon: Icons.add_rounded,
            onTap: () => context.push(AppRoutes.addProject),
          ),
          const SizedBox(width: 8),
          // Filter button
          _CircleIconButton(
            icon: Icons.tune_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Container(
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
        controller: _searchCtrl,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search projects...',
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
                    _searchCtrl.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textSecondary),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<ProjectModel> projects) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _FilterTab.values.map((tab) {
          final isActive = tab == _activeFilter;
          final count = _countFor(tab, projects);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeFilter = tab);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryForest
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primaryForest
                        : AppColors.border,
                    width: 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primaryForest
                                .withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (tab != _FilterTab.all) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
              child: const Icon(Icons.work_outline_rounded,
                  size: 34, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              _query.isNotEmpty
                  ? 'No projects match "$_query"'
                  : 'No projects in this category',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap + to create your first project.',
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
      onPressed: () => context.push(AppRoutes.addProject),
      backgroundColor: AppColors.primaryForest,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project Card
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  // Status appearance helpers
  Color get _statusBg => switch (project.status) {
        ProjectStatus.notStarted => AppColors.draftGreyBg,
        ProjectStatus.inProgress => AppColors.paidTealBg,
        ProjectStatus.planning => AppColors.dueSoonAmberBg,
        ProjectStatus.completed => const Color(0xFFE8F7F0),
        ProjectStatus.onHold => AppColors.draftGreyBg,
      };

  Color get _statusFg => switch (project.status) {
        ProjectStatus.notStarted => AppColors.draftGrey,
        ProjectStatus.inProgress => AppColors.accentTealGreen,
        ProjectStatus.planning => AppColors.dueSoonAmber,
        ProjectStatus.completed => AppColors.paidTeal,
        ProjectStatus.onHold => AppColors.draftGrey,
      };

  Color get _progressColor => switch (project.status) {
        ProjectStatus.notStarted => AppColors.draftGrey,
        ProjectStatus.inProgress => AppColors.accentTealGreen,
        ProjectStatus.planning => AppColors.dueSoonAmber,
        ProjectStatus.completed => AppColors.paidTeal,
        ProjectStatus.onHold => AppColors.draftGrey,
      };

  String get _statusLabel => switch (project.status) {
        ProjectStatus.notStarted => 'NOT STARTED',
        ProjectStatus.inProgress => 'IN PROGRESS',
        ProjectStatus.planning => 'PLANNING',
        ProjectStatus.completed => 'COMPLETED',
        ProjectStatus.onHold => 'ON HOLD',
      };

  String _formatBudget(double amount) {
    final s = amount.round().toString();
    if (s.length > 3) {
      return '\$${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return '\$$s';
  }

  String get _deadlineText {
    if (project.deadline == null) return 'No deadline';
    final d = project.deadline!;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (project.progressPct * 100).round();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: Title + client name ─────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          project.clientName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Row 2: Status chip + deadline ──────────────────────────
              Row(
                children: [
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _statusFg,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Deadline badge
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _deadlineText,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Row 3: Progress label + percentage ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Progress bar ────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: project.progressPct,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceMuted,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_progressColor),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),

              // ── Row 4: Budget + View Details ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Budget
                  Row(
                    children: [
                      const Text(
                        'Budget: ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatBudget(project.budget),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  // View Details
                  GestureDetector(
                    onTap: onTap,
                    child: Row(
                      children: const [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryForest,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppColors.primaryForest,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Circle icon button (AppBar)
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
