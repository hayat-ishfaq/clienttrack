import 'package:flutter/foundation.dart';

@immutable
class LineItemModel {
  final String id;
  final String description;
  final String category;
  final double amount;
  final int quantity;
  final double rate;

  const LineItemModel({
    required this.id,
    required this.description,
    this.category = 'General',
    required this.amount,
    this.quantity = 1,
    double? rate,
  }) : rate = rate ?? amount;

  LineItemModel copyWith({
    String? id,
    String? description,
    String? category,
    double? amount,
    int? quantity,
    double? rate,
  }) {
    return LineItemModel(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'category': category,
      'amount': amount,
      'quantity': quantity,
      'rate': rate,
    };
  }

  factory LineItemModel.fromMap(Map<String, dynamic> map) {
    final qty = (map['quantity'] as num?)?.toInt() ?? 1;
    final amt = (map['amount'] as num?)?.toDouble() ?? 0.0;
    final r = (map['rate'] as num?)?.toDouble() ?? amt;

    return LineItemModel(
      id: map['id'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      amount: amt,
      quantity: qty,
      rate: r,
    );
  }
}
