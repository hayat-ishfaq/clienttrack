import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';

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

  // Invoice details (mapped from Firestore / demo dataset)
  final String _clientName = 'Sarah Johnson';
  final String _clientInitials = 'SJ';
  final String _invoiceNumber = '#1023';
  final String _amount = '\$450.00';
  final String _statusBadge = '3 days overdue';
  final String _clientPhone = '+1 (555) 234-5678';
  final String _clientEmail = 'sarah@brightside.cafe';

  final Map<ReminderTone, String> _templates = {
    ReminderTone.friendly:
        'Hi Sarah, just a quick reminder that invoice #1023 for \$450 is currently due. Please let me know if you need anything from my side. Thanks!',
    ReminderTone.professional:
        'Dear Sarah,\n\nThis is a courteous follow-up regarding invoice #1023 for \$450.00, which is currently past due. Please confirm payment at your earliest convenience.\n\nBest regards,\nBrightside Cafe',
    ReminderTone.finalNotice:
        'URGENT: Invoice #1023 for \$450.00 is now overdue by 3 days. Please settle this outstanding balance immediately to avoid any service disruptions.\n\nThank you for your prompt attention.',
  };

  @override
  void initState() {
    super.initState();
    _messageController =
        TextEditingController(text: _templates[ReminderTone.friendly]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onToneSelected(ReminderTone tone) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTone = tone;
      _messageController.text = _templates[tone]!;
      _isEditing = false;
    });
  }

  Future<void> _handleAiPolish() async {
    HapticFeedback.mediumImpact();
    setState(() => _isPolishing = true);

    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isPolishing = false;
        if (_selectedTone == ReminderTone.friendly) {
          _messageController.text =
              'Hi Sarah! Hope your week is going great. Just a gentle heads-up that invoice #1023 (\$450) is ready for settlement whenever you have a moment. Thanks so much!';
        } else if (_selectedTone == ReminderTone.professional) {
          _messageController.text =
              'Dear Sarah,\n\nI hope this email finds you well. We would appreciate it if you could verify the payment status of invoice #1023 (\$450.00), due recently. Please let us know if you require any additional invoice details.\n\nWarm regards,\nClientTrack Finance';
        } else {
          _messageController.text =
              'Important Notice: Invoice #1023 for \$450.00 requires immediate settlement. Kindly process the pending balance today to maintain continuous service.\n\nThank you for prioritizing this.';
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

  Future<void> _shareNative() async {
    HapticFeedback.lightImpact();
    await SharePlus.instance.share(
      ShareParams(
        text: _messageController.text,
        subject: 'Payment Reminder for Invoice $_invoiceNumber',
      ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    HapticFeedback.lightImpact();
    final cleanPhone = _clientPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedText = Uri.encodeComponent(_messageController.text);
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$encodedText');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _shareNative();
    }
  }

  Future<void> _shareViaSms() async {
    HapticFeedback.lightImpact();
    final cleanPhone = _clientPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedText = Uri.encodeComponent(_messageController.text);
    final url = Uri.parse('sms:$cleanPhone?body=$encodedText');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _shareNative();
    }
  }

  Future<void> _shareViaMail() async {
    HapticFeedback.lightImpact();
    final url = Uri(
      scheme: 'mailto',
      path: _clientEmail,
      queryParameters: {
        'subject': 'Payment Reminder: Invoice $_invoiceNumber',
        'body': _messageController.text,
      },
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _shareNative();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildInvoiceSummaryCard(),
                  const SizedBox(height: 24),
                  // Reminder Tone Segmented Control
                  _buildReminderToneSection(),
                  const SizedBox(height: 24),
                  // Message Box Section
                  _buildMessageBoxSection(),
                  const SizedBox(height: 14),
                  // Free share counter & upgrade link
                  _buildUpgradeFooterNote(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Bottom Action & Share Via Area
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

  Widget _buildInvoiceSummaryCard() {
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
              _clientInitials,
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
                  _clientName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Invoice $_invoiceNumber',
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
                _amount,
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
                  color: const Color(0xFFDC2626), // Coral red badge
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusBadge,
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

  Widget _buildReminderToneSection() {
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
              _buildTonePill('Friendly', ReminderTone.friendly),
              _buildTonePill('Professional', ReminderTone.professional),
              _buildTonePill('Final', ReminderTone.finalNotice),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTonePill(String label, ReminderTone tone) {
    final isSelected = _selectedTone == tone;

    return Expanded(
      child: InkWell(
        onTap: () => _onToneSelected(tone),
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

  Widget _buildMessageBoxSection() {
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
              onTap: _isPolishing ? null : _handleAiPolish,
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
                      onPressed: _shareNative,
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
                  onTap: _shareViaWhatsApp,
                ),
                _buildAppShareIcon(
                  icon: Icons.chat_rounded,
                  label: 'Messages',
                  bgColor: const Color(0xFF3B82F6),
                  onTap: _shareViaSms,
                ),
                _buildAppShareIcon(
                  icon: Icons.mail_rounded,
                  label: 'Mail',
                  bgColor: const Color(0xFF1E293B),
                  onTap: _shareViaMail,
                ),
                _buildAppShareIcon(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  bgColor: const Color(0xFFF1F5F9),
                  iconColor: const Color(0xFF64748B),
                  onTap: _shareNative,
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
