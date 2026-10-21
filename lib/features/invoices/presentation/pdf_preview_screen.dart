import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../paywall/data/revenue_cat_service.dart';
import '../../settings/data/business_profile_repository.dart';
import '../../settings/domain/models/business_profile_model.dart';
import '../data/invoice_repository.dart';
import '../data/pdf_invoice_service.dart';
import '../domain/models/invoice_model.dart';

// ---------------------------------------------------------------------------
// Screen: PDF Preview / Final Review
// Conforms to Visily Mockup — Invoice Preview Screen
// ---------------------------------------------------------------------------

class PdfPreviewScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const PdfPreviewScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  bool _isExporting = false;

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _sharePdf(InvoiceModel invoice, BusinessProfileModel? profile, bool isPro) async {
    HapticFeedback.lightImpact();
    setState(() => _isExporting = true);
    try {
      await ref.read(pdfInvoiceServiceProvider).shareInvoicePdf(
        invoice: invoice,
        profile: profile,
        isPro: isPro,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _downloadPdf(InvoiceModel invoice, BusinessProfileModel? profile, bool isPro) async {
    HapticFeedback.lightImpact();
    setState(() => _isExporting = true);
    try {
      await ref.read(pdfInvoiceServiceProvider).shareInvoicePdf(
        invoice: invoice,
        profile: profile,
        isPro: isPro,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice PDF prepared for download!'),
            backgroundColor: AppColors.primaryForest,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _printDocument(InvoiceModel invoice, BusinessProfileModel? profile, bool isPro) async {
    HapticFeedback.lightImpact();
    try {
      await ref.read(pdfInvoiceServiceProvider).printInvoicePdf(
        invoice: invoice,
        profile: profile,
        isPro: isPro,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printer not available: $e')),
        );
      }
    }
  }

  Future<void> _emailToClient(InvoiceModel invoice, BusinessProfileModel? profile) async {
    HapticFeedback.lightImpact();
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: invoice.clientEmail,
      queryParameters: {
        'subject': 'Invoice #${invoice.invoiceNumber} from ClientTrack',
        'body':
            'Hi ${invoice.clientName},\n\nPlease find attached invoice #${invoice.invoiceNumber} for ${profile?.currencySymbol ?? '\$'}${invoice.totalAmount.toStringAsFixed(2)} due on ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}.\n\nThank you,\nClientTrack',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening mail client for ${invoice.clientEmail}...'),
            backgroundColor: AppColors.primaryForest,
          ),
        );
      }
    }
  }

  void _copyPaymentLink(InvoiceModel invoice) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(
      ClipboardData(
        text: 'https://pay.clienttrack.io/inv/${invoice.invoiceNumber}',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment link copied to clipboard!'),
        backgroundColor: AppColors.primaryForest,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showMoreMenu(
    TapDownDetails details,
    InvoiceModel invoice,
    BusinessProfileModel? profile,
    bool isPro,
  ) async {
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
          value: 'print',
          child: Row(
            children: [
              Icon(Icons.print_outlined, size: 20, color: AppColors.textPrimary),
              SizedBox(width: 12),
              Text('Print Document', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'link',
          child: Row(
            children: [
              Icon(Icons.link_rounded, size: 20, color: AppColors.textPrimary),
              SizedBox(width: 12),
              Text('Copy Payment Link', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'email',
          child: Row(
            children: [
              Icon(Icons.mail_outline_rounded, size: 20, color: AppColors.textPrimary),
              SizedBox(width: 12),
              Text('Email to Client', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
            ],
          ),
        ),
      ],
    );

    if (value == null || !mounted) return;
    if (value == 'print') {
      _printDocument(invoice, profile, isPro);
    } else if (value == 'link') {
      _copyPaymentLink(invoice);
    } else if (value == 'email') {
      _emailToClient(invoice, profile);
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
    final profile = ref.watch(businessProfileStreamProvider).asData?.value;
    final isPro = ref.watch(isProProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: _buildAppBar(invoice, profile, isPro),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFinalReviewBanner(invoice),
                  const SizedBox(height: 16),
                  _buildPaperDocumentSheet(invoice, profile, isPro),
                  const SizedBox(height: 24),
                  _buildQuoteSection(),
                  const SizedBox(height: 24),
                  _buildMoreActionsSection(invoice, profile, isPro),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildBottomActionButtons(invoice, profile, isPro),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(InvoiceModel invoice, BusinessProfileModel? profile, bool isPro) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invoice #${invoice.invoiceNumber}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Text(
            'Previewing Document',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
          onPressed: () => _sharePdf(invoice, profile, isPro),
        ),
        GestureDetector(
          onTapDown: (details) => _showMoreMenu(details, invoice, profile, isPro),
          child: const Padding(
            padding: EdgeInsets.only(right: 16, left: 4),
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

  // ── Final Review Banner ────────────────────────────────────────────────────

  Widget _buildFinalReviewBanner(InvoiceModel invoice) {
    final statusColor = invoice.status == InvoiceStatus.paid
        ? const Color(0xFF0F9D7B)
        : (invoice.isOverdue ? AppColors.overdueRed : AppColors.primaryForest);
    final statusBg = invoice.status == InvoiceStatus.paid
        ? const Color(0xFFE2F7F2)
        : (invoice.isOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFEBF6EE));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Final Review',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Check all details before sending',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            invoice.status.label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: statusColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Paper Document Sheet (Realistic PDF Card) ──────────────────────────────

  Widget _buildPaperDocumentSheet(InvoiceModel invoice, BusinessProfileModel? profile, bool isPro) {
    final currency = profile?.currencySymbol.isNotEmpty == true ? profile!.currencySymbol : '\$';
    final issueDateStr = DateFormat('MMM dd, yyyy').format(invoice.issueDate);
    final dueDateStr = DateFormat('MMM dd, yyyy').format(invoice.dueDate);
    final companyName = profile?.businessName.isNotEmpty == true
        ? profile!.businessName
        : (profile?.fullName.isNotEmpty == true ? profile!.fullName : 'Freelance Studio');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Logo/Doc icon + INVOICE & Company Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF6EE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.primaryForest,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'INVOICE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${invoice.invoiceNumber}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Company details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    companyName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (profile?.address.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      profile!.address,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (profile?.email.isNotEmpty == true) ...[
                    Text(
                      profile!.email,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (profile?.phone.isNotEmpty == true) ...[
                    Text(
                      profile!.phone,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          // Bill To & Details row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Bill To
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BILL TO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.clientName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (invoice.clientEmail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      invoice.clientEmail,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (invoice.clientPhone.isNotEmpty) ...[
                    Text(
                      invoice.clientPhone,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              // Right: Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'DETAILS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        'Date: ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        issueDateStr,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text(
                        'Due: ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        dueDateStr,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          // Line Items Table Header
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'QTY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'AMOUNT',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Line Items Rows
          if (invoice.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'No line items specified.',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary),
              ),
            )
          else
            ...invoice.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        item.description.isNotEmpty ? item.description : 'Service item',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.quantity.toStringAsFixed(
                          item.quantity.truncateToDouble() == item.quantity ? 0 : 2,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '$currency${item.amount.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Totals block (right aligned)
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 190,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$currency${invoice.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (invoice.taxAmount > 0 || invoice.taxRate > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tax (${invoice.taxRate.toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$currency${invoice.taxAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$currency${invoice.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryForest,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Notes / Payment instructions footer
          if (invoice.notes.isNotEmpty || profile?.bankDetails.isNotEmpty == true) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NOTES & INSTRUCTIONS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.notes.isNotEmpty
                        ? invoice.notes
                        : (profile?.bankDetails ?? 'Thank you for your business.'),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Center(
            child: Text(
              isPro
                  ? 'OFFICIAL INVOICE • ISSUED VIA CLIENTTRACK'
                  : 'VERIFIED FREELANCER DOCUMENT • GENERATED VIA CLIENTTRACK',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryForest,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quote / Tips Section ───────────────────────────────────────────────────

  Widget _buildQuoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.primaryForest, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Freelancer Tip',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryForest,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Invoices sent within 24 hours of milestone completion get paid 42% faster on average.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF166534),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── More Actions Section ───────────────────────────────────────────────────

  Widget _buildMoreActionsSection(InvoiceModel invoice, BusinessProfileModel? profile, bool isPro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MORE ACTIONS',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        // Action 1: Email to Client
        _buildActionCard(
          icon: Icons.mail_outline_rounded,
          title: 'Email to Client',
          subtitle: invoice.clientEmail.isNotEmpty ? invoice.clientEmail : 'Send via default email client',
          onTap: () => _emailToClient(invoice, profile),
        ),
        const SizedBox(height: 10),
        // Action 2: Print Document
        _buildActionCard(
          icon: Icons.print_outlined,
          title: 'Print Document',
          subtitle: 'AirPrint / Google Cloud Print / Local printer',
          onTap: () => _printDocument(invoice, profile, isPro),
        ),
        const SizedBox(height: 10),
        // Action 3: Copy Payment Link
        _buildActionCard(
          icon: Icons.open_in_new_rounded,
          title: 'Copy Payment Link',
          subtitle: 'Direct transfer or checkout link',
          onTap: () => _copyPaymentLink(invoice),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F6F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryForest, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Action Buttons ──────────────────────────────────────────────────

  Widget _buildBottomActionButtons(InvoiceModel invoice, BusinessProfileModel? profile, bool isPro) {
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
        child: Row(
          children: [
            // Download button (Outlined)
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _isExporting ? null : () => _downloadPdf(invoice, profile, isPro),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 19,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Download',
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
            // Share PDF button (Primary Forest)
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isExporting ? null : () => _sharePdf(invoice, profile, isPro),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryForest,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share_outlined, size: 19, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Share PDF',
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
      ),
    );
  }
}
