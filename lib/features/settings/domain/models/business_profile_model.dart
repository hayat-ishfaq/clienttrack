import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class BusinessProfileModel {
  final String uid;
  final String fullName;
  final String businessName;
  final String email;
  final String phone;
  final String address;
  final String website;
  final String? logoUrl;
  final String currencyCode;
  final String currencySymbol;
  final String paymentTerms;
  final String taxNumber;
  final String bankDetails;
  final DateTime? updatedAt;

  const BusinessProfileModel({
    required this.uid,
    this.fullName = '',
    this.businessName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.website = '',
    this.logoUrl,
    this.currencyCode = 'USD',
    this.currencySymbol = '\$',
    this.paymentTerms = 'Net 15',
    this.taxNumber = '',
    this.bankDetails = '',
    this.updatedAt,
  });

  BusinessProfileModel copyWith({
    String? uid,
    String? fullName,
    String? businessName,
    String? email,
    String? phone,
    String? address,
    String? website,
    String? logoUrl,
    String? currencyCode,
    String? currencySymbol,
    String? paymentTerms,
    String? taxNumber,
    String? bankDetails,
    DateTime? updatedAt,
  }) {
    return BusinessProfileModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      businessName: businessName ?? this.businessName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      taxNumber: taxNumber ?? this.taxNumber,
      bankDetails: bankDetails ?? this.bankDetails,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'businessName': businessName,
      'email': email,
      'phone': phone,
      'address': address,
      'website': website,
      'logoUrl': logoUrl,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'paymentTerms': paymentTerms,
      'taxNumber': taxNumber,
      'bankDetails': bankDetails,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory BusinessProfileModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return BusinessProfileModel(
      uid: uid,
      fullName: map['fullName'] as String? ?? '',
      businessName: map['businessName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      website: map['website'] as String? ?? '',
      logoUrl: map['logoUrl'] as String?,
      currencyCode: map['currencyCode'] as String? ?? 'USD',
      currencySymbol: map['currencySymbol'] as String? ?? '\$',
      paymentTerms: map['paymentTerms'] as String? ?? 'Net 15',
      taxNumber: map['taxNumber'] as String? ?? '',
      bankDetails: map['bankDetails'] as String? ?? '',
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  factory BusinessProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return BusinessProfileModel.fromMap(data, doc.id);
  }
}
