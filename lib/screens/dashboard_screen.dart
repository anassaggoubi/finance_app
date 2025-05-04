import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/chart_service.dart';
import '../services/firestore_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/chart_widget.dart';
import 'add_transaction_screen.dart';
import 'transaction_screen.dart';
import 'category_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ChartService _chartService = ChartService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<FinanceTransaction>>(
        stream: _firestoreService.getTransactions(),
        builder: (context, transactionsSnapshot) {
          if (transactionsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = transactionsSnapshot.data ?? [];

          return StreamBuilder<List<Category>>(
            stream: _firestoreService.getCategories(),
            builder: (context, categoriesSnapshot) {
              if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = categoriesSnapshot.data ?? [];
              
              final totalIncome = _chartService.calculateTotalIncome(transactions);
              final totalExpense = _chartService.calculateTotalExpense(transactions);
              final balance = _chartService.calculateBalance(transactions);
              
              final expensesByCategory = _chartService.calculateExpensesByCategory(
                  transactions, categories);
              final incomeByCategory = _chartService.calculateIncomeByCategory(
                  transactions, categories);
              
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: 'Recettes',
                              amount: totalIncome,
                              icon: Icons.arrow_upward,
                              color: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: SummaryCard(
                              title: 'Dépenses',
                              amount: totalExpense,
                              icon: Icons.arrow_downward,
                              color: Colors.red,
                            ),
                          ),
                          Expanded(
                            child: SummaryCard(
                              title: 'Solde',
                              amount: balance,
                              icon: Icons.account_balance_wallet,
                              color: balance >= 0 ? Colors.blue : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      PieChartWidget(
                        data: expensesByCategory,
                        categories: categories,
                        title: 'Répartition des dépenses par catégorie',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      PieChartWidget(
                        data: incomeByCategory,
                        categories: categories,
                        title: 'Répartition des recettes par catégorie',
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TransactionScreen(),
                              ),
                            );
                          },
                          child: const Text('Voir toutes les transactions'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}