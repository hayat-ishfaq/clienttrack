import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../clients/data/client_repository.dart';
import '../../clients/domain/models/client_model.dart';
import '../data/project_repository.dart';
import '../domain/models/project_model.dart';
import '../../../core/services/notification_service.dart';

// ---------------------------------------------------------------------------
// Screen: New Project / Edit Project
// Conforms to Visily Mockup — New Project Screen
// ---------------------------------------------------------------------------

enum ProjectStatusSelection {
  notStarted,
  inProgress,
  completed,
}

enum RateTypeSelection {
  fixed,
  hourly,
}

class NewProjectScreen extends ConsumerStatefulWidget {
  final String? projectId;

  const NewProjectScreen({
    super.key,
    this.projectId,
  });

  @override
  ConsumerState<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends ConsumerState<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _rateController;

  ClientModel? _selectedClient;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  ProjectStatusSelection _status = ProjectStatusSelection.notStarted;
  RateTypeSelection _rateType = RateTypeSelection.fixed;
  bool _autoInvoicingEnabled = true;
  bool _isSaving = false;
  bool _hasLoadedProject = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _rateController = TextEditingController(text: '0.00');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  // ── Date Picker ────────────────────────────────────────────────────────────

  Future<void> _pickDeadline() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryForest,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  // ── Client Picker Modal ────────────────────────────────────────────────────

