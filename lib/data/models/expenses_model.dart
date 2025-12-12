// ================================================================================
// MODELS - expenses_model.dart
// ================================================================================
import 'package:flutter/material.dart';

class Expense {
  final String id;
  final String category;
  final String subCategory;
  final String title;
  final String description;
  final double amount;
  final String? staffName;
  final DateTime expenseDate;
  final String responsiblePerson;
  final String? notes;
  final String? receiptNumber;
  final String recordedBy;

  Expense({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.title,
    required this.description,
    required this.amount,
    this.staffName,
    required this.expenseDate,
    required this.responsiblePerson,
    this.notes,
    this.receiptNumber,
    required this.recordedBy,
  });

  // JSON conversion
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      staffName: json['staffName'] as String?,
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      responsiblePerson: json['responsiblePerson'] as String,
      notes: json['notes'] as String?,
      receiptNumber: json['receiptNumber'] as String?,
      recordedBy: json['recordedBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subCategory': subCategory,
      'title': title,
      'description': description,
      'amount': amount,
      'staffName': staffName,
      'expenseDate': expenseDate.toIso8601String(),
      'responsiblePerson': responsiblePerson,
      'notes': notes,
      'receiptNumber': receiptNumber,
      'recordedBy': recordedBy,
    };
  }
}

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> subCategories;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.subCategories,
  });
}
