import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/firestore_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final FinanceTransaction? transaction;

  const AddTransactionScreen({
    Key? key,
    this.transaction,
  }) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  late TransactionType _transactionType;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.description;
      _amountController.text = widget.transaction!.amount.toString();
      _transactionType = widget.transaction!.type;
      _selectedCategoryId = widget.transaction!.categoryId;
      _selectedDate = widget.transaction!.date;
    } else {
      _transactionType = TransactionType.expense;
    }
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _saveTransaction() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final description = _descriptionController.text;
      final amount = double.parse(_amountController.text);
      
      if (widget.transaction == null) {
        _firestoreService.addTransaction(
          amount,
          description,
          _selectedDate,
          _transactionType,
          _selectedCategoryId!,
        );
      } else {
        final updatedTransaction = FinanceTransaction(
          id: widget.transaction!.id,
          amount: amount,
          description: description,
          date: _selectedDate,
          type: _transactionType,
          categoryId: _selectedCategoryId!,
        );
        _firestoreService.updateTransaction(updatedTransaction);
      }
      
      Navigator.pop(context);
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la transaction' : 'Nouvelle transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Type de transaction',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<TransactionType>(
                        title: const Text('Dépense'),
                        value: TransactionType.expense,
                        groupValue: _transactionType,
                        onChanged: (TransactionType? value) {
                          setState(() {
                            _transactionType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<TransactionType>(
                        title: const Text('Recette'),
                        value: TransactionType.income,
                        groupValue: _transactionType,
                        onChanged: (TransactionType? value) {
                          setState(() {
                            _transactionType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Montant',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.euro),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un montant';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un montant valide';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      'Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Modifier'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Catégorie',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                StreamBuilder<List<Category>>(
                  stream: _firestoreService.getCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final categories = snapshot.data ?? [];
                    
                    if (categories.isEmpty) {
                      return const Text('Aucune catégorie disponible');
                    }
                    
                    return Wrap(
                      spacing: 8.0,
                      children: categories.map((category) {
                        final isSelected = _selectedCategoryId == category.id;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          },
                          child: Chip(
                            label: Text(category.name),
                            avatar: CircleAvatar(
                              backgroundColor: Color(category.colorValue),
                              child: Text(
                                category.icon,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            backgroundColor: isSelected 
                                ? Color(category.colorValue).withOpacity(0.3) 
                                : null,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        isEditing ? 'Mettre à jour' : 'Ajouter',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}