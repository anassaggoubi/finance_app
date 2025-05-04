import '../models/transaction.dart';
import '../models/category.dart';

class ChartService {
  double calculateTotalIncome(List<FinanceTransaction> transactions) {
    return transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double calculateTotalExpense(List<FinanceTransaction> transactions) {
    return transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double calculateBalance(List<FinanceTransaction> transactions) {
    final income = calculateTotalIncome(transactions);
    final expense = calculateTotalExpense(transactions);
    return income - expense;
  }

  Map<String, double> calculateExpensesByCategory(
      List<FinanceTransaction> transactions, List<Category> categories) {
    final Map<String, double> result = {};
    
    for (var category in categories) {
      result[category.id] = 0;
    }
    
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        result[transaction.categoryId] = 
            (result[transaction.categoryId] ?? 0) + transaction.amount;
      }
    }
    
    return result;
  }

  Map<String, double> calculateIncomeByCategory(
      List<FinanceTransaction> transactions, List<Category> categories) {
    final Map<String, double> result = {};
    
    for (var category in categories) {
      result[category.id] = 0;
    }
    
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        result[transaction.categoryId] = 
            (result[transaction.categoryId] ?? 0) + transaction.amount;
      }
    }
    
    return result;
  }

  Map<String, double> calculateMonthlyTransactions(
      List<FinanceTransaction> transactions, TransactionType type) {
    final Map<String, double> result = {};
    
    for (var transaction in transactions) {
      if (transaction.type == type) {
        final month = '${transaction.date.month}-${transaction.date.year}';
        result[month] = (result[month] ?? 0) + transaction.amount;
      }
    }
    
    return result;
  }
}