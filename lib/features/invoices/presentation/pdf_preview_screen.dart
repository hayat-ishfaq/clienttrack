import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Screen: PDF Preview / Final Review
// Conforms to Visily Mockup — Invoice INV-2024-001 Preview
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

  // Invoice demo data (matching Visily mockup)
  final String _invoiceNumber = 'INV-2024-001';
  final String _status = 'DRAFT';

  final String _companyName = 'ClientTrack Inc.';
  final String _companyAddress1 = '123 Freelance Way';
  final String _companyAddress2 = 'Digital Valley, CA 94025';
  final String _companyCountry = 'United States';

  final String _clientName = 'Alex Thompson';
  final String _clientCompany = 'Acme Design Studio';
  final String _clientStreet = '456 Creative St.';
  final String _clientCity = 'San Francisco, CA 94103';
  final String _clientEmail = 'alex@acmedesign.co';

  final String _issueDate = 'May 24, 2024';
  final String _dueDate = 'Jun 07, 2024';

  final List<Map<String, dynamic>> _lineItems = const [
    {
      'description': 'Brand Identity Design - Phase 1',
      'qty': '1',
      'amount': '\$1,200.00',
      'numAmount': 1200.0,
    },
    {
      'description': 'Mobile App Wireframing (15 screens)',
      'qty': '40h',
      'amount': '\$2,400.00',
      'numAmount': 2400.0,
    },
    {
      'description': 'Client Consultation & Research',
      'qty': '5h',
      'amount': '\$350.00',
      'numAmount': 350.0,
    },
  ];

  final String _subtotal = '\$3,950.00';
  final String _tax = '\$0.00';
  final String _total = '\$3,950.00';

  final String _notes =
      'Thank you for your business. Payment is expected within 14 days. Please include invoice number INV-2024-001 in your transfer description.';

  // ── PDF Generation Logic ───────────────────────────────────────────────────

  Future<Uint8List> _generatePdfBytes() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF1B2A1E),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        _invoiceNumber,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromInt(0xFF6B7A6E),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        _companyName,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(_companyAddress1,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColor.fromInt(0xFF6B7A6E))),
                      pw.Text(_companyAddress2,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColor.fromInt(0xFF6B7A6E))),
                      pw.Text(_companyCountry,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColor.fromInt(0xFF6B7A6E))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              // Bill To & Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILL TO',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF9BA89E),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(_clientName,
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(_clientCompany,
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(_clientStreet,
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(_clientCity,
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'DETAILS',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF9BA89E),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Date: $_issueDate',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Due: $_dueDate',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              // Line Items Table
              pw.Table(
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(
                      color: PdfColor.fromInt(0xFFE1E8E2), width: 1),
                ),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                            color: PdfColor.fromInt(0xFFE1E8E2), width: 1),
                      ),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Text('DESCRIPTION',
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFF9BA89E))),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Text('QTY',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFF9BA89E))),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Text('AMOUNT',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFF9BA89E))),
                      ),
                    ],
                  ),
                  ..._lineItems.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Text(item['description'] as String,
                              style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Text(item['qty'] as String,
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Text(item['amount'] as String,
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text('Subtotal  ',
                              style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColor.fromInt(0xFF6B7A6E))),
                          pw.Text(_subtotal,
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        children: [
                          pw.Text('Tax (0%)  ',
                              style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColor.fromInt(0xFF6B7A6E))),
                          pw.Text(_tax,
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        children: [
                          pw.Text('Total  ',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(_total,
                              style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color:
                                      const PdfColor.fromInt(0xFF2E5D31))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              // Notes
              pw.Text(
                'NOTES & TERMS',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF9BA89E),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                _notes,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColor.fromInt(0xFF6B7A6E),
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Center(
                child: pw.Text(
                  'VERIFIED CLIENTTRACK DOCUMENT',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF2E5D31),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _sharePdf() async {
    HapticFeedback.lightImpact();
    setState(() => _isExporting = true);
    try {
      final bytes = await _generatePdfBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: '$_invoiceNumber.pdf',
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

  Future<void> _downloadPdf() async {
    HapticFeedback.lightImpact();
    setState(() => _isExporting = true);
    try {
      final bytes = await _generatePdfBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: '$_invoiceNumber.pdf',
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

  Future<void> _printDocument() async {
    HapticFeedback.lightImpact();
    try {
      final bytes = await _generatePdfBytes();
      await Printing.layoutPdf(onLayout: (_) => bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printer not available: $e')),
        );
      }
    }
  }

  Future<void> _emailToClient() async {
    HapticFeedback.lightImpact();
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _clientEmail,
      queryParameters: {
        'subject': 'Invoice $_invoiceNumber from ClientTrack',
        'body':
            'Hi $_clientName,\n\nPlease find attached invoice $_invoiceNumber for $_total due on $_dueDate.\n\nThank you,\nClientTrack',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening mail client for $_clientEmail...'),
            backgroundColor: AppColors.primaryForest,
          ),
        );
      }
    }
  }

  void _copyPaymentLink() {
    HapticFeedback.mediumImpact();
    Clipboard.setData(
      ClipboardData(
        text: 'https://pay.clienttrack.io/inv/${widget.invoiceId}',
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
      _printDocument();
    } else if (value == 'link') {
      _copyPaymentLink();
    } else if (value == 'email') {
      _emailToClient();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
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
                  _buildFinalReviewBanner(),
                  const SizedBox(height: 16),
                  _buildPaperDocumentSheet(),
                  const SizedBox(height: 24),
                  _buildQuoteSection(),
                  const SizedBox(height: 24),
                  _buildMoreActionsSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildBottomActionButtons(),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _invoiceNumber,
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
          onPressed: _sharePdf,
        ),
        GestureDetector(
          onTapDown: _showMoreMenu,
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

  Widget _buildFinalReviewBanner() {
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
                fontSize: 22,
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
        // DRAFT Status Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F7F2), // Light mint
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _status,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F9D7B), // Teal mint
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Paper Document Sheet (Realistic PDF Card) ──────────────────────────────

  Widget _buildPaperDocumentSheet() {
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
                    _invoiceNumber,
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
                    _companyName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _companyAddress1,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _companyAddress2,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _companyCountry,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
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
                    _clientName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _clientCompany,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _clientStreet,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _clientCity,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
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
                        _issueDate,
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
                        _dueDate,
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
          ..._lineItems.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      item['description'] as String,
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
                      item['qty'] as String,
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
                      item['amount'] as String,
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
              width: 180,
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
                        _subtotal,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tax (0%)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _tax,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
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
                        _total,
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
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          // Notes & Terms
          const Text(
            'NOTES & TERMS',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _notes,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontStyle: FontStyle.italic,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // Verified Document Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBE9DC)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 14,
                    color: Color(0xFF0F9D7B),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'VERIFIED CLIENTTRACK DOCUMENT',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Color(0xFF0F9D7B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Inspirational Quote ────────────────────────────────────────────────────

  Widget _buildQuoteSection() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '"Design is a formal response to a strategic question."',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // ── More Actions Section ───────────────────────────────────────────────────

  Widget _buildMoreActionsSection() {
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
          subtitle: _clientEmail,
          onTap: _emailToClient,
        ),
        const SizedBox(height: 10),
        // Action 2: Print Document
        _buildActionCard(
          icon: Icons.print_outlined,
          title: 'Print Document',
          subtitle: 'Requires WiFi printer',
          onTap: _printDocument,
        ),
        const SizedBox(height: 10),
        // Action 3: Copy Payment Link
        _buildActionCard(
          icon: Icons.open_in_new_rounded,
          title: 'Copy Payment Link',
          subtitle: 'Stripe, PayPal, etc.',
          onTap: _copyPaymentLink,
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

  Widget _buildBottomActionButtons() {
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
                  onPressed: _isExporting ? null : _downloadPdf,
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
                  onPressed: _isExporting ? null : _sharePdf,
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share_outlined,
                                size: 19, color: Colors.white),
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
