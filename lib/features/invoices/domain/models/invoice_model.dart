import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'line_item_model.dart';

enum InvoiceStatus {
  draft,
  sent,
  viewed,
  overdue,
  paid;

  String get label {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.viewed:
        return 'Viewed';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.paid:
        return 'Paid';
    }
  }

  static InvoiceStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'draft':
        return InvoiceStatus.draft;
      case 'sent':
        return InvoiceStatus.sent;
      case 'viewed':
        return InvoiceStatus.viewed;
      case 'overdue':
        return InvoiceStatus.overdue;
      case 'paid':
        return InvoiceStatus.paid;
      default:
        return InvoiceStatus.draft;
    }
  }
}

@immutable
class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String? projectId;
  final String? projectTitle;
  final InvoiceStatus status;
  final List<LineItemModel> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double amountPaid;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? paidAt;
  final String notes;
  final String paymentTerms;
  final DateTime? lastReminderSentAt;
  final int reminderCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    this.clientEmail = '',
    this.clientPhone = '',
    this.projectId,
    this.projectTitle,
    this.status = InvoiceStatus.draft,
    this.items = const [],
    this.subtotal = 0.0,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.totalAmount = 0.0,
    this.amountPaid = 0.0,
    required this.issueDate,
    required this.dueDate,
    this.paidAt,
    this.notes = '',
    this.paymentTerms = 'Net 15',
    this.lastReminderSentAt,
    this.reminderCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOverdue {
    if (status == InvoiceStatus.paid) return false;
    if (status == InvoiceStatus.overdue) return true;
    return dueDate.isBefore(DateTime.now());
  }

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  double get balanceDue => (totalAmount - amountPaid).clamp(0.0, double.infinity);

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? clientId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? projectId,
    String? projectTitle,
    InvoiceStatus? status,
    List<LineItemModel>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? amountPaid,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? paidAt,
    String? notes,
    String? paymentTerms,
    DateTime? lastReminderSentAt,
    int? reminderCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      notes: notes ?? this.notes,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      lastReminderSentAt: lastReminderSentAt ?? this.lastReminderSentAt,
      reminderCount: reminderCount ?? this.reminderCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'status': status.name,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'issueDate': Timestamp.fromDate(issueDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'notes': notes,
      'paymentTerms': paymentTerms,
      'lastReminderSentAt': lastReminderSentAt != null ? Timestamp.fromDate(lastReminderSentAt!) : null,
      'reminderCount': reminderCount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems.map((e) => LineItemModel.fromMap(e as Map<String, dynamic>)).toList();

    return InvoiceModel(
      id: id,
      invoiceNumber: map['invoiceNumber'] as String? ?? '',
      clientId: map['clientId'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      clientEmail: map['clientEmail'] as String? ?? '',
      clientPhone: map['clientPhone'] as String? ?? '',
      projectId: map['projectId'] as String?,
      projectTitle: map['projectTitle'] as String?,
      status: InvoiceStatus.fromString(map['status'] as String?),
      items: itemsList,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      issueDate: parseDate(map['issueDate'], DateTime.now()),
      dueDate: parseDate(map['dueDate'], DateTime.now().add(const Duration(days: 14))),
      paidAt: parseNullableDate(map['paidAt']),
      notes: map['notes'] as String? ?? '',
      paymentTerms: map['paymentTerms'] as String? ?? 'Net 15',
      lastReminderSentAt: parseNullableDate(map['lastReminderSentAt']),
      reminderCount: (map['reminderCount'] as num?)?.toInt() ?? 0,
      createdAt: parseNullableDate(map['createdAt']),
      updatedAt: parseNullableDate(map['updatedAt']),
    );
  }

  factory InvoiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return InvoiceModel.fromMap(data, doc.id);
  }
}
