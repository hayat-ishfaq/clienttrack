import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../clients/domain/models/client_model.dart';
import '../../settings/domain/models/business_profile_model.dart';
import '../domain/models/invoice_model.dart';

/// Service responsible for compiling invoice entities into professional,
/// high-resolution PDF byte streams using the `pdf` and `printing` packages.
class PdfInvoiceService {
  /// Generates raw PDF bytes for the provided [invoice].
  Future<Uint8List> generateInvoicePdfBytes({
    required InvoiceModel invoice,
    BusinessProfileModel? profile,
    ClientModel? client,
    bool isPro = false,
  }) async {
    final pdf = pw.Document(
      title: 'Invoice #${invoice.invoiceNumber}',
      author: profile?.businessName.isNotEmpty == true
          ? profile!.businessName
          : (profile?.fullName.isNotEmpty == true ? profile!.fullName : 'ClientTrack'),
      creator: 'ClientTrack Freelancer OS',
    );

    final currency = profile?.currencySymbol.isNotEmpty == true ? profile!.currencySymbol : '\$';
    final issueDateStr = DateFormat('MMM dd, yyyy').format(invoice.issueDate);
    final dueDateStr = DateFormat('MMM dd, yyyy').format(invoice.dueDate);

    // Color definitions
    const primaryGreen = PdfColor.fromInt(0xFF2E5D31);
    const darkText = PdfColor.fromInt(0xFF1E293B);
    const secondaryText = PdfColor.fromInt(0xFF64748B);
    const lightBorder = PdfColor.fromInt(0xFFE2E8F0);
    const surfaceBg = PdfColor.fromInt(0xFFF8FAFC);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header Row: Business & Document Title ──
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
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryGreen,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: surfaceBg,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          border: pw.Border.all(color: lightBorder),
                        ),
                        child: pw.Text(
                          '#${invoice.invoiceNumber}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        profile?.businessName.isNotEmpty == true
                            ? profile!.businessName
                            : (profile?.fullName.isNotEmpty == true ? profile!.fullName : 'Freelance Studio'),
                        style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      if (profile?.address.isNotEmpty == true) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          profile!.address,
                          style: const pw.TextStyle(fontSize: 9.5, color: secondaryText),
                        ),
                      ],
                      if (profile?.email.isNotEmpty == true) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          profile!.email,
                          style: const pw.TextStyle(fontSize: 9.5, color: secondaryText),
                        ),
                      ],
                      if (profile?.phone.isNotEmpty == true) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          profile!.phone,
                          style: const pw.TextStyle(fontSize: 9.5, color: secondaryText),
                        ),
                      ],
                      if (profile?.taxNumber.isNotEmpty == true) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Tax ID / VAT: ${profile!.taxNumber}',
                          style: const pw.TextStyle(fontSize: 9, color: secondaryText),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 26),

              // ── Bill To & Details Card ──
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: surfaceBg,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: lightBorder),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Client Info
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILLED TO',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryText,
                            letterSpacing: 0.8,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          invoice.clientName,
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        if (client?.company.isNotEmpty == true) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            client!.company,
                            style: const pw.TextStyle(fontSize: 10, color: darkText),
                          ),
                        ],
                        if (invoice.clientEmail.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            invoice.clientEmail,
                            style: const pw.TextStyle(fontSize: 9.5, color: secondaryText),
                          ),
                        ],
                        if (invoice.clientPhone.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            invoice.clientPhone,
                            style: const pw.TextStyle(fontSize: 9.5, color: secondaryText),
                          ),
                        ],
                      ],
                    ),
                    // Invoice Meta Details
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildMetaItem('DATE ISSUED', issueDateStr),
                        pw.SizedBox(height: 6),
                        _buildMetaItem('PAYMENT DUE', dueDateStr),
                        if (invoice.projectTitle != null && invoice.projectTitle!.isNotEmpty) ...[
                          pw.SizedBox(height: 6),
                          _buildMetaItem('PROJECT', invoice.projectTitle!),
                        ],
                        pw.SizedBox(height: 6),
                        pw.Row(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text(
                              'STATUS: ',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: secondaryText,
                              ),
                            ),
                            pw.Text(
                              invoice.status.label.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                fontWeight: pw.FontWeight.bold,
                                color: invoice.status == InvoiceStatus.paid
                                    ? primaryGreen
                                    : (invoice.isOverdue
                                        ? const PdfColor.fromInt(0xFFDC2626)
                                        : darkText),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 22),

              // ── Line Items Table ──
              pw.Text(
                'ITEMS & SERVICES',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: secondaryText,
                  letterSpacing: 0.8,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(color: lightBorder, width: 1),
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(5),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2.5),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: lightBorder, width: 1.5),
                      ),
                    ),
                    children: [
                      _buildHeaderCell('Description', pw.TextAlign.left),
                      _buildHeaderCell('Qty / Hrs', pw.TextAlign.center),
                      _buildHeaderCell('Unit Rate', pw.TextAlign.right),
                      _buildHeaderCell('Amount', pw.TextAlign.right),
                    ],
                  ),
                  // Items
                  ...invoice.items.map((item) {
                    return pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(color: lightBorder, width: 0.5),
                        ),
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 9),
                          child: pw.Text(
                            item.description.isNotEmpty ? item.description : 'Service item',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 9),
                          child: pw.Text(
                            item.quantity.toStringAsFixed(
                              item.quantity.truncateToDouble() == item.quantity ? 0 : 2,
                            ),
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 10, color: darkText),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 9),
                          child: pw.Text(
                            '$currency${item.rate.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 10, color: darkText),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 9),
                          child: pw.Text(
                            '$currency${item.amount.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 16),

              // ── Summary & Totals ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    child: pw.Column(
                      children: [
                        _buildTotalRow('Subtotal', '$currency${invoice.subtotal.toStringAsFixed(2)}'),
                        pw.SizedBox(height: 4),
                        if (invoice.taxRate > 0 || invoice.taxAmount > 0) ...[
                          _buildTotalRow(
                            'Tax (${invoice.taxRate.toStringAsFixed(0)}%)',
                            '$currency${invoice.taxAmount.toStringAsFixed(2)}',
                          ),
                          pw.SizedBox(height: 4),
                        ],
                        pw.Divider(color: lightBorder, height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Amount',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                            pw.Text(
                              '$currency${invoice.totalAmount.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        if (invoice.amountPaid > 0) ...[
                          pw.SizedBox(height: 4),
                          _buildTotalRow('Amount Paid', '-$currency${invoice.amountPaid.toStringAsFixed(2)}'),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Balance Due',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: const PdfColor.fromInt(0xFFDC2626),
                                ),
                              ),
                              pw.Text(
                                '$currency${invoice.balanceDue.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: const PdfColor.fromInt(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // ── Payment Details & Notes ──
              if (profile?.bankDetails.isNotEmpty == true || invoice.notes.isNotEmpty) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: surfaceBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    border: pw.Border.all(color: lightBorder),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (profile?.bankDetails.isNotEmpty == true) ...[
                        pw.Text(
                          'PAYMENT INSTRUCTIONS',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryText,
                            letterSpacing: 0.6,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          profile!.bankDetails,
                          style: const pw.TextStyle(fontSize: 9, color: darkText),
                        ),
                      ],
                      if (invoice.notes.isNotEmpty) ...[
                        if (profile?.bankDetails.isNotEmpty == true) pw.SizedBox(height: 8),
                        pw.Text(
                          'NOTES & TERMS',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryText,
                            letterSpacing: 0.6,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          invoice.notes,
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: secondaryText,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 14),
              ],

              // ── Document Verification Footer ──
              pw.Center(
                child: pw.Text(
                  isPro
                      ? 'OFFICIAL INVOICE • ISSUED VIA CLIENTTRACK'
                      : 'VERIFIED FREELANCER DOCUMENT • GENERATED VIA CLIENTTRACK',
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: 0.8,
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

  /// Triggers the native platform share sheet for the generated invoice PDF.
  Future<void> shareInvoicePdf({
    required InvoiceModel invoice,
    BusinessProfileModel? profile,
    ClientModel? client,
    bool isPro = false,
  }) async {
    final bytes = await generateInvoicePdfBytes(
      invoice: invoice,
      profile: profile,
      client: client,
      isPro: isPro,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Invoice_${invoice.invoiceNumber}.pdf',
    );
  }

  /// Opens the native platform printing or PDF layout dialog.
  Future<void> printInvoicePdf({
    required InvoiceModel invoice,
    BusinessProfileModel? profile,
    ClientModel? client,
    bool isPro = false,
  }) async {
    await Printing.layoutPdf(
      name: 'Invoice_${invoice.invoiceNumber}',
      onLayout: (PdfPageFormat format) async {
        return await generateInvoicePdfBytes(
          invoice: invoice,
          profile: profile,
          client: client,
          isPro: isPro,
        );
      },
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  static pw.Widget _buildMetaItem(String label, String value) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: const PdfColor.fromInt(0xFF64748B),
          ),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 9.5,
            color: PdfColor.fromInt(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(String text, pw.TextAlign align) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Text(
        text.toUpperCase(),
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 9.5,
            color: PdfColor.fromInt(0xFF64748B),
          ),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColor.fromInt(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Riverpod Provider
// ---------------------------------------------------------------------------

final pdfInvoiceServiceProvider = Provider<PdfInvoiceService>((ref) {
  return PdfInvoiceService();
});
