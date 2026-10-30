import 'dart:convert' show utf8;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/clients/data/client_repository.dart';
import '../../features/clients/domain/models/client_model.dart';
import '../../features/invoices/data/invoice_repository.dart';
import '../../features/invoices/domain/models/invoice_model.dart';
import '../../features/projects/data/project_repository.dart';
import '../../features/projects/domain/models/project_model.dart';

// ---------------------------------------------------------------------------
// FT-037: Accounting Data CSV Export Service
// ---------------------------------------------------------------------------

final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return CsvExportService(ref);
});

class CsvExportService {
  final Ref _ref;

  CsvExportService(this._ref);

  String _sanitizeCsv(String? input) {
    if (input == null || input.isEmpty) return '""';
    final escaped = input.replaceAll('"', '""');
    return '"$escaped"';
  }

  /// Exports all invoices to a formatted CSV string.
  String generateInvoicesCsv(List<InvoiceModel> invoices) {
    final dateFmt = DateFormat('yyyy-MM-dd');
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'Invoice Number,Client Name,Client Email,Project,Status,Issue Date,Due Date,Subtotal,Tax,Total,Amount Paid,Balance Due,Reminder Count',
    );

    for (final inv in invoices) {
      buffer.writeln([
        _sanitizeCsv(inv.invoiceNumber),
        _sanitizeCsv(inv.clientName),
        _sanitizeCsv(inv.clientEmail),
        _sanitizeCsv(inv.projectTitle ?? 'N/A'),
        _sanitizeCsv(inv.status.name.toUpperCase()),
        _sanitizeCsv(dateFmt.format(inv.issueDate)),
        _sanitizeCsv(dateFmt.format(inv.dueDate)),
        inv.subtotal.toStringAsFixed(2),
        inv.taxAmount.toStringAsFixed(2),
        inv.totalAmount.toStringAsFixed(2),
        inv.amountPaid.toStringAsFixed(2),
        inv.balanceDue.toStringAsFixed(2),
        inv.reminderCount.toString(),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Exports all clients to a formatted CSV string.
  String generateClientsCsv(List<ClientModel> clients) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'Client Name,Company,Role,Email,Phone,Website,Status,Address,Notes',
    );

    for (final c in clients) {
      buffer.writeln([
        _sanitizeCsv(c.name),
        _sanitizeCsv(c.company),
        _sanitizeCsv(c.role),
        _sanitizeCsv(c.email),
        _sanitizeCsv(c.phone),
        _sanitizeCsv(c.website),
        _sanitizeCsv(c.status.name.toUpperCase()),
        _sanitizeCsv(c.address),
        _sanitizeCsv(c.notes),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Exports all projects to a formatted CSV string.
  String generateProjectsCsv(List<ProjectModel> projects) {
    final dateFmt = DateFormat('yyyy-MM-dd');
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'Project Title,Client Name,Status,Rate Type,Budget,Hourly Rate,Deadline,Notes',
    );

    for (final p in projects) {
      buffer.writeln([
        _sanitizeCsv(p.title),
        _sanitizeCsv(p.clientName),
        _sanitizeCsv(p.status.name.toUpperCase()),
        _sanitizeCsv(p.rateType.name.toUpperCase()),
        p.budget.toStringAsFixed(2),
        p.hourlyRate.toStringAsFixed(2),
        _sanitizeCsv(p.deadline != null ? dateFmt.format(p.deadline!) : 'None'),
        _sanitizeCsv(p.description),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Generates consolidated accounting CSV files and opens the native Share Sheet.
  Future<void> exportAndShareAll() async {
    final invoices = _ref.read(invoicesStreamProvider).asData?.value ?? kSeedInvoices;
    final clients = _ref.read(clientsStreamProvider).asData?.value ?? kSeedClients;
    final projects = _ref.read(projectsStreamProvider).asData?.value ?? kSeedProjects;

    final invoicesCsv = generateInvoicesCsv(invoices);
    final clientsCsv = generateClientsCsv(clients);
    final projectsCsv = generateProjectsCsv(projects);

    final timestamp = DateFormat('yyyyMMdd').format(DateTime.now());

    final invoiceFile = XFile.fromData(
      utf8.encode(invoicesCsv),
      mimeType: 'text/csv',
      name: 'clienttrack_invoices_$timestamp.csv',
    );

    final clientFile = XFile.fromData(
      utf8.encode(clientsCsv),
      mimeType: 'text/csv',
      name: 'clienttrack_clients_$timestamp.csv',
    );

    final projectFile = XFile.fromData(
      utf8.encode(projectsCsv),
      mimeType: 'text/csv',
      name: 'clienttrack_projects_$timestamp.csv',
    );

    await SharePlus.instance.shareXFiles(
      [invoiceFile, clientFile, projectFile],
      text: 'ClientTrack Accounting Export ($timestamp)',
      subject: 'ClientTrack Accounting Export ($timestamp)',
    );
  }
}

