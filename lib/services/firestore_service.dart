import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class FirestoreService {
  final CollectionReference _transactionsCollection = 
      FirebaseFirestore.instance.collection('transactions');
  
  final CollectionReference _categoriesCollection = 
      FirebaseFirestore.instance.collection('categories');
  
  final _uuid = Uuid();

  Stream<List<Category>> getCategories() {
    return _categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addCategory(String name, String icon, Color color) async {
    final id = _uuid.v4();
    await _categoriesCollection.doc(id).set({
      'id': id,
      'name': name,
      'icon': icon,
      'colorValue': color.value,
    });
  }

  Future<void> updateCategory(Category category) async {
    await _categoriesCollection.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoriesCollection.doc(categoryId).delete();
  }

  Future<Category?> getCategoryById(String categoryId) async {
    DocumentSnapshot doc = await _categoriesCollection.doc(categoryId).get();
    if (doc.exists) {
      return Category.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<List<FinanceTransaction>> getTransactions() {
    return _transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FinanceTransaction.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addTransaction(
    double amount,
    String description,
    DateTime date,
    TransactionType type,
    String categoryId,
  ) async {
    final id = _uuid.v4();
    await _transactionsCollection.doc(id).set({
      'id': id,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'type': type.toString(),
      'categoryId': categoryId,
    });
  }

  Future<void> updateTransaction(FinanceTransaction transaction) async {
    await _transactionsCollection
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsCollection.doc(transactionId).delete();
  }

  Stream<List<FinanceTransaction>> getTransactionsByCategory(String categoryId) {
    return _transactionsCollection
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FinanceTransaction.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<FinanceTransaction>> getTransactionsByType(TransactionType type) {
    return _transactionsCollection
        .where('type', isEqualTo: type.toString())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FinanceTransaction.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<FinanceTransaction>> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return _transactionsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FinanceTransaction.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}