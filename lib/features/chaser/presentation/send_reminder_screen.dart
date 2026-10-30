import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/feature_gate_service.dart';
import '../../invoices/data/invoice_repository.dart';
import '../../invoices/domain/models/invoice_model.dart';
import '../data/reminder_repository.dart';
import '../domain/models/reminder_log_model.dart';

// ---------------------------------------------------------------------------
// Screen: Send Reminder
// Conforms to Visily Mockup — Send Reminder Screen
// ---------------------------------------------------------------------------

enum ReminderTone {
  friendly,
  professional,
  finalNotice,
}

class SendReminderScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const SendReminderScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  ConsumerState<SendReminderScreen> createState() => _SendReminderScreenState();
}

class _SendReminderScreenState extends ConsumerState<SendReminderScreen> {
  ReminderTone _selectedTone = ReminderTone.friendly;
  late TextEditingController _messageController;
  bool _isEditing = false;
  bool _isPolishing = false;
  bool _initialized = false;

  Map<ReminderTone, String> _buildTemplates(InvoiceModel inv) {
    final balance = '\$${inv.balanceDue.toStringAsFixed(2)}';
    final number = inv.invoiceNumber;
    final name = inv.clientName.split(' ').first;

    return {
      ReminderTone.friendly:
          'Hi $name, just a quick reminder that invoice $number for $balance is currently due. Please let me know if you need anything from my side. Thanks!',
      ReminderTone.professional:
          'Dear ${inv.clientName},\n\nThis is a courteous follow-up regarding invoice $number for $balance, which is currently past due. Please confirm payment at your earliest convenience.\n\nBest regards,\n${inv.projectTitle ?? 'ClientTrack'}',
      ReminderTone.finalNotice:
          'URGENT: Invoice $number for $balance is now overdue by ${inv.daysOverdue} days. Please settle this outstanding balance immediately to avoid any service disruptions.\n\nThank you for your prompt attention.',
    };
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onToneSelected(ReminderTone tone, InvoiceModel invoice) {
    HapticFeedback.selectionClick();
    final templates = _buildTemplates(invoice);
    setState(() {
      _selectedTone = tone;
      _messageController.text = templates[tone]!;
      _isEditing = false;
    });
  }

  Future<void> _handleAiPolish(InvoiceModel invoice) async {
    HapticFeedback.mediumImpact();
    setState(() => _isPolishing = true);

    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      final name = invoice.clientName.split(' ').first;
      final number = invoice.invoiceNumber;
      final balance = '\$${invoice.balanceDue.toStringAsFixed(2)}';

      setState(() {
        _isPolishing = false;
        if (_selectedTone == ReminderTone.friendly) {
          _messageController.text =
              'Hi $name! Hope your week is going great. Just a gentle heads-up that invoice $number ($balance) is ready for settlement whenever you have a moment. Thanks so much!';
        } else if (_selectedTone == ReminderTone.professional) {
          _messageController.text =
              'Dear ${invoice.clientName},\n\nI hope this message finds you well. We would appreciate it if you could verify the payment status of invoice $number ($balance). Please let us know if you require any additional details.\n\nWarm regards,\nFinance';
        } else {
          _messageController.text =
              'Important Notice: Invoice $number for $balance requires immediate settlement. Kindly process the pending balance today to maintain continuous service.\n\nThank you for prioritizing this.';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Message polished with AI for optimal response!'),
          backgroundColor: AppColors.primaryForest,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyToClipboard() {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: _messageController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder message copied to clipboard!'),
        backgroundColor: AppColors.primaryForest,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logReminderSent(InvoiceModel invoice, String channel) async {
    try {
      final log = ReminderLogModel(
        id: '',
        invoiceId: invoice.id,
        invoiceNumber: invoice.invoiceNumber,
        clientId: invoice.clientId,
        clientName: invoice.clientName,
        channel: channel,
        tone: _selectedTone.name,
        messageContent: _messageController.text,
        sentAt: DateTime.now(),
        recipient: (channel == 'whatsapp' || channel == 'sms')
            ? invoice.clientPhone
            : invoice.clientEmail,
      );
      await ref.read(reminderRepositoryProvider).logReminder(log);
    } catch (_) {}
  }

  /// Helper: shows a contextual upgrade snackbar.
  void _showGateBlockedSnackbar(String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reason, style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppColors.overdueRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Upgrade',
          textColor: Colors.white,
          onPressed: () => context.push(AppRoutes.paywall),
        ),
      ),
    );
  }

  Future<void> _shareNative(InvoiceModel invoice) async {
    // ── FT-019: Feature gate — free-tier reminder share limit ──────────────
    final gate = ref.read(featureGateServiceProvider);
    final gateResult = await gate.checkCanShareReminder();
    if (!gateResult.allowed) {
      if (!mounted) return;
      _showGateBlockedSnackbar(gateResult.blockedReason);
      context.push(AppRoutes.paywall);
      return;
    }
    // ────────────────────────────────────────────────────────────────────────
    HapticFeedback.lightImpact();
    await _logReminderSent(invoice, 'native');
    await SharePlus.instance.share(
      ShareParams(
        text: _messageController.text,
        subject: 'Payment Reminder for Invoice ${invoice.invoiceNumber}',
      ),
    );
  }

  Future<void> _shareViaWhatsApp(InvoiceModel invoice) async {
    // ── FT-019: gate ────────────────────────────────────────────────────────
    final gate = ref.read(featureGateServiceProvider);
    final gateResult = await gate.checkCanShareReminder();
    if (!gateResult.allowed) {
      if (!mounted) return;
      _showGateBlockedSnackbar(gateResult.blockedReason);
      context.push(AppRoutes.paywall);
      return;
    }
    // ────────────────────────────────────────────────────────────────────────
    HapticFeedback.lightImpact();
    await _logReminderSent(invoice, 'whatsapp');
    final cleanPhone = invoice.clientPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedText = Uri.encodeComponent(_messageController.text);

    final appUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedText');
    final webUri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedText');

    bool launched = false;
    try {
      if (await canLaunchUrl(appUri)) {
        launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }

    if (!launched) {
      await SharePlus.instance.share(
        ShareParams(
          text: _messageController.text,
          subject: 'Payment Reminder for Invoice ${invoice.invoiceNumber}',
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening WhatsApp... reminder logged!'),
          backgroundColor: AppColors.primaryForest,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareViaSms(InvoiceModel invoice) async {
    // ── FT-019: gate ────────────────────────────────────────────────────────
    final gate = ref.read(featureGateServiceProvider);
    final gateResult = await gate.checkCanShareReminder();
    if (!gateResult.allowed) {
      if (!mounted) return;
      _showGateBlockedSnackbar(gateResult.blockedReason);
      context.push(AppRoutes.paywall);
      return;
    }
    // ────────────────────────────────────────────────────────────────────────
    HapticFeedback.lightImpact();
    await _logReminderSent(invoice, 'sms');
    final cleanPhone = invoice.clientPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final encodedText = Uri.encodeComponent(_messageController.text);

    final separator = (!kIsWeb && Platform.isIOS) ? '&' : '?';
    final smsUri = Uri.parse('sms:$cleanPhone${separator}body=$encodedText');

    bool launched = false;
    try {
      if (await canLaunchUrl(smsUri)) {
        launched = await launchUrl(smsUri);
      }
    } catch (_) {
      launched = false;
    }

    if (!launched) {
      await SharePlus.instance.share(
        ShareParams(
          text: _messageController.text,
          subject: 'Payment Reminder for Invoice ${invoice.invoiceNumber}',
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening Messages... reminder logged!'),
          backgroundColor: AppColors.primaryForest,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareViaMail(InvoiceModel invoice) async {
    // ── FT-019: gate ────────────────────────────────────────────────────────
    final gate = ref.read(featureGateServiceProvider);
    final gateResult = await gate.checkCanShareReminder();
    if (!gateResult.allowed) {
      if (!mounted) return;
      _showGateBlockedSnackbar(gateResult.blockedReason);
      context.push(AppRoutes.paywall);
      return;
    }
    // ────────────────────────────────────────────────────────────────────────
    HapticFeedback.lightImpact();
    await _logReminderSent(invoice, 'email');
    final mailUri = Uri(
      scheme: 'mailto',
      path: invoice.clientEmail,
      queryParameters: {
        'subject': 'Payment Reminder: Invoice ${invoice.invoiceNumber}',
        'body': _messageController.text,
      },
    );

    bool launched = false;
    try {
      if (await canLaunchUrl(mailUri)) {
        launched = await launchUrl(mailUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }

    if (!launched) {
      await _shareNative(invoice);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening Email client... reminder logged!'),
          backgroundColor: AppColors.primaryForest,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceByIdProvider(widget.invoiceId));
    final invoice = invoiceAsync.asData?.value ??
        kSeedInvoices.firstWhere(
          (i) => i.id == widget.invoiceId,
          orElse: () => kSeedInvoices.first,
        );

    if (!_initialized) {
      _messageController.text =
          _buildTemplates(invoice)[ReminderTone.friendly]!;
      _initialized = true;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoice Summary Card
                  _buildInvoiceSummaryCard(invoice),
                  const SizedBox(height: 24),
                  // Reminder Tone Segmented Control
                  _buildReminderToneSection(invoice),
                  const SizedBox(height: 24),
                  // Message Box Section
                  _buildMessageBoxSection(invoice),
                  const SizedBox(height: 14),
                  // Free share counter & upgrade link
                  _buildUpgradeFooterNote(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Bottom Action & Share Via Area
          _buildBottomActionArea(invoice),
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
        'Send reminder',
        style: TextStyle(
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

  // ── Invoice Summary Card ───────────────────────────────────────────────────

  Widget _buildInvoiceSummaryCard(InvoiceModel invoice) {
    final initials = invoice.clientName.trim().isNotEmpty
        ? invoice.clientName
            .trim()
            .split(' ')
            .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
            .take(2)
            .join()
        : 'C';

    final statusBadge = invoice.isOverdue
        ? '${invoice.daysOverdue} days overdue'
        : invoice.status.label;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Client Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF1E293B),
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name and invoice
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.clientName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Invoice ${invoice.invoiceNumber}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Amount & Overdue Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${invoice.balanceDue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: invoice.isOverdue
                      ? const Color(0xFFDC2626)
                      : AppColors.sentBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusBadge,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Reminder Tone Section ──────────────────────────────────────────────────

  Widget _buildReminderToneSection(InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REMINDER TONE',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // Light grey track
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _buildTonePill('Friendly', ReminderTone.friendly, invoice),
              _buildTonePill('Professional', ReminderTone.professional, invoice),
              _buildTonePill('Final', ReminderTone.finalNotice, invoice),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTonePill(String label, ReminderTone tone, InvoiceModel invoice) {
    final isSelected = _selectedTone == tone;

    return Expanded(
      child: InkWell(
        onTap: () => _onToneSelected(tone, invoice),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
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
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ── Message Box Section ────────────────────────────────────────────────────

  Widget _buildMessageBoxSection(InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MESSAGE',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            // AI POLISH PRO Badge Button
            InkWell(
              onTap: _isPolishing ? null : () => _handleAiPolish(invoice),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // Light amber/cream
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isPolishing
                        ? const SizedBox(
                            width: 11,
                            height: 11,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFD97706)),
                            ),
                          )
                        : const Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: Color(0xFFD97706),
                          ),
                    const SizedBox(width: 4),
                    const Text(
                      'AI POLISH',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Message Container Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      maxLines: null,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() => _isEditing = !_isEditing);
                    },
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Upgrade Footer Note ────────────────────────────────────────────────────

  Widget _buildUpgradeFooterNote() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '1 free share left • ',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          InkWell(
            onTap: () => context.push(AppRoutes.paywall),
            child: const Text(
              'Upgrade',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryForest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Action & Share Via Area ─────────────────────────────────────────

  Widget _buildBottomActionArea(InvoiceModel invoice) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row of Copy and Share Buttons
            Row(
              children: [
                // Copy Button (Outlined)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _copyToClipboard,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.copy_outlined,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Share Button (Primary Forest)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _shareNative(invoice),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryForest,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.near_me_outlined,
                            size: 19,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Share',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // SHARE VIA Divider line
            Row(
              children: [
                const Text(
                  'SHARE VIA',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick App Share Row (WhatsApp, Messages, Mail, More)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAppShareIcon(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'WhatsApp',
                  bgColor: const Color(0xFF25D366),
                  onTap: () => _shareViaWhatsApp(invoice),
                ),
                _buildAppShareIcon(
                  icon: Icons.chat_rounded,
                  label: 'Messages',
                  bgColor: const Color(0xFF3B82F6),
                  onTap: () => _shareViaSms(invoice),
                ),
                _buildAppShareIcon(
                  icon: Icons.mail_rounded,
                  label: 'Mail',
                  bgColor: const Color(0xFF1E293B),
                  onTap: () => _shareViaMail(invoice),
                ),
                _buildAppShareIcon(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  bgColor: const Color(0xFFF1F5F9),
                  iconColor: const Color(0xFF64748B),
                  onTap: () => _shareNative(invoice),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppShareIcon({
    required IconData icon,
    required String label,
    required Color bgColor,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