  void _showClientPicker(List<ClientModel> clients) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Select Client',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ...clients.map(
                (c) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Text(
                      c.initials,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryForest,
                      ),
                    ),
                  ),
                  title: Text(
                    c.name,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: c.id == _selectedClient?.id
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    c.company,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: c.id == _selectedClient?.id
                      ? const Icon(Icons.check, color: AppColors.primaryForest)
                      : null,
                  onTap: () {
                    setState(() => _selectedClient = c);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Save Action ────────────────────────────────────────────────────────────

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
      final status = switch (_status) {
        ProjectStatusSelection.notStarted => ProjectStatus.notStarted,
        ProjectStatusSelection.inProgress => ProjectStatus.inProgress,
        ProjectStatusSelection.completed => ProjectStatus.completed,
      };
      final rateType = switch (_rateType) {
        RateTypeSelection.fixed => RateType.fixed,
        RateTypeSelection.hourly => RateType.hourly,
      };

      final project = ProjectModel(
        id: widget.projectId ?? '',
        clientId: _selectedClient?.id ?? '',
        clientName: _selectedClient?.name ?? 'Client',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: status,
        rateType: rateType,
        budget: rate,
        deadline: _deadline,
        progressPct: status == ProjectStatus.completed
            ? 1.0
            : (status == ProjectStatus.inProgress ? 0.5 : 0.0),
        autoInvoicingEnabled: _autoInvoicingEnabled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.projectId != null) {
        await ref.read(projectRepositoryProvider).updateProject(project);
      } else {
        await ref.read(projectRepositoryProvider).addProject(project);
      }
      await ref.read(notificationServiceProvider).scheduleProjectDeadlineReminder(project);

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.projectId != null
                  ? 'Project updated successfully!'
                  : 'Project "${_titleController.text.trim()}" created!',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: AppColors.primaryForest,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving project: $e'),
            backgroundColor: AppColors.overdueRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsStreamProvider).asData?.value ?? kSeedClients;
    if (_selectedClient == null && clients.isNotEmpty) {
      _selectedClient = clients.first;
    }

    if (widget.projectId != null && !_hasLoadedProject) {
      final projectAsync = ref.watch(projectByIdProvider(widget.projectId!));
      final project = projectAsync.asData?.value;
      if (project != null) {
        _hasLoadedProject = true;
        _titleController.text = project.title;
        _descriptionController.text = project.description;
        _rateController.text = project.budget.toStringAsFixed(2);
        _status = project.status == ProjectStatus.completed
            ? ProjectStatusSelection.completed
            : (project.status == ProjectStatus.inProgress
                ? ProjectStatusSelection.inProgress
                : ProjectStatusSelection.notStarted);
        _rateType = project.rateType == RateType.hourly
            ? RateTypeSelection.hourly
            : RateTypeSelection.fixed;
        if (project.deadline != null) {
          _deadline = project.deadline!;
        }
        _autoInvoicingEnabled = project.autoInvoicingEnabled;
        if (project.clientId.isNotEmpty && clients.isNotEmpty) {
          _selectedClient = clients.cast<ClientModel?>().firstWhere(
                (c) => c?.id == project.clientId,
                orElse: () => null,
              );
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Project Title
                    _buildProjectTitleField(),
                    const SizedBox(height: 20),
                    // Section 2: Description
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    // Section 3: Client Selector
                    _buildClientSelector(clients),
                    const SizedBox(height: 20),
                    // Section 4: Deadline
                    _buildDeadlineField(),
                    const SizedBox(height: 20),
                    // Section 5: Status
                    _buildStatusSegmentedControl(),
                    const SizedBox(height: 24),
                    // Section 6: Rate Information
                    _buildRateInformationSection(),
                    const SizedBox(height: 20),
                    // Section 7: Automatic Invoicing Card
                    _buildAutomaticInvoicingCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomActionArea(),
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
      title: Text(
        widget.projectId != null ? 'Edit project' : 'New project',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Section 1: Project Title ───────────────────────────────────────────────

  Widget _buildProjectTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PROJECT TITLE',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            controller: _titleController,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter a project title';
              }
              return null;
            },
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'e.g. Website Redesign',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ── Section 2: Description ─────────────────────────────────────────────────

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DESCRIPTION',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'Briefly describe the project goals...',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ── Section 3: Client Selector ─────────────────────────────────────────────

  Widget _buildClientSelector(List<ClientModel> clients) {
    final clientName = _selectedClient?.name ?? 'Select a client';
    final clientCompany = _selectedClient?.company ?? 'Tap to select client';
    final clientInitials = _selectedClient?.initials ?? 'CL';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CLIENT',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showClientPicker(clients),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFF3EBE1),
                  child: Text(
                    clientInitials,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7A5C3D),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Client Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        clientCompany,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Change Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CHANGE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Section 4: Deadline ────────────────────────────────────────────────────

  Widget _buildDeadlineField() {
    final formattedDate = DateFormat('MMM dd, yyyy').format(_deadline);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DEADLINE',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDeadline,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Section 5: Status ──────────────────────────────────────────────────────

  Widget _buildStatusSegmentedControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STATUS',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // Light grey track
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildStatusPill(
                label: 'Not Started',
                status: ProjectStatusSelection.notStarted,
              ),
              _buildStatusPill(
                label: 'In Progress',
                status: ProjectStatusSelection.inProgress,
              ),
              _buildStatusPill(
                label: 'Completed',
                status: ProjectStatusSelection.completed,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill({
    required String label,
    required ProjectStatusSelection status,
  }) {
    final isSelected = _status == status;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _status = status);
        },
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primaryForest
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ── Section 6: Rate Information ───────────────────────────────────────────

  Widget _buildRateInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RATE INFORMATION',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            // Fixed vs Hourly Pill
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildRateTypePill(
                    label: 'Fixed',
                    type: RateTypeSelection.fixed,
                  ),
                  _buildRateTypePill(
                    label: 'Hourly',
                    type: RateTypeSelection.hourly,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Text(
                '\$ ',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryForest,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _rateController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                _rateType == RateTypeSelection.fixed ? 'TOTAL' : '/HR',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRateTypePill({
    required String label,
    required RateTypeSelection type,
  }) {
    final isSelected = _rateType == type;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _rateType = type);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.primaryForest
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── Section 7: Automatic Invoicing Card ────────────────────────────────────

  Widget _buildAutomaticInvoicingCard() {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _autoInvoicingEnabled = !_autoInvoicingEnabled);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF), // Soft sky blue
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD0E5FF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              child: Icon(
                _autoInvoicingEnabled
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: const Color(0xFF2563EB),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Automatic Invoicing',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'ClientTrack Pro can auto-generate draft invoices based on your project status updates.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF4B5563),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Action Area ─────────────────────────────────────────────────────

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.projectId != null ? 'Update project' : 'Save project',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
