import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/feature_gate_service.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../domain/models/client_model.dart';
import '../data/client_repository.dart';

// ---------------------------------------------------------------------------
// Screen 09: Add / Edit Client
// Conforms to visily-09-add-edit-client.png
// ---------------------------------------------------------------------------

/// Pass [clientId] to switch to Edit mode; null = Add New Client.
class AddEditClientScreen extends ConsumerStatefulWidget {
  final String? clientId;

  const AddEditClientScreen({super.key, this.clientId});

  bool get isEditing => clientId != null;

  @override
  ConsumerState<AddEditClientScreen> createState() =>
      _AddEditClientScreenState();
}

class _AddEditClientScreenState extends ConsumerState<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // ── Controllers ────────────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingClient();
      });
    }
  }

  Future<void> _loadExistingClient() async {
    final client = await ref.read(clientRepositoryProvider).getClient(widget.clientId!);
    if (client != null && mounted) {
      setState(() {
        _nameCtrl.text = client.name;
        _companyCtrl.text = client.company;
        _emailCtrl.text = client.email;
        _phoneCtrl.text = client.phone;
        _websiteCtrl.text = client.website;
        _addressCtrl.text = client.address;
        _notesCtrl.text = client.notes;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    // ── FT-019: Feature gate — free-tier client limit check ────────────────
    if (!widget.isEditing) {
      final gate = ref.read(featureGateServiceProvider);
      final result = gate.checkCanAddClient();
      if (!result.allowed) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.blockedReason,
                style: const TextStyle(fontFamily: 'Inter')),
            backgroundColor: AppColors.overdueRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Upgrade',
              textColor: Colors.white,
              onPressed: () => context.push(AppRoutes.paywall),
            ),
          ),
        );
        context.push(AppRoutes.paywall);
        return;
      }
    }
    // ────────────────────────────────────────────────────────────────────────

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(clientRepositoryProvider);
      if (widget.isEditing) {
        final existing = await repo.getClient(widget.clientId!);
        final updated = (existing ?? ClientModel(id: widget.clientId!, name: _nameCtrl.text.trim())).copyWith(
          name: _nameCtrl.text.trim(),
          company: _companyCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          website: _websiteCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
        );
        await repo.updateClient(updated);
      } else {
        final newClient = ClientModel(
          id: '',
          name: _nameCtrl.text.trim(),
          company: _companyCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          website: _websiteCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          status: ClientStatus.active,
        );
        await repo.addClient(newClient);
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isSaving = false);

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? 'Client updated successfully.'
              : 'Client saved successfully.',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: AppColors.primaryForest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _onCancel() {
    if (_isDirty()) {
      _showDiscardDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  bool _isDirty() =>
      _nameCtrl.text.isNotEmpty ||
      _companyCtrl.text.isNotEmpty ||
      _emailCtrl.text.isNotEmpty;

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Discard changes?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'All unsaved changes will be lost.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Keep Editing',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Discard',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: AppColors.overdueRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
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
          'Deleting "${_nameCtrl.text}" will permanently remove all linked '
          'projects and invoices. This cannot be undone.',
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
            onPressed: () {
              Navigator.pop(ctx);
              // TODO(FT-007): delete from Firestore
              Navigator.of(context).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: AppColors.overdueRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isEditing ? 'Edit Client' : 'Add New Client';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: _buildAppBar(title),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
                left: 20, right: 20, top: 24, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar ──────────────────────────────────────────────────
                _buildAvatarSection(),
                const SizedBox(height: 32),

                // ── Basic Information ────────────────────────────────────────
                _buildSectionHeader(
                  icon: Icons.person_outline_rounded,
                  label: 'BASIC INFORMATION',
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Full Name'),
                const SizedBox(height: 8),
                _FormField(
                  controller: _nameCtrl,
                  hintText: 'Sarah Jenkins',
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Company Name'),
                const SizedBox(height: 8),
                _FormField(
                  controller: _companyCtrl,
                  hintText: 'Creative Studio Co.',
                  prefixIcon: Icons.business_outlined,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 28),

                // ── Contact Details ──────────────────────────────────────────
                _buildSectionHeader(
                  icon: Icons.mail_outline_rounded,
                  label: 'CONTACT DETAILS',
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Email Address'),
                const SizedBox(height: 8),
                _FormField(
                  controller: _emailCtrl,
                  hintText: 'sarah.j@creative-studio.co',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null; // optional
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    return emailRegex.hasMatch(v.trim())
                        ? null
                        : 'Enter a valid email';
                  },
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Phone Number'),
                const SizedBox(height: 8),
                _FormField(
                  controller: _phoneCtrl,
                  hintText: '+1 (555) 012-3456',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Website'),
                const SizedBox(height: 8),
                _FormField(
                  controller: _websiteCtrl,
                  hintText: 'www.creativestudio.co',
                  prefixIcon: Icons.language_outlined,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 28),

                // ── Location & Notes ─────────────────────────────────────────
                _buildSectionHeader(
                  icon: Icons.location_on_outlined,
                  label: 'LOCATION & NOTES',
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Office Address'),
                const SizedBox(height: 8),
                _FormField(
                  controller: _addressCtrl,
                  hintText:
                      '123 Design Lane, Suite 400, Portland, OR 97204',
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Additional Notes'),
                const SizedBox(height: 8),
                _FormField(
                  controller: _notesCtrl,
                  hintText:
                      'Preferred communication via email. Usually pays within 15 days of invoice issue.',
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 32),

                // ── Delete button (edit mode only) ───────────────────────────
                if (widget.isEditing) ...[
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _showDeleteDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.overdueRed,
                        side: const BorderSide(
                            color: AppColors.overdueRed, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      label: const Text(
                        'Delete Client',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Save button ──────────────────────────────────────────────
                PrimaryButton(
                  label: 'Save Client Profile',
                  icon: Icons.save_outlined,
                  isLoading: _isSaving,
                  onPressed: _onSave,
                ),
                const SizedBox(height: 12),

                // ── Cancel button ────────────────────────────────────────────
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: _onCancel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
        onPressed: _onCancel,
      ),
      title: Text(
        title,
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

  // ── Avatar section ─────────────────────────────────────────────────────────

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // TODO(FT-007): image picker for avatar
            },
            child: Stack(
              children: [
                // Avatar circle
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE2E8F0),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 36,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                // Camera badge
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryForest,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap to change photo',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryForest),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryForest,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal Form Field — styled to match the mockup
// ─────────────────────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.5,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 18,
                color: AppColors.textSecondary,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryForest, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.overdueRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.overdueRed, width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: AppColors.overdueRed,
        ),
      ),
    );
  }
}
