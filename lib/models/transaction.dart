import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  income,
  expense,
}

class FinanceTransaction {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionType type;
  final String categoryId;
  
  FinanceTransaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'type': type.toString(),
      'categoryId': categoryId,
    };
  }

  factory FinanceTransaction.fromMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      date: (map['date'] as Timestamp).toDate(),
      type: map['type'] == 'TransactionType.income' 
          ? TransactionType.income 
          : TransactionType.expense,
      categoryId: map['categoryId'],
    );
  }
}