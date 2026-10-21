import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum ClientStatus {
  active,
  pending,
  inactive;

  String get label {
    switch (this) {
      case ClientStatus.active:
        return 'Active';
      case ClientStatus.pending:
        return 'Pending';
      case ClientStatus.inactive:
        return 'Inactive';
    }
  }

  static ClientStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return ClientStatus.active;
      case 'pending':
        return ClientStatus.pending;
      case 'inactive':
        return ClientStatus.inactive;
      default:
        return ClientStatus.active;
    }
  }
}

@immutable
class ClientModel {
  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final String role;
  final ClientStatus status;
  final String website;
  final String address;
  final String notes;
  final int projectCount;
  final bool hasStar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ClientModel({
    required this.id,
    required this.name,
    this.company = '',
    this.email = '',
    this.phone = '',
    this.role = '',
    this.status = ClientStatus.active,
    this.website = '',
    this.address = '',
    this.notes = '',
    this.projectCount = 0,
    this.hasStar = false,
    this.createdAt,
    this.updatedAt,
  });

  String get timeAgo {
    final date = updatedAt ?? createdAt;
    if (date == null) return 'Recently';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes.clamp(1, 60)}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else {
      return '${(diff.inDays / 30).floor()}mo ago';
    }
  }

  Color get presenceDot {
    switch (status) {
      case ClientStatus.active:
        return const Color(0xFF22C55E);
      case ClientStatus.pending:
        return const Color(0xFFE0A030);
      case ClientStatus.inactive:
        return const Color(0xFFD64545);
    }
  }

  String get initials {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  ClientModel copyWith({
    String? id,
    String? name,
    String? company,
    String? email,
    String? phone,
    String? role,
    ClientStatus? status,
    String? website,
    String? address,
    String? notes,
    int? projectCount,
    bool? hasStar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      website: website ?? this.website,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      projectCount: projectCount ?? this.projectCount,
      hasStar: hasStar ?? this.hasStar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status.name,
      'website': website,
      'address': address,
      'notes': notes,
      'projectCount': projectCount,
      'hasStar': hasStar,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ClientModel(
      id: id,
      name: map['name'] as String? ?? '',
      company: map['company'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? '',
      status: ClientStatus.fromString(map['status'] as String?),
      website: map['website'] as String? ?? '',
      address: map['address'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      projectCount: (map['projectCount'] as num?)?.toInt() ?? 0,
      hasStar: map['hasStar'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  factory ClientModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ClientModel.fromMap(data, doc.id);
  }
}
