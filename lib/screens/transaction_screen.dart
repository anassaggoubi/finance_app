import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/firestore_service.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedFilter = 'Tous';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
                
                final now = DateTime.now();
                
                switch (value) {
                  case 'Aujourd\'hui':
                    _startDate = DateTime(now.year, now.month, now.day);
                    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                    break;
                  case 'Cette semaine':
                    _startDate = DateTime(now.year, now.month, now.day - now.weekday + 1);
                    _endDate = DateTime(now.year, now.month, now.day + (7 - now.weekday), 23, 59, 59);
                    break;
                  case 'Ce mois':
                    _startDate = DateTime(now.year, now.month, 1);
                    _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                    break;
                  case 'Cette année':
                    _startDate = DateTime(now.year, 1, 1);
                    _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
                    break;
                  case 'Tous':
                    _startDate = null;
                    _endDate = null;
                    break;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Aujourd\'hui',
                child: Text('Aujourd\'hui'),
              ),
              const PopupMenuItem(
                value: 'Cette semaine',
                child: Text('Cette semaine'),
              ),
              const PopupMenuItem(
                value: 'Ce mois',
                child: Text('Ce mois'),
              ),
              const PopupMenuItem(
                value: 'Cette année',
                child: Text('Cette année'),
              ),
              const PopupMenuItem(
                value: 'Tous',
                child: Text('Tous'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.filter_alt),
                const SizedBox(width: 8),
                Text('Filtre: $_selectedFilter'),
                if (_startDate != null && _endDate != null)
                  Text(
                    ' (${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)})',
                  ),
              ],
            ),
          ),
          
          StreamBuilder<List<Category>>(
            stream: _firestoreService.getCategories(),
            builder: (context, categoriesSnapshot) {
              if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final categories = categoriesSnapshot.data ?? [];
              
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        label: const Text('Toutes'),
                        selected: _selectedCategoryId == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = null;
                          });
                        },
                      ),
                    ),
                    ...categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: _selectedCategoryId == category.id,
                          backgroundColor: Color(category.colorValue).withOpacity(0.3),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = selected ? category.id : null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          Expanded(
            child: StreamBuilder<List<FinanceTransaction>>(
              stream: _firestoreService.getTransactions(),
              builder: (context, transactionsSnapshot) {
                if (transactionsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var transactions = transactionsSnapshot.data ?? [];
                
                if (_startDate != null && _endDate != null) {
                  transactions = transactions.where((transaction) =>
                    transaction.date.isAfter(_startDate!) &&
                    transaction.date.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
                }
                
                if (_selectedCategoryId != null) {
                  transactions = transactions.where((transaction) =>
                    transaction.categoryId == _selectedCategoryId).toList();
                }
                
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('Aucune transaction pour cette période'),
                  );
                }
                
                return StreamBuilder<List<Category>>(
                  stream: _firestoreService.getCategories(),
                  builder: (context, categoriesSnapshot) {
                    if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final categories = categoriesSnapshot.data ?? [];
                    
                    return ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        
                        final category = categories.firstWhere(
                          (cat) => cat.id == transaction.categoryId,
                          orElse: () => Category(
                            id: 'unknown',
                            name: 'Inconnu',
                            icon: '?',
                            colorValue: Colors.grey.value,
                          ),
                        );
                        
                        return TransactionCard(
                          transaction: transaction,
                          category: category,
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmation'),
                                content: const Text('Voulez-vous vraiment supprimer cette transaction ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _firestoreService.deleteTransaction(transaction.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTransactionScreen(
                                  transaction: transaction,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
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