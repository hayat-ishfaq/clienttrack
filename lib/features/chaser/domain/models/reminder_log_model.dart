import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class ReminderLogModel {
  final String id;
  final String invoiceId;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final String channel; // 'whatsapp', 'email', 'sms', 'other'
  final String tone; // 'friendly', 'professional', 'finalNotice'
  final String messageContent;
  final String recipient;
  final DateTime sentAt;

  const ReminderLogModel({
    required this.id,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.channel,
    required this.tone,
    required this.messageContent,
    required this.recipient,
    required this.sentAt,
  });

  ReminderLogModel copyWith({
    String? id,
    String? invoiceId,
    String? invoiceNumber,
    String? clientId,
    String? clientName,
    String? channel,
    String? tone,
    String? messageContent,
    String? recipient,
    DateTime? sentAt,
  }) {
    return ReminderLogModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      channel: channel ?? this.channel,
      tone: tone ?? this.tone,
      messageContent: messageContent ?? this.messageContent,
      recipient: recipient ?? this.recipient,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceId': invoiceId,
      'invoiceNumber': invoiceNumber,
      'clientId': clientId,
      'clientName': clientName,
      'channel': channel,
      'tone': tone,
      'messageContent': messageContent,
      'recipient': recipient,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }

  factory ReminderLogModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return ReminderLogModel(
      id: id,
      invoiceId: map['invoiceId'] as String? ?? '',
      invoiceNumber: map['invoiceNumber'] as String? ?? '',
      clientId: map['clientId'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      channel: map['channel'] as String? ?? 'other',
      tone: map['tone'] as String? ?? 'friendly',
      messageContent: map['messageContent'] as String? ?? '',
      recipient: map['recipient'] as String? ?? '',
      sentAt: parseDate(map['sentAt']),
    );
  }

  factory ReminderLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ReminderLogModel.fromMap(data, doc.id);
  }
}
